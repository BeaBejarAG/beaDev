({
    qsToEventMap: {
        'startURL'  : 'e.c:setStartUrl'
    },

    handleLogin: function(component, event) {
        const username = component.find("username").get("v.value");
        const password = component.find("password").get("v.value");
        const startUrl = decodeURIComponent(component.get("v.startUrl"));

        const action = component.get("c.loginToSite");
        action.setParams({username, password, startUrl});
        action.setCallback(this, function(a) {
            const state = a.getState();
            if (state === 'SUCCESS') {
                switch(a.getReturnValue()) {
                    case "Enter a value in the User Name field.":
                        component.set("v.errorMessage", "Please enter an email address below");
                    break;

                    case "Enter a value in the Password field.":
                        component.set("v.errorMessage", "Please enter a password below.");
                    break;

                    case "Your login attempt has failed. Make sure the username and password are correct.":
                        component.set("v.errorMessage", "Please make sure the username and password below are correct.");
                    break;

                    default:
                        component.set("v.errorMessage", a.getReturnValue());
                    break;
                }
            }
            if (state === 'ERROR') {
                component.set("v.errorMessage", "Unknown error");
            }
        });

        $A.enqueueAction(action);
    }
})