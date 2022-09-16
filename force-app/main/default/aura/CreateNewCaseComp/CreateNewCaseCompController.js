({
    handleClick : function(cmp, event, helper) {
      var urlEvent = $A.get("e.force:navigateToURL");
       var myUrl = '/contactsupport';
        urlEvent.setParams({
          "url": myUrl
        });
        urlEvent.fire();
    }
})