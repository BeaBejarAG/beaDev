({
    //This method will be executed at initialization of component.
	doInit : function(component, event, helper)
    {
        
        var str1='Your quote lines are not completely calculated!';
        var str2=' In order to proceed with this quote, click Edit Lines and click Quick Save and then Calculate buttons. Then Save the Quote.';
       
   		component.set("v.message",str1+str2);
	}
})