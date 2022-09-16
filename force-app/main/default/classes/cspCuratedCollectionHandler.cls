public with sharing class cspCuratedCollectionHandler {
    
    @AuraEnabled(cacheable=true)
    public static List<Map<String, Object>> getCuratedCollections(String product) {
        String networkName = cspCuratedCollectionHandler.getNetwork();
        String contactRegion = getContactRegion();
        String userId = UserInfo.getUserId();
        String query = 'SELECT Name, Id, Products__c, Short_Description__c, Utility_Icon__c, Priority__c, Region__c,';

        if (String.isNotEmpty(contactRegion)) {
            query += ' (Select Id from Knowledge_Collection_Associations__r WHERE Knowledge_Article__r.Region__c = \'\' OR Knowledge_Article__r.Region__c includes (\'' + contactRegion + '\'))';
        } else {
            query += ' (Select Id from Knowledge_Collection_Associations__r)';
        }
        query += ' From Curated_Collection__c WHERE Products__c includes (\'' + product + '\')';
        if (String.isNotEmpty(contactRegion)) {
            query += ' AND (Region__c = \'\' OR Region__c includes (\'' + contactRegion + '\'))';
        }
        query += ' ORDER BY Priority__c';

        List<Curated_Collection__c> collectionList = Database.query(query);

        List<Map<String, Object>> collectionResults = new List<Map<String, Object>>();
        for (Curated_Collection__c c: collectionList) {
            collectionResults.add(new Map<String, Object>{
                'id' => c.Id,
                'title' => c.Name,
                'articleCount' => c.Knowledge_Collection_Associations__r.size(),
                'shortDescription' => c.Short_Description__c,
                'icon' => c.Utility_Icon__c,
                'priority' => c.Priority__c,
                'url' => String.format('/{0}/s/collection/{1}', new List<String>{networkName, c.Id})
            });
        }
        return collectionResults;
    }

    @AuraEnabled(cacheable=true)
    public static List<Map<String, Object>> getCuratedArticles(String collectionId) {
        String networkName = cspCuratedCollectionHandler.getNetwork();
        String userId = UserInfo.getUserId();
        String contactRegion = getContactRegion();
        String query = 'SELECT Knowledge_Article__r.ArticleNumber FROM Knowledge_Collection_Association__c where Curated_Collection__r.id=:collectionId ORDER BY Priority__c';
        List<Knowledge_Collection_Association__c> prioritisedArticles = Database.query(query);

        List<String> prioritisedArticleNumbers = new List<String>();
        for (Knowledge_Collection_Association__c article: prioritisedArticles) {
            prioritisedArticleNumbers.add(article.Knowledge_Article__r.ArticleNumber);
        }

        query = 'SELECT Title, ArticleNumber, ArticleTotalViewCount, LastPublishedDate, UrlName, Product__c, Product_Features__c, Information_Article_Body__c, Region__c FROM Knowledge__kav where ArticleNumber IN :prioritisedArticleNumbers';
        if (String.isNotEmpty(contactRegion)) {
            query += ' AND (Region__c = \'\' OR Region__c includes (\'' + contactRegion + '\'))';
        }
        List<Knowledge__kav> latestArticles = Database.query(query);


        List<Map<String, Object>> curatedArticles = new List<Map<String, Object>>();
        for (Knowledge_Collection_Association__c article: prioritisedArticles) {
            for (Knowledge__kav detail: latestArticles) {
                if (detail.ArticleNumber == article.Knowledge_Article__r.ArticleNumber) {
                    curatedArticles.add(new Map<String, Object>{
                        'id' => detail.Id,
                        'number' => detail.ArticleNumber,
                        'title' => detail.Title,
                        'views' => detail.ArticleTotalViewCount,
                        'dttm' => detail.LastPublishedDate,
                        'product' => detail.Product__c,
                        'productCategory' => detail.Product_Features__c,
                        'snippet' => detail.Information_Article_Body__c,
                        'url' => String.format('/{0}/s/article/{1}', new List<String>{networkName, detail.UrlName})
                    });
                }
            }
        }
        return curatedArticles;
    }

    private static String getNetwork() {
        try {
            return [ SELECT UrlPathPrefix FROM Network WHERE Id = :Network.getNetworkId() ].UrlPathPrefix;
        } catch(QueryException e) {
            System.debug('Exception retrieving network id : ' + e.getMessage());
            return 'support';
        }
    }

    @TestVisible private static String getContactRegion() {
        String userId = Userinfo.getUserid();
        User currentUser = Database.query('SELECT ContactId, Contact.Region__c FROM User WHERE Id =: userId');
        if (currentUser != null && String.isNotBlank(currentUser.ContactId) && String.isNotEmpty(currentUser.Contact.Region__c)) {
            String region = currentUser.Contact.Region__c;
            return currentUser.Contact.Region__c;
        }
        return '';
    }
}