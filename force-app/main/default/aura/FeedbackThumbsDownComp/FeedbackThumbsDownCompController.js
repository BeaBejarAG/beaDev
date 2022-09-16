({

	handleClickSumbit : function(component, event, helper) 
    {
var createRecordEvent = $A.get("e.force:createRecord");
   createRecordEvent.setParams({
       "entityApiName": "Knowledge_Feedback__c",
       "defaultFieldValues": {
             'Owner' : '0056E0000012Lbb',
           'Name' : component.get("v.recordId")
        }
   });
   createRecordEvent.fire();
	},

    doneRendering: function(cmp, event, helper) {
        // Set the attribute value. 
        // You could also fire an event here instead.
           var action = cmp.get("c.getUserType");
    action.setCallback(this, function(response){
        var state = response.getState();
        if (state === "SUCCESS") {
                    if(response.getReturnValue() == "Guest")
        {
            cmp.set("v.loggedInUser", "false");
        }
        else
        {
          cmp.set("v.loggedInUser", "true");  
        }
         }
      });
       $A.enqueueAction(action);
     }

    }


    

});