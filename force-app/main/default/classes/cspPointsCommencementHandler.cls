public without sharing class cspPointsCommencementHandler {
    
    @InvocableMethod(label='Calculate when transactions have started')
    public static void calculatePointsStarted(List<Id> flexPointIds){
        List<FlexPoints_Transactions__c> transactions = new List<FlexPoints_Transactions__c>();
        for (Id flexPointId: flexPointIds) {
            transactions.add(new FlexPoints_Transactions__c(
                Id = flexPointId,
                Started__c = true
            ));
        }
        update transactions;
    }
}