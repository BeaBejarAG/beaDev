/************************************************************************************
 * Class Name: CaseTriggerHandler
 * Purpose: Handle actions on a Feed Item and Feed Comment trigger
 * Author: Chris Lewis
 * Release Version: 1
 * Release Code Coverage: Unkown
 * Notes: Please copy the template line below if you make changes, please mark the version change (Every push to Prod is a new version), Anotate any changed lines with your version and what was changed 
 * Also please ensure any test code is at least the same code coverage as the release code coverage.
 * This was originaly created by a 3rd party so missing annotations.
 * Changed By: YOURNAME Date: THISDATE Reason\Changes: YOUR REASON Version: PREV+1
 * *********************************************************************************/
public class FeedTriggerHandler {
    
@TestVisible
	private List<FeedItem> feeditems {
		get {
			if (feeditems == null) {
				feeditems = new List<FeedItem>();
			}

			return feeditems;
		}
		set;
	}

	@TestVisible
	private Map<Id, FeedItem> oldfeeditems {
		get {
			if (oldfeeditems == null) {
				oldfeeditems = new Map<Id, FeedItem>();
			}

			return oldfeeditems;
		}
		set;
	}
    
    @TestVisible
	private List<FeedComment> feedcomments {
		get {
			if (feedcomments == null) {
				feedcomments = new List<FeedComment>();
			}

			return feedcomments;
		}
		set;
	}

	@TestVisible
	private Map<Id, FeedComment> oldfeedcomments {
		get {
			if (oldfeedcomments == null) {
				oldfeedcomments = new Map<Id, FeedComment>();
			}

			return oldfeedcomments;
		}
		set;
	}

	@TestVisible
	private FeedTriggerHandler() { }

	public static FeedTriggerHandler getInstance(List<FeedItem> feeditems, Map<Id, FeedItem> oldfeeditems) {
		FeedTriggerHandler handler = new FeedTriggerHandler();
		handler.feeditems = feeditems;
		handler.oldfeeditems = oldfeeditems;

		return handler;
	}
    
    	public static FeedTriggerHandler getInstance(List<FeedComment> feedcomments, Map<Id, FeedComment> oldfeedcomments) {
		FeedTriggerHandler handler = new FeedTriggerHandler();
		handler.feedcomments = feedcomments;
		handler.oldfeedcomments = oldfeedcomments;

		return handler;
	}
    
    Public Void NewFeedComment(){
        
       	for (FeedComment thisFeedComm : feedcomments) {
        
        string ParentId = thisFeedComm.ParentId;

        if(ParentId != null && 
           ParentId.StartsWith('500')){
               
                 string TextBody = thisFeedComm.CommentBody;
               TextBody = TextBody.stripHtmlTags();
            
        Map<String, Object> params = new Map<String, Object>();
        params.put('InFeedComment', thisFeedComm);
        params.put('FeedItemBody', TextBody);       
        Flow.Interview.Salesforce_Support_Open_Case_On_Feed_Update FeedCommentFlow = new Flow.Interview.Salesforce_Support_Open_Case_On_Feed_Update(params);
        FeedCommentFlow.start();

    								  }
    }
    }
    
    public void NewFeedItem(){

	for (FeedItem thisFeedItem : feeditems) {
        
        string ParentId = thisFeedItem.ParentId;

        if(ParentId != null && 
           ParentId.StartsWith('500')){
               string TextBody = thisFeedItem.Body;
               TextBody = TextBody.stripHtmlTags();
            
        Map<String, Object> params = new Map<String, Object>();
        params.put('InFeedItem', thisFeedItem);
        params.put('FeedItemBody', TextBody);       
        Flow.Interview.Salesforce_Support_Open_Case_On_Feed_Update FeedItemFlow = new Flow.Interview.Salesforce_Support_Open_Case_On_Feed_Update(params);
        FeedItemFlow.start();

    								  }
    }
    

}
    

}