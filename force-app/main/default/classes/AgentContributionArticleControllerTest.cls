/** Test class for the custom extension controller.
*/
@isTest
private class AgentContributionArticleControllerTest {
    static testMethod void testAgentContributionArticleController() { 
         String caseSubject = 'my test';
         String caseDesc = 'my test description';

         Case c = new Case();
         c.subject= caseSubject;
         c.description = caseDesc;
         c.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Support').getRecordTypeId();
         insert c;
         String caseId = c.id;
         System.debug('Created Case: ' + caseId);
         
         ApexPages.currentPage().getParameters().put('sourceId', caseId);
         ApexPages.currentPage().getParameters().put('sfdc.override', '1');
         
         ApexPages.KnowledgeArticleVersionStandardController ctl = 
            new ApexPages.KnowledgeArticleVersionStandardController(new Knowledge__kav());
         
         new AgentContributionArticleController(ctl);

         System.assertEquals(caseId, ctl.getSourceId());
         System.assertEquals('From Case: '+caseSubject, ctl.getRecord().get('title'));
         System.assertEquals(caseDesc, ctl.getRecord().get('Information_Article_Body__c'));
   }
}