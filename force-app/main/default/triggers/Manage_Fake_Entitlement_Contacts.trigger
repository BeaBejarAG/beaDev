/************************************************************************************
 * Trigger Name: Manage_Fake_Entitlement_Contacts 
 * Purpose: Create/Update/Delete fake entitlement Contacts (ContactEntitlement__C).
 * Author: Chris Lewis
 * Release Version: 2
 * Release Code Coverage: 100%
 * Notes: Please copy the template line below if you make changes, please mark the version change (Every push to Prod is a new version), Anotate any changed lines with your version and what was changed 
 * Also please ensure any test code is at least the same code coverage as the release code coverage
 * Changed By: YOURNAME Date: THISDATE Reason\Changes: YOUR REASON Version: PREV+1
 * -------------------------------------------------------------------------------
 * Changed By: Chris Lewis Date: 23/07/2018 Reason\Changes: Removed all code and changed to be a referring a Class rather than code in trigger Version: 2
 * *********************************************************************************/
trigger Manage_Fake_Entitlement_Contacts on EntitlementContact (after insert, after update, before delete) 
{
EntitlmentContactTrigger ECT = new EntitlmentContactTrigger();
If(Trigger.IsInsert)
   {
   ECT.Manage_Fake_Entitlements_Insert(trigger.new);
   }
 
   If(Trigger.IsDelete)
   {
  ECT.Manage_Fake_Entitlements_Delete(trigger.old);
   }

}