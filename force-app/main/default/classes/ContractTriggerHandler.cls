public with sharing class ContractTriggerHandler {
    public static Boolean disableContractTrigger = false;
    public static final String RENEWAL_RECORD_TYPE = 'Renewal';
    public static final String DNR_STAGE = 'Do not renew';
    public static final String DEAD_STAGE = 'Dead';
    public static final String PENDING_STAGE = 'Pending Renewal';
    
    @TestVisible
    private Map<Id, Contract> newContractsMap {
        get {
            if (newContractsMap == null) {
                newContractsMap = new Map<Id, Contract>();
            }

            return newContractsMap;
        }
        set;
    }

    @TestVisible
    private Map<Id, Contract> oldContractsMap {
        get {
            if (oldContractsMap == null) {
                oldContractsMap = new Map<Id, Contract>();
            }

            return oldContractsMap;
        }
        set;
    }

    @TestVisible
    private ContractTriggerHandler() { }

    public static ContractTriggerHandler getInstance(Map<Id, Contract> newContractsMap, Map<Id, Contract> oldContractsMap) {
        ContractTriggerHandler handler = new ContractTriggerHandler();
        handler.newContractsMap = newContractsMap;
        handler.oldContractsMap = oldContractsMap;

        return handler;
    }

   
    public void deactivateAssets() {
        if (newContractsMap.isEmpty() == false) {
            Set<Id> contractIds = new Set<Id>();

            for (Contract thisContract : newContractsMap.values()) {
                Contract oldContract = oldContractsMap.get(thisContract.Id);

                if ((thisContract.Contract_Status__c == Label.Contract_Status_Dead
                            || thisContract.Contract_Status__c == Label.Contract_Status_Expired)
                        && oldContract != null
                        && oldContract.Contract_Status__c != thisContract.Contract_Status__c) {

                    contractIds.add(thisContract.Id);
                }
            }

            if (contractIds.isEmpty() == false) {
                List<Asset> assets = [SELECT Id, Status, Contract__c
                                        FROM Asset
                                        WHERE Contract__c in :contractIds];

                if (assets.isEmpty() == false) {
                    for (Asset thisAsset : assets) {
                        thisAsset.Status = Label.Asset_Status_Inactive;
                    }

                    List<Database.SaveResult> assetSaveResults = Database.update(assets, false);

                    Integer assetIndex = 0;
                    for (Asset thisAsset : assets) {
                        Database.SaveResult assetSaveResult = assetSaveResults[assetIndex];
                        Contract thisContract = newContractsMap.get(thisAsset.Contract__c);

                        if (assetSaveResult.isSuccess() == false) {
                            for (Database.Error thisError : assetSaveResult.getErrors()) {
                                thisContract.addError(thisError.getMessage());
                            }
                        }

                        assetIndex ++;
                    }
                }
            }
        }
    }

    //This method is used in both Update and Create renewal Opp methods, please ensure any changes relivant to both.
    public static Opportunity mapRenewalOpportunity(Contract contract, String accountName) {
        Opportunity opportunity = new Opportunity(
            AccountId = contract.AccountId,
            ContractId = contract.Id,
            RecordType = new RecordType(Name = RENEWAL_RECORD_TYPE),
            CloseDate = contract.Contract_End_Date__c == null ? Date.today() : contract.Contract_End_Date__c,
            Renewal_Date__c = contract.Contract_End_Date__c,
            Last_Uplift_Date__c = contract.Last_Uplift_Date__c,
            Price_Before_Last_Uplift__c = contract.Price_Before_Last_Uplift__c,
            IsDealer__c = contract.IsDealer__c,
            Name = accountName + ' Renewal',
            Primary_Contact__c = contract.CustomerSignedId
        );

        if(contract.Account.OwnerId != null) {
            opportunity.OwnerId = contract.Account.OwnerId;
        }

        if(getRenewalStage(contract) != null) {
            opportunity.StageName = getRenewalStage(contract);
        }

        return opportunity;
    }

    public static String getRenewalStage(Contract contract) {
        if(contract.Do_Not_Renew__c) {
            return DNR_STAGE;
        } else if(contract.Contract_Status__c == 'Dead') {
            return DEAD_STAGE;
        } else if(contract.Contract_End_Date__c > Date.today().addMonths(9)) {
            return PENDING_STAGE;
        }
        return null;
    }

    public static void createRenewalOpportunity(Map<Id, Contract> contracts) {
        Map<Id, Opportunity> opportunities = new Map<Id, Opportunity>();

        List<Id> accountIds = new List<Id>();
        for(Contract contract: contracts.values()) {
            accountIds.add(contract.AccountId);
        }
        Map<Id, Account> accountNames = new Map<Id, Account>([
            SELECT Name, OwnerId
            FROM Account
            WHERE ID IN: (accountIds)
        ]);

        for (Contract contract: contracts.values()) {
            // If contract associated with these assets doesn't meet criteria
            // then do not create opportunity
            if(contract.Contract_Status__c != 'Active' || contract.EndDate == null ||
                (contract.Name != null && contract.Name.contains('VAR_'))) {
                continue;
            }

            Opportunity opportunity = mapRenewalOpportunity(contract, accountNames.get(contract.AccountId).Name);
            if(opportunity.StageName == null) {
                opportunity.StageName = PENDING_STAGE;
            }

            try {
                opportunity.OwnerId = [
                    SELECT Id
                    FROM User
                    WHERE Alias = 'pbish'
                ].Id;
            } catch(QueryException e) {
                // If Peter doesn't exist do not override owner and
                // leave default mapping of account owner
            }

            opportunities.put(contract.Id, opportunity);
        }

        insert opportunities.values();
    }

    public static void updateRenewalOpportunity(Map<Id, Contract> contracts) {
        // Load existing renewal opportunities for the contracts and key
        // them with the contract ID
        List<Opportunity> opportunities = [
            SELECT Id, ContractId
            FROM Opportunity
            WHERE ContractId IN: contracts.keySet()
            AND RecordType.Name =: RENEWAL_RECORD_TYPE
            FOR UPDATE
        ];
        Map<Id, Opportunity> opportunityMap = new Map<Id, Opportunity>();
        for(Opportunity opportunity: opportunities) {
            opportunityMap.put(opportunity.ContractId, opportunity);
        }

        List<Id> accountIds = new List<Id>();
        for(Contract contract: contracts.values()) {
            accountIds.add(contract.AccountId);
        }
        Map<Id, Account> accountNames = new Map<Id, Account>([
            SELECT Name, OwnerId
            FROM Account
            WHERE ID IN: (accountIds)
        ]);

        Map<Id, Opportunity> opportunitiesToUpdate = new Map<Id, Opportunity>();
        Map<Id, Contract> opportunitiesToCreate = new Map<Id, Contract>();
        for(Contract contract: contracts.values()) {
            // If contract associated with these assets doesn't meet criteria
            // then do not create opportunity
            if(contract.Contract_Status__c != 'Active' || contract.EndDate == null ||
                (contract.Name != null && contract.Name.contains('VAR_'))) {
                continue;
            }

            try {
                Opportunity opportunity = mapRenewalOpportunity(contract, accountNames.get(contract.AccountId).Name);
                opportunity.Id = opportunityMap.get(contract.Id).Id;
                opportunitiesToUpdate.put(opportunity.Id, opportunity);
            } catch(Exception e) {
                // No existing opportunity was found
                opportunitiesToCreate.put(contract.Id, contract);
            }
        }
        update opportunitiesToUpdate.values();

        if(opportunitiesToCreate.size() > 0) {
            ContractTriggerHandler.createRenewalOpportunity(opportunitiesToCreate);
        }
    }

    @TestVisible
    private class ContractTriggerException extends Exception { }
}