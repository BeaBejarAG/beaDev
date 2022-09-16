/**
 * Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)
 **/
trigger dlrs_FlexPoints_TransactionsTrigger on FlexPoints_Transactions__c
    (before delete, before insert, before update, after delete, after insert, after undelete, after update)
{
    dlrs.RollupService.triggerHandler(FlexPoints_Transactions__c.SObjectType);
}