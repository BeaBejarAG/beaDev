@IsTest
private class cspFlexPointsTransactionsHandlerTest {
    @IsTest
    public static void getFlexPointTransactions() {
        Account account = new Account(
            Name = 'Account Name',
            Highest_CSP_Level__c = ''
        );
        insert account;

        Date requestedDate = Date.newInstance(2021, 06, 29);
        FlexPoints_Transactions__c flexPointTransaction = new FlexPoints_Transactions__c(
            Account__c = account.Id,
            Expired__c = false,
            Transaction_Status__c = 'Pending',
            Points__c = 1000,
            Requested_Date__c = requestedDate,
            Owner__c = UserInfo.getUserId()
        );
        insert flexPointTransaction;
        FlexPoints_Transactions__c result = [SELECT Request_Subject__c, Status__c, Points__c, Owner__r.Name, FlexPoint_Redemption_Case__r.Id, Requested_Date__c, Name FROM FlexPoints_Transactions__c LIMIT 1];

        String userId = UserInfo.getUserId();
        String owner = result.Owner__c != null ? (result.Owner__c.equals(userId) ? 'Me' : result.Owner__r.Name) : '';

        String networkName = 'Support';
        Map<String, Object> transactionMap = new Map<String, Object>{
            'id' => result.Id,
            'subject' => result.Request_Subject__c,
            'points' => result.Points__c,
            'ref' => result.Name,
            'date' => result.Requested_Date__c,
            'owner' => owner,
            'status' => result.Status__c,
            'caseId' => flexPointTransaction.FlexPoint_Redemption_Case__r.Id
        };

        List<Map<String, Object>> flexPointTransactionResult = cspFlexPointsTransactionsHandler.getFlexPointTransactions(account.Id, 'Top Up', 1, 0, false);
        Map<String, Object> transactionResult = flexPointTransactionResult.get(0);

        System.assertEquals(JSON.serialize(transactionMap.get('subject')), JSON.serialize(transactionResult.get('subject')));
        System.assertEquals(JSON.serialize(transactionMap.get('points')), JSON.serialize(transactionResult.get('points')));
        System.assertEquals(JSON.serialize(transactionMap.get('ref')), JSON.serialize(transactionResult.get('ref')));
        System.assertEquals(JSON.serialize(transactionMap.get('date')), JSON.serialize(transactionResult.get('date')));
        System.assertEquals(JSON.serialize(transactionMap.get('status')), JSON.serialize(transactionResult.get('status')));
        System.assertEquals(JSON.serialize(transactionMap.get('owner')), JSON.serialize(transactionResult.get('owner')));
        System.assertEquals(JSON.serialize(transactionMap.get('caseId')), JSON.serialize(transactionResult.get('caseId')));
    }
}