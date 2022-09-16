@IsTest
private class cspConsultantAccountHandlerTest {

    @TestSetup
    static void makeData(){
        Id pId = [SELECT Id FROM Profile WHERE Name = 'Customer Portal - Super User'].Id;
        List<Account> accounts = new List<Account>();
        Account account = new Account(
            Name = 'Account Name'
        );
        accounts.add(account);

        Account account2 = new Account(
            Name = 'Account Name2'
        );
        accounts.add(account2);
        insert accounts;

        Contact contact = new Contact(
            LastName = 'TestMan',
            Email = 'testContactEmail@theaccessgroup.com',
            AccountId = account.Id
        );
        insert contact;

        User user = new User();
        user.ProfileId = pId;
        user.Username = 'testEmail@theaccessgroup.com';
        user.LastName = 'LastName';
        user.Email = 'testEmail@theaccessgroup.com';
        user.Alias = 'alias';
        user.TimeZoneSidKey = 'Europe/London';
        user.LocaleSidKey = 'en_GB';
        user.EmailEncodingKey = 'ISO-8859-1';
        user.LanguageLocaleKey = 'en_US';
        user.ContactId = contact.Id;
        
        insert user;

        AccountContactRelation accountContact = new AccountContactRelation(
            AccountId = account2.Id,
            ContactId = contact.Id,
            Roles = 'Customer Success Portal Access'
        );
        insert accountContact;
    }

    @IsTest 
    static void itShouldRetrieveAccountNameFromAccountRelationObj() {
        String accountName = [SELECT Name FROM Account WHERE Name = 'Account Name' LIMIT 1].Name;
        User u = [SELECT ContactId FROM User WHERE LastName =: 'LastName'];
		System.runAs(u) {
            System.Test.startTest();
            List<AccountContactRelation> retrievedAccountRelations = cspConsultantAccountHandler.getAccountRelations(null);
            System.Test.stopTest();

            AccountContactRelation result = null;
            for (AccountContactRelation account : retrievedAccountRelations) {
                if (account.Account.Name.equals('Account Name')) {
                    result = account;
                }
            }

            System.assertEquals(2, retrievedAccountRelations.size());
            System.assertEquals(accountName, result.Account.Name);
            System.assertEquals(true, result.IsDirect);
        }
    }
}