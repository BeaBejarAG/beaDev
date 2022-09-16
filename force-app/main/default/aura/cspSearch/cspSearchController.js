({
    handleInit: function(component, event, helper) {
        // Used on a new page load to extract search in query string
        const searchText = new URL(location.href).searchParams.get('term');
        if(searchText && !helper.currentSearch && !component.get('v.searchText')) {
            helper.currentSearch = searchText;
        }
    },

	handleSearch: function(component, event, helper) {
        const searchText = component.get('v.searchText');
        if (searchText.length > 1) {
            helper.initiateSearch(component);
        }
    },

    handleRouteChange: function(component, event, helper) {
        // Search text could have changed from another component
        if(component.get('v.searchText') != helper.currentSearch &&
            helper.currentSearch !== undefined) {
            component.set('v.searchText', helper.currentSearch);
        }
    },

    handleFocus: function(component, event, helper) {
        const handlerUrl = component.get('v.handlerUrl');
        const searchText = component.get('v.searchText');

        component.find('autocomplete').search(searchText, handlerUrl, {
            includeReleaseNotes: component.get('v.includeReleaseNotesResults'),
            includeEvents: component.get('v.includeEventsResults'),
            includeKnowledge: component.get('v.includeKnowledgeResults'),
            includeCommunity: component.get('v.includeCommunityResults'),
            includeServicesCatalogue: component.get('v.includeServicesCatalogueResults')
        });
    },

    handleBlur: function(component, event, helper) {
        component.find('autocomplete').hide();
    },

    handleSearchKeyPress: function(component, event, helper) {
        const handlerUrl = component.get('v.handlerUrl');
        const searchText = component.get('v.searchText');
        helper.currentSearch = searchText;

        // When enter is pressed run the search
        if (event.which === 13 && searchText.length > 1) {
            component.find('searchBox').blur();
            helper.initiateSearch(component);
            component.find('searchButton').focus();
            component.find('autocomplete').hide();
            return;
        }

        // Update autocomplete results
        if(searchText.length > 2) {
            component.find('autocomplete').search(searchText, handlerUrl, {
                includeReleaseNotes: component.get('v.includeReleaseNotesResults'),
                includeEvents: component.get('v.includeEventsResults'),
                includeKnowledge: component.get('v.includeKnowledgeResults'),
                includeCommunity: component.get('v.includeCommunityResults'),
                includeServicesCatalogue: component.get('v.includeServicesCatalogueResults')
            });
        } else {
            component.find('autocomplete').hide();
        }
    },

    handleProductSelection: function(component, event, helper) {
        component.find('searchButton').focus();
        component.set('v.product', event.getParam('product'));
        component.find('autocomplete').setProduct({product: event.getParam('product')})
        component.find('searchBox').focus();
    }
})