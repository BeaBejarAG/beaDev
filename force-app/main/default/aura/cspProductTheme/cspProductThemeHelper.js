({
    setProductCategoryColor: function(component) {
        let classList = component.find('access-theme-product-bar').getElement().classList;
        Array.from(Array(29)).forEach((e, i) => classList.remove(`access-theme-product-bar-cat${i}`));

        if(component.get('v.product') && component.get('v.product').colour) {
            classList.add(component.get('v.product').colour);
        } else {
            classList.add('access-theme-product-bar-cat0');
        }
    }
})