@isTest(SeeAllData=false)
public with sharing class cspCaseHandlerTest {

    @testSetup static void setup() {
        Knowledge__kav newArticle = TestUtilities.getArticleAsADraft('New title', 'new-url-name' + Crypto.getRandomInteger());
        newArticle.Information_Article_Body__c = 'New article';
        newArticle.IsVisibleInCsp = false;
        newArticle.ValidationStatus = 'Validated';
        newArticle.RecordTypeId = Schema.SObjectType.Knowledge__kav.getRecordTypeInfosByName().get('KCS').getRecordTypeId();

        insert newArticle;
        String articleId = [SELECT KnowledgeArticleId FROM Knowledge__kav WHERE Id =: newArticle.Id].KnowledgeArticleId;
        KbManagement.PublishingService.publishArticle(articleId, true);
    }

    @IsTest Public Static Void RetrieveCases() {
       
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
            // Create product routing for allowing access to Dimensions in the portal
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

            // Create contact entitlement for a product - note only one here, no eontact entitlement for Dimensions
            ContactEntitlement__c cEnt = new ContactEntitlement__c(Real_Entitlement__c = ent.Id,
                                                                    Contact__c = contact1.Id);
            insert cEnt;

            //Create our portal user
            User user1 = TestUtilities.createPortalUser('Customer Portal - Support User', contact1.Id, 'test123p');
        }
        
        User u = [select Id, email, ContactId from User where alias = 'test123'];
        System.runAs(u) {
            Entitlement testEnt = [select Id, name from Entitlement where name = 'TestingEntitlement'];
            Case NewCase = CaseLogFlow.CreateNewCase('Apple1234', 'Pear123', '2', 'Access Approve', testEnt.Id);
            // Second case which we don't have entitlement for:
            Entitlement testEnt2 = [select Id, name from Entitlement where name = 'TestingEntitlement2'];
            Case NewCase2 = CaseLogFlow.CreateNewCase('Apple1234', 'Pear123', '2', 'Dimensions', testEnt2.Id);

            Date tomorrow = Date.today().addDays(2);
            Date yesterday = Date.today().addDays(-2);
            List<Map<String, Object>> cases = cspCaseHandler.getCases('', 10, 0, '', '', false, false, yesterday, tomorrow, false, portalAccount1.Id, true);
            System.assertEquals(2, cases.size());

            List<Map<String, Object>> nocases = cspCaseHandler.getCases('', 10, 0, '', '', false, false, tomorrow, null, false, portalAccount1.Id, true);
            System.assert(nocases.size() == 0);

            nocases = cspCaseHandler.getCases('', 1, 0, '', '', false, false, null, yesterday, false, portalAccount1.Id, true);
            System.assert(nocases.size() == 0);
        }
    }

    @IsTest Public Static Void GetCaseComments() {
        
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

            // Create contact entitlement for a product - note only one here, no eontact entitlement for Dimensions
            ContactEntitlement__c cEnt = new ContactEntitlement__c(Real_Entitlement__c = ent.Id,
                                                                    Contact__c = contact1.Id);
            insert cEnt;

            //Create our portal user
            User user1 = TestUtilities.createPortalUser('Customer Portal - Support User', contact1.Id, 'test123p');
        }
        
        User u = [select Id, email, ContactId from User where alias = 'test123'];
        System.runAs(u) {
            Entitlement testEnt = [select Id, name from Entitlement where name = 'TestingEntitlement'];
            Case NewCase = CaseLogFlow.CreateNewCase('Apple1234', 'Pear123', '2', 'Access Approve', testEnt.Id);

            Date tomorrow = Date.today().addDays(2);
            Date yesterday = Date.today().addDays(-2);
            List<Map<String, Object>> caseComments = cspCaseHandler.getCaseComments(NewCase.Id);
            System.assertEquals(1, caseComments.size());
        }
    }



    @IsTest Public Static Void GetCaseCounts() {

        User portalAccountOwner1 = TestUtilities.createUser('Support Admin', 'System Administrator', 'test123');

        Account portalAccount1 = new Account(Name = 'TestAccount', OwnerId = portalAccountOwner1.Id);
        System.runAs(portalAccountOwner1) {
            //Create account
            insert portalAccount1;
            // Create product routing for allowing access to Access Approve in the portal
            ProductRouting__c routing = new ProductRouting__c();
            routing.Related_Product_Range__c = 'Dimensions';
            routing.Visibility__c = 'Public';
            routing.Product_Division__c = 'No Primary Division';
            insert routing;

            // Create entitlement for case creation
            Entitlement ent = new Entitlement(Name = 'TestingEntitlement', 
                                                AccountId = portalAccount1.Id, 
                                                StartDate= Date.valueof(System.now().addDays(-2)), 
                                                EndDate = Date.valueof(System.now().addYears(2)),
                                                AssociatedProductRange__c = 'Dimensions');
            insert ent;
            //Create contact
            Contact contact1 = new Contact(FirstName = 'Test', 
                                            Lastname = 'McTesty', 
                                            AccountId = portalAccount1.Id, 
                                            Email = System.now().millisecond() + 'test@test.com');
            insert contact1;
            // Create contact entitlement for a product - note only one here, no eontact entitlement for Dimensions
            ContactEntitlement__c cEnt = new ContactEntitlement__c(Real_Entitlement__c = ent.Id,
                                                                    Contact__c = contact1.Id);
            insert cEnt;
            //Create our portal user
            User user1 = TestUtilities.createPortalUser('Customer Portal - Support User', contact1.Id, 'test123p');
            
        }
        
        User u = [select Id, email, ContactId from User where alias = 'test123'];
        System.runAs(u) {
            Entitlement testEnt = [select Id, name from Entitlement where name = 'TestingEntitlement'];
            Case NewCase = CaseLogFlow.CreateNewCase('Apple1234', 'Pear123', '2', 'Dimensions', testEnt.Id);

            Integer allCases = cspCaseHandler.getOpenCases('', true, portalAccount1.Id);
            System.assert(allCases == 1);
            allCases = cspCaseHandler.getOpenCases('Dimensions', true, portalAccount1.Id);
            System.assert(allCases == 1);
            allCases = cspCaseHandler.getOpenCases('Not A Product', true, portalAccount1.Id);
            System.assert(allCases == 0);

            Integer awaitingCases = cspCaseHandler.getAwaitingCustomerCases('', true, portalAccount1.Id);
            System.assert(awaitingCases == 0);
            awaitingCases = cspCaseHandler.getAwaitingCustomerCases('Dimensions', true, portalAccount1.Id);
            System.assert(awaitingCases == 0);
        }
    }

    @IsTest 
    public static void getCaseNumbers() {

        String region = 'Europe';

        // GIVEN We have a Product Routing Record
        ProductRouting__c productRouting = new ProductRouting__c();
        productRouting.Related_Product_Range__c = 'Access Approve';
        productRouting.Visibility__c = 'Public';
        productRouting.Product_Division__c = 'No Primary Division';
        insert productRouting;

        // AND 4 Case Contact Number records joined to the Product Routing Record
        Case_Contact_Number__c caseNumber1 = new Case_Contact_Number__c();
        caseNumber1.Region__c = region;
        caseNumber1.Country__c = 'United Kingdom';
        caseNumber1.Product_Routing__c = productRouting.Id;

        Case_Contact_Number__c caseNumber2 = new Case_Contact_Number__c();
        caseNumber2.Region__c = region;
        caseNumber2.Country__c = 'France';
        caseNumber2.Product_Routing__c = productRouting.Id;

        Case_Contact_Number__c caseNumber3 = new Case_Contact_Number__c();
        caseNumber3.Region__c = region;
        caseNumber3.Country__c = 'Germany';
        caseNumber3.Product_Routing__c = productRouting.Id;

        // this one should not be retrieved
        Case_Contact_Number__c caseNumber4 = new Case_Contact_Number__c();
        caseNumber4.Region__c = 'Africa';
        caseNumber4.Country__c = 'Germany';
        caseNumber4.Product_Routing__c = productRouting.Id;

        insert new List<Case_Contact_Number__c>{caseNumber1, caseNumber2, caseNumber3, caseNumber4};

        // WHEN We run our method to retrieve them via the juction object record, we should get 3 back
        System.Test.startTest();
            List<Case_Contact_Number__c> caseContactNumbers = cspCaseHandler.getCaseContacts(String.valueOf(productRouting.Id), region);
        System.Test.stopTest();

        // THEN we should have 3 associated records returned
        System.assertEquals(3, caseContactNumbers.size());

    }

    @IsTest
    public static void getFlexPointRedemptionCases() {
       
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

            // Create entitlement for case creation
            Entitlement ent = new Entitlement(Name = 'TestingEntitlement', 
                                                AccountId = portalAccount1.Id,
                                                AssociatedProductRange__c = 'Access Approve', 
                                                StartDate= Date.valueof(System.now().addDays(-2)), 
                                                EndDate = Date.valueof(System.now().addYears(2)));
            insert ent;
        }
        Entitlement ent = [SELECT Id FROM Entitlement WHERE Name = 'TestingEntitlement'];
        Account account = [SELECT Id FROM Account WHERE Name = 'TestAccount'];
        Date requestedDate = Date.newInstance(2021, 06, 29);

        User u = [SELECT Id, email, ContactId FROM User WHERE alias = 'test123' LIMIT 1];
        System.runAs(u) {
            Case newCase = new Case(
                Status = 'Pending',
                Description = 'Description',
                Subject = 'Subject',
                Origin = 'Web',
                Priority = '3',
                RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('FlexPoints Redemption').getRecordTypeId(),
                EntitlementId = ent.Id,
                RelatedProduct__c = 'Access Approve',
                Source__c = 'Support',
                CaseType__c = 'Feature request',
                Points_Estimate__c = 200,
                Date_Requested__c = requestedDate,
                Account__c = account.id
            );
            insert newCase;
            Case selectCase = [SELECT CaseNumber, OwnerId FROM Case LIMIT 1];
            List<Map<String, Object>> caseResultsList = cspCaseHandler.getFlexPointRedemptionCases(account.Id, 1, 0);
            Map<String, Object> caseResults = caseResultsList[0];
            String userId = UserInfo.getUserId();
            String owner = selectCase.OwnerId != null ? (selectCase.OwnerId.equals(userId) ? 'Me' : selectCase.Owner.Name) : '';

            String networkName = 'support';
            Map<String, Object> caseMap = new Map<String, Object>{
                'id' => newCase.Id,
                'subject' => newCase.Subject,
                'points' => newCase.Points_Estimate__c,
                'ref' => selectCase.CaseNumber,
                'date' => requestedDate,
                'owner' => owner,
                'status' => newCase.Status,
                'caseId' => newCase.Id
            };

            System.assertEquals(JSON.serialize(caseMap.get('id')), JSON.serialize(caseResults.get('id')));
            System.assertEquals(JSON.serialize(caseMap.get('subject')), JSON.serialize(caseResults.get('subject')));
            System.assertEquals(JSON.serialize(caseMap.get('points')), JSON.serialize(caseResults.get('points')));
            System.assertEquals(JSON.serialize(caseMap.get('ref')), JSON.serialize(caseResults.get('ref')));
            System.assertEquals(JSON.serialize(caseMap.get('date')), JSON.serialize(caseResults.get('date')));
            System.assertEquals(JSON.serialize(caseMap.get('owner')), JSON.serialize(caseResults.get('owner')));
            System.assertEquals(JSON.serialize(caseMap.get('status')), JSON.serialize(caseResults.get('status')));
            System.assertEquals(JSON.serialize(caseMap.get('caseId')), JSON.serialize(caseResults.get('caseId')));
        }
    }



    @IsTest
    public static void getOpenRequestCaseReference() {

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

            // Create entitlement for case creation
            Entitlement ent = new Entitlement(Name = 'TestingEntitlement', 
                                                AccountId = portalAccount1.Id,
                                                AssociatedProductRange__c = 'Access Approve', 
                                                StartDate= Date.valueof(System.now().addDays(-2)), 
                                                EndDate = Date.valueof(System.now().addYears(2)));
            insert ent;
        }
        Entitlement ent = [SELECT Id FROM Entitlement WHERE Name = 'TestingEntitlement'];
        Account account = [SELECT Id FROM Account WHERE Name = 'TestAccount'];
        Date requestedDate = Date.newInstance(2021, 06, 29);

        User u = [SELECT Id, email, ContactId FROM User WHERE alias = 'test123' LIMIT 1];
        System.runAs(u) {
            Case newCase = new Case(
                Status = 'Pending',
                Description = 'Description',
                Subject = 'Subject',
                Origin = 'Web',
                Priority = '3',
                RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('FlexPoints Redemption').getRecordTypeId(),
                EntitlementId = ent.Id,
                RelatedProduct__c = 'Access Approve',
                Source__c = 'Support',
                CaseType__c = 'Feature request',
                Points_Estimate__c = 200,
                Date_Requested__c = requestedDate,
                Account__c = account.id
            );
            insert newCase;
            Case selectCase = [SELECT CaseNumber, OwnerId FROM Case LIMIT 1];

            String caseNumber = cspCaseHandler.getOpenRequestCaseReference(newCase.Id);

            System.assertEquals(selectCase.CaseNumber, caseNumber);
        }
    }

    @IsTest
    public static void createSelfGenCase() {

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
            Boolean result = cspCaseHandler.createSelfGenCase(a.Id);
            Test.stopTest();

            System.assert(result == true);
        }
    }

    @IsTest static void ServiceAccount(){

        account acc = new account(
        name = 'Super Shiny Test'
        );
        insert acc;

        account accre = new account(
            name = 'Super Shiny relationship'
            );
            insert accre;

        contact conn = new Contact(
            firstname = 'Bob',
            LastName = 'Smithers',
            email = 'Bob.Smithers@Email.com',
            accountid = acc.id
        );
        insert conn;

        AccountContactRelation acr = new AccountContactRelation(
            accountid = accre.id,
            contactid = conn.id
        );
        insert acr;

        system.assertEquals(2, cspCaseHandler.GetServiceAccounts(acc.id).size());

    }

    @IsTest static void GetInACases(){

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
            // Create product routing for allowing access to Dimensions in the portal
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
                                            Lastname = 'McTesty1', 
                                            AccountId = portalAccount1.Id, 
                                            Email = System.now().millisecond() + 'test@test.com');
            insert contact1;


            // Create contact entitlement for a product - note only one here, no eontact entitlement for Dimensions
            ContactEntitlement__c cEnt = new ContactEntitlement__c(Real_Entitlement__c = ent.Id,
                                                                    Contact__c = contact1.Id);
            insert cEnt;

            //Create our portal user
            User user1 = TestUtilities.createPortalUser('Customer Portal - Support User', contact1.Id, 'test123p');
        }
        
        User u = [select Id, email, ContactId from User where alias = 'test123'];
        System.runAs(u) {
            Entitlement testEnt = [select Id, name from Entitlement where name = 'TestingEntitlement'];
            Entitlement testEnt2 = [select Id, name from Entitlement where name = 'TestingEntitlement2'];

            Contact contact1 = [SELECT Id FROM Contact WHERE LastName = 'McTesty1' LIMIT 1];
        
            case newInACase = new case();
            case NewProjCase = new case();
            
            newProjCase = new case(
                Status = 'Support Outstanding',
                Description = 'Cake',
                Subject = 'Pear123',
                Origin = 'Web',
                Priority = '2',
                RecordTypeId = Schema.SObjectType.case.getRecordTypeInfosByName().get('Project').getRecordTypeId(),
                RelatedProduct__c = 'Dimensions',
                EntitlementId = testEnt2.Id,   
                Source__c = 'Support',
                CaseType__c = 'Support Issue',
                Account__c = portalAccount1.id,
                ContactId = contact1.Id
            );
            insert newProjCase;            
                        

            newInACase = new case(
                Status = 'Support Outstanding',
                Description = 'Cake',
                Subject = 'Pear123',
                Origin = 'Web',
                Priority = '2',
                Parent_Project__c = newProjCase.id,
                RecordTypeId = Schema.SObjectType.case.getRecordTypeInfosByName().get('Issues and Actions').getRecordTypeId(),
                RelatedProduct__c = 'Dimensions',
                EntitlementId = testEnt2.Id,   
                Source__c = 'Support',
                ContactId = contact1.Id,
                Make_Public__c = true,
                CaseType__c = 'Support Issue'
            );
            insert newInACase;

            Date tomorrow = Date.today().addDays(2);
            Date yesterday = Date.today().addDays(-2);
            
            List<Map<String, Object>> inacases = cspCaseHandler.getInACases('', 10,0,'','',false,yesterday,tomorrow,true,portalAccount1.id,true);
            System.assertEquals(1, inacases.size());

            inacases = cspCaseHandler.getCases('', 10, 0, 'Cake', '', false, false, yesterday, tomorrow, true, portalAccount1.Id, true);
            System.assertEquals(0, inacases.size());
            
            inacases = cspCaseHandler.getCases('', 10, 0, '', 'Open', false, false, yesterday, tomorrow, true, portalAccount1.Id, true);
            System.assertEquals(0, inacases.size());

            inacases = cspCaseHandler.getCases('tucan', 10, 0, '', '', false, false, tomorrow, null, true, portalAccount1.Id, true);
            System.assertEquals(0, inacases.size());

        }

    }
    

    
    @IsTest static void getCasesForProject(){

        account acc = new account(
            name = 'Super Shiny Test'
            );
            insert acc;

        case csd = new case(
            accountid = acc.id,
            subject = 'test',
            description = 'test',
            RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Support').getRecordTypeId()
        );
        insert csd;

        List<Map<String, Object>> caseResults = cspCaseHandler.getCasesForProject(csd.id, 0,0,null,'Open');
        System.assertEquals(0, caseResults.size());
     
    }

    @IsTest static void GetServiceAccounts() {
        
        User portalAccountOwner1 = TestUtilities.createUser('Support Admin', 'System Administrator', 'test123');
        Account portalAccount1 = new Account(Name = 'TestAccount', OwnerId = portalAccountOwner1.Id);

        System.runAs(portalAccountOwner1) {
            //Create account
            insert portalAccount1;
            List<AccountContactRelation> AccountNames = cspCaseHandler.GetServiceAccounts(portalAccount1.Id);
            System.assertEquals(0, AccountNames.size());
        }
    }
}