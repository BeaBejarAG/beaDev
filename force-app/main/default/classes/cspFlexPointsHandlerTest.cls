@IsTest
private class cspFlexPointsHandlerTest {

    @TestSetup
    static void makeData(){

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

            Date requestedDate = Date.newInstance(2021, 06, 29);
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
                Account__c = portalAccount1.id
            );
            insert newCase;
        }
    }

    @IsTest
    public static void createNewCase() {
            Account a = [SELECT Id FROM Account WHERE Name = 'TestAccount' LIMIT 1];
            User u = [SELECT Id, email, ContactId FROM User WHERE alias = 'test123' LIMIT 1];
            Entitlement e = [SELECT Id FROM Entitlement LIMIT 1];

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

                Boolean result = cspFlexPointsHandler.createNewCase('description', 'subject', '4', 'Access Approve', serviceCatalogueEntry.Id, String.valueOf(e.Id), String.valueOf(a.Id), '100');
                System.assert(result == true);
            }
    }

    @IsTest
    public static void requestAQuote() {
        Account a = [SELECT Id FROM Account WHERE Name = 'TestAccount' LIMIT 1];
        User u = [SELECT Id, email, ContactId FROM User WHERE alias = 'test123' LIMIT 1];
        Entitlement e = [SELECT Id FROM Entitlement LIMIT 1];
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

            Boolean result = cspFlexPointsHandler.requestAQuote('description', 'subject', '4', 'Access Approve', serviceCatalogueEntry.Id, String.valueOf(e.Id), '100', a.Id);
            System.assert(result == true);
        }
    }

    @isTest
    private static void itShouldCreateATransactionUponQuoteApproval() {
        Account account = [SELECT Id FROM Account WHERE Name = 'TestAccount' LIMIT 1];
        User user = [SELECT Id FROM User WHERE Alias = 'test123p' LIMIT 1];
        Case caseObj = [SELECT Id FROM Case LIMIT 1];

        cspFlexPointsHandler.createQuoteApprovalTransaction(account.Id, 100, user.Id, caseObj.Id);

        FlexPoints_Transactions__c flexPointsTransaction = [SELECT Account__c, Points__c, Owner__c, Status__c, Type__c FROM FlexPoints_Transactions__c LIMIT 1];
        System.assertEquals(account.Id, flexPointsTransaction.Account__c);
        System.assertEquals(100, flexPointsTransaction.Points__c);
        System.assertEquals(user.Id, flexPointsTransaction.Owner__c);
        System.assertEquals('Pending', flexPointsTransaction.Status__c);
        System.assertEquals('Redemption', flexPointsTransaction.Type__c);
    }
}