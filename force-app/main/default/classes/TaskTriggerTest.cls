@isTest
private class TaskTriggerTest {

    static testMethod void testTaskTriggerOne() {
    	
    	Account acc = new Account();
    	acc.Name = 'Account test';
    	insert acc;
    	Contact contact = new Contact();
    	contact.FirstName = 'Contact';
    	contact.LastName = 'Name';
    	contact.AccountId = acc.Id;
    	contact.email = 'test@test.com';
    	insert contact;
    	
    	Campaign camp = new Campaign();
    	camp.Name = 'Campaign name';
    	insert camp;
        
        Id MarketTaskRType = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Marketo Task').getRecordTypeId();
        
        System.debug(MarketTaskRType);
        
        Task task = new Task();
        task.recordTypeId = MarketTaskRType;
        task.Description = 'Campaign ID: ' + camp.Id + '\n Division: aCloud\n Product: aCloud HR\n Reviewing Software: Yes\n Existing Software: No, we’re using manual systems\n TimeFrame: 0-3 Months ';
        task.WhoId = contact.Id;
        System.debug(task);
        try{
       		insert task;
        }catch(Exception e){
        	System.debug('debug');
        }
        
        Task task1 = new Task();
        task1.recordTypeId = MarketTaskRType;
        task1.Description = 'NANA: ' + camp.Id + '\n Division: aCloud\n Product: aCloud HR\n Reviewing Software: Yes\n Existing Software: No, we’re using manual systems\n TimeFrame: 0-3 Months ';
        task1.WhoId = contact.Id;
        System.debug(task1);
        try{
       		insert task1;
        }catch(Exception e){
        	System.debug('debug');
        }
        
        Task task2 = new Task();
        task2.recordTypeId = MarketTaskRType;
        task2.Description = ' qkuysgfniuxfgwqgfe';
        task2.WhoId = contact.Id;
        System.debug(task2);
        try{
       		insert task2;
        }catch(Exception e){
        	System.debug('debug');
        }
        
        Task task3 = new Task();
        task3.recordTypeId = MarketTaskRType;
        task3.Description = 'Campaign ID: ' + camp.Id + '\r\n Division: aCloud\r\n Product: aCloud HR\r\n Reviewing Software: Yes\r\n Existing Software: No, we’re using manual systems\r\n TimeFrame: 0-3 Months ';
        task3.WhoId = contact.Id;
        System.debug(task3);
        try{
       		insert task3;
        }catch(Exception e){
        	System.debug('debug');
        }
        
        Task task4 = new Task();
        task4.recordTypeId = MarketTaskRType;
        task4.Description = 'Campaign ID: ' + camp.Id + '\r\n Division:\r\n Product: aCloud HR\r\n Reviewing Software: Yes\r\n Existing Software: No, we’re using manual systems\r\n TimeFrame: 0-3 Months ';
        task4.WhoId = contact.Id;
        System.debug(task4);
        try{
       		insert task4;
        }catch(Exception e){
        	System.debug('debug');
        }
        
        Task task5 = new Task();
        task5.recordTypeId = MarketTaskRType;
        task5.Description = 'Campaign ID: ' + camp.Id + '\r\n Division: NA\r\n Product: aCloud HR\r\n Reviewing Software: Yes\r\n Existing Software: No, we’re using manual systems\r\n TimeFrame: 0-3 Months ';
        task5.WhoId = contact.Id;
        System.debug(task5);
        try{
       		insert task5;
        }catch(Exception e){
        	System.debug('debug');
        }
        
        Task task6 = new Task();
        task6.recordTypeId = MarketTaskRType;
        task6.Description = 'Campaign ID: ' + camp.Id + '\r\n Division: aCloud\r\n Product:\r\n Reviewing Software: Yes\r\n Existing Software: No, we’re using manual systems\r\n TimeFrame: 0-3 Months ';
        task6.WhoId = contact.Id;
        System.debug(task6);
        try{
       		insert task6;
        }catch(Exception e){
        	System.debug('debug');
        }
        
        Task task7 = new Task();
        task7.recordTypeId = MarketTaskRType;
        task7.Description = 'Campaign ID: ' + camp.Id + '\r\n Division: aCloud\r\n Product: NA\r\n Reviewing Software: Yes\r\n Existing Software: No, we’re using manual systems\r\n TimeFrame: 0-3 Months ';
        task7.WhoId = contact.Id;
        System.debug(task7);
        try{
       		insert task7;
        }catch(Exception e){
        	System.debug('debug');
        }
        
    }
    
    static testMethod void testTaskTriggerTwo() {
    	
    	Account acc = new Account();
    	acc.Name = 'Account test';
    	insert acc;
    	Contact contact = new Contact();
    	contact.FirstName = 'Contact';
    	contact.LastName = 'Name';
    	contact.email = 'test@test.com';
    	contact.AccountId = acc.Id;
    	insert contact;
    	
    	Campaign camp = new Campaign();
    	camp.Name = 'Campaign name';
    	insert camp;
        
        Id MarketTaskRType = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Marketo Task').getRecordTypeId();
        
        System.debug(MarketTaskRType);
        
        Task task1 = new Task();
        task1.recordTypeId = MarketTaskRType;
        task1.Description = 'Campaign ID: ' + camp.Id + '\r\n Division: aCloud\r\n Product: aCloud HR\r\n Reviewing Software:\r\n Existing Software: No, we’re using manual systems\r\n TimeFrame: 0-3 Months ';
        task1.WhoId = contact.Id;
        System.debug(task1);
        try{
       		insert task1;
        }catch(Exception e){
        	System.debug('debug');
        }
        
        Task task2 = new Task();
        task2.recordTypeId = MarketTaskRType;
        task2.Description = 'Campaign ID: ' + camp.Id + '\r\n Division: aCloud\r\n Product: aCloud HR\r\n Reviewing Software: NA\r\n Existing Software: No, we’re using manual systems\r\n TimeFrame: 0-3 Months ';
        task2.WhoId = contact.Id;
        System.debug(task2);
        try{
       		insert task2;
        }catch(Exception e){
        	System.debug('debug');
        }
        
        Task task3 = new Task();
        task3.recordTypeId = MarketTaskRType;
        task3.Description = 'Campaign ID: ' + camp.Id + '\r\n Division: aCloud\r\n Product: aCloud HR\r\n Reviewing Software: Yes\r\n Existing Software:\r\n TimeFrame: 0-3 Months ';
        task3.WhoId = contact.Id;
        System.debug(task3);
        try{
       		insert task3;
        }catch(Exception e){
        	System.debug('debug');
        }
        
        Task task4 = new Task();
        task4.recordTypeId = MarketTaskRType;
        task4.Description = 'Campaign ID: ' + camp.Id + '\r\n Division:\r\n Product: aCloud HR\r\n Reviewing Software: Yes\r\n Existing Software: NA\r\n TimeFrame: 0-3 Months ';
        task4.WhoId = contact.Id;
        System.debug(task4);
        try{
       		insert task4;
        }catch(Exception e){
        	System.debug('debug');
        }
        
        Task task5 = new Task();
        task5.recordTypeId = MarketTaskRType;
        task5.Description = 'Campaign ID: ' + camp.Id + '\r\n Division: NA\r\n Product: aCloud HR\r\n Reviewing Software: Yes\r\n Existing Software: No, we’re using manual systems\r\n TimeFrame: ';
        task5.WhoId = contact.Id;
        System.debug(task5);
        try{
       		insert task5;
        }catch(Exception e){
        	System.debug('debug');
        }
        
        Task task6 = new Task();
        task6.recordTypeId = MarketTaskRType;
        task6.Description = 'Campaign ID: ' + camp.Id + '\r\n Division: aCloud\r\n Product:\r\n Reviewing Software: Yes\r\n Existing Software: No, we’re using manual systems\r\n TimeFrame: NA ';
        task6.WhoId = contact.Id;
        System.debug(task6);
        try{
       		insert task6;
        }catch(Exception e){
        	System.debug('debug');
        }
        
    }
    
    static testMethod void testTaskTriggerThree() {
    	
    	Account acc = new Account();
    	acc.Name = 'Account test';
    	insert acc;
    	Contact contact = new Contact();
    	contact.FirstName = 'Contact';
    	contact.LastName = 'Name';
    	contact.email = 'test@test.com';
    	contact.AccountId = acc.Id;
    	insert contact;
    	
    	Campaign camp = new Campaign();
    	camp.Name = 'Campaign name';
    	insert camp;
        
        Id MarketTaskRType = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Marketo Task').getRecordTypeId();
        
        System.debug(MarketTaskRType);
        
        Task task1 = new Task();
        task1.recordTypeId = MarketTaskRType;
        task1.Description = 'Campaign ID- ' + camp.Id + '\n Division: aCloud\n Product: aCloud HR\n Reviewing Software: Yes\n Existing Software: No, we’re using manual systems\n TimeFrame: 0-3 Months ';
        task1.WhoId = contact.Id;
        System.debug(task1);
        try{
       		insert task1;
        }catch(Exception e){
        	System.debug('debug');
        }
        
        Task task2 = new Task();
        task2.recordTypeId = MarketTaskRType;
        task2.Description = 'Campaign ID: ' + camp.Id + '\n Division- aCloud\n Product: aCloud HR\n Reviewing Software: Yes\n Existing Software: No, we’re using manual systems\n TimeFrame: 0-3 Months ';
        task2.WhoId = contact.Id;
        System.debug(task2);
        try{
       		insert task2;
        }catch(Exception e){
        	System.debug('debug');
        }
        
        Task task3 = new Task();
        task3.recordTypeId = MarketTaskRType;
        task3.Description = 'Campaign ID: ' + camp.Id + '\n Division: aCloud\n Product- aCloud HR\n Reviewing Software: Yes\n Existing Software: No, we’re using manual systems\n TimeFrame: 0-3 Months ';
        task3.WhoId = contact.Id;
        System.debug(task3);
        try{
       		insert task3;
        }catch(Exception e){
        	System.debug('debug');
        }
        
        Task task4 = new Task();
        task4.recordTypeId = MarketTaskRType;
        task4.Description = 'Campaign ID: ' + camp.Id + '\n Division: aCloud \n Product: aCloud HR\n Reviewing Software- Yes\n Existing Software: No, we’re using manual systems\n TimeFrame: 0-3 Months ';
        task4.WhoId = contact.Id;
        System.debug(task4);
        try{
       		insert task4;
        }catch(Exception e){
        	System.debug('debug');
        }
        
        Task task5 = new Task();
        task5.recordTypeId = MarketTaskRType;
        task5.Description = 'Campaign ID: ' + camp.Id + '\n Division: aCloud\n Product: aCloud HR\n Reviewing Software: Yes\n Existing Software- No, we’re using manual systems\n TimeFrame: 0-3 Months ';
        task5.WhoId = contact.Id;
        System.debug(task5);
        try{
       		insert task5;
        }catch(Exception e){
        	System.debug('debug');
        }
        
        Task task6 = new Task();
        task6.recordTypeId = MarketTaskRType;
        task6.Description = 'Campaign ID: ' + camp.Id + '\n Division: aCloud\n Product: aCloud HR\n Reviewing Software: Yes\n Existing Software: No, we’re using manual systems\n TimeFrame- 0-3 Months ';
        task6.WhoId = contact.Id;
        System.debug(task6);
        try{
       		insert task6;
        }catch(Exception e){
        	System.debug('debug');
        }
        
    }
    
    static testMethod void testTaskTriggerFour() {
    	
    	Account acc = new Account();
    	acc.Name = 'Account test';
    	insert acc;
    	Contact contact = new Contact();
    	contact.FirstName = 'Contact';
    	contact.LastName = 'Name';
    	contact.email = 'test@test.com';
    	contact.AccountId = acc.Id;
    	insert contact;
    	
    	Campaign camp = new Campaign();
    	camp.Name = 'Campaign name';
    	insert camp;
        
        Id MarketTaskRType = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Marketo Task').getRecordTypeId();
        
        System.debug(MarketTaskRType);
        
        Task task1 = new Task();
        task1.recordTypeId = MarketTaskRType;
        task1.Description = 'Campaign ID: ' + camp.Id + ' \n Division: aCloud\n Product: aCloud HR\n Reviewing Software: Yes\n Existing Software: No, we’re using manual systems\n TimeFrame: 0-3 Months ';
        task1.WhoId = contact.Id;
        System.debug(task1);
        try{
       		insert task1;
        }catch(Exception e){
        	System.debug('debug');
        }	
        
    }
    
    static testMethod void testTaskTriggerFive() {
    	
    	Account acc = new Account();
    	acc.Name = 'Account test';
    	insert acc;
    	Contact contact = new Contact();
    	contact.FirstName = 'Contact';
    	contact.LastName = 'Name';
    	contact.email = 'test@test.com';
    	contact.AccountId = acc.Id;
    	insert contact;
    	
    	Campaign camp = new Campaign();
    	camp.Name = 'Campaign name';
    	insert camp;
        
        Id MarketTaskRType = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Marketo Task').getRecordTypeId();
        
        System.debug(MarketTaskRType);
        
        Task task5 = new Task();
        task5.recordTypeId = MarketTaskRType;
        task5.Description = 'Campaign ID: ' + camp.Id + ' \n Division: aCloud\n Product: aCloud HR\n Reviewing Software: Yes\n Existing Software: dog, we’re using manual systems\n TimeFrame: 0-3 Months ';
        task5.WhoId = contact.Id;
        System.debug(task5);
        try{
       		insert task5;
        }catch(Exception e){
        	System.debug('debug');
        }	
        
    }
    static testMethod void testTaskTriggerSix() {
        Account acc = new Account();
    	acc.Name = 'Account test';
    	insert acc;
    	Contact contact = new Contact();
    	contact.FirstName = 'Contact';
    	contact.LastName = 'Name';
    	contact.email = 'test@test.com';
    	contact.AccountId = acc.Id;
    	insert contact;
    	
    	Campaign camp = new Campaign();
    	camp.Name = 'Campaign name';
    	insert camp;
        
        Id MarketTaskRType = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Marketo Task').getRecordTypeId();
        
        System.debug(MarketTaskRType);
        
        Task task6 = new Task();
        task6.recordTypeId = MarketTaskRType;
        task6.Description = 'Campaign ID';
        task6.WhoId = contact.Id;
        System.debug(task6);
        try{
       		insert task6;
        }catch(Exception e){
        	System.debug('debug');
        }
    }
    static testMethod void testTaskTriggerSeven() {
        Account acc = new Account();
    	acc.Name = 'Account test';
    	insert acc;
    	Contact contact = new Contact();
    	contact.FirstName = 'Contact';
    	contact.LastName = 'Name';
    	contact.email = 'test@test.com';
    	contact.AccountId = acc.Id;
    	insert contact;
    	
    	Campaign camp = new Campaign();
    	camp.Name = 'Campaign name';
    	insert camp;
        
        Id MarketTaskRType = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Marketo Task').getRecordTypeId();
        
        System.debug(MarketTaskRType);
        
        Task task7 = new Task();
        task7.recordTypeId = MarketTaskRType;
        task7.Description = 'Campaign ID: ' + acc.Id + ' \n Division: aCloud\n Product: aCloud HR\n Reviewing Software: Yes\n Existing Software: dog, we’re using manual systems\n TimeFrame: 0-3 Months ';
        task7.WhoId = contact.Id;
        System.debug(task7);
        try{
       		insert task7;
        }catch(Exception e){
        	System.debug('debug');
        }
    }
    static testMethod void testTaskTriggerEight() {
        Account acc = new Account();
    	acc.Name = 'Account test';
    	insert acc;
    	Contact contact = new Contact();
    	contact.FirstName = 'Contact';
    	contact.LastName = 'Name';
    	contact.email = 'test@test.com';
    	contact.AccountId = acc.Id;
    	insert contact;
    	
    	Campaign camp = new Campaign();
    	camp.Name = 'Campaign name';
    	insert camp;
        
        Id MarketTaskRType = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Marketo Task').getRecordTypeId();
        
        System.debug(MarketTaskRType);
        
        Task task8 = new Task();
        task8.recordTypeId = MarketTaskRType;
        task8.Description = 'Campaign ID: ' + '' + ' \n Division: aCloud\n Product: aCloud HR\n Reviewing Software: Yes\n Existing Software: dog, we’re using manual systems\n TimeFrame: 0-3 Months ';
        task8.WhoId = contact.Id;
        System.debug(task8);
        try{
       		insert task8;
        }catch(Exception e){
        	System.debug('debug');
        }
    }
    static testMethod void testTaskTriggerNine() {
        Account acc = new Account();
    	acc.Name = 'Account test';
    	insert acc;
    	Contact contact = new Contact();
    	contact.FirstName = 'Contact';
    	contact.LastName = 'Name';
    	contact.email = 'test@test.com';
    	contact.AccountId = acc.Id;
    	insert contact;
    	
    	Campaign camp = new Campaign();
    	camp.Name = 'Campaign name';
    	insert camp;
        
        Id MarketTaskRType = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Marketo Task').getRecordTypeId();
        
        System.debug(MarketTaskRType);
        
        Task task9 = new Task();
        task9.recordTypeId = MarketTaskRType;
        task9.Description = 'Campaign ID: ' + camp.id + ' \n Division: '+ ' ' + '\n Product: aCloud HR\n Reviewing Software: Yes\n Existing Software: dog, we’re using manual systems\n TimeFrame: 0-3 Months ';
        task9.WhoId = contact.Id;
        System.debug('xpto:'+task9);
        try{
       		insert task9;
        }catch(Exception e){
        	System.debug('debug');
        }
    }
    static testMethod void testTaskTriggerTen() {
        Account acc = new Account();
    	acc.Name = 'Account test';
    	insert acc;
    	Contact contact = new Contact();
    	contact.FirstName = 'Contact';
    	contact.LastName = 'Name';
    	contact.email = 'test@test.com';
    	contact.AccountId = acc.Id;
    	insert contact;
    	
    	Campaign camp = new Campaign();
    	camp.Name = 'Campaign name';
    	insert camp;
        
        Id MarketTaskRType = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Marketo Task').getRecordTypeId();
        
        System.debug(MarketTaskRType);
        
        Task task10 = new Task();
        task10.recordTypeId = MarketTaskRType;
        task10.Description = 'Campaign ID: ' + camp.id + ' \n Division: aCloud\n Product: '+' '+ '\n Reviewing Software: Yes\n Existing Software: dog, we’re using manual systems\n TimeFrame: 0-3 Months ';
        task10.WhoId = contact.Id;
        System.debug('xpto:'+task10);
        try{
       		insert task10;
        }catch(Exception e){
        	System.debug('debug');
        }
    }
    static testMethod void testTaskTriggerEleven() {
        Account acc = new Account();
    	acc.Name = 'Account test';
    	insert acc;
    	Contact contact = new Contact();
    	contact.FirstName = 'Contact';
    	contact.LastName = 'Name';
    	contact.email = 'test@test.com';
    	contact.AccountId = acc.Id;
    	insert contact;
    	
    	Campaign camp = new Campaign();
    	camp.Name = 'Campaign name';
    	insert camp;
        
        Id MarketTaskRType = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Marketo Task').getRecordTypeId();
        
        System.debug(MarketTaskRType);
        
        Task task11 = new Task();
        task11.recordTypeId = MarketTaskRType;
        task11.Description = 'Campaign ID: ' + camp.Id + ' \n Division: aCloud\n Product: aCloud HR\n Reviewing Software: '+' '+' \n Existing Software: dog, we’re using manual systems\n TimeFrame: 0-3 Months ';
        task11.WhoId = contact.Id;
        System.debug(task11);
        try{
       		insert task11;
        }catch(Exception e){
        	System.debug('debug');
        }
    }
    static testMethod void testTaskTriggerTwelve() {
        Account acc = new Account();
    	acc.Name = 'Account test';
    	insert acc;
    	Contact contact = new Contact();
    	contact.FirstName = 'Contact';
    	contact.LastName = 'Name';
    	contact.email = 'test@test.com';
    	contact.AccountId = acc.Id;
    	insert contact;
    	
    	Campaign camp = new Campaign();
    	camp.Name = 'Campaign name';
    	insert camp;
        
        Id MarketTaskRType = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Marketo Task').getRecordTypeId();
        
        System.debug(MarketTaskRType);
        
        Task task12 = new Task();
        task12.recordTypeId = MarketTaskRType;
        task12.Description = 'Campaign ID: ' + camp.Id + ' \n Division: aCloud\n Product: aCloud HR\n Reviewing Software: Yes\n Existing Software: '+ ' ' + '\n TimeFrame: 0-3 Months ';
        task12.WhoId = contact.Id;
        System.debug(task12);
        try{
       		insert task12;
        }catch(Exception e){
        	System.debug('debug');
        }
    }
    static testMethod void testTaskTriggerThirteen() {
        Account acc = new Account();
    	acc.Name = 'Account test';
    	insert acc;
    	Contact contact = new Contact();
    	contact.FirstName = 'Contact';
    	contact.LastName = 'Name';
    	contact.email = 'test@test.com';
    	contact.AccountId = acc.Id;
    	insert contact;
    	
    	Campaign camp = new Campaign();
    	camp.Name = 'Campaign name';
    	insert camp;
        
        Id MarketTaskRType = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Marketo Task').getRecordTypeId();
        
        System.debug(MarketTaskRType);
        
        Task task13 = new Task();
        task13.recordTypeId = MarketTaskRType;
        task13.Description = 'Campaign ID: ' + camp.id + ' \n Division: aCloud\n Product: aCloud HR\n Reviewing Software: Yes\n Existing Software: dog, we’re using manual systems\n TimeFrame: ' + 'Error ';
        task13.WhoId = contact.Id;
        System.debug(task13);
        try{
       		insert task13;
        }catch(Exception e){
        	System.debug('debug');
        }
    }
    static testMethod void testTaskTriggerFourteen() {
        Account acc = new Account();
    	acc.Name = 'Account test';
    	insert acc;
    	Contact contact = new Contact();
    	contact.FirstName = 'Contact';
    	contact.LastName = 'Name';
    	contact.email = 'test@test.com';
    	contact.AccountId = acc.Id;
    	insert contact;
    	
    	Campaign camp = new Campaign();
    	camp.Name = 'Campaign name';
    	insert camp;
        
        Id MarketTaskRType = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Marketo Task').getRecordTypeId();
        
        System.debug(MarketTaskRType);
        
        Task task14 = new Task();
        task14.recordTypeId = MarketTaskRType;
        task14.Description = 'Campaign ID: ' + '' + ' \n Division: aCloud\n Product: aCloud HR\n Reviewing Software: Yes\n Existing Software: dog, we’re using manual systems\n TimeFrame: ' + ' ';
        task14.WhoId = contact.Id;
        System.debug(task14);
        try{
       		insert task14;
        }catch(Exception e){
        	System.debug('debug');
        }
    }
    static testMethod void testTaskTriggerFifteen() {
        Account acc = new Account();
    	acc.Name = 'Account test';
    	insert acc;
    	Contact contact = new Contact();
    	contact.FirstName = 'Contact';
    	contact.LastName = 'Name';
    	contact.email = 'test@test.com';
    	contact.AccountId = acc.Id;
    	insert contact;
    	
    	        
        Id MarketTaskRType = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Marketo Task').getRecordTypeId();
        
        System.debug(MarketTaskRType);
        
        Task task14 = new Task();
        task14.recordTypeId = MarketTaskRType;
        task14.Description = 'Campaign ID: ' + '' + ' \n Division: aCloud\n Product: aCloud HR\n Reviewing Software: Yes\n Existing Software: dog, we’re using manual systems\n TimeFrame: 18 - 54 Months';
        task14.WhoId = contact.Id;
        System.debug(task14);
        try{
       		insert task14;
        }catch(Exception e){
        	System.debug('debug');
        }
    }}