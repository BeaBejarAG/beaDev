({
    handleUser: function(component, event, helper) {
        const userId = component.get('v.user.Id');
        const total = userId.split('').map(x => x.charCodeAt(0)).reduce((a, b) => a + b);

        component.set('v.colour', `access-theme-user-cat${total % 28}`);
    },
	handleAvatarClick: function(component, event, helper) {
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": "/profile/" + component.get("v.user.Id")
        });
        urlEvent.fire();
    },
	handleMenuSelect: function(component, event, helper) {
        const page = event.getParam('value').trim();

        let url = "/"
        if(page == "My Profile") {
            url = "/profile/" + component.get("v.user.Id");
        } else if(page == "Settings") {
            url = "/settings/" + component.get("v.user.Id");
        } else if(page == "My Messages") {
            url = "/messages/Home"
        } else if(page == "Logout") {
            document.location.href = "/Support/secur/logout.jsp";
        }

        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": url
        });
        urlEvent.fire();
	}
})