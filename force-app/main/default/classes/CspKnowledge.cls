public with sharing class CspKnowledge {
    @AuraEnabled(cacheable=true)
    public static Map<String, Object> getKnowledgeArticle(String urlName){

        Knowledge__kav article = [
            SELECT Information_Article_Body__c, Product__c,
                Product_Features__c, Solution__c, Title, UrlName,
                LastPublishedDate, ArticleTotalViewCount, Enviroment__c,
                RecordType.DeveloperName, Release_note_image__c, What_s_New__c,
                How_this_version_will_be_made_available__c,
                Additional_Information__c, Join_the_converstaion__c, Article_Header_Image_Formula__c
            FROM Knowledge__kav
            WHERE UrlName =: urlName
            AND PublishStatus = 'Online'
            UPDATE VIEWSTAT
        ];

        try {
            ProductRouting__c pr = [
                SELECT Id, ProductColour__c, ImageUrl__c
                FROM ProductRouting__c
                WHERE Related_Product_Range__c =: article.Product__c
                LIMIT 1
            ];

            return new Map<String, Object>{
                'Id' => article.Id,
                'Url' => article.UrlName,
                'Title' => article.Title,
                'Views' => article.ArticleTotalViewCount,
                'Solution' => article.Solution__c,
                'Description' => article.Information_Article_Body__c,
                'Environment' => article.Enviroment__c,
                'PublishedDate' => article.LastPublishedDate,
                'ProductName' => article.Product__c,
                'ProductFeatures' => article.Product_Features__c,
                'RecordType' => article.RecordType.DeveloperName,
                'RelaseNoteImage' => article.Release_note_image__c,
                'WhatsNew' => article.What_s_New__c,
                'HowAvailable' => article.How_this_version_will_be_made_available__c,
                'AdditionalInformation' => article.Additional_Information__c,
                'JoinConversation' => article.Join_the_converstaion__c,
                'ArticleHeaderImage' => article.Article_Header_Image_Formula__c,
                'ProductColour' => pr.ProductColour__c != null ? pr.ProductColour__c.replace('Colour ', '') : '',
                'ProductImage' => pr.ImageUrl__c,
                'ProductId' => pr.Id
            };

        } catch(QueryException e) {
            return new Map<String, Object>{
                'Id' => article.Id,
                'Url' => article.UrlName,
                'Title' => article.Title,
                'Views' => article.ArticleTotalViewCount,
                'Solution' => article.Solution__c,
                'Description' => article.Information_Article_Body__c,
                'Environment' => article.Enviroment__c,
                'PublishedDate' => article.LastPublishedDate,
                'RecordType' => article.RecordType.DeveloperName,
                'RelaseNoteImage' => article.Release_note_image__c,
                'WhatsNew' => article.What_s_New__c,
                'HowAvailable' => article.How_this_version_will_be_made_available__c,
                'AdditionalInformation' => article.Additional_Information__c,
                'JoinConversation' => article.Join_the_converstaion__c,
                'ArticleHeaderImage' => article.Article_Header_Image_Formula__c
            };
        }
    }
}