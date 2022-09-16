public without sharing class cspPointsExpiryHandler {

    @InvocableMethod(label='Calculate Points Expiry')
    public static void calculatePointsExpiry(List<Id> accountIds){

        Map<Id, Map<String,Integer>> accountBalances = new Map<Id, Map<String,Integer>>();

        // Total Accruals
        for (AggregateResult ar : [SELECT
                                    Account__c,
                                    SUM(Points__c) Accruals
                                    FROM FlexPoints_Transactions__c
                                    WHERE Account__c IN: accountIds
                                    AND Type__c != 'Redemption'
                                    AND End_Date__c <= TODAY
                                    GROUP BY Account__c])
        {
            Map<String, Integer> balances = new Map<String, Integer> {
                'Accruals' => Integer.valueOf(ar.get('Accruals'))
            };

            accountBalances.put(Id.valueOf(String.valueOf(ar.get('Account__c'))), balances);
        }

        // Total Redemptions
        for (AggregateResult ar : [SELECT
                                    Account__c,
                                    SUM(Points__c) Redemptions
                                    FROM FlexPoints_Transactions__c
                                    WHERE Account__c IN: accountIds
                                    AND Type__c = 'Redemption'
                                    GROUP BY Account__c])
        {
            Id accountId = Id.valueOf(String.valueOf(ar.get('Account__c')));

            if (accountBalances.containsKey(accountId)) {
                Map<String, Integer> balances = accountBalances.get(accountId);
                balances.put('Redemptions', Integer.valueOf(ar.get('Redemptions')));
            }
        }

        // List of expiry transactions
        List<FlexPoints_Transactions__c> toInsert = new List<FlexPoints_Transactions__c>();

        for (Id accountId : accountBalances.keySet())
        {
            Map<String, Integer> balances = accountBalances.get(accountId);
            Integer accruals = balances.get('Accruals');
            Integer redemptions = balances.get('Redemptions') != null ? balances.get('Redemptions') : 0;

            // Calculate expiry points for account
            if (redemptions < accruals) {
                FlexPoints_Transactions__c flexPointTransaction = new FlexPoints_Transactions__c(
                    Account__c = accountId,
                    Points__c = accruals - redemptions,
                    Type__c = 'Redemption',
                    Expired__c = true
                );

                toInsert.add(flexPointTransaction);
            }
        }

        if (!toInsert.isEmpty()) {
            insert toInsert;
        }
    }
}