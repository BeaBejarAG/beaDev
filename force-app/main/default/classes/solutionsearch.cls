public class solutionsearch {
public case cases{get;set;}
    public solutionsearch(ApexPages.StandardController controller) {
        cases = (Case)controller.getRecord();
        cases.recordtypeid='012580000006Hfd';
    }

public list <case> acc {get;set;}
public string searchstring {get;set;}
public string RelatedProduct{get;set;}
public string SubAnalysis {get;set;}
public boolean ClosedCases {get;set;}
    
public void search(){
//string searchquery='select CaseNumber, id, subject, solution__c from case where RelatedProduct__c = :' +value1+ ' Limit 20'; 
//acc= Database.query(searchquery);
searchstring = '%'+ searchstring + '%';
if(ClosedCases)
{
    if(string.isBlank(RelatedProduct))
    {
    acc = [select CaseNumber, id, subject, solution__c from case where subject like :searchstring and IsClosed = true];
    }
    else if(string.isblank(SubAnalysis))
    {
     acc = [select CaseNumber, id, subject, solution__c from case where RelatedProduct__c = :RelatedProduct and subject like :searchstring and IsClosed = true];
    }
    else
    {
       acc = [select CaseNumber, id, subject, solution__c from case where RelatedProduct__c = :RelatedProduct and SubAnalysis__C = :SubAnalysis and subject like :searchstring and IsClosed = true]; 
    }
}
else if(!ClosedCases)
{
    
    if(string.isBlank(RelatedProduct))
    {
    acc = [select CaseNumber, id, subject, solution__c from case where subject like :searchstring ];
    }
    else if(string.isblank(SubAnalysis))
    {
     acc = [select CaseNumber, id, subject, solution__c from case where RelatedProduct__c = :RelatedProduct and subject like :searchstring ];
    }
    else
    {
       acc = [select CaseNumber, id, subject, solution__c from case where RelatedProduct__c = :RelatedProduct and SubAnalysis__C = :SubAnalysis and subject like :searchstring ]; 
    }
}

} 
}