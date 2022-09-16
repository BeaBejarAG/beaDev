// Owner A Mannering # Written by A Mannering @ The Access Group 2017
// 
// V1 Deployed to Production 28/04/2017 16:23
// V2 Updated Upselling logic to include accounts that have no contract data but have a became customer date 	02/05/2017 13:00
// V3 Update New Business logic to include Null Account code aswell as becamecustomerdate 	17/05/2017 12:17
// 
//  --------------------------------------------------------------------------------------


trigger OppLineLogicTrigger on OpportunityLineItem (before insert , Before Update) {
    
    
    //Declare Lists and Sets
    
    Set<Id> Accountids = new Set<Id>();
    Set<id> Oppsid = new Set<Id>();
    Set<Id> ParentIds = new Set<Id>();
    Set<String> thirdSet = new Set<String>();
    Set<String> LineItemSet = new Set<String>();
    List<OpportunityLineItem> oppLstToUpdate=new List<OpportunityLineItem>();
    list<Opportunitylineitem> Lineitem = [Select account__C, Account_Parent_Id__c From Opportunitylineitem where id in :trigger.new Limit 1];
    
    for(OpportunityLineItem OpplineItemsID : lineitem)
    
       {
        Accountids.add(OpplineItemsID.account__C);
        ParentIds.add(OpplineItemsID.Account_Parent_Id__c);
        oppsid.add(OpplineItemsID.id);
       }
    
   system.debug('id ' + accountids);
    
    //Create Lists to hold Product Family values from assets and opportunitylineitems
    
    List<OpportunityLineItem> ProductFamiliesOpps = [Select Product_Family__c from OpportunityLineItem where id in :oppsid Limit 1];
        list<Asset> ProductFamiliesAssests = new list<Asset>();
    
    if(ParentIds != null){
        ProductFamiliesAssests = [Select Asset_family__C from Asset where accountid in :Accountids];
    }
    else
    {
          ProductFamiliesAssests = [Select Asset_family__C from Asset where accountid in :Accountids or accountid in :ParentIds];
    }
    
    
    List<Contract> Contracts = [Select id From Contract where accountid in :accountids or accountid in :ParentIds];
    
    
    
    system.debug('Assets ' + ProductFamiliesAssests);
    system.debug('Assets ' + ProductFamiliesOpps);
    
    
    //loop through assets in list to store unique values in set
    
     for (Asset Asst : ProductFamiliesAssests) 
     {
        IF(asst.Asset_Family__c != Null)
        
        {
            thirdSet.add(Asst.Asset_family__C );
        }
    }
    
    //Loop through opportunitylineitems in list to store unique values in set
    
    for (OpportunityLineItem Oppline : ProductFamiliesopps)
    {
        If(oppline.Product_Family__c != Null)
        {
            LineItemSet.add(Oppline.Product_Family__c );
        }
    }
    
    //Retain any matches in both sets - ie if list one contains acloud and dimensions and list two contains acloud then acloud is retained
    
    
    
    system.debug('thirdset ' + thirdSet);

    system.debug(contracts.size());
    
  
    
    //Loop through opplineitems in trigger new and update type
    
    for(Opportunitylineitem Opplist1 : Trigger.new)
    {
        
        if(Opplist1.id != null && opplist1.Handover_Id__c == Null && ProductFamiliesOpps.size() >= 1 ){
            
           IF(Opplist1.BecameCustomerDate__c != Null && Opplist1.oppclosedate__C < Opplist1.BecameCustomerDate__c + 180 && Opplist1.From_Acquisitionoppline__c != True )
        
        {
            Opplist1.type__C = 'New Business';
        }
                 
                
           Else if(Opplist1.BecameCustomerDate__c == Null || opplist1.Account_Code__c == NULL)
           
           {
             Opplist1.type__C = 'New Business';
           }        
                        
            
            Else if (Contracts.isEmpty() && opplist1.BecameCustomerDate__c != Null){
            
             Opplist1.type__C = 'Cross-Selling';
            
           
        }
           
            
             
        
            Else if (thirdset.contains(opplist1.Product_Family__c)){
            
             Opplist1.type__C = 'Up-Selling';
            
            
        }
            
            
            Else {
                
                 Opplist1.type__C = 'Cross-Selling';
                
                }
            oppLstToUpdate.add(opplist1);
            system.debug('Opp' + oppLstToUpdate);
        }
         
       
            
            }

  
 
  

}