@isTest
private class cspPointsCommencementHandlerTest {

    @TestSetup
    static void setUp(){
        // Account
        Account account = new Account(Name = 'Test Account');
        insert account;

        // Transactions
        insert new List<FlexPoints_Transactions__c> {
            new FlexPoints_Transactions__c(Account__c = account.Id, Type__c = 'Redemption', Transaction_Status__c = 'Redeemed', Points__c = 50),
            new FlexPoints_Transactions__c(Account__c = account.Id, Type__c = 'Manual', Transaction_Status__c = 'Confirmed', Points__c = 200, Start_Date__c = Date.today()),
            new FlexPoints_Transactions__c(Account__c = account.Id, Type__c = 'Manual', Transaction_Status__c = 'Confirmed', Points__c = 100, Start_Date__c = Date.today()),
            new FlexPoints_Transactions__c(Account__c = account.Id, Type__c = 'Manual', Transaction_Status__c = 'Confirmed', Points__c = 50, Start_Date__c = Date.today())
        };
    }

    @isTest
    private static void itShouldUpdateTransactionsField() {
        List<FlexPoints_Transactions__c> transactions = [SELECT Id FROM FlexPoints_Transactions__c];

        List<Id> ids = new List<Id>();
        for (FlexPoints_Transactions__c flex: transactions) {
            ids.add(flex.Id);
        }

        // When the calculate transactions have started method is invoked
        cspPointsCommencementHandler.calculatePointsStarted(ids);

        // Then I expect 4 transactions to be returned with the started field set to true
        List<FlexPoints_Transactions__c> flexPointTransactions = [SELECT Points__c FROM FlexPoints_Transactions__c WHERE Started__c = true];
        System.assertEquals(4, flexPointTransactions.size());
    }
}