({
    handleInit: function(component, event, helper) {
        if(JSON.parse(window.sessionStorage.getItem('selectedProduct')) != null) {
            component.set('v.product', JSON.parse(window.sessionStorage.getItem('selectedProduct')));
        }
    },

    handleProductSelection: function(component, message, helper) {
        component.set('v.product', message.getParam('product'));
    },
})