({
    onClick: function(component, event, helper) {
       const id = event.target.dataset.menuItemId;
       if (id) {
           component.getSuper().navigate(id);

           /*const parent = component.get('v.menuItems').reduce((o, p) =>
               p.subMenu ? p.subMenu.reduce((r, s) => s.id == id ? p.id : r, o) : o);

           var appEvent = $A.get('e.c:cspNavigationEvent');
           appEvent.setParams({active: parent});
           appEvent.fire();*/
       }
    }
})