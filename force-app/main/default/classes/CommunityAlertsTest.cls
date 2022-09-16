@IsTest 

public with sharing class CommunityAlertsTest {

    @AuraEnabled

@IsTest Public Static void GetAlertHeader()
    
{
Service_Status_Update__c cia = new Service_Status_Update__c();
    cia.Title__c = 'ALTO Services';
    cia.Description__c = 'Test';
    cia.Visible__c = TRUE;
    cia.recordtypeId = '0124I0000006RgqQAE';
    insert cia;

List<Service_Status_Update__c> Alert = (CommunityAlerts.GetCommunityAlerts());
    if(Alert.size() > 0)
    {
System.assertEquals('ALTO Services',Alert[0].Title__c);
    }
}

@IsTest Public Static void GetServicePage()
    //DateTime dt = DateTime.Now()
{
Service_Status_Update__c ssp = new Service_Status_Update__c();
    ssp.Title__c = 'ALTO Status';
    ssp.Description__c = 'Test';
    ssp.Open_Date__c = DateTime.Now().date();
    ssp.Visible__c = TRUE;
    ssp.recordtypeId = '0124I0000006RgrQAE';
    insert ssp;

List<Service_Status_Update__c> Alert = (CommunityAlerts.GetServicePage());
    if(Alert.size() > 0)
    {
System.assertEquals('ALTO Status',Alert[0].Title__c);
    }
}

@IsTest Public Static void GetServiceStatus()
    
{
Service_Status_Update__c css = new Service_Status_Update__c();
css.Title__c = 'ALTO Service';
css.Description__c = 'Test';
css.Related_Product_Range__c = 'Dimensions';
css.Visible__c = TRUE;
css.recordtypeId = '0124I0000006RgqQAE';
    insert css;

List<Service_Status_Update__c> Alert = (CommunityAlerts.GetServiceStatus('Dimensions'));
    if(Alert.size() > 0)
    {
System.assertEquals('ALTO Service',Alert[0].Title__c);
    }
}

@IsTest Public Static void GetProductNotification()
    
{
Service_Status_Update__c cpn = new Service_Status_Update__c();
cpn.Title__c = 'ALTO Product';
cpn.Description__c = 'Test';
cpn.Related_Product_Range__c = 'Dimensions';
cpn.Visible__c = TRUE;
cpn.recordtypeId = '0124I000000Qn2xQAC';
    insert cpn;

List<Service_Status_Update__c> Alert = (CommunityAlerts.GetProductNotification('Dimensions'));
    if(Alert.size() > 0)
    {
System.assertEquals('ALTO Product',Alert[0].Title__c);
    }
}

@IsTest Public Static void GetProductNotificationnull()
    
{
Service_Status_Update__c cpn = new Service_Status_Update__c();
cpn.Title__c = 'ALTO Product';
cpn.Description__c = 'Test';
cpn.Related_Product_Range__c = null;
cpn.Visible__c = TRUE;
cpn.recordtypeId = '0124I000000Qn2xQAC';
    insert cpn;

List<Service_Status_Update__c> Alert = (CommunityAlerts.GetProductNotification(null));
    if(Alert.size() > 0)
    {
System.assertEquals('ALTO Product',Alert[0].Title__c);
    }
}

 @IsTest   Public Static List<Service_Status_Update__c> GetCommunityAlerts()
    {
        List<Service_Status_Update__c> comalert = new List<Service_Status_Update__c>([select Title__c, Description__c from Service_Status_Update__c where Visible__c = true]);
       return comalert;
    }
    
}