({
    handleUrlClick: function(urlname) {
        const urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": urlname
        });
        urlEvent.fire();
    }
})