public without sharing class cspCaseCollaboratorHandler {

    private static final String SUPPORT_USER_PROFILE_NAME = 'Customer Portal - Support User';
    private static final String SUPER_USER_PROFILE_NAME = 'Customer Portal - Super User';
    
    @AuraEnabled(cacheable=true)
    public static List<Map<String, Object>> getCaseCollaborators(String caseId) {
        List<Map<String, Object>> collaboratorMap = new List<Map<String, Object>>();

        List<Portal_Case_Collaborator__c> collaborators = [
            SELECT Id, Contact__c, Contact__r.Name, Contact__r.Community_User__r.FirstName, Contact__r.Community_User__r.LastName,
                Contact__r.Community_User__r.Email, Contact__r.Community_User__r.MediumPhotoUrl, Contact__r.Community_User__r.IsProfilePhotoActive
            FROM Portal_Case_Collaborator__c
            WHERE Case__c =: caseId
            ORDER BY Contact__r.Name
        ];

        for(Portal_Case_Collaborator__c collaborator : collaborators) {
            collaboratorMap.add(new Map<String, Object>{
                'id' => collaborator.Id,
                'contactId' => collaborator.Contact__c,
                'contactName' => collaborator.Contact__r.Name,
                'first' => collaborator.Contact__r.Community_User__r.FirstName,
                'last' => collaborator.Contact__r.Community_User__r.LastName,
                'email' => collaborator.Contact__r.Community_User__r.Email,
                'photoUrl' => collaborator.Contact__r.Community_User__r.MediumPhotoUrl,
                'isPhotoActive' => collaborator.Contact__r.Community_User__r.IsProfilePhotoActive
            });
        }

        return collaboratorMap;
    }

    @AuraEnabled(cacheable=false)
    public static void removeCaseCollaborator(Id collaboratorId) {
        Database.delete(collaboratorId);
    }

    @AuraEnabled(cacheable=false)
    public static void addCaseCollaborator(Id contactId, Id caseId) {
        Portal_Case_Collaborator__c collaborator = new Portal_Case_Collaborator__c(Case__c = caseId, Contact__c = contactId);
        insert collaborator;
    }

    @AuraEnabled(cacheable=false)
    public static void addCaseCollaborators(List<Id> contactIdList, Id caseId) {
        for (Id id : contactIdList) {
            Portal_Case_Collaborator__c collaborator = new Portal_Case_Collaborator__c(Case__c = caseId, Contact__c = id);
            insert collaborator;
        }
    }

    @AuraEnabled(cacheable=true)
    public static Boolean canAddCollaborators(Id caseId) {
        String userId = UserInfo.getUserId();
        String contactId = [Select contactid from User where id =:userId].contactId;

        // Retrieve the case to assess whether the current user is the owner of the case
        Case caseResult = [
            SELECT CreatedById, ContactId, RelatedProduct__c
            FROM Case
            WHERE Id =: caseId
            LIMIT 1
        ];
        return caseResult.CreatedById == userId || caseResult.ContactId == contactId;
    }

    @AuraEnabled(cacheable=false)
    public static String validateCaseCollaborator(String caseId, String contactId) {
        // Check that the selected contact is not already a collaborator
        Integer duplicateCount = [
            SELECT count()
            FROM Portal_Case_Collaborator__c
            WHERE Case__c =: caseId 
            AND Contact__c =: contactId
        ];
        if(duplicateCount > 0) {
            return 'This contact is already a collaborator on this case';
        }

        // Check that the selected contact is not already the case contact
        Case caseResult = [
            SELECT AccountId, ContactId, RelatedProduct__c, CreatedById
            FROM Case
            WHERE Id =: caseId
            LIMIT 1
        ];
        Integer creatorCount = [
            SELECT count()
            From User
            WHERE Id =: caseResult.CreatedById
            AND ContactId =: contactId
        ];
        if(contactId == caseResult.ContactId || creatorCount > 0) {
            return 'Cannot add case contact as a case collaborator';
        }

        Contact suggestedContact = [
            SELECT Community_User__r.Profile.Name
            FROM Contact
            WHERE Id =: contactId
        ];
        // Super users can be collaborators
        if (suggestedContact.Community_User__r.Profile.Name == cspCaseCollaboratorHandler.SUPER_USER_PROFILE_NAME) {
            return '';
        }
        if (suggestedContact.Community_User__r.Profile.Name != cspCaseCollaboratorHandler.SUPPORT_USER_PROFILE_NAME) {
            return 'Selected contacts must have profile: ' + cspCaseCollaboratorHandler.SUPPORT_USER_PROFILE_NAME + ' or ' + cspCaseCollaboratorHandler.SUPER_USER_PROFILE_NAME;
        }

        // Check whether the contact has an entitlement for the given product
        Boolean isEntitled = false;
        List<ContactEntitlement__c> contactEntitlements = cspProductSelection.getContactEntitlements(caseResult.AccountId, contactId);
        for (ContactEntitlement__c entitlement : contactEntitlements) {
            if (entitlement.Product__c == caseResult.RelatedProduct__c) {
                isEntitled = true;
            }
        }
        if (!isEntitled) {
            return 'The selected contact is not entitled for the prduct related to this case';
        }

        // Ensure that the contact is linked to the selected account
        List<AccountContactRelation> contactRelations = cspConsultantAccountHandler.getAccountRelations(contactId);
        for (AccountContactRelation relation : contactRelations) {
            if (relation.AccountId == caseResult.AccountId) {
                return '';
            }
        }
        return 'Selected contact is not a community user for the selected account';
    }

    @AuraEnabled(cacheable=true)
    public static List<Map<String, Object>> getPotentialCollaboratorsByCase(String caseId) {
        // Fetch the case details
        Case caseResult = [
            SELECT AccountId, ContactId, RelatedProduct__c, CreatedById
            FROM Case
            WHERE Id =: caseId
            LIMIT 1
        ];

        // Fetch all contacts related to the account, that are entitled to the product
        // Not the case owner
        // Not existing collaborators
        List<ContactEntitlement__c> collaboratorList = [
            SELECT Name, Contact__c, Contact__r.Name, Contact__r.Community_User__r.Profile.Name, Contact__r.Community_User__r.FirstName, Contact__r.Community_User__r.LastName,
                Contact__r.Community_User__r.Name, Contact__r.Community_User__r.Email, Contact__r.Community_User__r.MediumPhotoUrl, Contact__r.Community_User__r.IsProfilePhotoActive
            FROM ContactEntitlement__c
            WHERE Active__C = true
            AND Real_Entitlement__r.AccountId =:caseResult.AccountId
            AND Product__c =:caseResult.RelatedProduct__c
            AND Contact__c NOT IN (SELECT Contact__c FROM Portal_Case_Collaborator__c WHERE Case__c =: caseId)
            AND Contact__c !=: caseResult.ContactId
            AND Contact__r.Community_User__c !=: caseResult.CreatedById
        ];

        List<Map<String, Object>> collaboratorMap = new List<Map<String, Object>>();
        for(ContactEntitlement__c collaborator : collaboratorList) {
            collaboratorMap.add(new Map<String, Object>{
                'id' => collaborator.Contact__c,
                'contactName' => collaborator.Contact__r.Name,
                'first' => collaborator.Contact__r.Community_User__r.FirstName,
                'last' => collaborator.Contact__r.Community_User__r.LastName,
                'email' => collaborator.Contact__r.Community_User__r.Email,
                'photoUrl' => collaborator.Contact__r.Community_User__r.MediumPhotoUrl,
                'isPhotoActive' => collaborator.Contact__r.Community_User__r.IsProfilePhotoActive
            });
        }
        return collaboratorMap;
    }

    @AuraEnabled(cacheable=true)
    public static List<Map<String, Object>> getPotentialCollaborators(String accountId, String product) {
        Id userId = UserInfo.getUserId();
        Id userContactId = [SELECT ContactId FROM User WHERE Id =:userId].ContactId;

        // Fetch all contacts related to the account, that are entitled to the product
        // Not the current user
        List<ContactEntitlement__c> collaboratorList = [
            SELECT Name, Contact__c, Contact__r.Name, Contact__r.Community_User__r.Profile.Name, Contact__r.Community_User__r.FirstName, Contact__r.Community_User__r.LastName,
                Contact__r.Community_User__r.Name, Contact__r.Community_User__r.Email, Contact__r.Community_User__r.MediumPhotoUrl, Contact__r.Community_User__r.IsProfilePhotoActive
            FROM ContactEntitlement__c
            WHERE Active__C = true
            AND Real_Entitlement__r.AccountId =:accountId
            AND Product__c =:product
            AND Contact__c !=: userContactId
        ];

        List<Map<String, Object>> collaboratorMap = new List<Map<String, Object>>();
        for(ContactEntitlement__c collaborator : collaboratorList) {
            collaboratorMap.add(new Map<String, Object>{
                'id' => collaborator.Contact__c,
                'contactName' => collaborator.Contact__r.Name,
                'first' => collaborator.Contact__r.Community_User__r.FirstName,
                'last' => collaborator.Contact__r.Community_User__r.LastName,
                'email' => collaborator.Contact__r.Community_User__r.Email,
                'photoUrl' => collaborator.Contact__r.Community_User__r.MediumPhotoUrl,
                'isPhotoActive' => collaborator.Contact__r.Community_User__r.IsProfilePhotoActive
            });
        }
        return collaboratorMap;
    }

    @AuraEnabled
    public static Boolean isCaseViewable(String caseId, String caseContactId, String caseCreatedById) {
        Id userId = UserInfo.getUserId();
        Id profileId = UserInfo.getProfileId();
        
        String profileName = [SELECT Name FROM Profile WHERE Id = :profileId].Name;
        if (profileName == SUPER_USER_PROFILE_NAME) {
            return true;
        }
        
        if (userId == caseCreatedById) {
            return true;
        }

        Id userContactId = [SELECT ContactId FROM User WHERE Id =:userId].ContactId;
        if (caseContactId == userContactId) {
            return true;
        }

        List<Portal_Case_Collaborator__c> ccc = [SELECT Id 
                                              FROM Portal_Case_Collaborator__c 
                                              WHERE Contact__c = :userContactId
                                              AND  Case__c = :caseId
                                              LIMIT 1];
        if (ccc != null &&
            ccc.size() == 1) {
            return true;
        }
        return false;
    }
}