/************************************************************************************
 * Class Name: CustomLiveChat
 * Purpose: Handle Interactions to Live Chat custom forms
 * Author: Chris Lewis
 * Release Version: 1
 * Release Code Coverage: Unknown
 * Notes: Please copy the template line below if you make changes, please mark the version change (Every push to Prod is a new version), Anotate any changed lines with your version and what was changed 
 * Also please ensure any test code is at least the same code coverage as the release code coverage.
 * This was originaly created by a 3rd party so missing annotations.
 * Changed By: YOURNAME Date: THISDATE Reason\Changes: YOUR REASON Version: PREV+1
 * *********************************************************************************/
public with sharing class CustomLiveChat {
    
    public string ContactName {get;set;}
    public String caseId {get;set;}
    public String attachedRecords {get;set;}

    public CustomLiveChat() {
        attachedRecords = ApexPages.currentPage().getParameters().get('attachedRecords');
        caseId = LiveChatAttachedRecords.parse(attachedRecords).CaseId;
        
    }    


}