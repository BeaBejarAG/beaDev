({
    setProductCategoryColor: function(component, title) {
        const productBar = component.find('access-theme-product-bar').getElement();
        if (!productBar) return;

        let classList = productBar.classList;
        if (title != 'Services') {
            classList.add('slds-hide');
            return;
        }

        classList.remove('slds-hide');
        Array.from(Array(29)).forEach((e, i) => classList.remove(`access-theme-product-bar-cat${i}`));

        if(component.get('v.product') && component.get('v.product').colour) {
            classList.add(component.get('v.product').colour);
        } else {
            classList.add('access-theme-product-bar-cat0');
        }
    }
})