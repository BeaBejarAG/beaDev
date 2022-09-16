({
        initialize: function(component, event, helper) {
        $A.get("e.siteforce:registerQueryEventMap").setParams({"qsToEvent" : helper.qsToEventMap}).fire();
    },
    
    handleForgotPassword: function (component, event, helpler) {
        helpler.handleForgotPassword(component, event, helpler);
    },
    onKeyUp: function(component, event, helpler){
    //checks for "enter" key
        if (event.getParam('keyCode')===13) {
            helpler.handleForgotPassword(component, event, helpler);
        }
    },
    
    setExpId: function (component, event, helper) {
        var expId = event.getParam('expid');
        if (expId) {
            component.set("v.expid", expId);
        }
        helper.setBrandingCookie(component, event, helper);
    },
    
            navigateToLogin: function(cmp, event, helper) {
        var empLoginUrl = cmp.get("v.fplogin");
        if ($A.util.isUndefinedOrNull(empLoginUrl)) {
            empLoginUrl = cmp.get("v.fplogin");
        }
        var attributes = { url: empLoginUrl };
        $A.get("e.force:navigateToURL").setParams(attributes).fire();
    },


})