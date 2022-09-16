/***********************************************************************************************************************************************
 * Name: ContactCaseListTest - Test Class
 *
 * Written By: Darren Kelly.
 *
 * Description: Test the Class to manage exporting Case details into Excel.
 *              
 *
 * Notes:       1. Test that the page is called and that the queries are fired, cannot test that 
 *					an excel file was downloaded.
 *
 *
 * Version:     Version 1 - 20th December 2017.
 *
 * Change Log:  Changed By      Date    Description
 *              _____________   _______ ________________________________________________________________________________________________________
 *      
 *
 ***********************************************************************************************************************************************/

@isTest (SeeAllData=false)
private class ContactCaseListTest 
{

    static testMethod void myUnitTest() 
    {
        // Test the excel extract.
        // Create Cases to export
        // Add Comments
        // Run the code as currnet user
        
        // Create some Cases
        Account a = new Account();
        a.Name = 'Test Class Account';
        insert a;
        
        Id devRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Support').getRecordTypeId();
        Contact thisContact = TestUtilities.getContact();
        insert thisContact;
        Case c1 = new Case();
        c1.AccountId = a.Id;
        c1.Status = 'Support Outstanding';
        c1.Priority = '3';
        c1.Origin = 'Web';
        c1.Source__c = 'Support';
        c1.Subject = 'Test Class Case';
        c1.Description = 'Test Class Description';
        c1.ContactId = thisContact.Id;
        c1.RecordTypeId = devRecordTypeId;
        insert c1;
        
        
        CaseComment cc1 = new CaseComment();
        cc1.ParentId = c1.Id;
        cc1.CommentBody = 'New Comment fom Support';
        cc1.IsPublished = true;
        insert cc1;
        
        // Create the excel list by instantiating the Class
        ContactCaseList ccl = new contactCaseList();
        
        
    }
}