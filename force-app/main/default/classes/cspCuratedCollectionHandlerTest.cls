@isTest(SeeAllData=false)
public with sharing class cspCuratedCollectionHandlerTest {
    @IsTest Public Static Void RetrieveCollections() {

        Knowledge__kav newArticle = TestUtilities.getArticleAsADraft('New title', 'new-url-name' + Crypto.getRandomInteger());
        newArticle.Division__c = 'Business Management';
        newArticle.Product__c = 'Access Approve';
        newArticle.Product_Features__c = 'Configuration';

        insert newArticle;
        String articleId = [SELECT KnowledgeArticleId FROM Knowledge__kav WHERE Id =: newArticle.Id].KnowledgeArticleId;
        KbManagement.PublishingService.publishArticle(articleId, true);

        Curated_Collection__c approveCollection= new Curated_Collection__c(Name = 'Collection Name',
                                                                            Products__c = 'Access Approve',
                                                                            Short_Description__c = 'Description goes here',
                                                                            Utility_Icon__c = 'activity',
                                                                            Priority__c = 10);
        insert approveCollection;

        Knowledge_Collection_Association__c association = new Knowledge_Collection_Association__c(Curated_Collection__c = approveCollection.Id,
                                                                                                    Knowledge_Article__c = newArticle.Id,
                                                                                                    Priority__c = 10);
        insert association;

        List<Map<String, Object>> collections = cspCuratedCollectionHandler.getCuratedCollections('Access Approve');
        System.assert(collections.size() == 1);
        System.assert(collections[0].get('title') == approveCollection.Name);
        System.assert(collections[0].get('articleCount') == 1);
        System.assert(collections[0].get('shortDescription') == approveCollection.Short_Description__c);
        System.assert(collections[0].get('icon') == approveCollection.Utility_Icon__c);
        System.assert(collections[0].get('priority') == approveCollection.Priority__c);

        List<Map<String, Object>> noCollections = cspCuratedCollectionHandler.getCuratedCollections('Not a product');
        System.assert(noCollections.size() == 0);
    }

    @IsTest Public Static Void GetCuratedArticles() {

        Knowledge__kav newArticle = TestUtilities.getArticleAsADraft('New title', 'new-url-name' + Crypto.getRandomInteger());
        newArticle.Division__c = 'Business Management';
        newArticle.Product__c = 'Access Approve';
        newArticle.Product_Features__c = 'Configuration';

        insert newArticle;
        String articleId = [SELECT KnowledgeArticleId FROM Knowledge__kav WHERE Id =: newArticle.Id].KnowledgeArticleId;
        KbManagement.PublishingService.publishArticle(articleId, true);

        Curated_Collection__c approveCollection = new Curated_Collection__c(Name = 'Collection Name',
                                                                            Products__c = 'Access Approve',
                                                                            Short_Description__c = 'Description goes here',
                                                                            Utility_Icon__c = 'activity',
                                                                            Priority__c = 10);
        insert approveCollection;

        Knowledge_Collection_Association__c association = new Knowledge_Collection_Association__c(Curated_Collection__c = approveCollection.Id,
                                                                                                    Knowledge_Article__c = newArticle.Id,
                                                                                                    Priority__c = 10);
        insert association;

        List<Map<String, Object>> articles = cspCuratedCollectionHandler.getCuratedArticles(approveCollection.Id);
        System.assert(articles.size() == 1);
        System.assert(articles[0].get('id') == newArticle.Id);
        System.assert(articles[0].get('title') == newArticle.Title);

        List<Map<String, Object>> noArticles = cspCuratedCollectionHandler.getCuratedArticles('wrongid');
        System.assert(noArticles.size() == 0);
    }

    @IsTest Public Static Void TestGetContactRegion() {
        String region = cspCuratedCollectionHandler.getContactRegion();
        System.assert(region == '');
    }
}