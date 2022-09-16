/**
 * Class containing tests for OpportunityExtension
 */

@isTest public with sharing class OpportunityExtensionTest {
    /*
     * @description:This is a test method
     * @Return:Void
    */
    @isTest
    static void errorVerification() {
        
        Account acc=new Account(Name='Test Acc',Type='Prospect',billingstreet='Street 123',billingcity ='new york',billingPostalCode='442401',billingCountry='United States');  
        insert acc;
            
        Contact thisContact = new Contact(
            FirstName = 'Chris',
            LastName = 'Lewis',
            Email = 'Chris.Lewis@accountech.co.uk',
            Phone = '01234567890'
        );
        insert thisContact;
 
        /*Related Quote setup*/
        SBQQ__Quote__c  qt = new SBQQ__Quote__c ();
        qt.SBQQ__CustomerDiscount__c = 10;
        qt.SBQQ__Primary__c = true;
        qt.CPQ_Services_Discount__c=5;
        qt.CPQ_Software_Discount__c = 4;
        qt.SBQQ__PaymentTerms__c = 'Net 30';
        qt.SBQQ__Account__c=acc.id;
        insert qt;

        /*Opportunity setup*/
        Opportunity opp = new Opportunity();
        opp.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('CPQ Sales Accepted').getRecordTypeId();
        opp.SBQQ__PrimaryQuote__c = qt.Id;
        opp.Contract_Start_Date__c = Date.today(); 
        opp.Primary_Contact__c = thisContact.Id;
        String CloseReason='TestCloseReason';
        opp.Close_Reason__c = CloseReason;
        String OppName='testName';
        opp.Name = OppName;
        opp.StageName = 'Order Proccessing';
        opp.CloseDate = Date.today()+5;
        String Descp='testDescription';
        opp.SOW_Description__c = Descp;
        insert opp;
        qt.SBQQ__Opportunity2__c = opp.Id;
        update qt;

        /*Pre execution page setup*/
        ApexPages.StandardController sc = new ApexPages.StandardController(opp);
        OpportunityExtension oppExt = new OpportunityExtension(sc);
        PageReference pageRef = Page.OrderSummary;
        pageRef.getParameters().put('id', String.valueOf(opp.Id));

        Test.setCurrentPage(pageRef);
        Test.startTest();
        try {
          oppExt.submit();
        } 
        catch (DmlException e){
         System.assert( e.getMessage().contains('Please enter values of all the fields before submitting.'), e.getMessage() );
        }
        Test.stopTest();
    }

    /*
     * @description:This is a test method
     * @Return:Void
    */
    @isTest
    static void recordSuccessfulUpdate() 
    { 
        
        User userWithCustomPermission1=CreateUserData();
        Id oppId=CreateTestData(userWithCustomPermission1);
        
        /*Pre execution page setup*/
        
        Opportunity opp = [SELECT 
        Total_ABC__c,
        Total_SAAS__c,
        Total_Services__c,
        Total_Variable__c,
        SBQQ__PrimaryQuote__r.SBQQ__PaymentTerms__c,
        SBQQ__PrimaryQuote__r.SBQQ__SubscriptionTerm__c,
        SBQQ__PrimaryQuote__r.SBQQ__StartDate__c,
        Close_Reason__c,
        Competitior_Lost_To__c,
        Competitor_Product_Lost_To__c,
        CPQ_Opportunity_Deal_Type__c,
        SOW_Description__c
        FROM Opportunity WHERE id=:oppId];

        PageReference pageRef = Page.OrderSummary;
        pageRef.getParameters().put('id', String.valueOf(opp.Id));
        ApexPages.StandardController sc = new ApexPages.StandardController(opp);
        OpportunityExtension oppExt = new OpportunityExtension(sc);

        Test.setCurrentPage(pageRef);
        Test.startTest();
        
        oppExt.submit();
        
        Test.stopTest();

        opp = [SELECT Id  FROM Opportunity WHERE id=:opp.id];
        System.assertEquals(opp.id,opp.id);
    }
    /*
     * @description:This is a test data setup method.This method is used to create the User record.
     * @Return:User Record
    */
    static User CreateUserData()
    {
        Profile p = [select id from Profile where name='System Administrator']; 
        
        User userWithCustomPermission = new user(alias = 'test123', email='test123@noemail.com', Title = 'Mr',
                                    emailencodingkey='UTF-8', firstName='AccessOrg', lastname='Testing', languagelocalekey='en_US',
                                    localesidkey='en_IN', profileid = p.Id, country='India',
                                    timezonesidkey='Asia/Kolkata', username='AccessOrdTestUser@test.com'); 
        
        
          System.runAs(new User(Id = UserInfo.getUserId())) 
          {
             insert userWithCustomPermission;
        
          //    Given user w/permissions
          PermissionSet ps = new PermissionSet(Label = 'mockPs', Name = 'mockPs');
          insert ps;
        
          // Given custom permission associated to the mocked PermissionSet
          SetupEntityAccess sea = new SetupEntityAccess(
                    ParentId = ps.Id,
                    SetupEntityId = [SELECT Id FROM CustomPermission
                    WHERE DeveloperName = 'Account_Admin'][0].Id
            );
          insert sea;
        
          // Given mocked Permission Set assigned to user for test
          PermissionSetAssignment psa = new PermissionSetAssignment(AssigneeId = userWithCustomPermission.Id,PermissionSetId = ps.Id);
          insert psa;
        }
     return userWithCustomPermission;

    }
    
    /*
     * @description:This is a test data setup method.This method is used to create Account,Contact,Opportunity,Quote records etc.
     * @return:Id
    */
    
    static Id CreateTestData(User userWithCustomPermission1)
    {
        
        Account competitorAcc = new Account(Name='competitorAccount', Type='Competitor');
        System.runAs(userWithCustomPermission1) 
        {
        insert competitorAcc;
        }
        
        Competitor_Product__c competitorProduct = new Competitor_Product__c(Competitor_Account__c=competitorAcc.Id);
        insert competitorProduct;
        
        Account acc=new Account(Name='Test Acc',Type='Prospect',billingstreet='Street 123',billingcity ='new york',billingPostalCode='442401',billingCountry='United States');  
        System.runAs(userWithCustomPermission1) 
        {
        insert acc;
        }
        
        String ConName='TestLastName';
        Contact con=new Contact(Lastname=ConName,MobilePhone='1234567890',Phone='1234567890',Email='test@test.com',AccountId=acc.Id,mailingstreet='Street 123',mailingPostalCode='442401',mailingCountry='United States');
        insert con;
        
        /*Related Quote setup*/
        SBQQ__Quote__c  qt = new SBQQ__Quote__c();
        qt.SBQQ__Primary__c = true;
        qt.SBQQ__SubscriptionTerm__c = 36;
        qt.CPQ_Services_Discount__c= 5;
        qt.CPQ_Software_Discount__c = 4;
        qt.SBQQ__StartDate__c = Date.today();
        qt.SBQQ__PaymentTerms__c = 'Net 30';
        qt.CPQ_Deal_Type__c='Upsell';
        qt.SBQQ__Account__c=acc.id;
        insert qt;

        /*Opportunity setup*/
        Opportunity opp = new Opportunity();
        opp.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('CPQ Sales Accepted').getRecordTypeId();
        opp.SBQQ__PrimaryQuote__c = qt.Id;
        opp.Contract_Start_Date__c = Date.today(); 
        opp.Close_Reason__c = 'References';
        String OName='testName';
        opp.Name =OName;
        opp.StageName = 'Contacted';
        opp.CloseDate = Date.today()+5;
        opp.AccountId=acc.id;
        opp.Primary_Contact__c=con.id;
        opp.Competitior_Lost_To__c = competitorAcc.Id;
        opp.Competitor_Product_Lost_To__c = competitorProduct.Id; 
        //////////////////////////////////////////////////////////////
        opp.Discount_Approver_Name__c=UserInfo.getUserId() ;
        opp.New_Business__c=false; 
        opp.Contract_ARR_At_List_Price__c = 1;
        ///////////////////////////////////////////////////////////////
        String OppDescp='testDesc';
        opp.SOW_Description__c = OppDescp;
        insert opp;
        qt.SBQQ__Account__c=acc.id;
        qt.SBQQ__Opportunity2__c = opp.Id;
        update qt;

        /*Dependancies setup*/
        Product2 product = new Product2 (Name = 'Laptop X200', Family = 'Hardware');
        insert product;

        Id pricebookId = Test.getStandardPricebookId();
  
        PricebookEntry standartPricebookEntry = new PricebookEntry (Pricebook2Id = pricebookId, Product2Id = product.Id, UnitPrice = 10000, IsActive = true);
        insert standartPricebookEntry;
        
        system.debug(standartPricebookEntry.Pricebook2Id);
    
        Pricebook2 pricebook = new Pricebook2(Name='Custom Pricebook', isActive=true);
        insert pricebook;
        
        system.debug(pricebook.id);
        //PriceBook2Id is querried because process builder is changing the pricebook in background
        Opportunity tmp = [Select PriceBook2Id from Opportunity Where Id = :opp.id];

        PricebookEntry customPrice = new PricebookEntry(Pricebook2Id = tmp.PriceBook2Id, Product2Id = product.Id, UnitPrice = 12000, IsActive = true);
        insert customPrice;
        
        opp.Pricebook2Id = pricebook.Id;
        update opp;
        
        system.debug(opp.Pricebook2Id);
        system.debug(customPrice.Pricebook2Id);

        /*Line items setup*/
        list<OpportunityLineItem> OppLineItemList=new list<OpportunityLineItem>();
        
        OpportunityLineItem initialsProduct = new OpportunityLineItem (PricebookEntryId = customPrice.Id, Product2Id = product.Id, Quantity = 1, OpportunityId = opp.Id,CPQ_Revenue_Type__c = 'Initial Licences', TotalPrice = 10.00);
        OppLineItemList.add(initialsProduct);
        
        system.debug(initialsProduct.PricebookEntryId);
                
        OpportunityLineItem sAASProduct = new OpportunityLineItem (PricebookEntryId = customPrice.Id, Product2Id = product.Id, Quantity = 1, OpportunityId = opp.Id, CPQ_Revenue_Type__c = 'SAAS', TotalPrice = 10.00);
        OppLineItemList.add(sAASProduct);
        
        OpportunityLineItem servicesProduct = new OpportunityLineItem (PricebookEntryId = customPrice.Id, Product2Id = product.Id, Quantity = 1, OpportunityId = opp.Id,CPQ_Revenue_Type__c = 'Services', TotalPrice = 10.00);
        OppLineItemList.add(servicesProduct);
        
     
        insert OppLineItemList;
        
        return opp.id;
        
    }

}