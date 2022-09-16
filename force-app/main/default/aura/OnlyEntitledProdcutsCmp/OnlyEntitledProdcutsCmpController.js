({
 doInit: function(cmp) {
 //var action = cmp.get("c.apex_myCustomObjs");
 var action = cmp.get("c.MyEntitlements");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {

                cmp.set('v.myObject', response.getReturnValue());
                //cmp.set('v.counts', "nothing");

            }
            else if (state === "ERROR") {
                alert('Error : ' + JSON.stringify(errors));
            }
        });
        $A.enqueueAction(action);
    }
    }
})

({
    doAction : function(cmp, event) {
        var params = event.getParam('arguments');
        if (params) {
            var param1 = params.param1;
            // add your code here
        }
    }
})