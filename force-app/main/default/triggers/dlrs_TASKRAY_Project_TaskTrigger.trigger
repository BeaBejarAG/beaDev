/**
 * Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)
 **/
trigger dlrs_TASKRAY_Project_TaskTrigger on TASKRAY__Project_Task__c
    (before delete, before insert, before update, after delete, after insert, after undelete, after update)
{
    dlrs.RollupService.triggerHandler(TASKRAY__Project_Task__c.SObjectType);
}