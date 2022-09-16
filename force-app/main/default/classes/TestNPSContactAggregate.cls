@istest

public class TestNPSContactAggregate {
    
    public static testMethod void testinsertNewContact(){
        
        account acc = New Account();
        acc.Name = 'Test';
        Insert acc;
        
        test.startTest();        
        
        Contact Cont1 = New Contact();
        Cont1.LastName = 'Tester';
        Cont1.AccountId = acc.Id;
        Cont1.NPS__c = 'YES';
        
        
        Insert Cont1;
        
        List<Account> AccountswithNPSCoverage = [SELECT id from Account Where Contact_Count__c >= 1];
        
        system.assertEquals(1, AccountswithNPSCoverage.size() );
        
        test.stopTest();
       
        
    }
    
    public static testMethod void testBULKinsertNewContact(){
            
        List<Contact> BlkCont = New List<Contact>();
      
        Account Acc = new Account();
        acc.name = 'Test Account';
        acc.Type = 'Customer';
        acc.HasNPSCoverage__c = False;
        
        Insert Acc;
            
        test.startTest();        
        
        For(Integer i=0; i<200; i++){
                
        Contact Cont1 = New Contact();
        Cont1.LastName = 'Tester ' + i;
        Cont1.AccountId = acc.Id;
        Cont1.NPS__c = 'YES';
        
        BlkCont.add(Cont1);
        
                                        }        
        Insert BlkCont;
        
        List<Account> AccountswithNPSCoverage = [SELECT id from Account Where Contact_Count__c >= 1];
        
        system.assertEquals(1, AccountswithNPSCoverage.size());
        System.debug(acc.Contact_Count__c);
        //system.assertEquals(BlkCont.size(), acc.Contact_Count__c);
        
        test.stopTest();
       
        
    }
    public static testMethod void testUpdateContact(){     
      
        Account Acc = new Account();
        acc.name = 'Test Account';
        acc.Type = 'Customer';
        acc.HasNPSCoverage__c = False;
        
        Insert Acc;
            
        test.startTest();        
        
        Contact Cont1 = New Contact();
        Cont1.LastName = 'Tester';
        Cont1.AccountId = acc.Id;
        
        
        Insert Cont1;
        
        List<Account> AccountswithNPSCoverage = [SELECT id from Account Where Contact_Count__c >= 1];
        
        system.assertEquals(0, AccountswithNPSCoverage.size() );
        
        Cont1.NPS__c = 'YES';
        
        Update Cont1;
        
        List<Account> AccountswithNPSCoverage2 = [SELECT id from Account Where Contact_Count__c >= 1];
        
        system.assertEquals(1, AccountswithNPSCoverage2.size() );
        
        test.stopTest();
       
        
    }
    
        public static testMethod void testDeleteContact(){     
      
        Account Acc = new Account();
        acc.name = 'Test Account';
        acc.Type = 'Customer';
        acc.HasNPSCoverage__c = False;
        
        Insert Acc;
            
        test.startTest();        
        
        Contact Cont1 = New Contact();
        Cont1.LastName = 'Tester';
        Cont1.AccountId = acc.Id;
        Cont1.NPS__c = 'YES';
        
        
        Insert Cont1;
        
        List<Account> AccountswithNPSCoverage = [SELECT id from Account Where Contact_Count__c >= 1];
        
        system.assertEquals(1, AccountswithNPSCoverage.size() );
        
        
        
        Delete Cont1;
        
        List<Account> AccountswithNPSCoverage2 = [SELECT id from Account Where Contact_Count__c >= 1];
        
        system.assertEquals(0, AccountswithNPSCoverage2.size() );
        
        test.stopTest();
       
        
    }
    
    public static testMethod void testBULKinsertMultiAccountNewContact(){
            
        List<Contact> BlkCont = New List<Contact>();
      
        Account Acc = new Account();
        acc.name = 'Test Account';
        acc.Type = 'Customer';
        acc.HasNPSCoverage__c = False;
        
        Insert Acc;
        
        Account Acc2 = new Account();
        acc2.name = 'Test Account2';
        acc2.Type = 'Customer';
        acc2.HasNPSCoverage__c = False;
        
        Insert Acc2;
            
        test.startTest();        
        
        For(Integer i=0; i<200; i++){
                
        Contact Cont1 = New Contact();
        Cont1.LastName = 'Tester ' + i;
        Cont1.AccountId = acc.Id;
        Cont1.NPS__c = 'YES';
        
        BlkCont.add(Cont1);
        
                                        }  
        
        For(Integer i=0; i<200; i++){
                
        Contact Cont2 = New Contact();
        Cont2.LastName = 'Tester ' + i;
        Cont2.AccountId = acc2.Id;
        Cont2.NPS__c = 'YES';
        
        BlkCont.add(Cont2);
        
                                        }    
        Insert BlkCont;
        
        List<Account> AccountswithNPSCoverage = [SELECT id from Account Where Contact_Count__c >= 1];
        
        system.assertEquals(2, AccountswithNPSCoverage.size());
        System.debug(acc.Contact_Count__c);
        //system.assertEquals(BlkCont.size(), acc.Contact_Count__c);
        
        test.stopTest();
       
        
    }
}