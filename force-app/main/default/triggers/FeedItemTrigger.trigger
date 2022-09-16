trigger FeedItemTrigger on FeedItem (after insert, after update) {
    
      if (Trigger.isInsert) {
                FeedTriggerHandler handler = FeedTriggerHandler.getInstance(Trigger.new, null);
          handler.NewFeedItem();

            				} 
      else if (Trigger.isUpdate) {
                FeedTriggerHandler handler = FeedTriggerHandler.getInstance(Trigger.new, Trigger.oldMap);
								 
      							 }
}