trigger Contract on Contract (before update, after insert) {
    if (ContractTriggerHandler.disableContractTrigger == false) {
        if (Trigger.isBefore) {
            if (Trigger.isUpdate) {
                ContractTriggerHandler handler = ContractTriggerHandler.getInstance(Trigger.newMap, Trigger.oldMap);
                
                handler.deactivateAssets();
                //handler.createBaseElements();
                
            	ContractTriggerHandler.updateRenewalOpportunity(Trigger.newMap);
			}
		}
        if(Trigger.isAfter) {
            if(Trigger.isInsert) {
                ContractTriggerHandler.createRenewalOpportunity(Trigger.newMap);
            }
        }
    }
}