@isTest(SeeAllData=false)
public with sharing class cspCaseCollaboratorHandlerTest {

    @TestSetup
    static void createCase(){
        
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

            //Create contact
            Contact contact1 = new Contact(FirstName = 'Test', 
                                            Lastname = 'McTesty', 
                                            AccountId = portalAccount1.Id, 
                                            Email = System.now().millisecond() + 'test@test.com');
            insert contact1;

            //Create second contact
            Contact contact2 = new Contact(FirstName = 'Second', 
                                            Lastname = 'Contact', 
                                            AccountId = portalAccount1.Id, 
                                            Email = System.now().millisecond() + 'test@test.com');
            insert contact2;

            // Create contact entitlements for the product
            ContactEntitlement__c cEnt = new ContactEntitlement__c(Real_Entitlement__c = ent.Id,
            Contact__c = contact1.Id);
            insert cEnt;
            ContactEntitlement__c cEnt2 = new ContactEntitlement__c(Real_Entitlement__c = ent.Id,
                                                                    Contact__c = contact2.Id);
            insert cEnt2;

            //Create our portal users
            User user1 = TestUtilities.createPortalUser('Customer Portal - Support User', contact1.Id, 'test123p');

            User user2 = TestUtilities.createPortalUser('Customer Portal - Support User', contact2.Id, 'test456p');

            contact2.Community_User__c = user2.Id;
            update contact2;
        }
        
        User u = [select Id, email, ContactId from User where alias = 'test123p'];
        System.runAs(u) {
            Entitlement testEnt = [select Id, name from Entitlement where name = 'TestingEntitlement'];
            Case NewCase = CaseLogFlow.CreateNewCase('Apple1234', 'Pear123', '2', 'Access Approve', testEnt.Id);
        }
    }

    @IsTest Public Static Void getCaseCollaboratorsTest() {
        // GIVEN case and contact exist
        String caseId = [select Id from Case].Id;
        String contactId = [select Id from Contact where FirstName = 'Test'].Id;

        // AND a collaboration between the two
        Portal_Case_Collaborator__c collaborator = new Portal_Case_Collaborator__c(Case__c = caseId, Contact__c = contactId);
        insert collaborator;

        // WHEN I retrieve collaboration objects for that case
        List<Map<String,Object>> collaborators = cspCaseCollaboratorHandler.getCaseCollaborators(caseId);
        // THEN I should receive the one we created
        System.assertEquals(1, collaborators.size());
    }

    @IsTest Public Static Void validateCollaboratorTest() {
        // GIVEN case and contact exist
        String caseId = [select Id from Case].Id;
        String contactId = [select Id from Contact where FirstName = 'Second'].Id;

        // WHEN I validate the collaboration
        String validationMessage = cspCaseCollaboratorHandler.validateCaseCollaborator(caseId, contactId);
        // THEN there should be no validation error message
        System.assertEquals('', validationMessage);
    }

    @IsTest Public Static Void getPotentialCollaboratorsByCaseTest() {
        // GIVEN case exists
        String caseId = [select Id from Case].Id;

        // WHEN I fetch potential collaborators
        List<Map<String, Object>> collaborators = cspCaseCollaboratorHandler.getPotentialCollaboratorsByCase(caseId);
        // THEN there should be one available collaborator (just the one thaht didn't create the case)
        System.assertEquals(1, collaborators.size());
    }

    @IsTest Public Static Void getPotentialCollaboratorsByAccountAndProductTest() {
        // GIVEN case exists
        String accountId = [select Id from Account LIMIT 1].Id;
        String product = 'Access Approve';

        // Run as the created community user soit matches against their user id when fetching
        User u = [select Id, email, ContactId from User where alias = 'test123p'];
        System.runAs(u) {
            // WHEN I fetch potential collaborators
            List<Map<String, Object>> collaborators = cspCaseCollaboratorHandler.getPotentialCollaborators(accountId, product);
            // THEN there should be one available collaborators (doesn't include the current user)
            System.assertEquals(1, collaborators.size());
        }
    }

    @isTest
    private static void getCaseViewAccess() {
        // GIVEN we have all required data setup
        // Create account
        Account portalAccount1 = new Account(Name = 'TestAccount');
        insert portalAccount1;

        // Create contacts (one for each user/profile)
        Contact contact1 = new Contact(FirstName = 'Test', 
        Lastname = 'McTesty', 
        AccountId = portalAccount1.Id, 
        Email = System.now().millisecond() + 'test@test.com');

        Contact contact2 = new Contact(FirstName = 'Test2', 
        Lastname = 'McTesty2', 
        AccountId = portalAccount1.Id, 
        Email = System.now().millisecond() + 'test2@test.com');

        Contact contact3 = new Contact(FirstName = 'Test3', 
        Lastname = 'McTesty3', 
        AccountId = portalAccount1.Id, 
        Email = System.now().millisecond() + 'test3@test.com');
        insert new List<Contact>{contact1, contact2, contact3};

        // Create our users
        User userSupport = TestUtilities.createPortalUser(cspCaseHandler.SUPPORT_USER_PROFILE_NAME, contact1.Id, 'test123p');

        User userSuper = TestUtilities.createPortalUser(cspCaseHandler.SUPER_USER_PROFILE_NAME, contact2.Id, 'test456p');

        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Support').getRecordTypeId();

        // Created cases to test
        Case contactCase = new Case(
            Subject = 'test1 case',
            ContactId = contact1.Id,
            RecordTypeId = recordTypeId
        );

        Case collabCase = new Case(
            Subject = 'test2 case',
            ContactId = contact2.Id,
            RecordTypeId = recordTypeId
        );

        Case unlinkedCase = new Case(
            Subject = 'test3 case',
            ContactId = contact2.Id,
            RecordTypeId = recordTypeId
        );
        
        insert new List<Case>{contactCase, collabCase, unlinkedCase};

        // Create the junction object for test 2
        Portal_Case_Collaborator__c ccc1 = new Portal_Case_Collaborator__c(
            Contact__c = contact1.Id,
            Case__c = collabCase.Id
        );
        insert ccc1;

        // AND we get the running user ID to mock the 'caseCreatedById' value
        Id contextUserId = UserInfo.getUserId();
        
        // WHEN we get the case access for all scenarios
        Boolean contactCaseResult, collabCaseResult, unlinkedCaseResult, superUserResult;
        System.Test.startTest();
            System.runAs(userSupport) {
                contactCaseResult = cspCaseCollaboratorHandler.isCaseViewable(contactCase.Id, contactCase.ContactId, contextUserId);
                collabCaseResult = cspCaseCollaboratorHandler.isCaseViewable(collabCase.Id, collabCase.ContactId, contextUserId);
                unlinkedCaseResult = cspCaseCollaboratorHandler.isCaseViewable(unlinkedCase.Id, unlinkedCase.ContactId, contextUserId);
            }
            System.runAs(userSuper){
                superUserResult = cspCaseCollaboratorHandler.isCaseViewable(collabCase.Id, collabCase.ContactId, contextUserId);
            }
        System.Test.stopTest();

        // THEN we should get the right result returned
        System.assert(contactCaseResult, 'Case should be accessible (true) when linked via case contactId');
        System.assert(collabCaseResult, 'Case should be accessible (true) when linked via junction object');
        System.assert(!unlinkedCaseResult, 'Case should not be accessible (false) when unlinked');
        System.assert(superUserResult, 'Case should be accessible for super users (true)');
    }
}