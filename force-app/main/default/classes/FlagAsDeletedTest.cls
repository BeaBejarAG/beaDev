@isTest 
public class FlagAsDeletedTest {
@IsTest
    public static void testdelete()
    {
        account acc_test = new Account();
        acc_test.Name = 'Jack Tests Account';
        insert acc_test;
        
        Contract contract_test = new Contract();
        contract_test.AccountId = acc_test.Id;
        contract_test.Name = 'Test Contract';
        contract_test.Status = 'Draft';
        contract_test.PlanType__c = 'Classic';
        contract_test.ProductRange__c = 'Select HR';
        
        insert contract_test; 
        
        List<entitlement> ent_list = [Select id from entitlement where id = :contract_test.Id];
        
        
       
        
        entitlement ent_test = new entitlement(Name = 'Test Entitlement', AccountId = acc_test.Id, Contract__c = Contract_test.Id, AssociatedProductRange__c = 'Access Approve', plantype__C = 'Classic' );
              
        insert ent_test;
        
        
        Contact contact_test = new Contact();
        contact_test.FirstName = 'Jack';
        contact_test.LastName = 'Test';
        contact_test.Email = 'Jack.Test@test.com';
        contact_test.AccountId = acc_test.Id;
        
        insert contact_test;
                        
         

    }
    
}