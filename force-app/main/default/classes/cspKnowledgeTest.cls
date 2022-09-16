@isTest
public class cspKnowledgeTest {
    @isTest
    private static void getKnowledgeArticle() {
        Knowledge__kav newArticle = TestUtilities.getArticleAsADraft('New title', 'new-url-name' + Crypto.getRandomInteger());
        newArticle.Division__c = 'Business Management';
        newArticle.Product__c = 'Access Approve';
        newArticle.Product_Features__c = 'Configuration';
        
        ProductRouting__c pr = new ProductRouting__c(
            name = 'Access Approve',
            Related_Product_Range__c = 'Access Approve',
            Product_Division__c = 'FMS'
            
        );
        
        insert pr;

        insert newArticle;
        String articleId = [SELECT KnowledgeArticleId FROM Knowledge__kav WHERE Id =: newArticle.Id].KnowledgeArticleId;
        KbManagement.PublishingService.publishArticle(articleId, true);

        Map<String, Object> knowledgeResult = CspKnowledge.getKnowledgeArticle(newArticle.UrlName);

        System.assert(knowledgeResult != null);
        System.assert(knowledgeResult.get('Title') == newArticle.Title);
        System.assert(knowledgeResult.get('ProductName') == newArticle.Product__c);
    }
    @isTest
    private static void getKnowledgeArticleFail() {
        Knowledge__kav newArticle1 = TestUtilities.getArticleAsADraft('New title', 'new-url-fake-name' + Crypto.getRandomInteger());
        newArticle1.Division__c = 'Financial Management';
        newArticle1.Product__c = 'Dimensions';
        newArticle1.Product_Features__c = 'ADM';

        insert newArticle1;
        String articleId1 = [SELECT KnowledgeArticleId FROM Knowledge__kav WHERE Id =: newArticle1.Id].KnowledgeArticleId;
        KbManagement.PublishingService.publishArticle(articleId1, true);

        Map<String, Object> knowledgeResult1 = CspKnowledge.getKnowledgeArticle(newArticle1.UrlName);

        System.assert(knowledgeResult1 != null);
        System.assert(knowledgeResult1.get('Title') == newArticle1.Title);
        System.assert(knowledgeResult1.get('ProductName') == null);

    }
}