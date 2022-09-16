public with sharing class AssetTriggerHandler {
    public static Boolean disableAssetTrigger = false;
    public static Boolean disableBaseElementDeactivatation = false;
    public static Boolean disableBaseElementActivatation = false;

    @TestVisible
    private Map<Id, Asset> newAssetsMap {
        get {
            if (newAssetsMap == null) {
                newAssetsMap = new Map<Id, Asset>();
            }

            return newAssetsMap;
        }
        set;
    }

    @TestVisible
    private Map<Id, Asset> oldAssetsMap {
        get {
            if (oldAssetsMap == null) {
                oldAssetsMap = new Map<Id, Asset>();
            }

            return oldAssetsMap;
        }
        set;
    }

    @TestVisible
    private AssetTriggerHandler() { }

    public static AssetTriggerHandler getInstance(Map<Id, Asset> newAssetsMap, Map<Id, Asset> oldAssetsMap) {
        AssetTriggerHandler handler = new AssetTriggerHandler();
        handler.newAssetsMap = newAssetsMap;
        handler.oldAssetsMap = oldAssetsMap;

        return handler;
    }

    public static void createModules(Map<Id, Asset> assets) {
        List<Id> assetContractIds = new List<Id>();
        for(Asset asset: assets.values()) {
            assetContractIds.add(asset.Contract__c);
        }
        
        // Used later to determine if contracts for the assets are 
        // valid according to criteria - active and with an end date
        Map<Id, Contract> contractMap = new Map<Id, Contract>([
            SELECT Id,
                AccountId, 
                Account.Name,
                Account.OwnerId,
                Name, 
                Contract_Status__c, 
                CustomerSignedId, 
                EndDate, 
                Contract_End_Date__c,
                Last_Uplift_Date__c,
                Price_Before_Last_Uplift__c,
                IsDealer__c,
                Do_Not_Renew__c
            FROM Contract 
            WHERE Id IN: assetContractIds
        ]);
        
        // Find an existing opportunitity for the contracts 
        // associated with these assets, key with contract ID
        List<Opportunity> opportunities = [
            SELECT Id, ContractId 
            FROM Opportunity 
            WHERE ContractId IN: assetContractIds
            AND RecordType.Name =: ContractTriggerHandler.RENEWAL_RECORD_TYPE
        ];
        Map<Id, Opportunity> opportunityMap = new Map<Id, Opportunity>();
        for(Opportunity opportunity: opportunities) {
            opportunityMap.put(opportunity.ContractId, opportunity);
        }

        List<Module__c> modulesToCreate = new List<Module__c>();
        Map<Id, Asset> modulesToCreateAfterOpportunity = new Map<Id, Asset>();
        List<Id> opportunitiesToCreate = new List<Id>();
        for (Asset asset: assets.values()) {
            try {
                // If contract associated with these assets doesn't meet criteria
                // then do not create modules or opportunity
                Contract contract = contractMap.get(asset.Contract__c);
                if(contract.Contract_Status__c != 'Active' || contract.EndDate == null) {
                    continue;
                }
            } catch(Exception e) {
                continue;
            }
            
            try {
                Opportunity opportunity = opportunityMap.get(asset.Contract__c);
                modulesToCreate.add(AssetTriggerHandler.mapAssetToModule(asset, opportunity.Id));            
            } catch(Exception e) {
                opportunitiesToCreate.add(asset.Contract__c);
                modulesToCreateAfterOpportunity.put(asset.Id, asset);
            }
        }   
        insert modulesToCreate;
        
        // Any assets that were due to have modules created but couldn't
        // due to missing opportunity are created here and ran again
        if(opportunitiesToCreate.size() > 0) {
            Map<Id, Contract> contracts = new Map<Id, Contract>([
                SELECT Id, 
                    AccountId, 
                    Account.Name,
                    Account.OwnerId,
                    Name, 
                    Contract_Status__c, 
                    CustomerSignedId, 
                    EndDate, 
                    Contract_End_Date__c,
                    Last_Uplift_Date__c,
                    Price_Before_Last_Uplift__c,
                    IsDealer__c,
                    Do_Not_Renew__c
                FROM Contract
                WHERE Id IN: opportunitiesToCreate
            ]);
            
            for(Contract contract: contracts.values()) {
                ContractTriggerHandler.createRenewalOpportunity(contracts);
            }
            
            AssetTriggerHandler.createModules(modulesToCreateAfterOpportunity);
        }
    }
    
    public static void updateModules(Map<Id, Asset> assets) {
        // Find any existing modules for the assets in the list
        // and key them with the asset ID
        List<Module__c> modules = [
            SELECT Id, Asset__c, Contract__c, Account__c
            FROM Module__c
            WHERE Asset__c IN: assets.keySet()
        ]; 
        Map<Id, Module__c> modulesByAssetId = new Map<Id, Module__c>();
        for(Module__c module: modules) {
            modulesByAssetId.put(module.Asset__c, module);
        }
                
        List<Module__c> modulesToUpdate = new List<Module__c>();
        Map<Id, Asset> modulesToCreate = new Map<Id, Asset>();
        for (Asset asset: assets.values()) {
            // Map the Asset to the Module and update it, if the Module can't 
            // be found then add it to a list to be created 
            Module__c module = AssetTriggerHandler.mapAssetToModule(asset, null);  
            try {
                module.Id = modulesByAssetId.get(asset.Id).Id;
                modulesToUpdate.add(module);
            } catch(Exception e) {
                modulesToCreate.put(asset.Id, asset);
            }
        }
        update modulesToUpdate;
        
        // No existing module for this asset
        if(modulesToCreate.size() > 0) {
            AssetTriggerHandler.createModules(modulesToCreate);
        }
    }

    public static Module__c mapAssetToModule(Asset asset, Id opportunityId) {
        return new Module__c(
            Account__c = asset.AccountId,
            CurrencyIsoCode = asset.CurrencyIsoCode,
            Asset_Family__c = asset.Asset_Family__c,
            Name = asset.Name,
            Asset_Status__c = asset.Status,
            Contract__c = asset.Contract__c,
            Contract_End_Date__c = asset.Contract_End_Date__c,
            Contract_Status__c = asset.Contract_Status__c,
            Contract_Version__c = asset.Contract_Version__c,
            Description__c = asset.Description,
            DNR_Date__c = asset.DNR_Date__c,
            DNR_Reason_Code_1__c = asset.DNR_Reason_Code_1__c,
            DNR_Reason_Code_2__c = asset.DNR_Reason_Code_2__c,
            Do_Not_Renew__c = asset.Do_Not_Renew__c,
            Expected_Warranty_End_Date__c = asset.Expected_Warranty_End_Date__c,
            Install_Date__c = asset.InstallDate,
            Integration_Id__c = asset.Integration_Id__c,
            License_Key__c = asset.LicenseKey__c,
            Module__c = asset.Module__c,
            Number_of_Users__c = asset.Number_of_Users__c,
            Opportunity__c = opportunityId,
            Original_Start_Date__c = asset.Original_Start_Date__c,
            Price__c = asset.Price,
            Product__c = asset.Product2Id,
            Product_Code_SME__c = asset.Product_Code_SME__c,
            Product_Name_SME__c = asset.Product_Name_SME__c,
            Product_Code__c = asset.ProductCode,
            Product_SKU__c = asset.StockKeepingUnit,
            Quantity__c = asset.Quantity,
            Renewal_Price__c = asset.Renewal_Price__c,
            Revenue_Type__c = asset.ProductFamily,
            Serial_Number__c = asset.SerialNumber,
            Total_Price__c = asset.Total_Price__c,
            Total_Renewal_Price__c = asset.Total_Renewal_Price__c,
            Usage_End_Date__c = asset.UsageEndDate,
            Asset__c = asset.Id
        );
    }

    private class AssetTriggerException extends Exception { }
}