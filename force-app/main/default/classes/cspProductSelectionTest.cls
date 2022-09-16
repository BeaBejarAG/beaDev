@isTest(SeeAllData=false)
public with sharing class cspProductSelectionTest {
    @isTest
    private static void testGetProductList()
    {
        ProductRouting__c routing = new ProductRouting__c();
        routing.Related_Product_Range__c = 'Access Approve';
        routing.Visibility__c = 'Public';
        routing.Product_Division__c = 'No Primary Division';
        insert routing;

        Test.startTest();
            List<Map<String, String>> resultList = cspProductSelection.getProductList(null);
        Test.stopTest();
        System.assertEquals(1, resultList.size(), resultList);
    }

    @isTest
    private static void testGetProductListByEntitlement() {

        User portalAccountOwner1 = TestUtilities.createUser('Support Admin', 'System Administrator', 'test123');
        System.runAs(portalAccountOwner1) {
            //Create account
            Account portalAccount1 = new Account(Name = 'TestAccount', OwnerId = portalAccountOwner1.Id);
            insert portalAccount1;

            // Create product routing for allowing access to Access Approve in the portal
            ProductRouting__c routing = new ProductRouting__c();
            routing.Related_Product_Range__c = 'Access Approve';
            routing.Visibility__c = 'Public';
            routing.Product_Division__c = 'No Primary Division';
            insert routing;

            // Create entitlement to link account and product
            Entitlement ent = new Entitlement(Name = 'TestingEntitlement',
                                                AccountId = portalAccount1.Id,
                                                StartDate= Date.valueof(System.now().addDays(-2)),
                                                EndDate = Date.valueof(System.now().addYears(2)),
                                                AssociatedProductRange__c = 'Access Approve');
            insert ent;
            //Create contact
            Contact contact1 = new Contact(FirstName = 'Test',
                                            Lastname = 'McTesty',
                                            AccountId = portalAccount1.Id,
                                            Email = System.now().millisecond() + 'test@test.com');
            insert contact1;

            // Create contact entitlement for a product
            ContactEntitlement__c cEnt = new ContactEntitlement__c(Real_Entitlement__c = ent.Id,
                                                                    Contact__c = contact1.Id);
            insert cEnt;

            //Create our portal user
            User user1 = TestUtilities.createPortalUser('Customer Portal - Support User', contact1.Id, 'test123p');
        }

        User u = [select Id, email, ContactId from User where alias = 'test123p'];
        System.runAs(u) {
            Id accountId = [SELECT Id FROM Account WHERE Name = 'TestAccount'].Id;
            Test.startTest();
                List<Map<String, String>> resultList = cspProductSelection.getProductList(String.valueOf(accountId));
                List<String> flatResultList = cspProductSelection.getFlatProductList(String.valueOf(accountId));
                Map<String, String> singleResult = cspProductSelection.getProduct('Access Approve', String.valueOf(accountId));
            Test.stopTest();
            System.assert( resultList.size() == 1 );
            System.assert( flatResultList.size() == 1 );
            System.assert( singleResult != null );
        }
    }
    
    @isTest
    private static void testGetContactEntitlements() {

        User portalAccountOwner1 = TestUtilities.createUser('Support Admin', 'System Administrator', 'test123');

        System.runAs(portalAccountOwner1) {
            //Create account
            Account portalAccount1 = new Account(Name = 'TestAccount', OwnerId = portalAccountOwner1.Id);
            insert portalAccount1;

            // Create product routing for allowing access to Access Approve in the portal
            ProductRouting__c routing = new ProductRouting__c();
            routing.Related_Product_Range__c = 'Access Approve';
            routing.Visibility__c = 'Public';
            routing.Product_Division__c = 'No Primary Division';
            insert routing;

            // Create entitlement to link account and product
            Entitlement ent = new Entitlement(Name = 'TestingEntitlement',
                                                AccountId = portalAccount1.Id,
                                                StartDate= Date.valueof(System.now().addDays(-2)),
                                                EndDate = Date.valueof(System.now().addYears(2)),
                                                AssociatedProductRange__c = 'Access Approve');
            insert ent;
            //Create contact
            Contact contact1 = new Contact(FirstName = 'Test',
                                            Lastname = 'McTesty',
                                            AccountId = portalAccount1.Id,
                                            Email = System.now().millisecond() + 'test@test.com');
            insert contact1;

            // Create contact entitlement for a product
            ContactEntitlement__c cEnt = new ContactEntitlement__c(Real_Entitlement__c = ent.Id,
                                                                    Contact__c = contact1.Id);
            insert cEnt;

            //Create our portal user
            User user1 = TestUtilities.createPortalUser('Customer Portal - Support User', contact1.Id, 'test123p');
        }

        User u = [select Id, email, ContactId from User where alias = 'test123'];
        System.runAs(u) {
            Id accountId = [SELECT Id FROM Account WHERE Name = 'TestAccount'].Id;
            Id contactId = [SELECT Id FROM Contact WHERE FirstName = 'Test'].Id;
            Test.startTest();
            List<ContactEntitlement__c> contactEntitlements = cspProductSelection.getContactEntitlements(String.valueOf(accountId), String.valueOf(contactId));
            Test.stopTest();
            System.assert( contactEntitlements.size() == 1 );
        }
    }

    @isTest
    private static void testGetEmptyProductListForNonMatchingEntitlement() {

        User portalAccountOwner1 = TestUtilities.createUser('Support Admin', 'System Administrator', 'test123');

        System.runAs(portalAccountOwner1) {
            //Create account
            Account portalAccount1 = new Account(Name = 'TestAccount', OwnerId = portalAccountOwner1.Id);
            insert portalAccount1;

            Contact contact1 = new Contact(FirstName = 'Test',
                                            Lastname = 'McTesty',
                                            AccountId = portalAccount1.Id,
                                            Email = System.now().millisecond() + 'test@test.com');
            insert contact1;

            //Create our portal user
            User user1 = TestUtilities.createPortalUser('Customer Portal - Support User', contact1.Id, 'test123p');
        }

        User u = [select Id, email, ContactId from User where alias = 'test123'];
        System.runAs(u) {
            Id accountId = [SELECT Id FROM Account WHERE Name = 'TestAccount'].Id;
            Test.startTest();
                List<Map<String, String>> resultList = cspProductSelection.getProductList(String.valueOf(accountId));
            Test.stopTest();
            System.assert( resultList.size() == 0);
        }
    }
}