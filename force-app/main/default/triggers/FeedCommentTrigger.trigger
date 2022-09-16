trigger FeedCommentTrigger on FeedComment (after insert, after update) {
      if (Trigger.isInsert) {
                FeedTriggerHandler handler = FeedTriggerHandler.getInstance(Trigger.new, null);
          handler.NewFeedComment();

            				} 
      else if (Trigger.isUpdate) {
                FeedTriggerHandler handler = FeedTriggerHandler.getInstance(Trigger.new, Trigger.oldMap);
								 
      							 }
}