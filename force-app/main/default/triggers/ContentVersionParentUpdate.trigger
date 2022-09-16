/************************************************************************************
 * Class Name: ContentVersionParentUpdate 
 * Purpose: Associate Islatest ContentVersion with opportunity so id can be downloaded into local SQL with body
 * Author: Andrew Mannering
 * Release Version: 1
 * Release Code Coverage: 100%
 * Notes: Please copy the template line below if you make changes, please mark the version change (Every push to Prod is a new version), Anotate any changed lines with your version and what was changed 
 * Also please ensure any test code is at least the same code coverage as the release code coverage
 * Changed By: Andrew Mannering Date: 28/11/2018 Reason\Changes: Remove need for file sharing group Version: 2
 * Changed By: Chris Lewis Date: 09/07/2020 Reason\Changes: Originall code searched the whole DB for an Opp, this one only looks for the opp in question in a loop as we hit a limit on the search Version: 3
 * *********************************************************************************/

trigger ContentVersionParentUpdate on ContentVersion (After insert, after update) {
    // create a set of all the unique opportunity ids for SOQL below
    Set<id> ContentdocumetIds = new set<id>();
    List<ContentVersion> ContentVersionstoUpdate = New List<ContentVersion>();
    List<ContentDocumentLink> ContentLinkstoCreate = New List<ContentDocumentLink>();
    id Usr = [Select id from User where firstname = 'Integration' AND isactive = TRUE Limit 1].id;
    
  if (Trigger.isInsert) {   
    for (ContentVersion CV1 : Trigger.new){
         ContentdocumetIds.add(CV1.ContentDocumentId);
    }
    
    System.debug(ContentdocumetIds);
       
     // create a map so that Opportunity is locatable by its Id (key)
     // 
    Map<string, contentdocumentlink> myMap = new Map<string, contentdocumentlink>(); 
    
    
//Loop through all the ID's check to see if there is a match in the ContentDocumentLink. Then check this link to see if it is an Opportunity (Starts with 006) and add it to a Map
//
    for(id CurrentID: ContentdocumetIds)
    {
        for(contentdocumentlink objCS : [Select z.linkedentityid, z.contentdocumentid From contentdocumentlink z WHERE contentdocumentid = :CurrentID])
        {
         String entID = String.valueof(objCS.LinkedEntityId);   
        
            if (entID.StartsWith('006')){
                    myMap.put(objCS.contentdocumentid, objCS);
            }
        }
                               
    }

  //  for(contentdocumentlink objCS : [Select z.linkedentityid, z.contentdocumentid From contentdocumentlink z WHERE contentdocumentid IN :ContentdocumetIds AND LinkedEntityId IN
   //     (select ID from opportunity where RecordTypeId != '0124I0000006RPfQAM' and RecordTypeId != '01258000000O8JiAAK' and LastModifiedDate >= LAST_N_YEARS:1)] )
   // 

    
    System.debug(myMap);
  //    } 
     
    
        For (ContentVersion CV1 :trigger.new){
        
        IF(mymap.size() > 0){

        contentversion CV2 = new contentversion(Id = CV1.Id);
        
        System.debug('Linkedid' + myMap.get(CV1.ContentDocumentId).linkedentityid); 
        
        if(myMap.get(CV1.ContentDocumentId).linkedentityid.getSObjectType() == Schema.Opportunity.getSObjectType()){
            
        Cv2.AssociatedOppLinkID__c = myMap.get(CV1.ContentDocumentId).linkedentityid;
        
        ContentDocumentlink INTuserLINK = New ContentDocumentLink();
            INTuserLINK.ContentDocumentId = CV1.ContentDocumentId;
            INTUserLink.LinkedEntityId = Usr;
            INTUserLink.Visibility = 'AllUsers';
            INTUserLink.ShareType = 'V';
            
            ContentLinkstoCreate.add(INTuserLINK);            
            
            
            ContentVersionstoupdate.add(CV2);
        }
    }

    }
            Update ContentVersionstoUpdate;
            Insert ContentLinkstoCreate;
  }
    if (Trigger.isUpdate){
        system.debug('Before ID Fire');
        system.debug(ContentdocumetIds.isEmpty());
        if(ContentdocumetIds.isEmpty()){
        for (ContentVersion CV1 : Trigger.new){
           for(ContentVersion CVOld: Trigger.old){
                System.debug('CVID');
               System.debug(CV1.AssociatedOppLinkID__c);
                System.debug(CVOld.AssociatedOppLinkID__c);
               if(CV1.AssociatedOppLinkID__c != CVOld.AssociatedOppLinkID__c || CV1.AssociatedOppLinkID__c == null ){
                        ContentdocumetIds.add(CV1.ContentDocumentId);
               }
            }
        }
    system.debug('Check Content');
    System.debug(ContentdocumetIds);
       
     // create a map so that Opportunity is locatable by its Id (key)
     // 
    Map<string, contentdocumentlink> myMapUpdate = new Map<string, contentdocumentlink>(); 

    system.debug(ContentdocumetIds.isEmpty());
        if(!ContentdocumetIds.isEmpty()){
    for(id CurrentID: ContentdocumetIds)
    {
        for(contentdocumentlink objCS : [Select z.linkedentityid, z.contentdocumentid From contentdocumentlink z WHERE contentdocumentid = :CurrentID])
        {
         String entID = String.valueof(objCS.LinkedEntityId);   
        
            if (entID.StartsWith('006')){
                    myMapUpdate.put(objCS.contentdocumentid, objCS);
            }
        }
                               
    }
}

     System.debug('map');
    System.debug(myMapUpdate);
  //    } 
     
     IF(myMapUpdate.size() > 0){
System.Debug('InsideMap');
        For (ContentVersion CV1 :trigger.new){
        
       

        contentversion CV2 = new contentversion(Id = CV1.Id);
        
        if(myMapUpdate.get(CV1.ContentDocumentId).linkedentityid.getSObjectType() == Schema.Opportunity.getSObjectType()){
            
        Cv2.AssociatedOppLinkID__c = myMapUpdate.get(CV1.ContentDocumentId).linkedentityid;
                    
            
            ContentVersionstoupdate.add(CV2);
        }
    }


    }
    System.Debug('UpdateFired');
            Update ContentVersionstoUpdate;
    } 
    }
    
                
    }