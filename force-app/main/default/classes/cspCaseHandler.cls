public with sharing class cspCaseHandler {

    /**
     * Constants for the profile names
     */
    @testVisible
    private static final String SUPPORT_USER_PROFILE_NAME = 'Customer Portal - Support User';
    @testVisible
    private static final String SUPER_USER_PROFILE_NAME = 'Customer Portal - Super User';

    @AuraEnabled(cacheable=false)
    public static List<Map<String, Object>> getCases(String product, Integer amount, Integer offset, String searchTerm, String status, Boolean myCases, Boolean collaborationCases, Date startDate, Date endDate, Boolean projectCases, String selectedAccId, Boolean superUser) {
        List<Map<String, Object>> caseResults = new List<Map<String, Object>>();

        List<String> entitledProducts = superUser ? cspProductSelection.getFlatProductList(selectedAccId) : cspProductSelection.getEntitledProductList(selectedAccId);

        String networkName = cspCaseHandler.getNetwork();
        String userId = UserInfo.getUserId();
        String contactId = [Select contactid from User where id =:userId].contactId;
        String query = 'SELECT Id, CaseNumber, Account.Name, Service_Account__c, RelatedProduct__c, CreatedDate, ContactId, Contact.Name, Priority, CreatedBy.Name, CreatedById, Project_Lead__c, SubAnalysis__c, ClosedDate, Project_Lead__r.Name, OwnerId, Owner.Name, LastModifiedDate, Status, Status_Group__c, Subject FROM Case ';

        if (projectCases) {
            query += 'WHERE RecordType.Name IN (\'Project\', \'Project Manual\') AND Make_Public__c = true';
        } else {
            query += 'WHERE RecordType.Name IN (\'Support\', \'Parent Case\')';
        }

        if (String.isNotBlank(product) && !projectCases) {
            query += ' AND RelatedProduct__c =:product';
        } else if (!projectCases) {
            query += ' AND RelatedProduct__c IN :entitledProducts';
        }
        if (String.isNotBlank(searchterm)) {
            searchTerm = String.escapeSingleQuotes(searchterm);
            query += ' AND (CaseNumber LIKE \'%' + searchTerm + '%\' OR Subject LIKE \'%' + searchTerm + '%\')';
        }
        if (String.isNotBlank(status) && !status.equals('All status')) {
            if (status.equals('Open')) {
                query += ' AND Status_Group__c != \'Solved\'';
            } else {
                query += ' AND Status_Group__c =: status';
            }
        }

        if (myCases) {
            query += ' AND (CreatedById =:userId OR (ContactId != null AND ContactId =:contactId))';
        } else if (collaborationCases) {
            query += ' AND Id IN (SELECT Case__c FROM Portal_Case_Collaborator__c WHERE Contact__c =:contactId)';
        }

        if (String.isNotBlank(selectedAccId)) {
            query += ' AND AccountId =:selectedAccId';
        }

        if (startDate != null) {
            startDate.addDays(-1);
            query += ' AND CreatedDate > :startDate';
        }

        if (endDate != null) {
            endDate.addDays(1);
            query += ' AND CreatedDate < :endDate';
        }
        if(amount == 1000){
            query += String.format(' ORDER BY LastModifiedDate DESC LIMIT {0}', new List<Object>{++amount});
        }
        else {
            query += String.format(' ORDER BY LastModifiedDate DESC LIMIT {0} OFFSET {1}', new List<Object>{++amount, offset});
        }

        for (Case c: Database.query(query)) {
            String createdUser = c.CreatedById.equals(userId) ? 'Me' : c.CreatedBy.Name;
            String contactUser = c.ContactId != null ? (c.ContactId.equals(contactId) ? 'Me' : c.Contact.Name) : '';
            String owner = c.OwnerId != null ? (c.OwnerId.equals(userId) ? 'Me' : c.Owner.Name) : '';
            String projectLead = c.Project_Lead__c != null ? c.Project_Lead__r.Name : '';
            caseResults.add(new Map<String, Object>{
                'id' => c.Id,
                'subject' => c.Subject,
                'product' => c.RelatedProduct__c,
                'status' => c.Status,
                'AccountName' => c.Account.Name,
                'ServiceAccount' =>c.Service_Account__c,
                'statusGroup' => c.Status_Group__c,
                'reference' => c.CaseNumber,
                'created' => c.CreatedDate,
                'createdBy' => createdUser,
                'contact' => contactUser,
                'projectLead' => projectLead,
                'owner' => owner,
                'lastModified' => c.LastModifiedDate,
                'url' => String.format('/{0}/s/case/{1}', new List<String>{networkName, c.Id}),
                'priority' => c.Priority,
                'subAnalysis' => c.SubAnalysis__c,
                'closeddate' => c.ClosedDate
            });
        }
        return caseResults;
    }

    @AuraEnabled(cacheable=true)
    public static List<AccountContactRelation> GetServiceAccounts(id AccountId){
        List<AccountContactRelation> AccountNames = new List<AccountContactRelation>();
        try {
            string query = 'SELECT Account.name FROM AccountContactRelation';

            AccountNames = Database.Query(query);
        }
        catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return AccountNames;
    }

    @AuraEnabled(cacheable=false)
    public static List<Map<String, Object>> getInACases(String product, Integer amount, Integer offset, String searchTerm, String status, Boolean myCases, Date startDate, Date endDate, Boolean projectCases, String selectedAccId, Boolean superUser) {
        List<Map<String, Object>> caseResults = new List<Map<String, Object>>();

        List<String> entitledProducts = superUser ? cspProductSelection.getFlatProductList(selectedAccId) : cspProductSelection.getEntitledProductList(selectedAccId);

        String networkName = cspCaseHandler.getNetwork();
        String userId = UserInfo.getUserId();
        String contactId = [Select contactid from User where id =:userId].contactId;
        String query = 'SELECT Id, CaseNumber, RelatedProduct__c, CreatedDate, ContactId, Contact.Name, CreatedBy.Name, CreatedById, Project_Lead__c, Project_Lead__r.Name, OwnerId, Owner.Name, LastModifiedDate, Status, Status_Group__c, Subject FROM Case ';
               query += 'WHERE RecordType.Name IN (\'Issues And Actions\') AND Make_Public__c = true';

        if (String.isNotBlank(searchterm)) {
            searchTerm = String.escapeSingleQuotes(searchterm);
            query += ' AND (CaseNumber LIKE \'%' + searchTerm + '%\' OR Subject LIKE \'%' + searchTerm + '%\')';
        }
        if (String.isNotBlank(status) && !status.equals('All status')) {
            if (status.equals('Open')) {
                query += ' AND Status_Group__c != \'Solved\'';
            } else {
                query += ' AND Status_Group__c =: status';
            }
        }

        if (myCases) {
            query += ' AND (CreatedById =:userId OR (ContactId != null AND ContactId =:contactId))';
        }

        if (String.isNotBlank(selectedAccId)) {
            query += ' AND AccountId =:selectedAccId';
        }

        if (startDate != null) {
            startDate.addDays(-1);
            query += ' AND CreatedDate > :startDate';
        }

        if (endDate != null) {
            endDate.addDays(1);
            query += ' AND CreatedDate < :endDate';
        }

        query += String.format(' ORDER BY LastModifiedDate DESC LIMIT {0} OFFSET {1}', new List<Object>{++amount, offset});

        for (Case c: Database.query(query)) {
            String createdUser = c.CreatedById.equals(userId) ? 'Me' : c.CreatedBy.Name;
            String contactUser = c.ContactId != null ? (c.ContactId.equals(contactId) ? 'Me' : c.CreatedBy.Name) : '';
            String owner = c.OwnerId != null ? (c.OwnerId.equals(userId) ? 'Me' : c.Owner.Name) : '';
            String projectLead = c.Project_Lead__c != null ? c.Project_Lead__r.Name : '';
            caseResults.add(new Map<String, Object>{
                'id' => c.Id,
                'subject' => c.Subject,
                'product' => c.RelatedProduct__c,
                'status' => c.Status,
                'statusGroup' => c.Status_Group__c,
                'reference' => c.CaseNumber,
                'created' => c.CreatedDate,
                'createdBy' => createdUser,
                'contact' => contactUser,
                'projectLead' => projectLead,
                'owner' => owner,
                'lastModified' => c.LastModifiedDate,
                'url' => String.format('/{0}/s/case/{1}', new List<String>{networkName, c.Id})
            });
        }
        return caseResults;
    }

    @AuraEnabled(cacheable=false)
    public static List<Map<String, Object>> getCasesForProject(String caseId, Integer amount, Integer offset, String searchTerm, String status) {
        List<Map<String, Object>> caseResults = new List<Map<String, Object>>();

        String networkName = cspCaseHandler.getNetwork();
        String userId = UserInfo.getUserId();
        String contactId = [Select contactid from User where id =:userId].contactId;
        String query = 'SELECT Id, CaseNumber, RelatedProduct__c, CreatedDate, ContactId, Contact.Name, CreatedBy.Name, CreatedById, LastModifiedDate, Status, Status_Group__c, Subject FROM Case ';

        query += 'WHERE RecordType.Name = \'Issues and Actions\' AND Make_Public__c = true AND Parent_Project__c =:caseId';

        if (String.isNotBlank(searchterm)) {
            searchTerm = String.escapeSingleQuotes(searchterm);
            query += ' AND (CaseNumber LIKE \'%' + searchTerm + '%\' OR Subject LIKE \'%' + searchTerm + '%\')';
        }
        if (String.isNotBlank(status) && !status.equals('All status')) {
            if (status.equals('Open')) {
                query += ' AND Status_Group__c != \'Solved\'';
            } else {
                query += ' AND Status_Group__c =: status';
            }
        }

        query += String.format(' ORDER BY LastModifiedDate DESC LIMIT {0} OFFSET {1}', new List<Object>{++amount, offset});

        for (Case c: Database.query(query)) {
            String createdUser = c.CreatedById.equals(userId) ? 'Me' : c.CreatedBy.Name;
            String contactUser = c.ContactId != null ? (c.ContactId.equals(contactId) ? 'Me' : c.CreatedBy.Name) : '';
            caseResults.add(new Map<String, Object>{
                'id' => c.Id,
                'subject' => c.Subject,
                'product' => c.RelatedProduct__c,
                'status' => c.Status,
                'statusGroup' => c.Status_Group__c,
                'reference' => c.CaseNumber,
                'created' => c.CreatedDate,
                'createdBy' => createdUser,
                'contact' => contactUser,
                'lastModified' => c.LastModifiedDate,
                'url' => String.format('/{0}/s/case/{1}', new List<String>{networkName, c.Id})
            });
        }
        return caseResults;
    }

    @AuraEnabled(cacheable=false)
    public static List<Map<String, Object>> getCaseComments(String caseId) {
        List<Map<String, Object>> commentMap = new List<Map<String, Object>>();

        Case caseObject = [
            SELECT Id, CreatedById, CreatedDate, Description, Solution__c, Status_Group__c, CreatorFullPhotoUrl,
                CreatorName, CreatedBy.Name, RecordType.Name,
                (SELECT Id, CreatedById, CommentBody, CreatedDate,
                    CreatorFullPhotoUrl, CreatorName, CreatedBy.Name
                FROM CaseComments
                WHERE IsPublished = true
                ORDER BY CreatedDate DESC)
            FROM Case
            WHERE Id =: caseId
        ];

        if(caseObject.RecordType.Name != 'Project' && caseObject.RecordType.Name != 'Project Manual') {
            if (caseObject.Status_Group__c == 'Solved' &&  String.isNotEmpty(caseObject.Solution__c)) {
                /* Add a fake comment from the solution field if it exists */
                commentMap.add(new Map<String, Object>{
                    'CreatedById' => '',
                    'CommentBody' => caseObject.Solution__c,
                    'CreatedDate' => '',
                    'CreatorFullPhotoUrl' => '',
                    'CreatorName' => '',
                    'CreatedBy' => '',
                    'Id' => caseObject.Solution__c,
                    'Solution' => 'true'
                });
            }

            for(CaseComment comment: caseObject.CaseComments) {
                commentMap.add(comment.getPopulatedFieldsAsMap());
            }
        }

        /* Add a default fake comment from the details in the description */
        commentMap.add(new Map<String, Object>{
            'CreatedById' => caseObject.CreatedById,
            'CommentBody' => caseObject.Description,
            'CreatedDate' => caseObject.CreatedDate,
            'CreatorFullPhotoUrl' => caseObject.CreatorFullPhotoUrl,
            'CreatorName' => caseObject.CreatorName,
            'CreatedBy' => caseObject.CreatedBy,
            'Id' => caseObject.Id
        });

        return commentMap;
    }

    @AuraEnabled(cacheable=false)
    public static CaseComment addCaseComment(String caseId, String body) {
        CaseComment caseObject = new CaseComment(
            ParentId = caseId,
            CommentBody = body,
            IsPublished = true
        );
        insert caseObject;
        return caseObject;
    }

    @AuraEnabled(cacheable=false)
    public static List<CombinedAttachment> getCaseAttachments(String caseId) {
        return [
            SELECT Id,
                (SELECT Id, Title FROM CombinedAttachments)
            FROM Case
            WHERE Id =: caseId
        ].CombinedAttachments;
    }

    @AuraEnabled(cacheable=true)
    public static Integer getOpenCases(String product, Boolean superUser, String selectedAccId) {
        List<String> entitledProducts = superUser ? cspProductSelection.getFlatProductList(selectedAccId) : cspProductSelection.getEntitledProductList(selectedAccId);
        String userId = UserInfo.getUserId();
        String contactId = [Select contactid from User where id =:userId].contactId;
        List<String> validRecordTypes = new List<String>{'Support', 'Parent Case'};
        Integer caseCount = 0;


        String query = '';
        if (String.isNotBlank(product)){
            query = 'SELECT COUNT() FROM Case WHERE Status_Group__c != \'Solved\' AND RecordType.Name IN :validRecordTypes AND (CreatedById =:userId OR (ContactId != null AND  ContactId =:contactId)) AND RelatedProduct__c =:product ';
        } else {
            query = 'SELECT COUNT() FROM Case WHERE Status_Group__c != \'Solved\' AND RecordType.Name IN :validRecordTypes AND (CreatedById =:userId OR (ContactId != null AND ContactId =:contactId)) AND RelatedProduct__c IN :entitledProducts ';
        }

        if (selectedAccId != null) {
            query += 'AND AccountId =: selectedAccId';
        }

        caseCount = Database.countQuery(query);
        return caseCount;
    }

    @AuraEnabled(cacheable=true)
    public static Integer getAwaitingCustomerCases(String product, Boolean superUser, String selectedAccId) {
        List<String> entitledProducts = superUser ? cspProductSelection.getFlatProductList(selectedAccId) : cspProductSelection.getEntitledProductList(selectedAccId);
        String userId = UserInfo.getUserId();
        String contactId = [Select contactid from User where id =:userId].contactId;
        List<String> validRecordTypes = new List<String>{'Support', 'Parent Case'};
        Integer caseCount = 0;

        String query = '';
        if (String.isNotBlank(product)){
            query = 'SELECT COUNT() FROM Case WHERE Status_Group__c = \'Needs Action\' AND RecordType.Name IN :validRecordTypes AND (CreatedById =:userId OR (ContactId != null AND  ContactId =:contactId)) AND RelatedProduct__c =:product ';
        } else {
            query = 'SELECT COUNT() FROM Case WHERE Status_Group__c = \'Needs Action\' AND RecordType.Name IN :validRecordTypes AND (CreatedById =:userId OR (ContactId != null AND ContactId =:contactId)) AND RelatedProduct__c IN :entitledProducts ';
        }

        if (selectedAccId != null) {
            query += 'AND AccountId =: selectedAccId';
        }

        caseCount = Database.countQuery(query);
        return caseCount;
    }

    @AuraEnabled
    public static Boolean createSelfGenCase(String selectedAccountId){
        return createSelfGenCase(selectedAccountId, 'FlexPoints Points Top Up Request');
    }

    @AuraEnabled(cacheable=false)
    public static Boolean createAccountUpgradeSelfGenCase(String selectedAccountId) {
        return createSelfGenCase(selectedAccountId, 'FlexPoints Account Upgrade request');
    }

    private static Boolean createSelfGenCase(String selectedAccountId, String subject) {
        String userId = UserInfo.getUserId();
        String contactId = [Select contactid from User where id =:userId].contactId;

        Case newCase = new Case(
            Status = 'Pending',
            Description = subject,
            Subject = subject,
            Origin = 'WebForm',
            Priority = '4',
            RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Sales Opportunity').getRecordTypeId(),
            Source__c = 'Support',
            CaseType__c = 'Other services',
            ContactId = contactId,
            Account__c = selectedAccountId
        );
        Savepoint sp = Database.setSavepoint();

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
    public static List<Map<String, Object>> getFlexPointRedemptionCases(String selectedAccountId, Integer caseLimitAmount, Integer caseOffset){
        String recordTypeId = String.valueOf(Schema.SObjectType.Case.getRecordTypeInfosByName().get('FlexPoints Redemption').getRecordTypeId());
        List<Id> flexPointIds = new List<Id>();
        for (FlexPoints_Transactions__c flex : [SELECT FlexPoint_Redemption_Case__c FROM FlexPoints_Transactions__c WHERE Account__c =: selectedAccountId]) {
            flexPointIds.add(flex.FlexPoint_Redemption_Case__c);
        }

        String listQuery = 'SELECT Id, Subject, Status, Points_Estimate__c, OwnerId, Owner.Name, Date_Requested__c, CaseNumber, Type FROM Case WHERE Account.Id =: selectedAccountId AND RecordTypeId =: recordTypeId' + ' ';

        listQuery += 'AND ((Status = \'Estimate Required\') OR (Status = \'Pending\' AND Id NOT IN :flexPointIds))' + ' ';
        listQuery += 'ORDER BY Date_Requested__c DESC NULLS LAST' + ' ';
        listQuery += String.format('LIMIT {0} OFFSET {1}', new List<Object>{caseLimitAmount, caseOffset});

        String userId = UserInfo.getUserId();

        List<Map<String, Object>> casesResults = new List<Map<String, Object>>();

        for (Case c: Database.query(listQuery)) {
            String owner = c.OwnerId != null ? (c.OwnerId.equals(userId) ? 'Me' : c.Owner.Name) : '';
            casesResults.add(new Map<String, Object>{
                'id' => c.Id,
                'subject' => c.Subject,
                'points' => c.Points_Estimate__c,
                'ref' => c.CaseNumber,
                'date' => c.Date_Requested__c,
                'status' => c.Status,
                'owner' => owner,
                'caseId' => c.Id,
                'type' => c.Type
            });
        }

        return casesResults;
    }

    @AuraEnabled(cacheable=true)
    public static String getOpenRequestCaseReference(String caseId) {
        return [SELECT CaseNumber FROM Case WHERE Id =: caseId].CaseNumber;
    }

    /**
     * Gets the Case contact Number records
     * @param   productRoutingId    Id value (passed as string from lwc) to query for
     * @param   region              The region to match to User.Contact.Region__c value
     * @return  Array of Case_Contact_Number__c records which match
     */
    @AuraEnabled(cacheable=true)
    public static List<Case_Contact_Number__c> getCaseContacts(String productRoutingId, String region) {

        String query = 'SELECT Country__c, Contact_Telephone_Number__c FROM Case_Contact_Number__c WHERE Product_Routing__c = \'' + productRoutingId + '\'';

        if(String.isNotBlank(region)) {
            query += ' AND (Region__c = \'\' OR Region__c INCLUDES (\'' + region + '\'))';
        }

        query += ' ORDER BY Country__c ASC NULLS LAST';

        return Database.query(query);
    }

    private static String getNetwork() {
        try {
            return [ SELECT UrlPathPrefix FROM Network WHERE Id = :Network.getNetworkId() ].UrlPathPrefix;
        } catch(QueryException e) {
            System.debug('Exception retrieving network id : ' + e.getMessage());
            return 'support';
        }
    }
}