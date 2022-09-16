@IsTest
private class cspContactsHandlerTest {

    @TestSetup
    static void makeData(){
        Account account = new Account(
            Name = 'Account Name',
            Highest_CSP_Level__c = ''
        );
        insert account;

        Contact contact = new Contact(
            LastName = 'TestMan',
            Email = 'testContactEmail@theaccessgroup.com',
            AccountId = account.Id
        );
        insert contact;

        User user = TestUtilities.createPortalUser('Customer Portal - Support User', contact.Id, 'test123p');
    }

    @IsTest Public Static Void GetPlan() {
        Id id = [SELECT Id FROM Account].Id;
        String plan = cspContactsHandler.getPlan(String.valueOf(id));
    }
    @IsTest Public Static Void GetCSM() {
        Id id = [SELECT Id FROM Account].Id;
        User plan = cspContactsHandler.getCSM(String.valueOf(id));
    }
    @IsTest Public Static Void GetAccountManager() {
        Id id = [SELECT Id FROM Account].Id;
        User plan = cspContactsHandler.getAccountManager(String.valueOf(id));
    }

    @IsTest
    public static void getFlexPoints() {

        User portalAccountOwner1 = TestUtilities.createUser('Support Admin', 'System Administrator', 'test123');
        System.runAs(portalAccountOwner1) {
            			//Create account
			Account portalAccount1 = new Account(Name = 'TestAccount', OwnerId = portalAccountOwner1.Id);
			insert portalAccount1;

            Account pgportalAccount1 = new Account(Name = 'pgTestAccount', OwnerId = portalAccountOwner1.Id);
			insert pgportalAccount1;
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
           
            //Create Guadian contact
			Contact pgcontact1 = new Contact(FirstName = 'Test', 
										   Lastname = 'McGurdian', 
										   AccountId = portalAccount1.Id, 
										   Email = System.now().millisecond() + 'test@test.com');
			insert pgcontact1;
			//Create our portal user
            User pguser1 = TestUtilities.createPortalUser('Customer Portal - Support User', pgcontact1.Id, 'test456p');

            AccountContactRelation acr = new AccountContactRelation(
                AccountId = pgportalAccount1.Id,
                ContactId = pgcontact1.Id,
                roles = 'Points Guardian'
            );

            insert acr;

            Date requestedDate = Date.today();
            Date endDate = requestedDate.addDays(7);
            Date endDate2 = requestedDate.addDays(70);
            Id accountId = [SELECT Id FROM Account WHERE Name = 'TestAccount'].Id;

            Boolean IsNonPointUser =  cspContactsHandler.getIsNonPointsUser(accountId);
            system.assertEquals(true, IsNonPointUser);

            List<User> PointsGuardians = cspContactsHandler.getPointsGuardians(pgportalAccount1.Id);
            system.assertEquals(1, PointsGuardians.size());

            FlexPoints_Transactions__c flexPointTransactionPending = new FlexPoints_Transactions__c(
                Account__c = accountId,
                Transaction_Status__c = 'Pending',
                Type__c = 'Redemption',
                Points__c = 1000,
                Requested_Date__c = requestedDate,
                End_Date__c = endDate,
                Expired__c = false,
                Owner__c = UserInfo.getUserId()
            );
            insert flexPointTransactionPending;

            Decimal PointsEndSoon =  cspContactsHandler.getExpiringSoonPoints(accountId);
            system.assertEquals(0, PointsEndSoon);
    
            FlexPoints_Transactions__c flexPointTransactionConfirmed = new FlexPoints_Transactions__c(
                Account__c = accountId,
                Transaction_Status__c = 'Confirmed',
                Type__c = 'Redemption',
                Points__c =  1000,
                Expired__c = false,
                End_Date__c = endDate2,
                Requested_Date__c = requestedDate,
                Owner__c = UserInfo.getUserId()
            );
            insert flexPointTransactionConfirmed;
    
            FlexPoints_Transactions__c flexPointTransactionCancelled = new FlexPoints_Transactions__c(
                Account__c = accountId,
                Transaction_Status__c = 'Cancelled',
                Type__c = 'Redemption',
                Points__c = 1000,
                Requested_Date__c = requestedDate,
                End_Date__c = endDate,
                Expired__c = false,
                Owner__c = UserInfo.getUserId()
            );
            insert flexPointTransactionCancelled;
        

        system.runas(pguser1){
          Boolean isPointGuardian = cspContactsHandler.getIsPointsGuardian(pgportalAccount1.Id);

          system.assertEquals(true, isPointGuardian);


        }
    }

        FlexPoints_Transactions__c flexPointTransactionPending = [SELECT Account__c, Status__c, Type__c, Points__c, Requested_Date__c, End_Date__c FROM FlexPoints_Transactions__c WHERE Status__c = 'Pending'];
        FlexPoints_Transactions__c flexPointTransactionConfirmed = [SELECT Account__c, Status__c, Type__c, Points__c, Requested_Date__c, End_Date__c FROM FlexPoints_Transactions__c WHERE Status__c = 'Confirmed'];
        FlexPoints_Transactions__c flexPointTransactionCancelled = [SELECT Account__c, Status__c, Type__c, Points__c, Requested_Date__c, End_Date__c FROM FlexPoints_Transactions__c WHERE Status__c = 'Cancelled'];
        Id accountId = [SELECT Id FROM Account WHERE Name = 'TestAccount'].Id;
        
        Decimal totalAccural = 0;
        Decimal totalRedemptions = 2000;
        Decimal expiringSoon = 0;

        Map<String,Object> results = new Map<String, Object>{
            'id' => accountId,
            'availablePoints' => totalAccural - totalRedemptions,
            'totalConfirmed' => flexPointTransactionConfirmed.Points__c,
            'totalPending' => flexPointTransactionPending.Points__c,
            'currentBalance' => totalAccural - totalRedemptions,
            'expiringSoon' => expiringSoon
        };

        Map<String, Object> balances = cspContactsHandler.getFlexPoints(String.valueOf(accountId));

        System.assertEquals(JSON.serialize(results.get('totalConfirmed')), JSON.serialize(balances.get('totalConfirmed')));
        System.assertEquals(JSON.serialize(results.get('totalPending')), JSON.serialize(balances.get('totalPending')));
        System.assertEquals(JSON.serialize(results.get('availablePoints')), JSON.serialize(balances.get('availablePoints')));
        System.assertEquals(JSON.serialize(results.get('currentBalance')), JSON.serialize(balances.get('currentBalance')));
        System.assertEquals(JSON.serialize(results.get('expiringSoon')), JSON.serialize(balances.get('expiringSoon')));
        System.assertEquals(JSON.serialize(results.get('id')), JSON.serialize(balances.get('id')));
    }
    
}