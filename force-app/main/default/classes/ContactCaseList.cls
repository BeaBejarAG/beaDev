/***********************************************************************************************************************************************
 * Name: ContactCaseList
 *
 * Written By: Darren Kelly.
 *
 * Description: Class to manage exporting Case details into Excel:
 *              
 *					1. The code could be called from anywhere in Salesforce, but will be used by Community Users.
 *					   The VF page will simply hand off to this controller. Complete the following:  
 *						- Get the List of Cases for the current user.
 *						- For these cases then get the list of PUBLIC case comments.
 *
 * Notes:       1. The VF page that calls this controller has "application/vnd.ms-excel#mycases.xls" in 
 *					the header. This will render the VF page contant as Excel.
 *
 *
 * Version:     Version 1 - 20th December 2017.
 *
 * Change Log:  Changed By      Date    Description
 *              _____________   _______ ________________________________________________________________________________________________________
 *      
 *
 ***********************************************************************************************************************************************/

public class ContactCaseList
{
    // Global declarations
    public List<Case> cse;
    public List<CaseComment> cseCmts; 
    Id userid = Userinfo.getUserId();
    
    //*************************************************************************************************
	//	Controller method - get the lists for the VF page to render as Excel
	//
	//
	//*************************************************************************************************
    public ContactCaseList() 
    {
            List <Case> cse = getcse();
            List <CaseComment> cseCmts = getcseCmts();
    }
    
    // Getter methods.
    public List<Case> getcse()
    {

            Id userid = Userinfo.getUserId();
                cse = [Select CaseNumber, (Select parent.CaseNumber, CreatedDate, ParentId, IsPublished, CommentBody From CaseComments),   Priority, status, Description, Subject, Origin, Contact.Name, Solution__c, Owner.Name,
                		Status_Summary__c, Created_Post_Go_Live__c, Division__c, Modified_In_Last_7_Days__c, Parent.CaseNumber, CaseImportance__c, Type,
                		RelatedProduct__c, SubAnalysis__c, Case_Escalated__c, CustomerLastContacted__c, NextContactDate__c,
                		CreatedDate, ClosedDate
                        from case
                        where contactid = : userId limit 1000];
                return cse;
    }

	// Comments getter - this uses a for loop as the comments are a list in the list and will need to be 
	// iterated over before they can be presented.
    public List<CaseComment> getcseCmts()
    {
			List <CaseComment> cseCmts = new List <CaseComment>();
            Id userid = Userinfo.getUserId();
            for (Case c : [Select CaseNumber, 
            				(Select parent.CaseNumber, CreatedDate, ParentId, IsPublished, CommentBody From CaseComments where IsPublished = true)
                           from case
                           where createdbyid = : userId limit 1000])
                           {
                        		if (c.CaseComments != null)
                        		{
                        			for (CaseComment cc : c.CaseComments)
                    				{
                    					if (cc != null)
                        				cseCmts.add(cc);
                    				}
                        		}		
                        	}
                
                return cseCmts;
    }    
    

    
}