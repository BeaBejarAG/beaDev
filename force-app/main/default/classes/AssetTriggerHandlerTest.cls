@isTest(SeeAllData=false)
public class AssetTriggerHandlerTest {
    @isTest
    private static void newAssetsMap() {
        Account thisAccount = TestUtilities.getAccount();
        insert thisAccount;

        Asset thisAsset = TestUtilities.getAsset(thisAccount.Id);
        insert thisAsset;

        AssetTriggerHandler thisAssetTriggerHandler;

        Test.startTest();
        thisAssetTriggerHandler = new AssetTriggerHandler();

        System.assertEquals(0, thisAssetTriggerHandler.newAssetsMap.size());

        thisAssetTriggerHandler = new AssetTriggerHandler();

        thisAssetTriggerHandler.newAssetsMap.put(thisAsset.Id, thisAsset);

        System.assertEquals(1, thisAssetTriggerHandler.newAssetsMap.size());
        System.assert(thisAssetTriggerHandler.newAssetsMap.containsKey(thisAsset.Id));
        System.assertEquals(thisAsset, thisAssetTriggerHandler.newAssetsMap.get(thisAsset.Id));
        Test.stopTest();
    }

    @isTest
    private static void oldAssetsMap() {
        Account thisAccount = TestUtilities.getAccount();
        insert thisAccount;

        Asset thisAsset = TestUtilities.getAsset(thisAccount.Id);
        insert thisAsset;

        AssetTriggerHandler thisAssetTriggerHandler;

        Test.startTest();
        thisAssetTriggerHandler = new AssetTriggerHandler();

        System.assertEquals(0, thisAssetTriggerHandler.oldAssetsMap.size());

        thisAssetTriggerHandler = new AssetTriggerHandler();

        thisAssetTriggerHandler.oldAssetsMap.put(thisAsset.Id, thisAsset);

        System.assertEquals(1, thisAssetTriggerHandler.oldAssetsMap.size());
        System.assert(thisAssetTriggerHandler.oldAssetsMap.containsKey(thisAsset.Id));
        System.assertEquals(thisAsset, thisAssetTriggerHandler.oldAssetsMap.get(thisAsset.Id));
        Test.stopTest();
    }

    @isTest
    private static void AssetTriggerHandler() {
        AssetTriggerHandler thisAssetTriggerHandler;

        Test.startTest();
        thisAssetTriggerHandler = new AssetTriggerHandler();

        System.assertNotEquals(null, thisAssetTriggerHandler);
        Test.stopTest();
    }

    @isTest
    private static void itShouldCloneAssetsToModules() {
        Account account = TestUtilities.getAccount();
        insert account;

        Contact contact = TestUtilities.getContact(account);
        insert contact;

        Contract contract = new Contract(
            AccountId = account.Id,
            Contract_Status__c = 'Active',
            EndDate = date.today(),
            Contract_End_Date__c = date.today(),
            CustomerSignedId = contact.Id
        );
        insert contract;

        Contact secondaryContact = new Contact(
            LastName = 'test2',
            AccountId = account.Id,
            Email = 'test2@test2.com'
        );
        insert secondaryContact;

        contract.CustomerSignedId = secondaryContact.Id;
        update contract;
        
        Asset asset = new Asset(
            Contract__c = contract.id,
            Name = 'Test Asset',
            AccountId = account.id
        );

        System.Test.startTest();

        insert asset;

        System.Test.stopTest();
        
        List<Module__c> modules = [
            SELECT Id, Contract__c, Account__c
            FROM Module__c 
            WHERE Asset__c =: asset.Id
        ];

        System.assertEquals(1, modules.size());
        System.assertEquals(contract.id, modules.get(0).Contract__c);
        System.assertEquals(account.id, modules.get(0).Account__c);
    }

    @isTest
    private static void itShouldCreateOpportunityIfNotExists() {
        Account account = TestUtilities.getAccount();
        insert account;

        Contact contact = TestUtilities.getContact(account);
        insert contact;

        Contract contract = new Contract(
            AccountId = account.Id,
            Contract_Status__c = 'Active',
            EndDate = date.today(),
            Contract_End_Date__c = date.today(),
            CustomerSignedId = contact.Id
        );
        insert contract;

        Contact secondaryContact = new Contact(
            LastName = 'test2',
            AccountId = account.Id,
            Email = 'test2@test2.com'
        );
        insert secondaryContact;

        contract.CustomerSignedId = secondaryContact.Id;
        update contract;

        Opportunity opportunity = [
            SELECT 
                Primary_Contact__c
            FROM Opportunity
            WHERE ContractId =: contract.Id
        ];
        delete opportunity;
        
        Asset asset = new Asset(
            Contract__c = contract.id,
            Name = 'Test Asset',
            AccountId = account.id
        );

        System.Test.startTest();

        insert asset;

        System.Test.stopTest();
        
        List<Module__c> modules = [
            SELECT Id, Contract__c, Account__c
            FROM Module__c 
            WHERE Asset__c =: asset.Id
        ];

        System.assertEquals(1, modules.size());
        System.assertEquals(contract.id, modules.get(0).Contract__c);
        System.assertEquals(account.id, modules.get(0).Account__c);
    }
}