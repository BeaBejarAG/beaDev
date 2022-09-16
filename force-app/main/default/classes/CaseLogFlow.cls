public with sharing class 
CaseLogFlow 
{

 
@AuraEnabled
public static List<ContactEntitlement__c> MyEntitlements() {
    
    string contactiduser = [Select contactid from User where id = :Userinfo.getUserid()].contactId;
    List<ContactEntitlement__c> objList = new List<ContactEntitlement__c>();
    for
     (ContactEntitlement__c myObj: [select ContactEntitlement__c.Product__C, ContactEntitlement__c.Topic_ID__c, ContactEntitlement__c.Real_Entitlement__c, ContactEntitlement__c.Real_Entitlement__r.PlanType__c,  ContactEntitlement__c.Name
from ContactEntitlement__c 
   where ContactEntitlement__c.Active__C = true                           
and (ContactEntitlement__c.Contact__C = :[Select contactid from User where id =: Userinfo.getUserid()].contactId or ContactEntitlement__c.ContactID18__C =:[Select contactid from User where id =: Userinfo.getUserid()].contactId

      )]) 
     {
        objList.add(myObj);
     }
return objList;
    
}
    
    @AuraEnabled
public static string ContactEmail() {
    List<User> UserID = new List<User>();
    UserID =  [SELECT Id, ContactId, Contact.AccountId FROM User WHERE Id = :UserInfo.getUserId()];
    
    List<Contact> ContactID = new List<Contact>();
    
    ContactID = [Select email from contact where Id = :UserID[0].contactId];
    string contactemail;
   if (ContactID.Size() > 0)
     {
    contactemail = ContactID[0].Email;
   }

        return contactemail;
    
}
    
    @AuraEnabled
public static string ContactId() {
    List<User> UserID = new List<User>();
    UserID =  [SELECT Id, ContactId, Contact.AccountId FROM User WHERE Id = :UserInfo.getUserId()];
    
    List<Contact> ContactID = new List<Contact>();
    
    ContactID = [Select id from contact where Id = :UserID[0].contactId];
    string contactiduser;
   if (ContactID.Size() > 0)
     {
    contactiduser = ContactID[0].Id;
   }

        return contactiduser;
    
}
      @AuraEnabled
    public static case CreateNewCase(string description, string subject, string priority, string product, string entid, String Subbie) {
         case newCase = new case();
        try{
    newCase = new case(
    Status = 'Support Outstanding',
    Description = description,
    Subject = subject,
    Origin = 'Web',
    Priority = priority,
    RecordTypeId = '012580000006HfcAAE',
    RelatedProduct__c = product,
    EntitlementId = entid,
    SubAnalysis__c = Subbie,    
    Source__c = 'Support',
    CaseType__c = 'Support Issue'
    );
        
        insert newCase;
        }
        catch(exception e){
            System.debug('Error: ' + e.getMessage());
        } 
        
        newCase = [select CaseNumber, Id, Subject from case where id=:newCase.Id];
return newCase;   
}
   
    
        @AuraEnabled
    public static case CreateNewCase(string description, string subject, string priority, string product, string entid) {
         case newCase = new case();
        try{
    newCase = new case(
    Status = 'Support Outstanding',
    Description = description,
    Subject = subject,
    Origin = 'Web',
    Priority = priority,
    RecordTypeId = '012580000006HfcAAE',
    RelatedProduct__c = product,
    EntitlementId = entid,
    Source__c = 'Support',
    CaseType__c = 'Support Issue'
    );
        
        insert newCase;
        }
        catch(exception e){
            System.debug('Error: ' + e.getMessage());
        } 
        
        newCase = [select CaseNumber, Id, Subject from case where id=:newCase.Id];
return newCase;   
}
    @AuraEnabled
    public static void LinkFilesToDoc(string casenumber, List<string> docid)
    {
        for (Integer i=0; i< docid.size(); i++ )
        {
          ContentDocumentLink CDL = new ContentDocumentLink(ContentDocumentId = docid[i], LinkedEntityId = CaseNumber, ShareType = 'I');
            system.debug('Worked' + docid[i] + CaseNumber );
        try {
            insert CDL;
            }
        catch(DmlException e) {
    System.debug('An unexpected error has occurred: ' + e.getMessage());
}   
        }
       

    }
        @AuraEnabled
    public static void FilesToRemove(string docid)
    {
 ContentDocument cdn = new ContentDocument (id = docid);
        
        try{
            delete cdn;
        }
         catch(DmlException e) {
         }

       

    }
    
     public String UserName{get;set;}   
    
    public list<string> GetCurrentMap(){
        
        list<string> options = new List<string>();
        Map<String,List<String>> objResults = new Map<String,List<String>>();
        objResults = getDependentMap();
       
        options = GetSubs('Access Care Planning', objResults);
        return options;
        
        
        
    }

    

    public pagereference show()
    {
        UserName = ApexPages.currentPage().getParameters().get('UserName');
        return null;
    }
    
    @AuraEnabled 
    public static list<string> GetSubs(string product, map<string,List<string>> subsinc)
    {
        list<string> Subs = new List<string>();
        Subs = subsinc.get(product);
        return subs;
        
    }
    
    
      @AuraEnabled 
    public static Map<String, List<String>> getDependentMap() {
        sObject objDetail = new case(); 
        String controllingField = 'RelatedProduct__c';
        String dependentField = 'SubAnalysis__c';

        Map<String,List<String>> objResults = new Map<String,List<String>>();

        //Schema.sObjectType objType = objDetail.getSObjectType().getDescribe().getName();
        /*if (objType==null){
            return objResults; 
        }*/
        Map<String, Schema.SObjectField> objFieldMap = objDetail.getSObjectType().getDescribe().fields.getMap();

        if (!objFieldMap.containsKey(controllingField) || !objFieldMap.containsKey(dependentField)){
            return objResults;     
        }

        Schema.SObjectField theField = objFieldMap.get(dependentField);
        System.debug('theField --->' +theField);
        Schema.SObjectField ctrlField = objFieldMap.get(controllingField);

        List<Schema.PicklistEntry> contrEntries = ctrlField.getDescribe().getPicklistValues();
        System.debug('contrEntries ----->'+contrEntries);
        List<PicklistEntryWrapper> depEntries = wrapPicklistEntries(theField.getDescribe().getPicklistValues());
        System.debug('depEntries ----> '+depEntries);
        List<String> controllingValues = new List<String>();

        for (Schema.PicklistEntry ple : contrEntries) {
            String label = ple.getLabel();
            objResults.put(label, new List<String>());
            controllingValues.add(label);
        }
        System.debug('controllingValues --->'+controllingValues);

        for (PicklistEntryWrapper plew : depEntries) {
            String label = plew.label;
            String validForBits = base64ToBits(plew.validFor);
            for (Integer i = 0; i < validForBits.length(); i++) {
                String bit = validForBits.mid(i, 1);
                if (bit == '1') {
                    objResults.get(controllingValues.get(i)).add(label);
                }
            }
        }
        system.debug(objResults+'****objResults');
        return objResults;

    }


    public static String decimalToBinary(Integer val) {
        String bits = ''; 
        while (val > 0) {
            Integer remainder = Math.mod(val, 2);
            val = Integer.valueOf(Math.floor(val / 2));
            bits = String.valueOf(remainder) + bits;
        }
        return bits;
    }

    public static String base64ToBits(String validFor) {
        if (String.isEmpty(validFor)) return '';

        String validForBits = '';

        for (Integer i = 0; i < validFor.length(); i++) {
            String thisChar = validFor.mid(i, 1);
            Integer val = base64Chars.indexOf(thisChar);
            String bits = decimalToBinary(val).leftPad(6, '0');
            validForBits += bits;
        }

        return validForBits;
    }

    private static final String base64Chars = '' +
        'ABCDEFGHIJKLMNOPQRSTUVWXYZ' +
        'abcdefghijklmnopqrstuvwxyz' +
        '0123456789+/';


    private static List<PicklistEntryWrapper> wrapPicklistEntries(List<Schema.PicklistEntry> PLEs) {
        return (List<PicklistEntryWrapper>)
            JSON.deserialize(JSON.serialize(PLEs), List<PicklistEntryWrapper>.class);
    }

    public class PicklistEntryWrapper{
        public String active {get;set;}
        public String defaultValue {get;set;}
        public String label {get;set;}
        public String value {get;set;}
        public String validFor {get;set;}
        public PicklistEntryWrapper(){            
        }

    }



    
}