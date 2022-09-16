@IsTest
public class SolutionSearchTest {
    
@IsTest Public Static void Search()
{
   case newcase = new case (description='test');
    insert newcase;
    
//    case cases = [select CaseNumber, id, subject, solution__c from case];
    
//    boolean iscaseclosed = false;
    
//    PageReference pageref = Page.Solution_SearchPage;
//    Test.setCurrentPage(pageref);
    
//    Apexpages.currentPage().getParameters().put('searchstring','test');
//    boolean pbv = ApexPages.currentPage().getParameters().get('ClosedCases') == 'true';
    
//    Apexpages.StandardController sc = new Apexpages.StandardController(cases);
//    solutionsearch ext = new solutionsearch(sc);
//    ext.search();
//    
solutionsearch sc = new solutionsearch(new ApexPages.StandardController(newcase));
    sc.closedcases = true;
    sc.searchstring = 'test';
    sc.search();
    
    sc.closedcases = false;
    sc.searchstring = 'test';
    sc.search();
    
    sc.closedcases = false;
    sc.searchstring = 'test';
    sc.RelatedProduct = 'Dimensions';
    sc.search();
    
    sc.closedcases = true;
    sc.searchstring = 'test';
    sc.RelatedProduct = 'Dimensions';
    sc.search();
    
    sc.closedcases = false;
    sc.searchstring = 'test';
    sc.RelatedProduct = 'Dimensions';
    sc.SubAnalysis = 'Other';
    sc.search();
    
    sc.closedcases = true;
    sc.searchstring = 'test';
    sc.RelatedProduct = 'Dimensions';
    sc.SubAnalysis = 'Other';
    sc.search();
}
}