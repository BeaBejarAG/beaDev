@isTest(SeeAllData=false)
public class ContractTriggerHandlerTest {
    @isTest
    private static void newContractsMap() {
        ContractTriggerHandler.disableContractTrigger = true;

        Account thisAccount = TestUtilities.getAccount();
        insert thisAccount;

        Contract thisContract = TestUtilities.getContract(thisAccount.Id);
        insert thisContract;

        ContractTriggerHandler thisContractTriggerHandler = new ContractTriggerHandler();

        Test.startTest();
        thisContractTriggerHandler.newContractsMap = null;

        System.assertEquals(0, thisContractTriggerHandler.newContractsMap.size());

        thisContractTriggerHandler.newContractsMap.put(thisContract.Id, thisContract);

        System.assertEquals(1, thisContractTriggerHandler.newContractsMap.size());
        System.assertEquals(thisContract, thisContractTriggerHandler.newContractsMap.get(thisContract.Id));
        Test.stopTest();
    }

    @isTest
    private static void oldContractsMap() {
        ContractTriggerHandler.disableContractTrigger = true;

        Account thisAccount = TestUtilities.getAccount();
        insert thisAccount;

        Contract thisContract = TestUtilities.getContract(thisAccount.Id);
        insert thisContract;

        ContractTriggerHandler thisContractTriggerHandler = new ContractTriggerHandler();

        Test.startTest();
        thisContractTriggerHandler.oldContractsMap = null;

        System.assertEquals(0, thisContractTriggerHandler.oldContractsMap.size());

        thisContractTriggerHandler.oldContractsMap.put(thisContract.Id, thisContract);

        System.assertEquals(1, thisContractTriggerHandler.oldContractsMap.size());
        System.assertEquals(thisContract, thisContractTriggerHandler.oldContractsMap.get(thisContract.Id));
        Test.stopTest();
    }

    @isTest
    private static void ContractTriggerHandler() {
        ContractTriggerHandler.disableContractTrigger = true;

        ContractTriggerHandler thisContractTriggerHandler;

        Test.startTest();
        thisContractTriggerHandler = new ContractTriggerHandler();

        System.assertNotEquals(null, thisContractTriggerHandler);
        Test.stopTest();
    }

    @isTest
    private static void getInstance() {
        ContractTriggerHandler.disableContractTrigger = true;

        Account thisAccount = TestUtilities.getAccount();
        insert thisAccount;

        Contract thisContract = TestUtilities.getContract(thisAccount.Id);
        insert thisContract;

        Map<Id, Contract> newContractsMap = new Map<Id, Contract>();
        newContractsMap.put(thisContract.Id, thisContract);

        Map<Id, Contract> oldContractsMap = new Map<Id, Contract>();
        oldContractsMap.put(thisContract.Id, thisContract);

        ContractTriggerHandler thisContractTriggerHandler;

        Test.startTest();
        thisContractTriggerHandler = ContractTriggerHandler.getInstance(null, null);

        System.assertEquals(0, thisContractTriggerHandler.newContractsMap.size());
        System.assertEquals(0, thisContractTriggerHandler.oldContractsMap.size());

        thisContractTriggerHandler = ContractTriggerHandler.getInstance(newContractsMap, oldContractsMap);

        System.assertEquals(1, thisContractTriggerHandler.newContractsMap.size());
        System.assertEquals(thisContract, thisContractTriggerHandler.newContractsMap.get(thisContract.Id));
        System.assertEquals(thisContract, thisContractTriggerHandler.oldContractsMap.get(thisContract.Id));
        Test.stopTest();
    }

  
    @isTest
    private static void deactivateAssets() {
        ContractTriggerHandler.disableContractTrigger = true;

        Account thisAccount = TestUtilities.getAccount();
        insert thisAccount;

        Contract thisContract = TestUtilities.getContract(thisAccount.Id);
        insert thisContract;

        Contract oldContract = TestUtilities.getContract(thisAccount.Id);
        insert oldContract;

        Asset thisAsset = TestUtilities.getAsset(thisAccount.Id);
        thisAsset.Status = Label.Asset_Status_Active;
        insert thisAsset;

        ContractTriggerHandler thisContractTriggerHandler;

        Test.startTest();
        thisContractTriggerHandler = new ContractTriggerHandler();

        thisContractTriggerHandler.deactivateAssets();

        thisAsset = [SELECT Id, Status
                        FROM Asset];

        System.assertEquals(Label.Asset_Status_Active, thisAsset.Status);

        thisContract.Contract_Status__c = Label.Contract_Status_Dead;
        update thisContract;

        thisContractTriggerHandler = new ContractTriggerHandler();
        thisContractTriggerHandler.newContractsMap.put(thisContract.Id, thisContract);

        thisContractTriggerHandler.deactivateAssets();

        thisAsset = [SELECT Id, Status
                        FROM Asset];

        System.assertEquals(Label.Asset_Status_Active, thisAsset.Status);

        thisContract.Contract_Status__c = Label.Contract_Status_Dead;
        update thisContract;

        oldContract.Contract_Status__c = Label.Contract_Status_Expired;
        update oldContract;

        thisContractTriggerHandler = new ContractTriggerHandler();
        thisContractTriggerHandler.newContractsMap.put(thisContract.Id, thisContract);
        thisContractTriggerHandler.oldContractsMap.put(thisContract.Id, oldContract);

        thisContractTriggerHandler.deactivateAssets();

        thisAsset = [SELECT Id, Status
                        FROM Asset];

        System.assertEquals(Label.Asset_Status_Active, thisAsset.Status);

        thisAsset.Contract__c = thisContract.Id;
        update thisAsset;

        thisContract.Contract_Status__c = Label.Contract_Status_Dead;
        update thisContract;

        oldContract.Contract_Status__c = Label.Contract_Status_Expired;
        update oldContract;

        thisContractTriggerHandler = new ContractTriggerHandler();
        thisContractTriggerHandler.newContractsMap.put(thisContract.Id, thisContract);
        thisContractTriggerHandler.oldContractsMap.put(thisContract.Id, oldContract);

        thisContractTriggerHandler.deactivateAssets();

        thisAsset = [SELECT Id, Status
                        FROM Asset];

        System.assertEquals(Label.Asset_Status_Inactive, thisAsset.Status);

        thisAsset.Status = Label.Asset_Status_Active;
        update thisAsset;

        thisContract.Contract_Status__c = Label.Contract_Status_Active;
        update thisContract;

        oldContract.Contract_Status__c = Label.Contract_Status_Expired;

        thisContractTriggerHandler = new ContractTriggerHandler();
        thisContractTriggerHandler.newContractsMap.put(thisContract.Id, thisContract);
        thisContractTriggerHandler.oldContractsMap.put(thisContract.Id, oldContract);

        thisContractTriggerHandler.deactivateAssets();

        thisAsset = [SELECT Id, Status
                        FROM Asset];

        System.assertEquals(Label.Asset_Status_Active, thisAsset.Status);

        //thisContract.Contract_Status__c = Label.Contract_Status_Dead;
        //update thisContract;

        //oldContract.Contract_Status__c = Label.Contract_Status_Dead;
        //update oldContract;

        thisContractTriggerHandler = new ContractTriggerHandler();
        thisContractTriggerHandler.newContractsMap.put(thisContract.Id, thisContract);
        thisContractTriggerHandler.oldContractsMap.put(thisContract.Id, oldContract);

        thisContractTriggerHandler.deactivateAssets();

        thisAsset = [SELECT Id, Status
                        FROM Asset];

        System.assertEquals(Label.Asset_Status_Active, thisAsset.Status);
        Test.stopTest();
    }
    
    @isTest
    private static void itShouldCreateAnOpportunityWhenContractIsCreated() {
        Account account = TestUtilities.getAccount();
        insert account;
        
        Contact contact = TestUtilities.getContact(account);
        insert contact;
        
        Contract contract = new Contract(
            AccountId = account.Id,
            Contract_Status__c = 'Active',
            EndDate = date.today(),
            CustomerSignedId = contact.Id
        );
        insert contract;
        
        System.Test.startTest();
        
        Opportunity opportunity = [
            SELECT 
                Id, 
                RecordType.Name 
            FROM Opportunity 
            WHERE ContractId =: contract.Id
        ];
        
        System.Test.stopTest();
        
        System.assertNotEquals(null, opportunity);
        System.assertEquals('Renewal', opportunity.RecordType.Name);
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
            CustomerSignedId = contact.Id
        );
        insert contract;
        
        Asset asset1 = new Asset(
            AccountId = account.Id,
            Name = '1243256845908',
            Contract__c = contract.Id
        );
        insert asset1;
        
        System.Test.startTest();
                
        List<Module__c> modules = [
            SELECT 
                Id 
            FROM Module__c
            WHERE Contract__c =: contract.Id
        ];
        
        System.Test.stopTest();
        
        System.assertEquals(1, modules.size());
    }
    
    @isTest
    private static void itShouldUpdateOpportunityWhenContractsUpdated() {
        Account account = TestUtilities.getAccount();
        insert account;

        Contact contact = TestUtilities.getContact(account);
        insert contact;

        Contract contract = new Contract(
            AccountId = account.Id,
            Contract_Status__c = 'Active',
            EndDate = date.today(),
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
        
        System.Test.startTest();
        
        update contract;
        
        System.Test.stopTest();

        Opportunity opportunity = [
            SELECT 
                Primary_Contact__c, Name, RecordType.Name
            FROM Opportunity
            WHERE ContractId =: contract.Id
            AND RecordType.Name =: ContractTriggerHandler.RENEWAL_RECORD_TYPE

        ];
        
        System.assertEquals(secondaryContact.Id, opportunity.Primary_Contact__c);
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

        System.Test.startTest();

        update contract;

        System.Test.stopTest();

        System.assertEquals(secondaryContact.Id, opportunity.Primary_Contact__c);
    }
}