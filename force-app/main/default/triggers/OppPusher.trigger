trigger OppPusher on Opportunity (before update) {
    
Date dNewCloseDate;
Date dOldCloseDate;
Boolean bPushed=false;

for (Opportunity oIterator : Trigger.new) { //Bulk trigger handler so that you can mass update opportunities and this fires for all'
                                            // gets new values for updated rows
    dNewCloseDate = oIterator.CloseDate; // get the new closedate 
    dOldCloseDate = System.Trigger.oldMap.get(oIterator.Id).CloseDate; //get the old closedate for this opportunity
    if (dOldCloseDate<dNewCloseDate) { //if the new date is after the old one, look if the month numbers are different
        if (dOldCloseDate.month()<dNewCloseDate.month()) { // the month number is higher, it's been pushed out
            bPushed=true;
        }
        else {
            if (dOldCloseDate.year()<dNewCloseDate.year()) { // the month wasn't higher, but the year was, pushed!
                bPushed=true;
                }
            }
        
    }
    if (bPushed==true) { // let's go make them sorry
        if (oIterator.PushCount__c==null) {
            oIterator.PushCount__c=1;
        }
        else {
        oIterator.PushCount__c++;           
        }
    }
}
    
}