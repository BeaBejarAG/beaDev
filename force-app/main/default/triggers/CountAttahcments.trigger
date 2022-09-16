trigger CountAttahcments on Opportunity (before Update) {
    
    list<ContentVersion> ContentsVersion = [Select id From ContentVersion Where associatedopplinkID__c in :trigger.new];
    List<Attachment> Attch = [Select id from Attachment Where Parentid in : Trigger.new];
    
    integer Attachmentcount = ContentsVersion.size() + Attch.size();
    
    
    
    For(Opportunity opp : Trigger.new){
        
        opp.attachments__C = Attachmentcount;
        
        
    }
    

}