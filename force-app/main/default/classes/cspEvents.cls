public with sharing class cspEvents {
    @AuraEnabled(cacheable=true)
    public static List<Map<String, Object>> getEvents(Map<String, Object> product, String category, Integer offset, Integer amount) {
        String categoryFilter = 'Start__c != null';
        String productName = null;
        String plan = null;
        Boolean internalPlan = false;
        String ContactRegion = getContactRegion();

        if(product != null && product.get('id') != null) {
            plan = checkPlan((String)product.get('successPlanName'));
            productName = (String)product.get('name');
            // Internal users see all events
            internalPlan = plan == 'Internal';
        }

        if(category == 'upcoming_webinars') {
            categoryFilter = 'RecordType.Name = \'Online Event\' AND Start__c >= TODAY';
        } else if(category == 'previous_events') {
            categoryFilter = 'Start__c < TODAY AND (RecordType.Name = \'Online Event\' OR RecordType.Name = \'Access World\')';
        } else if(category == 'user_group_events') {
            categoryFilter = 'RecordType.Name = \'Onsite Events\'';
        } else if(category == 'access_world') {
            categoryFilter = 'RecordType.Name = \'Access World\'';
        }

        String query = 'SELECT ' +
            'Name, Title__c, Description__c, Start__c, Recording_Link__c, ' +
            'Duration__c, Registration_Link__c, Success_Plan__c ' +
            'FROM Event__c ' +
            'WHERE ' + categoryFilter + ' ' +
            (product == null ? '' : 'AND Product__c includes (:productName) ') +
            (String.isNotEmpty(contactRegion) ? 'AND (Region__c = \'\' OR Region__c includes (\'' + contactRegion + '\')) ' : '') +
            (category == 'upcoming_webinars' ? 'ORDER BY Start__c ASC ' : 'ORDER BY Start__c DESC ') +
            'LIMIT ' + ++amount + ' ' +
            'OFFSET :offset';

        List<Map<String, Object>> events = new List<Map<String, Object>>();
        for(Event__c event: Database.query(query)) {
            Boolean premierPlan = false;
            Boolean inactive = true;
            if(event.Success_Plan__c != null) {
                // It's a premier event if only the premier plan is selected
                premierPlan = event.Success_Plan__c == 'Premier';
                // Event is noly visible if the customer's plan is available
                inactive = plan == null || !event.Success_Plan__c.contains(plan);
            }
            events.add(new Map<String, Object> {
                'id' => event.Id,
                'name' => event.Name,
                'start' => event.Start__c,
                'title' => event.Title__c,
                'description' => event.Description__c,
                'duration' => event.Duration__c,
                'registrationLink' => event.Registration_Link__c,
                'recordingLink' => event.Recording_Link__c,
                'premier' => premierPlan,
                'future' => event.Start__c > Datetime.now(),
                'inactive' => internalPlan ? false : inactive
            });
        }

        return events.size() > 0 ? events : null;
    }

    @AuraEnabled(cacheable=true)
    public static Map<String, Object> getEvent(String eventId) {
        Event__c event = [
            SELECT
                Name, Title__c, Description__c, Start__c, Recording_Link__c,
                Duration__c, Registration_Link__c, Success_Plan__c
            FROM Event__c
            WHERE Name =: eventId
        ];

        Boolean premierPlan = false;
        if(event.Success_Plan__c != null && event.Success_Plan__c.contains('Premier')) {
            premierPlan = true;
        }

        return new Map<String, Object> {
            'id' => event.Id,
            'name' => event.Name,
            'start' => event.Start__c,
            'title' => event.Title__c,
            'description' => event.Description__c,
            'duration' => event.Duration__c,
            'registrationLink' => event.Registration_Link__c,
            'recordingLink' => event.Recording_Link__c,
            'premier' => premierPlan,
            'future' => event.Start__c > Datetime.now()
        };
    }

    private static String checkPlan(String planName) {
        if (String.isEmpty(planName)) {
            return null;
        }
        if (planName.containsIgnoreCase('Premier')) {
            return 'Premier';
        }
        if (planName.containsIgnoreCase('Standard')) {
            return 'Standard';
        }
        if (planName.containsIgnoreCase('Essential')) {
            return 'Essential';
        }
        return planName;
    }

    @TestVisible private static String getContactRegion() {
        String userId = Userinfo.getUserid();
        User currentUser = Database.query('SELECT ContactId, Contact.Region__c FROM User WHERE Id =: userId');
        if (currentUser != null && String.isNotBlank(currentUser.ContactId) && String.isNotEmpty(currentUser.Contact.Region__c)) {
            String region = currentUser.Contact.Region__c;
            return currentUser.Contact.Region__c;
        }
        return '';
    }
}