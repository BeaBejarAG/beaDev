@isTest
public class lscEntitlementHandlerTest {

    @IsTest
    public static void GetAccountEnts(){

        Account acc = new Account(Name='Test Account 1');
        insert acc;
        
        ProductRouting__C prod = new ProductRouting__C(name='Dimensions');
        prod.Product_Division__c = 'No Primary Division';
        insert prod;
        
        contract con = new Contract(Name='DM555',PlanType__C = 'Classic', ProductRange__c = 'Dimensions', AccountID = acc.id);
        insert con;
        
        Contact Ctact = new Contact(FirstName='Mike', LastName='Hunt', Email='Test@Test.com', AccountId = acc.id, Status__c = 'Active');
        insert Ctact;
        
        Entitlement Ent = new Entitlement(name='Dimensions Classic', Contract__C = con.id, AssociatedProductRange__c = 'Dimensions', AccountID = acc.id, StartDate = date.today(), EndDate = date.today() + 2);
        insert Ent;

        lscEntitlementHandler lsc = new lscEntitlementHandler();

        List<Contact> acccon = new List<Contact>();
		List<Contact> accconfiltered = new List<Contact>();
        List<String> conids = new List<String>();
        List<EntitlementContact> entcon = new List<EntitlementContact>();
        List<Entitlement> EntList = new List<Entitlement>();
        List<Entitlement> EntListacc = new List<Entitlement>();

        acccon = lscEntitlementHandler.GetAccountContacts(ent.id, acc.id);
        Integer sizeOfContactList = acccon.size();

        System.Assert(sizeOfContactList > 0);

        conids.add(acccon[0].Id);

        accconfiltered = lscEntitlementHandler.GetAccountContactsFliterd(ent.id, acc.id, 'Mi');
        Integer sizeOfEntitmenetListfiltered = accconfiltered.size();
        
        System.Assert(sizeOfEntitmenetListfiltered > 0);
        
        entlistacc = lscEntitlementHandler.GetAccountEntitlements(Ctact.id, acc.id);
        Integer sizeOfEntitmenetListacc = entlistacc.size();
        
        System.Assert(sizeOfEntitmenetListacc > 0);


        lscEntitlementHandler.AddEntContacts(conids, ent.id);

        entcon = lscEntitlementHandler.GetEntitlementContacts(ent.id);
        Integer sizeOfEntList = entcon.size();

        System.Assert(sizeOfEntList > 0);
        
        entlist = lscEntitlementHandler.GetContactEntitlements(Ctact.id, acc.id);
        Integer sizeOfEntitmenetList = entlist.size();
        
        System.Assert(sizeOfEntitmenetList > 0);
        

        lscEntitlementHandler.DeleteEntContacts(entcon[0].Id);

        entcon = lscEntitlementHandler.GetEntitlementContacts(ent.id);
        sizeOfEntList = entcon.size();

        System.Assert(sizeOfEntList == 0);

		lscEntitlementHandler.AddEntContactscon(Ctact.id, ent.id);
        
        lscEntitlementHandler.DeleteEntContact(ent.id, Ctact.id);
        
        

    }
}