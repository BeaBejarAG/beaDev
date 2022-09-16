trigger deletedOppLineItem_Tr on OpportunityLineItem (before delete) 
{
    for(OpportunityLineItem e: trigger.old)
     {
        String OpportunityLineItemID= e.Id;
        String OpportunityId=e.OpportunityId;
        Datetime d= System.now();
          System.debug(e);
         deletedOppLineItem__c myCustomObject = new deletedOppLineItem__c (datenTime__c = d, oppId__c = OpportunityId, oppLineItemID__c=OpportunityLineItemID,name ='Abcd');
         insert myCustomObject;
         System.debug(myCustomObject);
     }
 
}