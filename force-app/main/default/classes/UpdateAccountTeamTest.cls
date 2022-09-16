// Andrew Mannering 03/08/2017 13:08
// Test Class for UpdateAccountTeam Trigger
// This class need updating so it creates its own user rahter than using real users for the test, as when people leave (Like andrew did) it breaks deployment
@isTest
public class UpdateAccountTeamTest {
    
    /* public static testMethod void testinsertnewCSM(){
        //Check CSM Is created in account Team When new account is created
        id Usr = [Select id from User where Alias = 'clewi' AND isactive = TRUE Limit 1].id;
      
        
              
      
        test.startTest();
            
        Account Acc = new Account();
        acc.name = 'Test Account';
        acc.Type = 'Customer';
        acc.CSM_Owner__c = Usr;
        
        Insert Acc;
            
                
        
        accountteammember team = new accountteammember();
        team.AccountId = acc.id;
        team.TeamMemberRole = 'Customer Success Manager';
        team.UserId = acc.CSM_Owner__c;
        team.AccountAccessLevel = 'Edit';
        team.CaseAccessLevel = 'Edit';
        
        Insert team;
        
        List<Accountteammember> accountteamsize = [SELECT id from Accountteammember Where accountid = :acc.Id AND TeamMemberRole = 'Customer Success Manager'];
        
        system.assertEquals(1, accountteamsize.size() );
        
        test.stopTest();
       
        
    }
    
        public static testMethod void testUpdateCSM(){
        //Check old CSM is removed and New CSM created when ids dont Match
        id Usr = [Select id from User where Alias = 'clewi' AND isactive = TRUE Limit 1].id;
        id UsrReplace = [Select id from User where Alias = 'intuser' AND isactive = TRUE Limit 1].id;     
      
                    
      
   
            
        Account Acc = new Account();
        acc.name = 'Test Account';
        acc.Type = 'Customer';
        acc.CSM_Owner__c = Usr;
        acc.ownerid = UsrReplace;
        
        Insert Acc;
            
                
        
        accountteammember team = new accountteammember();
        team.AccountId = acc.id;
        team.TeamMemberRole = 'Customer Success Manager';
        team.UserId = acc.CSM_Owner__c;
        team.AccountAccessLevel = 'Edit';
        team.CaseAccessLevel = 'Edit';
        
        Insert team;
        
        List<Accountteammember> accountteamsize = [SELECT id from Accountteammember Where accountid = :acc.Id AND TeamMemberRole = 'Customer Success Manager'];
        
        system.assertEquals(1, accountteamsize.size() );
        
        test.startTest();
        
        // Replace Insert CSM with New CSM To trigger Update
        acc.CSM_Owner__c = usrReplace;
            
        Update acc;  
        
        System.assertEquals('00558000001IEk4', acc.CSM_Owner__c); 
            
        test.stopTest();    
       
        
    }
    
            public static testMethod void testinsertCSMoldaccount(){
		//check CSM is inserted for existing Account        
        id Usr = [Select id from User where Alias = 'clewi' AND isactive = TRUE Limit 1].id;
           
      
                    
      
   
            
        Account Acc = new Account();
        acc.name = 'Test Account';
        acc.Type = 'Customer';
                
        Insert Acc;
        
               
        test.startTest();
        
        //insert CSM into existing account
        acc.CSM_Owner__c = usr;
                
                
            
        Update acc; 
                
        List<Accountteammember> accountteamsize = [SELECT id from Accountteammember Where accountid = :acc.Id AND TeamMemberRole = 'Customer Success Manager'];        
        
        System.assertEquals(1, accountteamsize.size()); 
            
        test.stopTest();    
       
        
    } */

}