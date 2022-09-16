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
        if(JSON.parse(window.sessionStorage.getItem('selectedProduct')) != null) {
            component.set('v.product', JSON.parse(window.sessionStorage.getItem('selectedProduct')));
        }
    },
    handleProductSelection: function(component, message, helper) {
        component.set('v.product', message.getParam('product'));
        component.find('search').set('v.searchText', '');
    }
})