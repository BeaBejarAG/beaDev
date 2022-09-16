({
    doInit: function (cmp, event, helper) {
        cmp.set('v.columns', [
            {label: 'Issue', initialWidth: 200, fieldName: 'Title__c', type: 'text'},
            {label: 'Detail', fieldName: 'Description__c', type: 'text'},
            {label: 'Open Date', initialWidth: 110, fieldName: 'Open_Date__c', type: 'date'},
            {label: 'Status', initialWidth: 150, fieldName: 'Status__c', type: 'text'}
        ]);
        
         var action = cmp.get("c.GetServicePage");
 
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {

                cmp.set('v.ServiceStatusData', response.getReturnValue());
                //cmp.set('v.counts', "nothing");

            }
            else if (state === "ERROR") {
                alert('Error : ' + JSON.stringify(errors));
            }
        });
        $A.enqueueAction(action);
    }
});