trigger Assign_Permissions on KCS_Level__c (before insert, before update, before delete) {
    
        	for(KCS_Level__c KCS: Trigger.new)
        {
            KCSLevelTriggerHandler.RunKCSFlow(KCS.KCS_User__c, KCS.KCS_Level__c);         
        }


}