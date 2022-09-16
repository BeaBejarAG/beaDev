@IsTest
public class EntitlmentContactTriggerTest {
    
    static testmethod void Testbooleantrue()
    {
        Account acc = new Account(Name='Test Account 1');
        insert acc;
        
        Account acc2 = new Account(Name='Test Account 2');
        insert acc2;
        
        ProductRouting__C prod = new ProductRouting__C(name='Dimensions');
        prod.Product_Division__c = 'No Primary Division';
        insert prod;
        
        contract con = new Contract(Name='DM555',PlanType__C = 'Classic', ProductRange__c = 'Dimensions', AccountID = acc.id);
        insert con;
        
        Contact Ctact = new Contact(FirstName='Mike', LastName='Hunt', Email='Test@Test.com', AccountId = acc.id);
        insert Ctact;
        
        Entitlement Ent = new Entitlement(name='Dimensions Classic', Contract__C = con.id, AssociatedProductRange__c = 'Dimensions', AccountID = acc.id, StartDate = date.today(), EndDate = date.today() + 2);
        insert Ent;
        
        EntitlementContact EntCon = new EntitlementContact(Contactid = Ctact.id, Entitlementid = Ent.id);
        insert EntCon;
        
        delete EntCon;
    }
    
        static testmethod void TestbooleanFalse()
    {
        Account acc = new Account(Name='Test Account 1');
        insert acc;
        
        Account acc2 = new Account(Name='Test Account 2');
        insert acc2;
        
        ProductRouting__C prod = new ProductRouting__C(name='Dimensions');
        prod.Product_Division__c = 'No Primary Division';
        insert prod;
        
        contract con = new Contract(Name='DM555',PlanType__C = 'Classic', ProductRange__c = 'Dimensions', AccountID = acc.id);
        insert con;
        
        Contact Ctact = new Contact(FirstName='Mike', LastName='Hunt', Email='Test@Test.com', AccountId = acc2.id);
        insert Ctact;
        
        Entitlement Ent = new Entitlement(name='Dimensions Classic', Contract__C = con.id, AssociatedProductRange__c = 'Dimensions', AccountID = acc2.id, StartDate = date.today(), EndDate = date.today() + 2);
        insert Ent;
        
        EntitlementContact EntCon = new EntitlementContact(Contactid = Ctact.id, Entitlementid = Ent.id);
        insert EntCon;
        
        delete EntCon;
    }

}