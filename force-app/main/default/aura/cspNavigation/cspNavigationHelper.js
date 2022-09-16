({
    setChildNodes: function(component, parent) {
        try{
        	component.set('v.menuItems', component.get('v.originalMenuItems').reduce((o, e) =>
            	e.subMenu && (e.id == parent || (!parent && e.active)) ? e.subMenu : o));
        } catch(e){
            console.error(e)
        }
	},
    showMenu: function(menuItemId) {
        if(menuItemId) {
	        document.querySelector('ul[data-menu-item-id="' + menuItemId + '"]').classList.remove('slds-hide');            
        }
    },
    hideMenu: function(menuItemId) {
        if(menuItemId) {
	        document.querySelector('ul[data-menu-item-id="' + menuItemId + '"]').classList.add('slds-hide');            
        }
    },
    navigateTo: function(component, id) {
       if (id) {
           component.getSuper().navigate(id);
       }
	},
    showSidemenuButton: function(component) {
        if(component.find('sidemenu-button').getElement()) {
	        component.find('sidemenu-button').getElement().classList.remove('slds-hide');
        }
        if(component.find('navigation').getElement()) {
        	component.find('navigation').getElement().style.display = 'none';
        }
    },
    showSidemenu: function(component) {
        if(component.find('navigation-list').getElement()) {
        	component.find('navigation-list').getElement().classList.remove('slds-list_horizontal');
            component.find('navigation-list').getElement().classList.add('slds-list_vertical');
        }
        if(component.find('navigation').getElement()) {
       		component.find('navigation').getElement().style.display = 'block';
        	component.find('navigation').getElement().classList.add('slds-is-fixed');
        }
    },
    hideSidemenuButton: function(component) {
        if(component.find('sidemenu-button').getElement()) {
        	component.find('sidemenu-button').getElement().classList.add('slds-hide');
        }
        if(component.find('navigation').getElement()) {
	        component.find('navigation').getElement().style.display = 'block';
        }
    },
    hideSidemenu: function(component) {
        if(component.find('navigation-list').getElement()) {
	        component.find('navigation-list').getElement().classList.remove('slds-list_vertical');
        	component.find('navigation-list').getElement().classList.add('slds-list_horizontal'); 
        }
        if(component.find('navigation').getElement()) {
    	    component.find('navigation').getElement().style.display = 'none';
	        component.find('navigation').getElement().classList.remove('slds-is-fixed');
        }
    }
})