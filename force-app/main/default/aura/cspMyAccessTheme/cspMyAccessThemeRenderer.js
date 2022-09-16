({
    rerender: function(component, helper) {
        this.superRerender();
        const title = window.document.title;
        component.set('v.pageTitle', title);
        helper.setProductCategoryColor(component, title);
    }
})