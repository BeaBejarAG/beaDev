public with sharing class GetProductEntitlementsComm 
{    
 
@AuraEnabled
//public static List<ContactEntitlement__c> MyEntitlements() {
//    List<ContactEntitlement__c> objList = new List<ContactEntitlement__c>();
//    for(ContactEntitlement__c myObj: [select ContactEntitlement__c.Product__C, ContactEntitlement__c.Topic_ID__c
//from ContactEntitlement__c 
//where ContactEntitlement__c.Contact__C = :[Select contactid from User where id =: Userinfo.getUserid()].contactId]) {
    //    objList.add(myObj);
  //  }
//return objList;
    
//}
//
    public static boolean GetCurrentUser(id userid){
        boolean CommunityUser;
        string ProfileId = [select ProfileId from User where id = :Userinfo.getUserid()].ProfileId;
        
        if(ProfileId.contains('00e58000000Nh5B')){
            CommunityUser = true;
        }
        else if (ProfileId.contains('00e58000000NgDx'))
        {
            CommunityUser = true;
        }
        else if (ProfileId.Contains('00e58000000hlf5'))
        {
            CommunityUser = true;
        }
        else
        {
            CommunityUser = false;
        }
        
        return CommunityUser;
       
    }
 @AuraEnabled   
public static List<ContactEntitlement__c> MyEntitlements() {
    
    string contactiduser = [Select contactid from User where id = :Userinfo.getUserid()].contactId;
    List<ContactEntitlement__c> objList = new List<ContactEntitlement__c>();
    for
     (ContactEntitlement__c myObj: [select ContactEntitlement__c.Product__C, ContactEntitlement__c.Topic_ID__c
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
    public static List<Entitlement> MyEntitlementsPayroll() {
    List<ContactEntitlement__c> objList = new List<ContactEntitlement__c>();
    List<Entitlement> EntList = new List<Entitlement>();
    for(ContactEntitlement__c myObj: [select ContactEntitlement__c.Product__C, ContactEntitlement__c.Topic_ID__c, ContactEntitlement__c.Real_Entitlement__c
    from ContactEntitlement__c 
    where ContactEntitlement__c.Product__C = 'Payroll'                                      ])
        {
        //objList.add(myObj);
         for(Entitlement EntObj : [select Entitlement.Name, Entitlement.Payroll_Licence__c, Entitlement.Payroll_Status__c, Entitlement.Payroll_Licence_Paid__c, Entitlement.Payroll_Contract__c, 
                                   Entitlement.Payroll_Users__c, Entitlement.Payroll_Product__c, Entitlement.Payroll_CC_Email__c, Entitlement.Payroll_Credit_Controller__c, Entitlement.Payroll_EMPS__c, 
                                   Entitlement.Payroll_is_hosted__c, Entitlement.Payroll_Is_Dealer__c, Entitlement.Payroll_Ref__c,Entitlement.Payroll_Is_URL__c, Entitlement.Payroll_serial__c
                              from Entitlement
                              where Entitlement.id = :myObj.Real_Entitlement__c ])
     {
         EntList.add(EntObj);
     }
           
        }
        
return EntList;


    
}
    
    
    
}