public without sharing class cspConsultantAccountHandler {
    private static void retrieveAccountContactRelations(List<AccountContactRelation> results, Id contactId) {
        String accessCommunityDefaultAccountId = '0015800000s8gWeAAI';
        String customerSuccessRole = 'Customer Success Portal Access';
        List<AccountContactRelation> accountContactRelations = [
            SELECT Account.Name, IsDirect 
            FROM AccountContactRelation 
            WHERE Contact.Id =: contactId 
            AND Account.Id != null
            AND Account.Id !=: accessCommunityDefaultAccountId
            AND (Roles INCLUDES (:customerSuccessRole) OR IsDirect = true)
            ];

        for (AccountContactRelation accountContact : accountContactRelations) {
            if (accountContact != null) {
                results.add(accountContact);
            }
        }
    }

    private static List<AccountContactRelation> getAccountIds(String selectedContactId) {
        List<AccountContactRelation> results = new List<AccountContactRelation>();
        
        try{
            if (selectedContactId != null) {
                Id contactId = Id.valueOf(selectedContactId);
                retrieveAccountContactRelations(results, contactId);
            } else{
                User currentUser = [SELECT ContactId FROM User WHERE Id =: Userinfo.getUserId()];
                if (currentUser != null && String.isNotBlank(currentUser.ContactId)) {
                    Id contactId = currentUser.ContactId;
                    retrieveAccountContactRelations(results, contactId);
                }
            }
        } catch(QueryException e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
        }
        return results;
    }

    @AuraEnabled(cacheable=true)
    public static List<AccountContactRelation> getAccountRelations(String contactId) { 
        return getAccountIds(contactId);
    }
}