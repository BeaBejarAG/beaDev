Global class PreChatFormCtrl {
    public string productGroupOptions{get;set;}
    public String email { get; set; }

    
    public PreChatFormCtrl(){
  		Schema.DescribeFieldResult fieldResult =case.RelatedProduct__c.getDescribe();
   		List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        productGroupOptions = json.serialize (ple);
	}
    @RemoteAction
	global static Boolean getEmail(String email) {
		list<Contact> lstContacts = [SELECT Id FROM Contact WHERE Email = :email limit 1];
        if (lstContacts != null && !lstContacts.isEmpty()){
            return true;
        }
        return false;
    }

}