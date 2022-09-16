({

   doneRendering: function(cmp, event, helper) {
    var analyticsInteraction = $A.get("e.forceCommunity:analyticsInteraction");
    analyticsInteraction.setParams({
        hitType : 'event',
        eventCategory : 'Article',
        eventAction : 'Article Open',
        eventLabel : 'Loading A Page',
        eventValue: 200
    });
    analyticsInteraction.fire();
    }
})