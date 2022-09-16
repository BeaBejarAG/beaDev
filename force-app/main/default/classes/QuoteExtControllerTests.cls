@isTest
private class QuoteExtControllerTests {
    
    testMethod static void testSubmit() {
                        Account acc=new Account(Name='Test Acc',Type='Prospect',billingstreet='Street 123',billingcity ='new york',billingPostalCode='442401',billingCountry='United States');  
        {
        insert acc;
        }
        
        SBQQ__Quote__c quote = new SBQQ__Quote__c(SBQQ__Account__c=acc.id);
        insert quote;
        
        Test.startTest();
        QuoteExtController con = new QuoteExtController(new ApexPages.StandardController(quote));
        con.onSubmit();
        quote = [SELECT ApprovalStatus__c FROM SBQQ__Quote__c WHERE Id = :quote.Id LIMIT 1];
        Test.stopTest();
        
        System.assertEquals('Approved', quote.ApprovalStatus__c);
    }
    
    testMethod static void testRecall() {
                                Account acc=new Account(Name='Test Acc',Type='Prospect',billingstreet='Street 123',billingcity ='new york',billingPostalCode='442401',billingCountry='United States');  
        {
        insert acc;
        }
        SBQQ__Quote__c quote = new SBQQ__Quote__c(SBQQ__Account__c=acc.id);
        insert quote;
        
        Test.startTest();
        QuoteExtController con = new QuoteExtController(new ApexPages.StandardController(quote));
        con.onRecall();
        quote = [SELECT ApprovalStatus__c FROM SBQQ__Quote__c WHERE Id = :quote.Id LIMIT 1];
        Test.stopTest();
        
        System.assertEquals('Recalled', quote.ApprovalStatus__c);
    }
}