({
    //This method will be executed at initialization of component.This method is used to assign display message to the attribute.
	doInit : function(component, event, helper)
    {
        
        var str1='You have added Additional Services to this Quote. Please fill in the Services Description on the Quote with some detail that is meaningful for the customer';
   		component.set("v.message",str1);
	}
})