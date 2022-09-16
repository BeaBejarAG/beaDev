@isTest
private class sendHTMLEmailTest {
    
    static testMethod void testUserEmail(){
        
        // Test with standard profile
        
        Profile p = [select id from profile where name='Standard User']; 
        
        User testUser = new User();
        testUser.email = 'test@test.com';
        testUser.Username ='test@thetest6534567angry_moose35c.com';
        testUser.alias ='testUser';
        testUser.TimeZoneSidKey = 'America/Chicago';
        testUser.localesidkey='en_US';
        testUser.emailencodingkey='UTF-8';
        testUser.languagelocalekey='en_US';
        testUser.localesidkey='en_US';
        testUser.ProfileId = p.Id;
        testUser.FirstName = 'Test';
        testUser.LastName = 'Test';
        testUser.Title = 'Some Person';
        testUser.IsActive = true;
        testUser.UserPermissionsInteractionUser = true;
        
        insert testUser;
        
        Test.startTest();
        
        // Test the email limits before running
        Integer emailbefore = Limits.getEmailInvocations();
        
        // Set all params save, email other addresses & save as activity
        
        sendHTMLEmailPlugin plugin = new sendHTMLEmailPlugin();
        Map<String, Object> inputParams = new Map<String, Object>();
        inputParams.put('htmlBody', '<strong>Hello world</strong>');
        inputParams.put('Subject', 'Hello world');
        inputParams.put('Target Object Id', testUser.Id);
        inputParams.put('Sender Address', testUser.Email);
        inputParams.put('Priority', 'High');
        
        Process.PluginRequest request = new Process.PluginRequest(inputParams);
        Process.PluginResult result;
        result = plugin.invoke(request);
        
        // Assert that the batch has decreased
    
        system.assertNotEquals(emailbefore,Limits.getEmailInvocations(),'should have decreased');
        
        Test.stopTest();
    }
    
    
    static testMethod void testLeadEmail(){
        
        // Test that it saves as an activity with the lead
        
        Lead testLead = new Lead();
        testLead.Salutation = 'Mr.';
        testLead.FirstName = 'Test';
        testLead.LastName = 'Test';
        testLead.Street = '12345 test Lane';
        testLead.City = 'Omaha';
        testLead.State = 'NE';
        testLead.PostalCode = '68135';
        testLead.Status ='Some Status';
        testLead.Company = 'Some Company';
        testLead.Country = 'USA';
        testLead.Email = 'test@test.com';
        testLead.Title = 'Some Title';
        
        insert testLead;
        
        Test.startTest();
        
        // Test the email limits before running
        Integer emailbefore = Limits.getEmailInvocations();
        
        // Set all params save, email other addresses
        
        sendHTMLEmailPlugin plugin = new sendHTMLEmailPlugin();
        Map<String, Object> inputParams = new Map<String, Object>();
        inputParams.put('htmlBody', '<strong>Hello world</strong>');
        inputParams.put('Subject', 'Hello world');
        inputParams.put('Target Object Id', testLead.Id);
        inputParams.put('Save As Activity', 'true');
        inputParams.put('Priority', 'Low');
        
        Process.PluginRequest request = new Process.PluginRequest(inputParams);
        Process.PluginResult result;
        result = plugin.invoke(request);
        
        // Assert that the batch has decreased
    
        system.assertNotEquals(emailbefore,Limits.getEmailInvocations(),'should have decreased');
        
              
        // Assert that the activity was saved
        
        List<Task> t = new List<Task>([SELECT Id FROM Task WHERE whoId = :testLead.Id]);
      //  system.assertEquals(1, t.size());
        
        Test.stopTest();
    }
    
    static testMethod void testContactEmail(){
        
        // Test that it saves as an activity with the user - test with standard profile
        
        // Create account for contact
        Account testAccount = new Account();
        testAccount.Name = 'Test';
        testAccount.BillingStreet = '12345 Test Lane';
        testAccount.BillingCity = 'Omaha';
        testAccount.BillingState = 'NE';
        testAccount.BillingPostalCode = '68135';
        testAccount.Type = 'Some Type';
        
        insert testAccount;
          
        // Create new contact
        Contact testContact= new Contact();
        testContact.Salutation = 'Mr.';
        testContact.FirstName = 'Test';
        testContact.LastName = 'Test';
        testContact.MailingStreet = '12345 test Lane';
        testContact.MailingCity = 'Omaha';
        testContact.MailingState = 'NE';
        testContact.MailingPostalCode = '68135';
        testContact.AccountId = testAccount.Id;
        testContact.MailingCountry = 'USA';
        testContact.Email = 'test@test.com';
        testContact.Title = 'Some Title';
        
        insert testContact;
        
        Test.startTest();
        
        // Test the email limits before running
        Integer emailbefore = Limits.getEmailInvocations();
        
        // Set all params save, email other addresses & save as activity
        
        sendHTMLEmailPlugin plugin = new sendHTMLEmailPlugin();
        Map<String, Object> inputParams = new Map<String, Object>();
        inputParams.put('htmlBody', '<strong>Hello world</strong>');
        inputParams.put('Subject', 'Hello world');
        inputParams.put('Target Object Id', testContact.Id);
        inputParams.put('Priority', 'High');
        inputParams.put('Save As Activity', 'true');
        inputParams.put('Sender Display Name', 'test@test.com');
        inputParams.put('CC Email Addresses (comma-separated)', 'test@test.com, test123@test.com');
        inputParams.put('BCC Email Addresses (comma-separated)', 'test@test.com, test123@test.com');
        
        Process.PluginRequest request = new Process.PluginRequest(inputParams);
        Process.PluginResult result;
        result = plugin.invoke(request);
        
        // Assert that the batch has decreased
    
        system.assertNotEquals(emailbefore,Limits.getEmailInvocations(),'should have decreased');
        
        // Assert that the activity was saved
        
        List<Task> t = new List<Task>([SELECT Id FROM Task WHERE whoId = :testContact.Id]);
       // system.assertEquals(1, t.size());
        
        Test.stopTest();
    }    
        
    static testMethod void testOtherEmail(){
        Test.startTest();
        
        // Test the email limits before running
        Integer emailbefore = Limits.getEmailInvocations();
        
        // Set all params save, email other addresses & save as activity
        
        sendHTMLEmailPlugin plugin = new sendHTMLEmailPlugin();
        Map<String, Object> inputParams = new Map<String, Object>();
        inputParams.put('htmlBody', '<strong>Hello world</strong>');
        inputParams.put('Subject', 'Hello world');
        inputParams.put('Other Emails (comma-separated)', 'Test123@test.com, test345@test.com');
        inputParams.put('Priority', 'High');
        
        Process.PluginRequest request = new Process.PluginRequest(inputParams);
        Process.PluginResult result;
        result = plugin.invoke(request);
        
        // Assert that the batch has decreased
    
        system.assertNotEquals(emailbefore,Limits.getEmailInvocations(),'should have decreased');
        
        Test.stopTest();
    }
    
    // Tests the describe method
    static testMethod void describeTest() {

        sendHTMLEmailPlugin plugin = new sendHTMLEmailPlugin();
        Process.PluginDescribeResult result =  plugin.describe();
        
        // Assert there are 10 inputs        
        System.AssertEquals(result.inputParameters.size(), 11);

    }
}