@IsTest
class SandboxPostPrepTest {

    @IsTest static void RunPostPrep(){
        Test.startTest();
        Test.testSandboxPostCopyScript(
            new SandboxPostPrep(), UserInfo.getOrganizationId(), UserInfo.getOrganizationId(), UserInfo.getOrganizationName());
        Test.stopTest();   
        
        list<Account> acc = [select id, name from account where AccountNumber = 'SSE001'];
        list<contact> con = [select id, name from Contact where email = 'Sean.Sheep@Notarealemail.com'];
        list<ProductRouting__c> pr = [select id, name from ProductRouting__c where name = 'Access Applause'];
        list<Entitlement> ent = [select id, name from Entitlement where name = 'Standard Access Applause'];
        list<EntitlementContact> enc = [select id, name from EntitlementContact];

        system.assertEquals(1, acc.size());
        system.assertEquals(1, con.size());
        system.assertEquals(1, pr.size());
        system.assertEquals(1, enc.size());


    }


}