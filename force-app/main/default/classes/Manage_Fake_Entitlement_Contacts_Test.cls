@IsTest
private class Manage_Fake_Entitlement_Contacts_Test {

    static testMethod void CreateContact()
    {
        Account acc = new Account(Name='Test Account 1');
        insert acc;
        
        ProductRouting__C prod = new ProductRouting__C(name='Dimensions');
        prod.Product_Division__c = 'No Primary Division';
        insert prod;
        
        contract con = new Contract(Name='DM555',PlanType__C = 'Classic', ProductRange__c = 'Dimensions', AccountID = acc.id);
        insert con;
        
        Contact Ctact = new Contact(FirstName='Mike', LastName='Hunt', Email='Test@Test.com', AccountID = acc.id);
        insert Ctact;
        
        Entitlement Ent = new Entitlement(name='Dimensions Classic', Contract__C = con.id, AssociatedProductRange__c = 'Dimensions', AccountID = acc.id, StartDate = date.today(), EndDate = date.today() + 2);
        insert Ent;
        
        EntitlementContact EntCon = new EntitlementContact(Contactid = Ctact.id, Entitlementid = Ent.id);
        insert EntCon;
    }
    
        static testMethod void UpdateContact()
    {
        Account acc = new Account(Name='Test Account 1');
        insert acc;
        
        ProductRouting__C prod = new ProductRouting__C(name='Dimensions');
        prod.Product_Division__c = 'No Primary Division';
        insert prod;
        
        ProductRouting__C prod2 = new ProductRouting__C(name='Focalpoint');
        prod2.Product_Division__c = 'No Primary Division';
        insert prod2;
        
        contract con = new Contract(Name='DM555',PlanType__C = 'Classic', ProductRange__c = 'Dimensions', AccountID = acc.id);
        insert con;
        
        Contact Ctact = new Contact(FirstName='Mike', LastName='Hunt', Email='Test@Test.com', AccountID = acc.id);
        insert Ctact;
        
        Entitlement Ent = new Entitlement(name='Dimensions Classic', Contract__C = con.id, AssociatedProductRange__c = 'Dimensions', AccountID = acc.id, StartDate = date.today(), EndDate = date.today() + 2);
        insert Ent;
        
        EntitlementContact EntCon = new EntitlementContact(Contactid = Ctact.id, Entitlementid = Ent.id);
        insert EntCon;
        
        Ent.AssociatedProductRange__c = 'Focalpoint';
        update con;
        
        delete EntCon;
    }
    
            static testMethod void DeleteContact()
    {
        Account acc = new Account(Name='Test Account 1');
        insert acc;
        
        ProductRouting__C prod = new ProductRouting__C(name='Dimensions');
        prod.Product_Division__c = 'No Primary Division';
        insert prod;
        
        ProductRouting__C prod2 = new ProductRouting__C(name='Focalpoint');
        prod2.Product_Division__c = 'No Primary Division';
        insert prod2;
        
        contract con = new Contract(Name='DM555',PlanType__C = 'Classic', ProductRange__c = 'Dimensions', AccountID = acc.id);
        insert con;
        
        Contact Ctact = new Contact(FirstName='Mike', LastName='Hunt', Email='Test@Test.com', AccountID=acc.id);
        insert Ctact;
        
        Entitlement Ent = new Entitlement(name='Dimensions Classic', Contract__C = con.id, AssociatedProductRange__c = 'Dimensions', AccountID = acc.id, StartDate = date.today(), EndDate = date.today() + 2);
        insert Ent;
        
        EntitlementContact EntCon = new EntitlementContact(Contactid = Ctact.id, Entitlementid = Ent.id);
        insert EntCon;
        
        delete EntCon;
    }
}