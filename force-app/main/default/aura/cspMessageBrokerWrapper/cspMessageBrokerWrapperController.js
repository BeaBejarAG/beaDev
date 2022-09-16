({
    fireProductSelection: function(component, event) {
        const appEvent = $A.get('e.c:cspProductSelectionEvent');
        appEvent.setParams({ product: event.getParam('product') });
        appEvent.fire();
    },

    fireAccountSelection: function(component, event) {
        const appEvent = $A.get('e.c:cspAccountSelectionEvent');
        appEvent.setParams({ selectedAccountId: event.getParam('selectedAccountId') });
        appEvent.fire();
    },

    fireProfile: function(component, event) {
        const appEvent = $A.get('e.c:cspProfileEvent');
        appEvent.setParams({ event: event.getParam('event'), userList: event.getParam('userList') });
        appEvent.fire();
    },

    handleProductSelection: function(component, message, helper) {
        if(message.getParam('product') && message.getParam('product').brokered) {
            return;
        }

        component.find('messageBroker').setProduct(message.getParam('product'));
    },

    handleSearch: function(component, message, helper) {
        const searchText = message.getParam('searchText');
        component.find("messageBroker").setSearch(searchText);
    }
})