@isTest(SeeAllData=true)
public class cspArticleProductMappingTest {
    
    @isTest
    private static void processArticles() {
        Knowledge__kav newArticle = TestUtilities.getArticleAsADraft('New title', 'new-url-name' + Crypto.getRandomInteger());
        newArticle.Division__c = 'Business Management';
        newArticle.Product__c = 'Access Approve';
        newArticle.Product_Features__c = 'Configuration';
        newArticle.Featured__c = true;
        
        insert newArticle;
        String articleId = [SELECT KnowledgeArticleId FROM Knowledge__kav WHERE Id =: newArticle.Id].KnowledgeArticleId;
        KbManagement.PublishingService.publishArticle(articleId, true);

        Test.StartTest();
        cspArticleProductMapping noOpMapper = new cspArticleProductMapping('SELECT Id, KnowledgeArticleId, Title, Product__c, Division__c, (SELECT Id,toLabel(DataCategoryName),DataCategoryGroupName FROM DataCategorySelections) FROM Knowledge__kav WHERE publishStatus=\'online\' LIMIT 20', true);
        ID noOpBatch = Database.executeBatch(noOpMapper);

        cspArticleProductMapping mapper = new cspArticleProductMapping('SELECT Id, KnowledgeArticleId, Title, Product__c, Division__c, (SELECT Id,toLabel(DataCategoryName),DataCategoryGroupName FROM DataCategorySelections) FROM Knowledge__kav WHERE publishStatus=\'online\' LIMIT 20', false);
        ID batchprocessid = Database.executeBatch(mapper);
        Test.StopTest();
    }
}