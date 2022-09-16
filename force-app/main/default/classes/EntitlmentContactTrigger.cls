/************************************************************************************
 * Class Name: EntitlementContactTrigger 
 * Purpose: Create/Update/Delete fake entitlement Contacts (ContactEntitlement__C).
 * Author: Chris Lewis
 * Release Version: 1
 * Release Code Coverage: 100%
 * Notes: Please copy the template line below if you make changes, please mark the version change (Every push to Prod is a new version), Anotate any changed lines with your version and what was changed 
 * Also please ensure any test code is at least the same code coverage as the release code coverage
 * Changed By: YOURNAME Date: THISDATE Reason\Changes: YOUR REASON Version: PREV+1
 * *********************************************************************************/
public class EntitlmentContactTrigger {
    
    public boolean Check_If_account_Correct(EntitlementContact RealEntitlementCont)
    {
        Entitlement EntAccountID = [SELECT AccountId FROM Entitlement WHERE id = :RealEntitlementCont.entitlementid]; 
        Contact ConAccountID = [SELECT AccountId, (SELECT AccountId FROM AccountContactRelations) FROM Contact WHERE id = :RealEntitlementCont.ContactId]; 
        system.debug('Ent Account ID = :' + EntAccountID);
        system.debug('Contact Account ID = :' + ConAccountID);
        

        List<Id> accountContactRelationIds = new List<Id>();
        for(AccountContactRelation accountContactRelation: ConAccountId.AccountContactRelations) {
          accountContactRelationIds.add(accountContactRelation.AccountId);
        }
        
        //if(EntAccountID.AccountId != ConAccountID.AccountId)
        if (!accountContactRelationIds.contains(EntAccountID.AccountId))
        {
            return false;
        }      
        return true;
    }
    
    public void Manage_Fake_Entitlements_Insert(EntitlementContact[] newTrigger)
    {
   //Create Empty list to fill with new records to be added
   List<ContactEntitlement__C> FakeEntitlementContact = new List<ContactEntitlement__C>();
   
   //Add new records to the list
   for(EntitlementContact RealEntitlementCont : newTrigger) 
      {
          IF(!Check_If_account_Correct(RealEntitlementCont))
          RealEntitlementCont.EntitlementId.addError('One or more Contact Accounts do not match the Entitlement Account. Contact and Entitlement must be on the same Account.');
          
      //Create Empty Fake Entitlement Contact Object
      ContactEntitlement__C NewFakeEntCont = new ContactEntitlement__C();
      
      //id FakeEntitlementid = [Select Id from Entitlement__C where Entitlement__C = :RealEntitlementCont.entitlementid].id;
      string EntitlementProduct = [Select AssociatedProductRange__c from Entitlement where id = :RealEntitlementCont.entitlementid].AssociatedProductRange__c;
      
       //Assign Varibles
       NewFakeEntCont.Name = EntitlementProduct;
       NewFakeEntCont.Contact__c = RealEntitlementCont.contactid;
       NewFakeEntCont.Real_Entitlement__c= RealEntitlementCont.EntitlementID;

      //Add to the list
      FakeEntitlementContact.add(NewFakeEntCont);

      }
   //Check if the list is empty, if not add to the Database
        if (FakeEntitlementContact.isEmpty() == false)
        {
               Database.insert(FakeEntitlementContact);
        }
    }
    
    
        public void Manage_Fake_Entitlements_Delete(EntitlementContact[] oldTrigger)
    {
        List<ContactEntitlement__C> delFakeEntitlementContact = new List<ContactEntitlement__C>();
   
      for(EntitlementContact RealEntitlementCont : oldTrigger)
      {
       //Double check the object exists
      //id FakeEntitlementid = [Select Id from Entitlement__C where Entitlement__C = :RealEntitlementCont.entitlementid].id;
      ContactEntitlement__C[] ExitingEntitlementCon = [Select Id from ContactEntitlement__C where Real_Entitlement__C= :RealEntitlementCont.entitlementid and contact__c = :RealEntitlementCont.contactid];
      ContactEntitlement__C NewFakeEntCont = new ContactEntitlement__C();
      
     if(ExitingEntitlementCon .size() > 0)
     {
        NewFakeEntCont.id = ExitingEntitlementCon[0].id;
          delFakeEntitlementContact.add(NewFakeEntCont);
      }
   
 
   }
     if (delFakeEntitlementContact.isEmpty() == false){
   Database.delete(delFakeEntitlementContact);
   }
 // EO Delete
  }
    
}