({
 doInit: function(cmp) {
     
 var getprof = cmp.get("c.GetCurrentUser");
             getprof.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
               var results = response.getReturnValue();
                if (results == true){
                    var action = cmp.get("c.MyEntitlementsPayroll");
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
            else if (state === "ERROR") {
                alert('Error : ' + JSON.stringify(errors));
            }
        });
     $A.enqueueAction(getprof);
     
 
    }
    }
)