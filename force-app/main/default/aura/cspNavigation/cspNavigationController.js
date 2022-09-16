({
    handleInit: function(component, event, helper) {
        return;
        if(component.get('v.originalMenuItems').length == 0 && component.get('v.menuItems').length > 0) {
            component.set('v.originalMenuItems', component.get('v.menuItems'));  
        	helper.setChildNodes(component);
        }
        window.addEventListener('resize', () => {
            if(window.innerWidth < 720) {
				helper.showSidemenuButton(component);
        	} else {
		        helper.hideSidemenu(component);
				helper.hideSidemenuButton(component);
            }
        });
    },
    handleRender: function(component, event, helper) {
        return;
        if(window.innerWidth < 720) {
			helper.showSidemenuButton(component);
        }
    },
    handleHideSidemenu: function(component, event, helper) {
        if(window.innerWidth < 720) {
	        helper.hideSidemenu(component);
        }
    },
    handleShowSidemenu: function(component, event, helper) {
		helper.showSidemenu(component);
    },
    handleNavigationEvent: function(component, event, helper) {
        helper.setChildNodes(component, parseInt(event.getParam('active'))); 
    },
    handleSubmenu: function(component, event, helper) {
        helper.showMenu(event.target.dataset.menuItemId);
    },
    hideSubmenu: function(component, event, helper) {
        helper.hideMenu(event.target.dataset.menuItemId);
    },
    onClick: function(component, event, helper) {
		helper.navigateTo(component, event.target.dataset.menuItemId);
    }
})