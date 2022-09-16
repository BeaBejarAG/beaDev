@IsTest
private class cspSuccessPlanHandlerTest {

    @TestSetup
    static void makeData(){
        Id pId = [SELECT Id FROM Profile WHERE Name = 'Customer Portal - Super User'].Id;

        Account account = new Account(
            Name = 'Account Name'
        );

        insert account;

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
    }

    @IsTest Public Static Void GetContacts() {
        String accountName = [SELECT Name FROM Account LIMIT 1].Name;
        List<Map<String, Object>> contacts = cspSuccessPlanHandler.getContactsForAccount('Access Approve', 'Support', '', 5, 0, accountName);
    }

    @IsTest 
    Public Static Void GetContactsLevelRead() {
        String accountName = [SELECT Name FROM Account LIMIT 1].Name;
        List<Map<String, Object>> contacts = cspSuccessPlanHandler.getContactsForAccount('Access Approve', 'Read', '', 5, 0, accountName);
    }

    @IsTest 
    Public Static Void GetContactsLevelRService() {
        String accountName = [SELECT Name FROM Account LIMIT 1].Name;
        List<Map<String, Object>> contacts = cspSuccessPlanHandler.getContactsForAccount('Access Approve', 'Service', '', 5, 0, accountName);
    }

    @IsTest 
    Public Static Void GetContactsLevelSearchTerm() {
        String accountName = [SELECT Name FROM Account LIMIT 1].Name;
        List<Map<String, Object>> contacts = cspSuccessPlanHandler.getContactsForAccount('Access Approve', 'Support', 'Alphabet', 5, 0, accountName);
    }
    
}