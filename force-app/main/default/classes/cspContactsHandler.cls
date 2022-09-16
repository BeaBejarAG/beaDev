public without sharing class cspContactsHandler {

    @AuraEnabled(cacheable=true)
    public static String getPlan(String selectedAccId) {
        if (String.isBlank(selectedAccId)) {
            return 'No Plan';
        }
        String plan = [SELECT Highest_CSP_Level__c FROM Account WHERE Id =: selectedAccId].Highest_CSP_Level__c;

        if (String.isEmpty(plan)) {
            plan = 'Essential';
        }
        return plan;
    }

    @AuraEnabled(cacheable=true)
    public static User getCSM(String selectedAccId) {
        if (String.isBlank(selectedAccId)) {
            return null;
        }
        String csmId = [SELECT CSM_Owner__c FROM Account WHERE Id =: selectedAccId].CSM_Owner__c;
        User user = null;

        if (!String.isEmpty(csmId)) {
            user = [SELECT Name, Email, Phone, MobilePhone, MediumPhotoUrl, IsProfilePhotoActive FROM User WHERE Id =: csmId];
        }

        return user;
    }

    @AuraEnabled(cacheable=true)
    public static User getAccountManager(String selectedAccId) {
        if (String.isBlank(selectedAccId)) {
            return null;
        }
        String accountManagerId = [SELECT OwnerId FROM Account WHERE Id =: selectedAccId].OwnerId;
        return [SELECT Name, Email, Phone, MobilePhone, MediumPhotoUrl, IsProfilePhotoActive FROM User WHERE Id =: accountManagerId];
    }

    @AuraEnabled(cacheable=true)
    public static Boolean getIsPointsGuardian(String selectedAccountId){
        String pointsGuardianRole = 'Points Guardian';
        User currentUser = [SELECT ContactId FROM User WHERE Id =: Userinfo.getUserId()];
        List<AccountContactRelation> accountContactRelations = new List<AccountContactRelation>();

        if (currentUser != null && String.isNotBlank(currentUser.ContactId)) {
            Id contactId = currentUser.ContactId;

            accountContactRelations = [
                SELECT Id FROM AccountContactRelation
                WHERE Contact.Id =: contactId
                AND Account.Id =: selectedAccountId
                AND Roles INCLUDES (:pointsGuardianRole)
            ];
        }

        return (accountContactRelations.size() > 0);
    }

    @AuraEnabled(cacheable=true)
    public static Boolean getIsNonPointsUser(String selectedAccountId) {
        return [SELECT Count() FROM FlexPoints_Transactions__c WHERE Account__c =: selectedAccountId] == 0;
    }

    @AuraEnabled(cacheable=true)
    public static List<User> getPointsGuardians(String selectedAccountId) {
        return [SELECT Contact.Name, Contact.Email, MediumPhotoUrl, IsProfilePhotoActive FROM User WHERE ContactId IN (SELECT ContactId FROM AccountContactRelation WHERE AccountId = :selectedAccountId AND Roles INCLUDES ('Points Guardian'))];
    }

    @AuraEnabled(cacheable=false)
    public static Decimal getExpiringSoonPoints(String accountId) {
        Account account = [SELECT Total_Redemptions__c FROM Account WHERE Id =: accountId LIMIT 1];
        return calcExpiringSoonPoints(account);
    }

    private static Decimal calcExpiringSoonPoints(Account account) {
        AggregateResult[] arAccural = [SELECT
            SUM(Points__c) Accruals
            FROM FlexPoints_Transactions__c
            WHERE Account__c =: account.Id
            AND Type__c != 'Redemption'
            AND End_Date__c = NEXT_N_DAYS:30
        ];

        Integer accuralPoints = 0;

        if ((arAccural.size() > 0) && arAccural[0].get('Accruals') != null) {
            accuralPoints = Integer.valueOf(arAccural[0].get('Accruals'));
        }
        Decimal expiringSoonPoints = 0;
        if (account != null) {
            expiringSoonPoints = (account.Total_Redemptions__c > accuralPoints) ? 0 : (accuralPoints - account.Total_Redemptions__c);
        }
        return expiringSoonPoints;
    }
    
    @AuraEnabled(cacheable=false)
    public static Map<String, Object> getFlexPoints(String selectedAccountId){
        Account[] accounts = [SELECT Total_Accruals__c, Total_Confirmed__c, Total_Pending__c, Total_Redemptions__c FROM Account WHERE Id =: selectedAccountId];

        Map<String,Object> balances = new Map<String,Object>();
        if (accounts.size() > 0) {
            Account account = accounts[0];
            Decimal expiringSoonPoints = calcExpiringSoonPoints(account);
            balances = new Map<String,Object>{
                'id' => account.Id,
                'availablePoints' => account.Total_Accruals__c - account.Total_Redemptions__c,
                'totalConfirmed' => account.Total_Confirmed__c,
                'totalPending' => account.Total_Pending__c,
                'currentBalance' => account.Total_Accruals__c - account.Total_Redemptions__c,
                'expiringSoon' => expiringSoonPoints
            };
        }
        return balances;
    }
}