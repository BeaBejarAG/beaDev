global class SandboxPostPrep implements SandboxPostCopy {

    global void runApexClass(SandboxContext context){

        account acc = new account();
        acc.Name = 'Super Shiny Entertainment';
        acc.AccountNUmber = 'SSE001';
        insert acc;

        account acc1 = new account();
        acc1.Name = 'Abysmaly Dirty Bordom';
        acc1.AccountNUmber = 'ADB001';
        insert acc1;

        Contact con = new Contact();
        con.FirstName = 'Sean';
        con.LastName = 'Sheep';
        con.Email = 'Sean.Sheep@Notarealemail.com';
        con.Status__c = 'Active';
        con.Accountid = acc.id;
        insert con;

        Contact con1 = new Contact();
        con1.FirstName = 'sally';
        con1.LastName = 'Sheep';
        con1.Email = 'sally.Sheep@Notarealemail.com';
        con1.Status__c = 'Active';
        con1.Accountid = acc.id;
        insert con1;

        Contact con2 = new Contact();
        con2.FirstName = 'Mat';
        con2.LastName = 'Creep';
        con2.Email = 'Mat.Creep@Notarealotheremail.com';
        con2.Status__c = 'Active';
        con2.Accountid = acc1.id;
        insert con2;

        Contact con3 = new Contact();
        con3.FirstName = 'Ally';
        con3.LastName = 'Dancer';
        con3.Email = 'Ally.Dancer@Notarealotheremail.com';
        con3.Status__c = 'Active';
        con3.Accountid = acc1.id;
        insert con3;

        ProductRouting__c prc = new ProductRouting__c();
        prc.Name = 'Access Applause';
        prc.Related_Product_Range__c = 'Access Applause';
        prc.Enabled_For_Web_Cases__c = 'Available';
        prc.Enabled_For_Telephony__c = 'Available';
        prc.Dedicated_Telephone_Number__c = '01234 567 890';
        prc.Product_Division__c = 'HCM';
        insert prc;



        Entitlement ent = new Entitlement();
        ent.name = 'Standard Access Applause';
        ent.AssociatedProductRange__c = 'Access Applause';
        ent.ProductRouting__c = prc.id;
        ent.StartDate = Date.newInstance(2020, 01, 01);
        ent.EndDate = Date.newInstance(3000, 01, 01);
        ent.PlanType__c = 'Standard';
        ent.Accountid = acc.id;
        insert ent;

        EntitlementContact entc = new EntitlementContact();
        entc.Contactid = con.id;
        entc.EntitlementId = ent.id;
        insert entc;




    }
}