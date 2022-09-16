public without sharing class cspSuccessPlanHandler {
    @AuraEnabled(cacheable=true)
    public static List<Map<String, Object>> getContactsForAccount(String product, String level, String searchTerm, Integer amount, Integer offset, String selectedAccId) {
        // We want to get all of the users that are associated with the currently selected product
        // Every contact on the account where there is an active community user (can use Can_Log_Into_Community__c to identify)
        // Pull the user's details from Community_User__r and profile from Community_User_Profile__c / Community_User__r.Profile

        // any contact with the super profile is super
        // any contact with the readonly profile is readonly
        // any contact with the awaiting confirmation profile is awaiting confirmation
        // a contact with the support profile and a contact entitlement for that product is support
        // a contact with the support profile but no contact entitlement is readonly

        // first fetch all the contact account relations to find all the possible users for the contact
        List<String> contacts = fetchContactsForAccount(selectedAccId);

        List<Map<String, Object>> contactResults = new List<Map<String, Object>>();

        String query = 'SELECT Id, Community_User__r.Profile.Name, Community_User__r.FirstName, Community_User__r.LastName, Community_User__r.Name, Community_User__r.Email, Community_User__r.MediumPhotoUrl, Community_User__r.IsProfilePhotoActive,' + 
            ' (Select Product__c FROM ContactEntitlements__r WHERE Active__c=true AND Product__c=:product AND Real_Entitlement__r.AccountId =:selectedAccId) FROM Contact';
        query += ' where Id IN :contacts AND Can_Log_Into_Community__c = true';

        if (String.isNotBlank(level)) {
            if (level.contains('Support')) {
                query += ' AND Id IN (SELECT Contact__c FROM ContactEntitlement__c WHERE Active__c = true AND Product__c =:product AND Contact__r.AccountId =:selectedAccId)';
            } else if (level.contains('Read')) {
                query += ' AND (NOT Community_User__r.Profile.Name LIKE \'%Super%\') AND (NOT Community_User__r.Profile.Name LIKE \'%Profile Unassigned%\') AND (Id NOT IN (SELECT Contact__c FROM ContactEntitlement__c WHERE Active__c = true AND Product__c =:product AND Contact__r.AccountId =:selectedAccId))';
            } else {
                query += ' AND (Community_User__r.Profile.Name LIKE \'%' + level + '%\')';
            }
        }
        

        if (String.isNotBlank(searchterm)) {
            searchTerm = String.escapeSingleQuotes(searchterm);
            query += ' AND (Community_User__r.Name LIKE \'%' + searchTerm + '%\' OR Community_User__r.Email LIKE \'%' + searchTerm + '%\')';
        }

        query += String.format(' ORDER BY Community_User__r.LastName ASC LIMIT {0} OFFSET {1}', new List<Object>{++amount, offset});

        for (Contact c: Database.query(query)) {
            String contactLevel = c.Community_User__r.Profile.Name;
            if (contactLevel.contains('Support')) {
                contactLevel = c.ContactEntitlements__r.size() > 0 ? 'Support' : 'Read Only';
            }
            if (contactLevel != 'Support') {
                contactLevel += c.ContactEntitlements__r.size() > 0 ? ';Support' : '';
            }

            contactResults.add(new Map<String, Object>{
                'id' => c.Id,
                'name' => c.Community_User__r.Name,
                'first' => c.Community_User__r.FirstName,
                'last' => c.Community_User__r.LastName,
                'email' => c.Community_User__r.Email,
                'level' => contactLevel,
                'photoUrl' => c.Community_User__r.MediumPhotoUrl,
                'isPhotoActive' => c.Community_User__r.IsProfilePhotoActive
            });
        }
        return contactResults;

    }

    private static List<String> fetchContactsForAccount(String selectedAccId) {
        List<String> contacts = new List<String>();

        String customerSuccessRole = 'Customer Success Portal Access';
        List<AccountContactRelation> accountContactRelations = [
            SELECT Contact.Id FROM AccountContactRelation
            WHERE Account.Id =: selectedAccId
            AND (Roles INCLUDES (:customerSuccessRole) OR IsDirect = true)
        ];

        for (AccountContactRelation accountContact : accountContactRelations) {
            if (accountContact != null) {
                contacts.add(accountContact.ContactId);
            }
        }
        return contacts;
    }
}