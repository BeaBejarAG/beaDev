public with sharing class cspReleaseNoteHandler {
    @AuraEnabled(cacheable=true)
    public static List<Map<String, Object>> getReleaseNotes(String product, Integer amount, Integer offset) {
        List<Map<String, Object>> releaseNotes = new List<Map<String, Object>>();
        String networkName = cspReleaseNoteHandler.getNetwork();
        String contactRegion = getContactRegion();
        String query = 'SELECT Id, Product__c, Version__c, Knowledge__c, Knowledge__r.Title, Knowledge__r.UrlName, Release_Date__c, Type__c, Postponed__c, Event__r.Recording_Link__c, Release_Details__c FROM Release_Note__c Where id != null ';

        query += String.isNotBlank(product) ? ' AND Product__c =:product' : '';

        query += String.isNotEmpty(contactRegion) ? ' AND (Region__c = \'\' OR Region__c includes (\'' + contactRegion + '\'))' : '';

        query += String.format(' ORDER BY Release_Date__c DESC LIMIT {0} OFFSET {1}', new List<Object>{++amount, offset});

        for (Release_Note__c n: Database.query(query)) {
            releaseNotes.add(new Map<String, Object>{
                'id' => n.Id,
                'version' => n.Version__c,
                'product' => n.Product__c,
                'releaseDate' => n.Release_Date__c,
                'releaseNotes' => n.Knowledge__r.Title,
                'recordingLink' => n.Event__r.Recording_Link__c,
                'upgradeType' => n.Type__c,
                'postponed' => n.Postponed__c,
                'articleUrl' => '/' + networkName + '/s/article/' + n.Knowledge__r.UrlName,
                'component' => n.Release_Details__c
            });
        }
        return releaseNotes;
    }

    private static String getNetwork() {
        try {
            return [ SELECT UrlPathPrefix FROM Network WHERE Id = :Network.getNetworkId() ].UrlPathPrefix;
        } catch(QueryException e) {
            System.debug('Exception retrieving network id : ' + e.getMessage());
            return 'support';
        }
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