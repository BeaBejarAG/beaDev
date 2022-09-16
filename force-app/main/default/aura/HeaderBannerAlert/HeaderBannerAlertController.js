({
    toggle : function(component, event, helper) {
        var toggleText = component.find("text");
        $A.util.toggleClass(toggleText, "toggle");
    },

    doInit: function(cmp) {
 var action = cmp.get("c.GetCommunityAlerts");
 
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {

                cmp.set('v.counts', response.getReturnValue());
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
    rerender: function(cmp, helper) {
        this.superRerender();
 
        // Get the Id and Record View
        var accountId = cmp.get('ka26E0000008OUSQA2');
 
        // Show or Hide the Account View depending on the Id value
        if (!accountId)
        {
                   var toggleText = component.find("text");
        $A.util.toggleClass(toggleText, "toggle");
        }
        else
        {
                 var toggleText = component.find("text");
        $A.util.toggleClass(toggleText, "toggle");
        }
    },
})