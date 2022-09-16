({
    curentSearch: '',
	initiateSearch: function(component) {
        const searchText = component.get('v.searchText');
        const product = component.get('v.product');
        this.currentSearch = searchText;

        const handlerUrl = component.get('v.handlerUrl');
        const currentUrl = document.location.pathname.replace(/\/([a-z0-9]+)\/s/gi, '');

        if(currentUrl === handlerUrl) {
            const appEvent = $A.get("e.c:cspSearchEvent");
            appEvent.setParams({ searchText: searchText });
            appEvent.fire();
            /* The return statement has been removed. 
            This is because the currentUrl and handleUrl 
            variable do not contain the term param, which
             will cause the condition check if(currentUrl === handlerUrl) 
             to always be true after the first search. 
             This prevents the url from being updated.*/
        }

        const urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            url: component.get('v.handlerUrl') + `?term=${searchText}`
        });
        urlEvent.fire();
    }
})