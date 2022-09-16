({
                navigateToLogin: function(cmp, event, helper) {
        var empLoginUrl = cmp.get("v.fplogin");
        var attributes = { url: empLoginUrl };
        $A.get("e.force:navigateToURL").setParams(attributes).fire();
    }
})