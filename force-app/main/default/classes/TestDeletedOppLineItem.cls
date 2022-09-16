@isTest(seeAllData=true)
public class TestDeletedOppLineItem {
    
   
public static testMethod void testoppinsert(){
    
date datetimes = date.today();
        
Account acc = new Account(Name = 'Test Account');
insert acc;

Contact Cnt = new contact(lastname = 'Tester', Phone = '+441223123123');
    Cnt.AccountId = acc.id;
    
    Insert cnt;
    
Campaign cmp1 = new Campaign(name= 'testcampaign');

        Product2 prod = new Product2(Name = 'Laptop X200', 
            Family = 'Hardware');
        insert prod;
        
        // Get standard price book ID.
        // This is available irrespective of the state of SeeAllData.
        Id pricebookId = Test.getStandardPricebookId();
        
        // 1. Insert a price book entry for the standard price book.
        // Standard price book entries require the standard price book ID we got earlier.
        PricebookEntry standardPrice = new PricebookEntry(
            Pricebook2Id = pricebookId, Product2Id = prod.Id,
            UnitPrice = 10000, IsActive = true);
        insert standardPrice;
        
        // Create a custom price book
        Pricebook2 customPB = new Pricebook2(Name='Custom Pricebook', isActive=true);
        insert customPB;
        
        // 2. Insert a price book entry with a custom price.
        PricebookEntry customPrice = new PricebookEntry(
            Pricebook2Id = customPB.Id, Product2Id = prod.Id,
            UnitPrice = 12000, IsActive = true);
        insert customPrice;

Opportunity opp1 = new Opportunity (Name='Opp1',StageName='Stage 0 - Lead Handed Off',CloseDate=Date.today(),Pricebook2Id = customPrice.Pricebook2Id, AccountId = acc.id, campaignid = cmp1.id);

    opp1.Primary_Contact__c = cnt.Id;
    
    insert opp1;
    
        

OpportunityLineItem lineItem1 = new OpportunityLineItem (OpportunityID=opp1.id,PriceBookEntryID=customPrice.id, quantity=4, totalprice=200);
insert lineItem1;   

string lineitemid = lineitem1.Id;  
String oppid1 = opp1.Id;

 System.debug('Harshit Mishra::'+lineItem1);
 delete lineItem1;
 system.assert(true, 'should delete');
    
    
 deletedOppLineItem__c myCustomObject = new deletedOppLineItem__c (datenTime__c = datetimes, oppId__c = oppid1, oppLineItemID__c=lineitemId,name ='Abcd');
  
    
        try{
    
insert myCustomObject;
            system.assertEquals(lineitemId,mycustomobject.oppLineItemID__c);
    }
    catch (DMLexception e){
        
        system.assert(false, 'should be no failure');   
    }
   
  
          
  
    
    
    
    
 


        
       
}
    
      
}