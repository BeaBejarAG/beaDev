({
    qsToEventMap: {
        'startURL': 'e.c:setStartUrl'
    },

    qsToEventMap2: {
        'expid': 'e.c:setExpId'
    },

    populateTimezoneInputSelectOptions: function(component) {
        const action = component.get('c.retrieveTimezoneValues');
        action.setCallback(this, ((a) => {
            const returnValue = a.getReturnValue();
            if (returnValue) {
                let selectOptions =
                    [{ label: 'Select a Timezone', value: null, selected: true }].concat(JSON.parse(returnValue));

                component.find('TimezoneSelectSingle').set('v.options', selectOptions);

                component.set('v.timezoneSelectOptionsRetrieved', true);
            }
        }));
        $A.enqueueAction(action);
    },

    populateRegionInputSelectOptions: function(component) {
        const action = component.get('c.retrieveRegionValues');
        action.setCallback(this, ((a) => {
            const returnValue = a.getReturnValue();
            if (returnValue) {
                let selectOptions =
                    [{ label: 'Select a Region', value: null, selected: true }].concat(JSON.parse(returnValue));

                component.find('RegionSelectSingle').set('v.options', selectOptions);

                component.set('v.regionSelectOptionsRetrieved', true);
            }
        }));
        $A.enqueueAction(action);
    },

    handleSelfRegister: function (component, event, helpler) {
        var accountId = component.get("v.accountId");
        var regConfirmUrl = component.get("v.regConfirmUrl");
        var firstname = component.find("firstname").get("v.value");
        var lastname = component.find("lastname").get("v.value");
        var email = component.find("email").get("v.value");
        var emailcon = component.find("emailcon").get("v.value");
        var includePassword = component.get("v.includePasswordField");
        var password = component.find("password").get("v.value");
        var confirmPassword = component.find("confirmPassword").get("v.value");
        var action = component.get("c.selfRegister");
        var extraFields = JSON.stringify(component.get("v.extraFields"));   // somehow apex controllers refuse to deal with list of maps
        var startUrl = component.get("v.startUrl");

        const timezone = component.find("TimezoneSelectSingle").get("v.value");
        if (!timezone) {
            component.set("v.errorMessage", "Please select a Timezone");
            component.set("v.showError", true);

            return;
        }

        const region = component.find("RegionSelectSingle").get("v.value");
        if (!region) {
            component.set("v.errorMessage", "Please select a Region");
            component.set("v.showError", true);

            return;
        }

        startUrl = decodeURIComponent(startUrl);

        if (email.toLowerCase() != emailcon.toLowerCase()) {
            component.set("v.errorMessage", "Please Check your Email Addresses Match");
            component.set("v.showError", true);
        }
        else {
            component.set("v.isLoading", true);

            action.setParams({
                firstname: firstname, lastname: lastname, email: email,
                password: password, confirmPassword: confirmPassword,
                accountId: accountId, regConfirmUrl: regConfirmUrl, timezone: timezone,
                region: region, extraFields: extraFields, startUrl: startUrl,
                includePassword: includePassword
            });
            action.setCallback(this, function (a) {
                let rtnValue = a.getReturnValue();
                if (rtnValue !== null) {
                    if (rtnValue.includes('Your request cannot be processed at this time')) {
                        component.set("v.errorMessage", "This e-mail address is already in use, or on an inactive account please try to the reset password instead. If this does not work or you believe this is incorrect please contact SupportCommunity@theaccessgroup.com");
                    } else {
                        component.set("v.errorMessage", rtnValue);
                    }
                    component.set("v.showError", true);
                    component.set("v.isLoading", false);
                }
            });
            $A.enqueueAction(action);
        }
    },

    getExtraFields: function (component, event, helpler) {
        var action = component.get("c.getExtraFields");
        action.setParam("extraFieldsFieldSet", component.get("v.extraFieldsFieldSet"));
        action.setCallback(this, function (a) {
            var rtnValue = a.getReturnValue();
            if (rtnValue !== null) {
                component.set('v.extraFields', rtnValue);
            }

            component.set("v.isLoading", false);
        });
        $A.enqueueAction(action);
    },

    setBrandingCookie: function (component, event, helpler) {
        var expId = component.get("v.expid");
        if (expId) {
            var action = component.get("c.setExperienceId");
            action.setParams({ expId: expId });
            action.setCallback(this, function (a) { });
            $A.enqueueAction(action);
        }
    }
})