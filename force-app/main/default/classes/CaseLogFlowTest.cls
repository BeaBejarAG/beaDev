@isTest(SeeAllData=false)
public with sharing class CaseLogFlowTest {

	@IsTest public static void GetContactEmail() {

		String contactEmail = CaseLogFlow.ContactEmail();
		System.assertEquals(true, String.isEmpty(contactEmail));
		
	}
    
    @IsTest public static void BaseRun(){

		User portalAccountOwner1 = TestUtilities.createUser('Support Admin', 'System Administrator', 'test123');
        Account portalAccount1 = new Account(Name = 'TestAccount', OwnerId = portalAccountOwner1.Id);

        System.runAs(portalAccountOwner1) {
            //Create account
            insert portalAccount1;
			Contact contact1 = TestUtilities.getContact(portalAccount1);
			insert contact1;
			// Create entitlement 
			Entitlement ent = new Entitlement(
				Name = 'TestingEntitlement', 
				AccountId = portalAccount1.Id, 
				StartDate= Date.valueof(System.now().addDays(-2)), 
				EndDate = Date.valueof(System.now().addYears(2)),
				AssociatedProductRange__c = 'Access Approve'
			);
			insert ent;
			// Create contact entitlement 
			ContactEntitlement__c cEnt = new ContactEntitlement__c(
				Real_Entitlement__c = ent.Id,
				Contact__c = contact1.Id
			);
			insert cEnt;
			System.Test.startTest();
			List<ContactEntitlement__c> cEntOut = CaseLogFlow.MyEntitlements();
			System.assertEquals(0, cEntOut.size());
			String contactId = CaseLogFlow.ContactId();
			System.assertEquals(true, String.isEmpty(contactId));
			System.Test.stopTest();
		}
        
    }
    
    @IsTest Public static Void NonStatic(){
        List<String> maps = new List<String>();
        CaseLogFlow CFL = new CaseLogFlow();
        maps = CFL.GetCurrentMap();
        CFL.show();
    }
    
    @IsTest Public Static Void DependantPickList(){
        Map<String, List<String>> ms = new  Map<String, List<String>>();
        ms = CaseLogFlow.getDependentMap();    
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
			//Create our portal user
			User user1 = TestUtilities.createPortalUser('Customer Portal - Support User', contact1.Id, 'test123p');
		}
		
		User u = [select Id, email, ContactId from User where alias = 'test123'];
		System.runAs(u) {
			Entitlement testEnt = [select Id, name from Entitlement where name = 'TestingEntitlement'];
			Case NewCase = CaseLogFlow.CreateNewCase('Apple1234', 'Pear123', '2', 'Dimensions', testEnt.Id);
		}
        
        User ud = [select Id, email, ContactId from User where alias = 'test123'];
		System.runAs(ud) {
			Entitlement testEnt = [select Id, name from Entitlement where name = 'TestingEntitlement'];
			Case NewCase = CaseLogFlow.CreateNewCase('Apple1234', 'Pear123', '2', 'Dimensions', testEnt.Id, 'Other');
		}
	}
}