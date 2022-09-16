trigger Asset on Asset (before update, after insert, after update, before insert) {
	if (AssetTriggerHandler.disableAssetTrigger == false) {
		if (Trigger.isBefore) {
			if (Trigger.isUpdate) {
				AssetTriggerHandler handler = AssetTriggerHandler.getInstance(Trigger.newMap, Trigger.oldMap);
                
	            AssetTriggerHandler.updateModules(Trigger.newMap);
			}
		} else if (Trigger.isAfter) {
			if (Trigger.isInsert) {
				AssetTriggerHandler handler = AssetTriggerHandler.getInstance(Trigger.newMap, null);

                AssetTriggerHandler.createModules(Trigger.newMap);
			}
		}
	}
}