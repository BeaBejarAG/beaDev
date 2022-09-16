({
    render: function(component, helper) {
        const ret = this.superRender();
        helper.setProductCategoryColor(component);
        return ret;
    },
    rerender: function(component, helper) {
        const ret = this.superRerender();        
        helper.setProductCategoryColor(component);
        return ret;
    }
})