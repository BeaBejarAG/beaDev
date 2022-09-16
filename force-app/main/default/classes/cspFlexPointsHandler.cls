public without sharing class cspFlexPointsHandler {
    @AuraEnabled(cacheable=false)
    public static Boolean requestAQuote(String description, String subject, String priority,
    String product, String serviceId, String entitlementId, String points, String accountId){
        if (entitlementId == null) {
            return false;
        }
        Savepoint sp = Database.setSavepoint();

        Service_Catalogues__c service = [SELECT Account_Journey_Stage__c, Hours_to_Deliver__c, Delivered_By__c, Location__c,
        Service_Description__c, Service_Outcomes__c, Service_Prerequisites__c, Service_Title__c,
        Service_Type__c, User_Level__c, Estimate_Required__c, Days_to_Deliver__c, Products__c, Delivery_Type__c, Division__c
        FROM Service_Catalogues__c WHERE Id =: serviceId];

        Case newCase = createCaseObj(description, subject, priority, product, serviceId, entitlementId, service, points, accountId);

        try {
            insert newCase;

            Case validateCase = [SELECT CaseNumber, Id, Subject FROM Case WHERE Id =: newCase.Id];
            if (validateCase != null){
                return true;
            } else {
                Database.rollback(sp);
                return false;
            }
        } catch(DmlException e) {
            System.debug('An unexpected error has occurred: ' + e.getMessage());
            Database.rollback(sp);
            return false;
        }
    }

    @AuraEnabled(cacheable=false)
    public static Boolean createNewCase(String description, String subject, String priority,
    String product, String serviceId, String entitlementId, String accountId, String points){
        if (entitlementId == null) {
            return false;
        }
        Savepoint sp = Database.setSavepoint();

        Service_Catalogues__c service = [SELECT Account_Journey_Stage__c, Hours_to_Deliver__c, Delivered_By__c, Location__c,
        Service_Description__c, Service_Outcomes__c, Service_Prerequisites__c, Service_Title__c,
        Service_Type__c, User_Level__c, Estimate_Required__c, Days_to_Deliver__c, Products__c, Delivery_Type__c, Division__c
        FROM Service_Catalogues__c WHERE Id =: serviceId];

        Case newCase = createCaseObj(description, subject, priority, product, serviceId, entitlementId, service, points, accountId);
        try {
            insert newCase;

            Case validateCase = [SELECT CaseNumber, Id, Subject FROM Case WHERE Id =: newCase.Id];
            if (validateCase != null){
                return createTransactionRecord(validateCase.Id, accountId, Integer.valueOf(points), sp);
            } else {
                Database.rollback(sp);
                return false;
            }
        } catch(DmlException e) {
            System.debug('An unexpected error has occurred: ' + e.getMessage());
            Database.rollback(sp);
            return false;
        }
    }

    private static Boolean createTransactionRecord(Id caseId, String accountId, Integer points, Savepoint sp){
        Date dateToday = Date.today();
        Id value = Id.valueOf(accountId);
        FlexPoints_Transactions__c flexPointsTransaction = new FlexPoints_Transactions__c(
            FlexPoint_Redemption_Case__c = caseId,
            Type__c = 'Redemption',
            Requested_Date__c = dateToday,
            Transaction_Status__c = 'Pending',
            Account__c = value,
            Points__c = points,
            Owner__c = UserInfo.getUserId()
        );
        try {
            insert flexPointsTransaction;

            FlexPoints_Transactions__c validateTransaction = [SELECT Id FROM FlexPoints_Transactions__c WHERE Id =: flexPointsTransaction.Id];
            if (validateTransaction != null) {
                return true;
            } else {
                Database.rollback(sp);
                return false;
            }
        } catch(DmlException e) {
            System.debug('An unexpected error has occurred: ' + e.getMessage());
            Database.rollback(sp);
            return false;
        }
    }

    private static Case createCaseObj(String description, String subject, String priority,
    String product, String serviceId, String entitlementId, Service_Catalogues__c service, String points, String accountId) {
        Date dateToday = Date.today();
        return new Case(
            Status = service.Estimate_Required__c ? 'Estimate Required' : 'Pending',
            Description = description,
            Subject = subject,
            Origin = 'WebForm',
            Priority = priority,
            RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('FlexPoints Redemption').getRecordTypeId(),
            EntitlementId = Id.valueOf(entitlementId),
            RelatedProduct__c = product,
            Source__c = 'Support',
            CaseType__c = 'Feature request',

            Date_Requested__c = dateToday,
            Journey_Stage__c = service.Account_Journey_Stage__c,
            Points_Value__c = service.Estimate_Required__c ? null : Integer.valueOf(points),
            Hours_to_Deliver__c = service.Hours_to_Deliver__c,
            Delivered_By__c = service.Delivered_By__c,
            Location__c = service.Location__c,
            Service_Description__c = service.Service_Description__c,
            Service_Outcomes__c = service.Service_Outcomes__c,
            Service_Prerequisites__c = service.Service_Prerequisites__c,
            Service_Title__c = service.Service_Title__c,
            Service_Type__c = service.Service_Type__c,
            User_Level__c = service.User_Level__c,
            Account__c = accountId,
            AccountId = accountId,
            Delivery_Type__c = service.Delivery_Type__c,
            Days_to_Deliver__c = service.Days_to_Deliver__c,
            ProductMapped__c = service.Products__c,
            Division_FPT__c = service.Division__c
        );
    }

    @AuraEnabled(cacheable=false)
    public static FlexPoints_Transactions__c createQuoteApprovalTransaction(String accountId, Integer points, String owner, String caseId) {
        return createNewFlexPointsTransaction(accountId, points, owner, caseId, 'Pending', null);
    }

    @AuraEnabled(cacheable=false)
    public static FlexPoints_Transactions__c createCancellationFeeTransaction(String accountId, Integer points, String owner, String serviceName, String caseId) {
        return createNewFlexPointsTransaction(accountId, points, owner, caseId, 'Cancellation Fee', serviceName);
    }

    public static FlexPoints_Transactions__c createNewFlexPointsTransaction(String accountId, Integer points, String owner, String caseId, String status, String serviceName) {
        Date dateToday = Date.today();
        FlexPoints_Transactions__c flexPointsTransaction = new FlexPoints_Transactions__c(
            Type__c = 'Redemption',
            Requested_Date__c = dateToday,
            Transaction_Status__c = status,
            Points__c = points,
            Account__c = accountId,
            Expired__c = false,
            Owner__c = owner,
            FlexPoint_Redemption_Case__c = caseId,
            Cancelled_Service_Name__c = serviceName
        );
        insert flexPointsTransaction;
        return flexPointsTransaction;
    }

    @AuraEnabled(cacheable=false)
    public static void updateCase(String caseId, Integer points) {
        Case caseToUpdate = [SELECT Points_Value__c FROM Case WHERE Id =: caseId];
        caseToUpdate.Points_Value__c = points;
        caseToUpdate.Status = 'Pending';
        update caseToUpdate;
    }

    @AuraEnabled(cacheable=false)
    public static void rejectCase(String caseId) {
        Case caseToReject = [SELECT Status FROM Case WHERE Id =: caseId];
        caseToReject.Status = 'Rejected';
        update caseToReject;
    }
}