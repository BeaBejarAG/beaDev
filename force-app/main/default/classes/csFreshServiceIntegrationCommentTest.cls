@IsTest public class csFreshServiceIntegrationCommentTest {


    private class RestMock implements HttpCalloutMock {

        public HTTPResponse respond(HTTPRequest req) {
            String fullJson = '{}';

            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'text/json');
            res.setBody(fullJson);
            res.setStatusCode(404);
            return res;
        }
    }

    @IsTest Public Static Void IntegrationTest (){
		
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
        
            case NewCase = new case(
            subject = 'Test',
            description = 'Test',
            contactid = contact1.Id,
            Remedyforce_Alto_Incident_Number__c = '10',
            recordtypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Support').getRecordTypeId() );
            insert NewCase;

            csFreshServiceIntegrationCommentFuture.FSIntRequest intreq = new csFreshServiceIntegrationCommentFuture.FSIntRequest();
            intreq.ticketId = '42';
            intreq.CaseId = NewCase.Id;
            
            Test.setMock(HttpCalloutMock.class, new RestMock());

            csFreshServiceIntegrationCommentCall.FSIntRequest intreqCall = new csFreshServiceIntegrationCommentCall.FSIntRequest();
            intreqCall.ticketId = '10';
            List<Case> caseList = new List<Case>();
            caseList.add(NewCase);

            Test.startTest();
            csFreshServiceIntegrationCommentFuture.CreateNote('42', 'body');
            csFreshServiceIntegrationCommentCall.invokeapexcallout(caseList);
            test.stopTest();
        } 
    }
}