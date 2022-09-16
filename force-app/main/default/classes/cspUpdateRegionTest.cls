@isTest
public class cspUpdateRegionTest {
    @TestSetup
    static void makeData(){

        List<Contact> contactsToInsert = new List<Contact>();
        List<Account> accountsToInsert = new List<Account>();

        for(Integer i = 0; i < 200; i++) {
            Account acc = new Account();
            acc.Name = 'AccountForContact'+i;
            acc.Access_Centre__c = 'ANZ-NSW';
            accountsToInsert.add(acc);
        }

        insert accountsToInsert;
        // Refresh list with Id
        accountsToInsert = [SELECT Id FROM Account];

        // Create a load of contacts
        for(Integer i = 0; i < 200; i++) {
            Contact con = new Contact();
            con.LastName ='Contact'+i;

            // as long as we are below 50 (0-49)
            if(i < 50) {
                con.AccountId = accountsToInsert[i].Id;
            }

            contactsToInsert.add(con);
        }

        insert contactsToInsert;
        
    }
    
    @isTest
    static void itShouldUpdateTheRegionsOnTheContacts() {
        // GIVEN We have already set our test records in setup
        // WHEN we run our batched method with a default constructor
        System.Test.startTest();
            cspUpdateRegion batchJobProcess = new cspUpdateRegion(true);
            DataBase.executeBatch(batchJobProcess); 
        System.Test.stopTest();

        List<Contact> contactsForEurope = [SELECT Id FROM Contact WHERE Region__c = :cspUpdateRegion.REGION_EUROPE];
        List<Contact> contactsForOceania = [SELECT Id FROM Contact WHERE Region__c = :cspUpdateRegion.REGION_OCEANIA];

        // THEN We should have 150 Europe Contacts
        System.assertEquals(150, contactsForEurope.size());

        // AND 50 Oceania Contacts
        System.assertEquals(50, contactsForOceania.size());

    }
}