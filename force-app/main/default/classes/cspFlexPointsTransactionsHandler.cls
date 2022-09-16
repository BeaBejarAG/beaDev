public without sharing class cspFlexPointsTransactionsHandler {
    @AuraEnabled(cacheable=false)
    public static List<Map<String, Object>> getFlexPointTransactions(String selectedAccountId, String statusType, Integer lmt, Integer ofst, Boolean isTransHistory) {
        String listQuery = 'SELECT Request_Subject__c, Status__c, Points__c, Owner__c, Owner__r.Name, FlexPoint_Redemption_Case__r.Id, Requested_Date__c, Name, Type__c, Cancelled_Service_Name__c FROM FlexPoints_Transactions__c WHERE Account__c =: selectedAccountId' + ' ';

        if (isTransHistory) {
            listQuery += 'AND (Start_Date__c <= TODAY OR Start_Date__c = NULL)' + ' ';
            listQuery += 'ORDER BY Requested_Date__c DESC NULLS LAST' + ' ';
            listQuery += String.format('LIMIT {0} OFFSET {1}', new List<Object>{lmt, ofst});
        } else {
            listQuery += 'AND Status__c =: statusType' + ' ';
            listQuery += 'ORDER BY Requested_Date__c DESC NULLS LAST';
        }

        String networkName = cspFlexPointsTransactionsHandler.getNetwork();
        String userId = UserInfo.getUserId();

        List<Map<String, Object>> transactionsResults = new List<Map<String, Object>>();

        for (FlexPoints_Transactions__c c: Database.query(listQuery)) {
            String owner = c.Owner__c != null ? (c.Owner__c.equals(userId) ? 'Me' : c.Owner__r.Name) : '';
            transactionsResults.add(new Map<String, Object>{
                'id' => c.Id,
                'subject' => c.Request_Subject__c,
                'points' => c.Points__c,
                'ref' => c.Name,
                'date' => c.Requested_Date__c,
                'status' => c.Status__c,
                'owner' => owner,
                'caseId' => c.FlexPoint_Redemption_Case__r.Id,
                'type' => c.Type__c,
                'cancelledService' => c.Cancelled_Service_Name__c
            });
        }

        return transactionsResults;
    }

    private static String getNetwork() {
        try {
            return [ SELECT UrlPathPrefix FROM Network WHERE Id = :Network.getNetworkId() ].UrlPathPrefix;
        } catch(QueryException e) {
            System.debug('Exception retrieving network id : ' + e.getMessage());
            return 'support';
        }
    }

    @AuraEnabled
    public static String getTransactionReference(String caseId) {
        return [SELECT Name FROM FlexPoints_Transactions__c WHERE FlexPoint_Redemption_Case__c =: caseId].Name;
    }
}