@isTest
private class cspPointsExpiryHandlerTest {

    @TestSetup
    static void setUp(){
        // Account
        Account account = new Account(Name = 'Test Account');
        insert account;

        // Transactions
        insert new List<FlexPoints_Transactions__c> {
            // Accrual - end date in the future
            new FlexPoints_Transactions__c(Account__c = account.Id, Type__c = 'Manual', Transaction_Status__c = 'Confirmed', Points__c = 200, End_Date__c = DateTime.now().date().addDays(1)),
            // Accrual - end date in the past
            new FlexPoints_Transactions__c(Account__c = account.Id, Type__c = 'Manual', Transaction_Status__c = 'Confirmed', Points__c = 100, End_Date__c = DateTime.now().date().addDays(-1)),
            // Accrual - end date today
            new FlexPoints_Transactions__c(Account__c = account.Id, Type__c = 'Manual', Transaction_Status__c = 'Confirmed', Points__c = 50, End_Date__c = DateTime.now().date())
        };
    }

    @isTest
    private static void itShouldCreateAnExpiryTransactionWithNoRedemptions() {
        // Given we have an account with transactions
        // And a transaction ends today
        Account account = [SELECT Id FROM Account WHERE Name = 'Test Account'];

        // When the calculate points expiry method is invoked
        cspPointsExpiryHandler.calculatePointsExpiry(new List<Id> { account.Id });

        // Then I expect a transaction to be created of type redemption, status expired and points value 100
        FlexPoints_Transactions__c flexPointTransaction = [SELECT Points__c FROM FlexPoints_Transactions__c WHERE Type__c = 'Redemption' AND Expired__c = true];
        System.assertEquals(150, flexPointTransaction.Points__c);
    }

    @isTest
    private static void itShouldCreateAnExpiryTransactionWithRedemptions() {
        // Given we have an account with transactions
        // And a transaction ends today
        Account account = [SELECT Id FROM Account WHERE Name = 'Test Account'];

        // Transactions
        insert new List<FlexPoints_Transactions__c> {
            // Redemption
            new FlexPoints_Transactions__c(Account__c = account.Id, Type__c = 'Redemption', Transaction_Status__c = 'Redeemed', Points__c = 50)
        };

        // When the calculate points expiry method is invoked
        cspPointsExpiryHandler.calculatePointsExpiry(new List<Id> { account.Id });

        // Then I expect a transaction to be created of type redemption, status expired and points value 100
        FlexPoints_Transactions__c flexPointTransaction = [SELECT Points__c FROM FlexPoints_Transactions__c WHERE Type__c = 'Redemption' AND Expired__c = true];
        System.assertEquals(100, flexPointTransaction.Points__c);
    }
}