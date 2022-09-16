({
    //This method will be executed at initialization of component.This method is used to assign display message to the attribute.
	doInit : function(component, event, helper)
    {
        
        var str1='You cannot proceed and submit this Quote for approval because the Customer Success Plan - Premier value should not be less than £5,000 per annum.'
        var str2='Please reconfigure the products in the Edit Lines screen and select a different Customer Success Plan.'
   		component.set("v.message",str1+str2);
	}
})