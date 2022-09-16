@ IsTest(SeeAllData = False) 
public with sharing class cspCaseCountTest {
    @IsTest Public Static Void GetContactEmail() {
        string ContactEmail = CaseLogFlow.ContactEmail();

    }

    @IsTest Public Static Void CreateNewCase() {

        User portalAccountOwner1 = TestUtilities.createUser('Support Admin', 'System Administrator', 'test123');

        System.runAs(portalAccountOwner1) {
            //Create account
            Account portalAccount1 = new Account(Name = 'TestAccount', OwnerId = portalAccountOwner1.Id);
            insert portalAccount1;
            // Create entitlement for case creation
            Entitlement ent = new Entitlement(Name = 'TestingEntitlement', 
                                                AccountId = portalAccount1.Id, 
                                                StartDate= Date.valueof(System.now().addDays(-2)), 
                                                EndDate = Date.valueof(System.now().addYears(2)));
            insert ent;
            //Create contact
            Contact contact1 = new Contact(FirstName = 'Test', 
                                            Lastname = 'McTesty', 
                                            AccountId = portalAccount1.Id, 
                                            Email = System.now().millisecond() + 'test@test.com');
            insert contact1;
            
            User user1 = TestUtilities.createPortalUser('Customer Portal - Support User', contact1.Id, 'test123p');
        }
        
        User u = [select Id, email, ContactId from User where alias = 'test123'];
        System.runAs(u) {
            Entitlement testEnt = [select Id, name from Entitlement where name = 'TestingEntitlement'];
            Case NewCase = CaseLogFlow.CreateNewCase('Apple1234', 'Pear123', '2', 'Dimensions', testEnt.Id);
        }
    }

    @istest public static void TestCaseCounts(){
        Case cse = TestUtilities.getCase();
        cse.Status = 'Support Oustanding';
        cse.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Support').getRecordTypeId();
        insert cse;

        Integer count = cspCaseCount.getOpenCases();

        system.assertEquals(1, count);

        cse.Status = 'Customer Outstanding';

        update cse;

        count = cspCaseCount.getAwaitingCustomerCases();

        system.assertEquals(1, count);

    }
}