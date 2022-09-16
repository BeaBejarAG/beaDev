({
    initialize: function (component, event, helper) {
        $A.get("e.siteforce:registerQueryEventMap").setParams({ "qsToEvent": helper.qsToEventMap }).fire();
        $A.get("e.siteforce:registerQueryEventMap").setParams({ "qsToEvent": helper.qsToEventMap2 }).fire();

        // Retrieve Timezone values from the server and populate the input select options
        helper.populateTimezoneInputSelectOptions(component);
        
        // Retrieve Region values from the server and populate the input select options
        helper.populateRegionInputSelectOptions(component);

        component.set('v.extraFields', helper.getExtraFields(component, event, helper));
    },

    handleSelfRegister: function (component, event, helpler) {
        helpler.handleSelfRegister(component, event, helpler);
    },

    setStartUrl: function (component, event, helpler) {
        var startUrl = event.getParam('startURL');
        if (startUrl) {
            component.set("v.startUrl", startUrl);
        }
    },

    navigateToLogin: function (cmp, event, helper) {
        var empLoginUrl = cmp.get("v.fplogin");
        if ($A.util.isUndefinedOrNull(empLoginUrl)) {
            empLoginUrl = cmp.get("v.fplogin");
        }
        var attributes = { url: empLoginUrl };
        $A.get("e.force:navigateToURL").setParams(attributes).fire();
    },

    setExpId: function (component, event, helper) {
        var expId = event.getParam('expid');
        if (expId) {
            component.set("v.expid", expId);
        }
        helper.setBrandingCookie(component, event, helper);
    },

    onKeyUp: function (component, event, helpler) {
        //checks for "enter" key
        if (event.getParam('keyCode') === 13) {
            helpler.handleSelfRegister(component, event, helpler);
        }
    }
})