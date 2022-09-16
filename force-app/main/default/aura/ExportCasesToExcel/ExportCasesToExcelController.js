({
	exportCases: function (component, event, helper) 
    {
        var recordId = component.get("v.recordId");
        var url = '/Support/apex/ContactCases';
        window.open(url, '_self');
    }
})