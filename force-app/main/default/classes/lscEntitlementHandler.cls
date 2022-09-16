public with sharing class lscEntitlementHandler {
    public lscEntitlementHandler() {
    }
    @AuraEnabled(cacheable=true)
    public static List<EntitlementContact> GetEntitlementContacts(id EntId)
    {
        List<EntitlementContact> enc = new List<EntitlementContact>();
        enc = [select id, name, contact.email, contact.name, contact.account.name, contact.status__c, contact.Id, contact.Community_User_Profile__c from EntitlementContact where EntitlementId = :EntId order by name];
        //enc = [select id, name, email from contact where id in (select ContactId from EntitlementContact where entitlementid = :EntId and isdeleted = false)];
        //select name, email from contact where id in (select ContactId from EntitlementContact where entitlementid = '5507E000000gZbNQAU')
    


        return enc;
    }
    @AuraEnabled
    public static List<Contact> GetAccountContacts(id EntId, id AccId)
    {
        List<Contact> enc = new List<Contact>();
        //enc = [select id, name from EntitlementContact where EntitlementId = :EntId];
        enc = [select name, email from contact where id not in (select ContactId from EntitlementContact where entitlementid = :EntId and isdeleted = false) and accountid = :Accid and (Status__c = 'Active' or Status__c = 'Maternity Leave' or Status__c = 'Furlough Leave' ) order by name];
        //select name, email from contact where id not in (select ContactId from EntitlementContact where entitlementid = '5507E000000gZbNQAU')
            //Active", "Maternity Leave" and "Furlough Leave"


        return enc;
    }

    @AuraEnabled(cacheable=true)
    public static List<entitlement > GetContactEntitlements(id ContactId, id AccountID)
    {
        List<entitlement> enc = new List<entitlement>();
        enc = [select id, name, AuthorisedContacts__c, RemainingAuthorisedContacts__c, AssociatedProductRange__c  from entitlement where id in (select entitlementid from entitlementcontact where contactid = :ContactId)  and accountid = :AccountID and active__c = true order by AssociatedProductRange__c ];
       // enc = [select name, email from contact where id not in (select ContactId from EntitlementContact where entitlementid = :EntId and isdeleted = false) and accountid = :Accid order by name];
        //select name, email from contact where id not in (select ContactId from EntitlementContact where entitlementid = '5507E000000gZbNQAU')
        //select id, Contact__c, Real_Entitlement__r.name  from contactentitlement__c where Contact__c = '0033H0000055B91QAE'


        return enc;
    }

    @AuraEnabled(cacheable=true)
    public static List<entitlement > GetAccountEntitlements(id ContactId, id AccountID)
    {
        List<entitlement> enc = new List<entitlement>();
        enc = [select id, name, AuthorisedContacts__c, RemainingAuthorisedContacts__c from entitlement where id not in (select entitlementid from entitlementcontact where contactid = :ContactId) and accountid = :AccountID and active__c = true order by AssociatedProductRange__c];
       // enc = [select name, email from contact where id not in (select ContactId from EntitlementContact where entitlementid = :EntId and isdeleted = false) and accountid = :Accid order by name];
        //select name, email from contact where id not in (select ContactId from EntitlementContact where entitlementid = '5507E000000gZbNQAU')
        //select id, Contact__c, Real_Entitlement__r.name  from contactentitlement__c where Contact__c = '0033H0000055B91QAE'


        return enc;
    }

    @AuraEnabled
    public static List<Contact> GetAccountContactsFliterd(id EntId, id AccId, String filter)
    {
        string filterSearch = '%'+filter+'%';
        List<Contact> enc = new List<Contact>();
        //enc = [select id, name from EntitlementContact where EntitlementId = :EntId];
        enc = [select name, email from contact where id not in (select ContactId from EntitlementContact where entitlementid = :EntId and isdeleted = false) and accountid = :Accid and name like :filterSearch and (Status__c = 'Active' or Status__c = 'Maternity Leave' or Status__c = 'Furlough Leave' )  order by name];
        //select name, email from contact where id not in (select ContactId from EntitlementContact where entitlementid = '5507E000000gZbNQAU')


        return enc;
    }


    @AuraEnabled
    public static boolean DeleteEntContacts(id EntContID)
    {
        EntitlementContact[] EntCont = [Select id, name from EntitlementContact where id = :EntContID];

        try{
        delete EntCont;
        }
        catch (DmlException e)
        {
            return false;
        }

        return true;
    }

    @AuraEnabled
    public static string DeleteEntContact(id EntID, id conid)
    {
        EntitlementContact[] EntCont = [Select id, name from EntitlementContact where contactid = :conid and Entitlementid = :EntID];

        try{
        delete EntCont;
        }
        catch (Exception e){
            return e.getMessage();    
        }
            return 'Success';

    }

    @AuraEnabled
    public static void AddEntContacts(List<string> ContactIds, string EntID){
        
        for(string conid : ContactIds)
        {
            EntitlementContact entcont = new EntitlementContact(
                ContactId = conid,
                EntitlementId = EntID

            );

            insert entcont;
        }
    }

    @AuraEnabled
    public static string AddEntContactscon(string conid, string EntID){
        
        try{
            EntitlementContact entcont = new EntitlementContact(
                ContactId = conid,
                EntitlementId = EntID

            );

            insert entcont;
        }
        catch (Exception e){
        return e.getMessage();    
        }
        return 'Success';
        
    }
}