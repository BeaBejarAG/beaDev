({
  //           handleClickSupportCall: function(cmp, event, helper) {
  //    var urlEvent = $A.get("e.force:navigateToURL");
  //      var myUrl = '/case/Case/00B58000002C9xoEAC';
  //      urlEvent.setParams({
  //        "url": myUrl
  //      });
  //      urlEvent.fire();
  //  }
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
     },
    
    handleClickSupportCall : function(cmp, event, helper) {
      var urlEvent = $A.get("e.force:navigateToURL");
       var myUrl = '/contactsupport';
        urlEvent.setParams({
          "url": myUrl
        });
        urlEvent.fire();
    },
    
      handleClickYes: function(cmp, event, helper) {
      var urlEvent = $A.get("e.force:navigateToURL");
       var myUrl = '/thankyouforyourinput';
        urlEvent.setParams({
          "url": myUrl
        });
        urlEvent.fire();
    }
    

})