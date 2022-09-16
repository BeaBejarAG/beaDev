@isTest
public with sharing class cspServiceCatalogueEntryHandlerTest {
    @isTest
    public static void getServiceCatalogueEntry() {

        User portalAccountOwner1 = TestUtilities.createUser('Support Admin', 'System Administrator', 'test123');

        System.runAs(portalAccountOwner1) {
            // Create account
    		Account portalAccount1 = new Account(Name = 'TestAccount', OwnerId = portalAccountOwner1.Id);
    		insert portalAccount1;

            //Create contact
			Contact contact1 = new Contact(FirstName = 'Test', 
            Lastname = 'McTesty', 
            AccountId = portalAccount1.Id, 
            Email = System.now().millisecond() + 'test@test.com');

            insert contact1;
            //Create our portal user
            User user1 = TestUtilities.createPortalUser('Customer Portal - Support User', contact1.Id, 'test123p');

        }
        Account a = [SELECT Id FROM Account WHERE Name = 'TestAccount'];
        User u = [SELECT Id, email, ContactId FROM User WHERE alias = 'test123' LIMIT 1];
        System.runAs(u) {
            Service_Catalogues__c serviceCatalogueEntry = new Service_Catalogues__c();
            serviceCatalogueEntry.Service_Description__c = 'Entry Description';
            serviceCatalogueEntry.Points_Conversion__c = 10000;
            serviceCatalogueEntry.Service_Title__c = 'Catalogue Entry';
            serviceCatalogueEntry.Account_Journey_Stage__c = 'Applicable to all';
            serviceCatalogueEntry.Delivered_By__c = 'Professional Services';
            serviceCatalogueEntry.Delivery_Type__c = 'Bite Size';
            serviceCatalogueEntry.Location__c = 'Remote';
            serviceCatalogueEntry.Products__c = 'Access Approve';
            serviceCatalogueEntry.Region__c = 'Asia';
            serviceCatalogueEntry.Service_Type__c = 'Integrations';
            serviceCatalogueEntry.User_Level__c = 'Beginner';

            insert serviceCatalogueEntry;

            Test.startTest();
            List<Service_Catalogues__c> catalogueEntries =  cspServiceCatalogueEntryHandler.getServiceCatalogueEntries(a.Id, '', 4, 0, false, '', '', '', '', '', '', false);
            Test.stopTest();

            System.assertEquals(0, catalogueEntries.size());
        }
    }

    @isTest
    public static void getServiceCatalogueEntryWithProduct() {

        User portalAccountOwner1 = TestUtilities.createUser('Support Admin', 'System Administrator', 'test123');

        System.runAs(portalAccountOwner1) {
            // Create account
    		Account portalAccount1 = new Account(Name = 'TestAccount', OwnerId = portalAccountOwner1.Id);
    		insert portalAccount1;

            //Create contact
			Contact contact1 = new Contact(FirstName = 'Test', 
            Lastname = 'McTesty', 
            AccountId = portalAccount1.Id, 
            Email = System.now().millisecond() + 'test@test.com');

            insert contact1;
            //Create our portal user
            User user1 = TestUtilities.createPortalUser('Customer Portal - Support User', contact1.Id, 'test123p');
        }
        Account a = [SELECT Id FROM Account WHERE Name = 'TestAccount'];
        User u = [SELECT Id, email, ContactId FROM User WHERE alias = 'test123p' LIMIT 1];
        System.runAs(u) {
            Service_Catalogues__c serviceCatalogueEntry = new Service_Catalogues__c();
            serviceCatalogueEntry.Service_Description__c = 'Entry Description';
            serviceCatalogueEntry.Points_Conversion__c = 10000;
            serviceCatalogueEntry.Service_Title__c = 'Catalogue Entry';
            serviceCatalogueEntry.Account_Journey_Stage__c = 'Applicable to all';
            serviceCatalogueEntry.Delivered_By__c = 'Professional Services';
            serviceCatalogueEntry.Delivery_Type__c = 'Bite Size';
            serviceCatalogueEntry.Location__c = 'Remote';
            serviceCatalogueEntry.Products__c = 'Access Applause';
            serviceCatalogueEntry.Region__c = 'Asia';
            serviceCatalogueEntry.Service_Type__c = 'Integrations';
            serviceCatalogueEntry.User_Level__c = 'Beginner';

            Service_Catalogues__c serviceCatalogueEntryWithProduct = new Service_Catalogues__c();
            serviceCatalogueEntryWithProduct.Service_Description__c = 'Entry Description For Product Object';
            serviceCatalogueEntryWithProduct.Points_Conversion__c = 30000;
            serviceCatalogueEntryWithProduct.Service_Title__c = 'Catalogue Entry For Product Object';
            serviceCatalogueEntryWithProduct.Products__c = 'Access Approve';
            serviceCatalogueEntryWithProduct.Account_Journey_Stage__c = 'Applicable to all';
            serviceCatalogueEntryWithProduct.Delivered_By__c = 'Professional Services';
            serviceCatalogueEntryWithProduct.Delivery_Type__c = 'Bite Size';
            serviceCatalogueEntryWithProduct.Location__c = 'Remote';
            serviceCatalogueEntryWithProduct.Region__c = 'Asia';
            serviceCatalogueEntryWithProduct.Service_Type__c = 'Integrations';
            serviceCatalogueEntryWithProduct.User_Level__c = 'Beginner';

            insert serviceCatalogueEntry;
            insert serviceCatalogueEntryWithProduct;

            Test.startTest();
            List<Service_Catalogues__c> catalogueEntries =  cspServiceCatalogueEntryHandler.getServiceCatalogueEntries(a.Id, 'Access Approve', 4, 0, false, 'Integrations', 'Beginner', 'Applicable to all', 'Bite Size', 'Professional Services', 'Remote', false);
            Test.stopTest();

            System.assertEquals(1, catalogueEntries.size());
            Service_Catalogues__c result = catalogueEntries[0];
            System.assertEquals(serviceCatalogueEntryWithProduct.Service_Description__c, result.Service_Description__c);
            System.assertEquals(serviceCatalogueEntryWithProduct.Points_Conversion__c, result.Points_Conversion__c);
            System.assertEquals(serviceCatalogueEntryWithProduct.Service_Title__c, result.Service_Title__c);
        }
    }

    @isTest
    public static void getServiceCatalogue() {

        User portalAccountOwner1 = TestUtilities.createUser('Support Admin', 'System Administrator', 'test123');

        Account portalAccount1 = new Account(Name = 'TestAccount', OwnerId = portalAccountOwner1.Id);

        System.runAs(portalAccountOwner1) {
            //Create account
            insert portalAccount1;

            // Create product routing for allowing access to Access Approve in the portal
            ProductRouting__c routing = new ProductRouting__c();
            routing.Related_Product_Range__c = 'Access Approve';
            routing.Visibility__c = 'Public';
            routing.Product_Division__c = 'No Primary Division';
            insert routing;
            // Create product routing for allowing access to Access Approve in the portal
            ProductRouting__c routing2 = new ProductRouting__c();
            routing2.Related_Product_Range__c = 'Dimensions';
            routing2.Visibility__c = 'Public';
            routing2.Product_Division__c = 'No Primary Division';
            insert routing2;

            // Create entitlement for case creation
            Entitlement ent = new Entitlement(Name = 'TestingEntitlement', 
                                                AccountId = portalAccount1.Id, 
                                                StartDate= Date.valueof(System.now().addDays(-2)), 
                                                EndDate = Date.valueof(System.now().addYears(2)),
                                                AssociatedProductRange__c = 'Access Approve');
            insert ent;

            // Create another entitlement which we won't use
            Entitlement ent2 = new Entitlement(Name = 'TestingEntitlement2', 
                                                AccountId = portalAccount1.Id, 
                                                StartDate= Date.valueof(System.now().addDays(-2)), 
                                                EndDate = Date.valueof(System.now().addYears(2)),
                                                AssociatedProductRange__c = 'Dimensions');
            insert ent2;

            //Create contact
            Contact contact1 = new Contact(FirstName = 'Test', 
                                            Lastname = 'McTesty', 
                                            AccountId = portalAccount1.Id, 
                                            Email = System.now().millisecond() + 'test@test.com');
            insert contact1;

            // Create contact entitlement for a product - note only one here, no contact entitlement for Dimensions
            ContactEntitlement__c cEnt = new ContactEntitlement__c(Real_Entitlement__c = ent.Id,
                                                                    Contact__c = contact1.Id);
            insert cEnt;

            //Create our portal user
            User user1 = TestUtilities.createPortalUser('Customer Portal - Support User', contact1.Id, 'test123p');
        }

        User u = [select Id, email, ContactId from User where alias = 'test123p'];

        System.runAs(u) {
            Service_Catalogues__c serviceCatalogueEntry = new Service_Catalogues__c();
            serviceCatalogueEntry.Service_Description__c = 'Entry Description';
            serviceCatalogueEntry.Points_Conversion__c = 10000;
            serviceCatalogueEntry.Service_Title__c = 'Catalogue Entry';
            serviceCatalogueEntry.Account_Journey_Stage__c = 'Applicable to all';
            serviceCatalogueEntry.Delivered_By__c = 'Professional Services';
            serviceCatalogueEntry.Delivery_Type__c = 'Bite Size';
            serviceCatalogueEntry.Location__c = 'Remote';
            serviceCatalogueEntry.Products__c = 'Access Approve';
            serviceCatalogueEntry.Region__c = 'Asia';
            serviceCatalogueEntry.Service_Type__c = 'Integrations';
            serviceCatalogueEntry.User_Level__c = 'Beginner';

            insert serviceCatalogueEntry;

            Service_Catalogues__c servCat = cspServiceCatalogueEntryHandler.getServiceCatalogue(String.valueOf(serviceCatalogueEntry.Id));
            System.assert( servCat != NULL);
        }
    }

    @isTest
    public static void getRelatedProduct() {

        User portalAccountOwner1 = TestUtilities.createUser('Support Admin', 'System Administrator', 'test123');

        Account portalAccount1 = new Account(Name = 'TestAccount', OwnerId = portalAccountOwner1.Id);

        System.runAs(portalAccountOwner1) {
            //Create account
            insert portalAccount1;

            // Create product routing for allowing access to Access Approve in the portal
            ProductRouting__c routing = new ProductRouting__c();
            routing.Related_Product_Range__c = 'Access Approve';
            routing.Visibility__c = 'Public';
            routing.Product_Division__c = 'No Primary Division';
            insert routing;
            // Create product routing for allowing access to Access Approve in the portal
            ProductRouting__c routing2 = new ProductRouting__c();
            routing2.Related_Product_Range__c = 'Dimensions';
            routing2.Visibility__c = 'Public';
            routing2.Product_Division__c = 'No Primary Division';
            insert routing2;

            // Create entitlement for case creation
            Entitlement ent = new Entitlement(Name = 'TestingEntitlement', 
                                                AccountId = portalAccount1.Id, 
                                                StartDate= Date.valueof(System.now().addDays(-2)), 
                                                EndDate = Date.valueof(System.now().addYears(2)),
                                                AssociatedProductRange__c = 'Access Approve');
            insert ent;

            // Create another entitlement which we won't use
            Entitlement ent2 = new Entitlement(Name = 'TestingEntitlement2', 
                                                AccountId = portalAccount1.Id, 
                                                StartDate= Date.valueof(System.now().addDays(-2)), 
                                                EndDate = Date.valueof(System.now().addYears(2)),
                                                AssociatedProductRange__c = 'Dimensions');
            insert ent2;

            //Create contact
            Contact contact1 = new Contact(FirstName = 'Test', 
                                            Lastname = 'McTesty', 
                                            AccountId = portalAccount1.Id, 
                                            Email = System.now().millisecond() + 'test@test.com');
            insert contact1;

            // Create contact entitlement for a product - note only one here, no contact entitlement for Dimensions
            ContactEntitlement__c cEnt = new ContactEntitlement__c(Real_Entitlement__c = ent.Id,
                                                                    Contact__c = contact1.Id);
            insert cEnt;

            //Create our portal user
            User user1 = TestUtilities.createPortalUser('Customer Portal - Support User', contact1.Id, 'test123p');
        }

        User u = [select Id, email, ContactId from User where alias = 'test123'];

        System.runAs(u) {
            Service_Catalogues__c serviceCatalogueEntry = new Service_Catalogues__c();
            serviceCatalogueEntry.Service_Description__c = 'Entry Description';
            serviceCatalogueEntry.Points_Conversion__c = 10000;
            serviceCatalogueEntry.Service_Title__c = 'Catalogue Entry';
            serviceCatalogueEntry.Account_Journey_Stage__c = 'Applicable to all';
            serviceCatalogueEntry.Delivered_By__c = 'Professional Services';
            serviceCatalogueEntry.Delivery_Type__c = 'Bite Size';
            serviceCatalogueEntry.Location__c = 'Remote';
            serviceCatalogueEntry.Products__c = 'Access Approve';
            serviceCatalogueEntry.Region__c = 'Asia';
            serviceCatalogueEntry.Service_Type__c = 'Integrations';
            serviceCatalogueEntry.User_Level__c = 'Beginner';

            insert serviceCatalogueEntry;

            Map<String, String> product = cspServiceCatalogueEntryHandler.getRelatedProduct(String.valueOf(serviceCatalogueEntry.Id), String.valueOf(portalAccount1.Id));
            List<Map<String,String>> productList = new List<Map<String,String>>();
            productList.add(product);
            System.assert( productList.size() == 1 );
        }
    }

}