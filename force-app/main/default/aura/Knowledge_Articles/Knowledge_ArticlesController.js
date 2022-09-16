({
    doInit : function(component, event, helper) 
    {
        var actionArticle = component.get("c.getArticle");

        actionArticle.setParams({
            recordId : component.get("v.recordId")
        });

        actionArticle.setCallback(this, function(response) {
            component.set("v.Article", response.getReturnValue());
        })

        console.log('>> ' + component.get("v.recordId"));
        $A.enqueueAction(actionArticle);


    }
})