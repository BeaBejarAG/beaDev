({
    initialize: function(component, event, helper) {
        $A.get("e.siteforce:registerQueryEventMap").setParams({"qsToEvent" : helper.qsToEventMap}).fire();
    },

    login: function(component, event, handler) {
        component.set('v.showLoginForm', true);
    },

    setStartUrl: function (component, event, helper) {
        var startUrl = event.getParam('startURL');
        if(startUrl) {
            component.set("v.startUrl", startUrl);
        }
    },

    continueToKnowledge: function(component, event, handler) {
        const urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            url: '/Support/s/'
        });
        urlEvent.fire();
    },

    register: function(component, event, handler) {
        const urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            url: '/SelfRegister'
        });
        urlEvent.fire();
    },

    handleKeyDown: function(component, event, handler) {
        if(event.which == 13) {
            handler.handleLogin(component, event);
        }
    },

    handleLogin: function (component, event, handler) {
        handler.handleLogin(component, event);
    }
})