public without sharing class cspSupportAnalystsHandler {

    @AuraEnabled(cacheable=true)
    public static List<Entitlement> getSupportAnalysts(String selectedAccId) {
        return [SELECT
                    AssociatedProductRange__c,
                    NamedAgentEntitlement__r.Name,
                    NamedAgentEntitlement__r.IsProfilePhotoActive,
                    NamedAgentEntitlement__r.MediumPhotoUrl
                    FROM Entitlement
                    WHERE Active__c = true
                    AND AccountId =: selectedAccId
                    AND PlanType__c LIKE 'Premier%'];
    }
}