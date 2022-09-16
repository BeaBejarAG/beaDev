({
    handleClick: function (component, event, handler) {
      const urlEvent = $A.get("e.force:navigateToURL");
      urlEvent.setParams({
        url: '/post'
      });
      urlEvent.fire();
    },

    handleHideProfile: function (component, event, handler) {
      component.find('popover').hide(
        event
      );
    },

    handleShowProfile: function (component, message, handler) {
      component.find('popover').show(
        message.getParam('event'),
        message.getParam('userList')
      );
    },

    handleViewProfile: function (component, message, handler) {
        const url = message.getParam('url');
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            url
        });
        urlEvent.fire();
    }
})