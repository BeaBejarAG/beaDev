({
    handleInit: function(component, event, helper) {
        if(component.get('v.pageTitle') != window.document.title) {
			component.set('v.pageTitle', window.document.title);
        }
	},
    rerender: function(component, event, helper) {
        if(component.get('v.pageTitle') != window.document.title) {
			component.set('v.pageTitle', window.document.title);
        }
    },
    handleUser: function(component, event, helper) {
        const userId = component.get('v.user.Id');
        const total = userId.split('').map(x => x.charCodeAt(0)).reduce((a, b) => a + b);
        component.set('v.colour', `access-theme-user-cat${total % 28}`);
    }
})