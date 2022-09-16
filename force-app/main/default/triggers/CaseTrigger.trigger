trigger CaseTrigger on Case (before insert, after insert, before update, after update) {
    if (CaseTriggerHandler.disableCaseTrigger == false) {
        if (Trigger.isBefore) {
            if (Trigger.isInsert) {
                //CaseTriggerHandler handler = CaseTriggerHandler.getInstance(Trigger.new, null);
                //handler.CaseLoopKiller(trigger.new); 
                //handler.ThisShouldntRunOnSave();
                //handler.createIncidents();
                //handler.closeIncidents();

            } else if (Trigger.isUpdate) {
                //CaseTriggerHandler handler = CaseTriggerHandler.getInstance(Trigger.new, Trigger.oldMap);
                //handler.CloseAllMilestones();
                //handler.createIncidents();
                //handler.closeIncidents();

            }
        } else if (Trigger.isAfter){
            DateTime completionDate = System.now(); 
            List<Id> updateCases = new List<Id>();
            for (Case c : Trigger.new){
                if (((c.isClosed == true)||(c.Status == 'Closed'))&&((c.SlaStartDate 
                    <= completionDate)&&(c.SlaExitDate == null) && c.RecordTypeId == '012580000006HfdAAE'))
                updateCases.add(c.Id);
            }

            if (Trigger.isInsert) {
                CaseTriggerHandler.afterCaseInsert(Trigger.new);
            } else if (Trigger.isUpdate) {
                CaseTriggerHandler.afterCaseUpdate(Trigger.new);
            }

            if (updateCases.isEmpty() == false)
                CaseTriggerHandler.completeMilestone(updateCases, 'First Response', completionDate);
        }        
    }
}