/************************************************************************************
 * Class Name: CommunityAlerts
 * Purpose: Get the data from the object Service_Status_Update__c
 * Author: Chris Lewis
 * Release Version: 1
 * Release Code Coverage: Unknown
 * Notes: Please copy the template line below if you make changes, please mark the version change (Every push to Prod is a new version), Anotate any changed lines with your version and what was changed 
 * Also please ensure any test code is at least the same code coverage as the release code coverage.
 * This was originaly created by a 3rd party so missing annotations.
 * Changed By: YOURNAME Date: THISDATE Reason\Changes: YOUR REASON Version: PREV+1
 * *********************************************************************************/

public with sharing class CommunityAlerts {
    
@AuraEnabled  
   Public Static List<Service_Status_Update__c> GetCommunityAlerts()
    {
        List<Service_Status_Update__c> comalert = new List<Service_Status_Update__c>([select Title__c, Description__c from Service_Status_Update__c where Visible__c = true and recordtypeId = '0124I0000006RgqQAE']);
       return comalert;
    }
    @AuraEnabled  
       Public Static List<Service_Status_Update__c> GetServicePage()
    {
        List<Service_Status_Update__c> servicepage = new List<Service_Status_Update__c>([select Title__c, Description__c, Open_Date__c, Status__c from Service_Status_Update__c where Visible__c = true and recordtypeId = '0124I0000006RgrQAE']);
       return servicepage;
    }

    @AuraEnabled
    public static List<Service_Status_Update__c> GetServiceStatus(string product){
      try {
         List<Service_Status_Update__c> comalert = new List<Service_Status_Update__c>([select Title__c, Description__c, Related_Product_Range__c  from Service_Status_Update__c where Visible__c = true and recordtypeId = '0124I0000006RgqQAE' and related_product_Range__c includes (:product)]);          
         return comalert;
      } catch (Exception e) {
          throw new AuraHandledException(e.getMessage());
          return null;
       }
       return null;
    }

    @AuraEnabled
    public static List<Service_Status_Update__c> GetProductNotification(string product){
      try {
         List<Service_Status_Update__c> comalert = new List<Service_Status_Update__c>([select Title__c, Description__c, Related_Product_Range__c  from Service_Status_Update__c where Visible__c = true and recordtypeId = '0124I000000Qn2xQAC' and related_product_Range__c includes (:product)]);          
         return comalert;
      } catch (Exception e) {
          throw new AuraHandledException(e.getMessage());
          return null;
       }
       return null;
    }
    
    
}