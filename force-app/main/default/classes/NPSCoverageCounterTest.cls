@isTest
public class NPSCoverageCounterTest {
    
  //      public static testMethod void testBULKinsertNewContact(){
            
    //    List<Contact> BlkCont = New List<Contact>();
      
      //  Account Acc = new Account();
        //acc.name = 'Test Account';
        //acc.Type = 'Customer';
        //acc.HasNPSCoverage__c = False;
        
        //Insert Acc;
            
        //test.startTest();        
        
        //For(Integer i=0; i<200; i++){
                
        //Contact Cont1 = New Contact();
        //Cont1.LastName = 'Tester ' + i;
        //Cont1.AccountId = acc.Id;
        /***Cont1.NPS__c = 'YES';
        
        BlkCont.add(Cont1);
        
                                        }        
        Insert BlkCont;//
        
        List<Account> AccountswithNPSCoverage = [SELECT id from Account Where id = :acc.Id];
        
       // system.assertEquals(True, Acc.HasNPSCoverage__c);
            System.debug(acc.Contact_Count__c);
            system.assertEquals(BlkCont.size(), acc.Contact_Count__c);
        
        test.stopTest();
       
        
    }
    
    public static testMethod void testinsertNewContact(){
      
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
        
        List<Account> AccountswithNPSCoverage = [SELECT id from Account Where hasnpscoverage__C = True];
        
        system.assertEquals(1, AccountswithNPSCoverage.size() );
        
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
        
        List<Account> AccountswithNPSCoverage = [SELECT id from Account Where hasnpscoverage__C = True];
        
        system.assertEquals(0, AccountswithNPSCoverage.size() );
        
        Cont1.NPS__c = 'YES';
        
        Update Cont1;
        
        List<Account> AccountswithNPSCoverage2 = [SELECT id from Account Where hasnpscoverage__C = True];
        
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
        
        List<Account> AccountswithNPSCoverage = [SELECT id from Account Where hasnpscoverage__C = True];
        
        system.assertEquals(1, AccountswithNPSCoverage.size() );
        
        
        
        Delete Cont1;
        
        List<Account> AccountswithNPSCoverage2 = [SELECT id from Account Where hasnpscoverage__C = True];
        
        system.assertEquals(0, AccountswithNPSCoverage2.size() );
        
        test.stopTest();
       
        
    }*/
}