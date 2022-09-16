public with sharing class cspGlobalSearchHandler {
    @AuraEnabled(cacheable=true)
    public static List<Map<String, Object>> searchKnowledge(String query, String product, Integer amount, Integer offset, String objectName, String product_feature, Boolean highlight, String excludeObject, String selectedAccId) {
        String networkName = cspGlobalSearchHandler.getNetwork();
        String contactRegion = getContactRegion();
        List<String> entitledProducts = cspProductSelection.getFlatProductList(selectedAccId);

        Search.SearchResults results = Search.find(
            'FIND \'' + cspGlobalSearchHandler.sanitise(query) + '*\' ' +
            'IN ALL FIELDS RETURNING ' + objectName + '( ' +
                'Id, Title, ArticleTotalViewCount, LastPublishedDate, RecordType.DeveloperName, ' +
                'UrlName, Product__c, Product_Features__c, Information_Article_Body__c, What_s_New__c ' +
                'WHERE PublishStatus = \'Online\' ' +
                (String.isEmpty(product) ? 'AND Product__c IN :entitledProducts ' : 'AND Product__c = :product ') +
                (String.isEmpty(excludeObject) ? '' : 'AND Id != :excludeObject ') +
                (String.isEmpty(product_feature) ? '' : 'AND Product_Features__c INCLUDES (:product_feature) ') +
                (String.isEmpty(contactRegion) ? '' : ' AND (Region__c = \'\' OR Region__c includes (\'' + contactRegion + '\'))') +
                'LIMIT ' + ++amount + ' ' +
                'OFFSET :offset ' +
            ')' + (Network.getNetworkId() != null ? ' WITH NETWORK = \'' + Network.getNetworkId() + '\'' : ''));

        List<Map<String, Object>> searchResults = new List<Map<String, Object>>();
        for (Search.SearchResult searchObject: results.get(objectName)) {
            SObject sobj = searchObject.getSObject();
            Knowledge__kav article = (Knowledge__kav)sobj;
            String type = article.RecordType.DeveloperName;

            String dynamicDetails = type.equals('Release_Notes') ? (String)sobj.get('What_s_New__c') : (String)sobj.get('Information_Article_Body__c');
            String snippet = highlight ? cspGlobalSearchHandler.highlight(query, dynamicDetails) : dynamicDetails;

            searchResults.add(new Map<String, Object>{
                'type' => objectName,
                'id' => (String)sobj.get('Id'),
                'title' => (String)sobj.get('Title'),
                'views' => (Integer)sobj.get('ArticleTotalViewCount'),
                'dttm' => (Datetime)sobj.get('LastPublishedDate'),
                'product' => (String)sobj.get('Product__c'),
                'productCategory' => (String)sobj.get('Product_Features__c'),
                'recordType' => type,
                'snippet' => snippet,
                'url' => '/' + networkName + '/s/article/' + (String)sobj.get('UrlName')
            });
        }
        return searchResults;
    }

    @AuraEnabled(cacheable=true)
    public static List<Map<String, Object>> searchCommunities(String query, String product, Integer amount, Integer offset, String objectName, Boolean highlight, String excludeObject, String topicName, String groupName) {
        String networkName = cspGlobalSearchHandler.getNetwork();

        Search.SearchResults results = Search.find(
            'FIND \'' + cspGlobalSearchHandler.sanitise(query) + '*\' ' +
            'IN ALL FIELDS RETURNING ' + objectName + '( ' +
                'Id, Title, CreatedDate, CommentCount, Body, ParentId  ' +
                'WHERE Type IN (\'AdvancedTextPost\',\'ContentPost\',\'LinkPost\',\'QuestionPost\',\'TextPost\') ' +
                'AND Title != \'\' ' +
                (String.isEmpty(excludeObject) ? '' : 'AND Id != :excludeObject ') +
                (String.isEmpty(topicName) ? '' : 'AND Id IN (SELECT EntityId FROM TopicAssignment WHERE EntityType = \'FeedItem\' AND EntityKeyPrefix = \'0D5\' AND Topic.Name =:topicName) ') +
                (String.isEmpty(groupName) ? '' : 'AND ParentId IN (SELECT Id FROM CollaborationGroup WHERE Name =:groupName) ') +
                'LIMIT ' + ++amount + ' ' +
                'OFFSET :offset' +
            ')' + (Network.getNetworkId() != null ? ' WITH NETWORK = \'' + Network.getNetworkId() + '\'' : ''));

        List<TopicAssignment> topicAssignments = new List<TopicAssignment>();
        List<FeedItem> groupAssignments = new List<FeedItem>();
        if (String.isEmpty(groupName) && String.isEmpty(topicName)) {
            List<String> resultSet = new List<String>();
            for (Search.SearchResult searchObject: results.get(objectName)) {
                SObject sobj = searchObject.getSObject();
                resultSet.add((String)sobj.get('Id'));
            }

            topicAssignments = [
                SELECT Topic.Name, EntityId FROM TopicAssignment
                WHERE EntityId IN :resultSet
            ];

            groupAssignments = [
                SELECT Parent.Name, Id FROM FeedItem
                WHERE ParentId IN (SELECT Id FROM CollaborationGroup)
                AND Id In :resultSet
            ];
        }

        List<Map<String, Object>> searchResults = new List<Map<String, Object>>();
        for (Search.SearchResult searchObject: results.get(objectName)) {
            SObject sobj = searchObject.getSObject();

            String resultTopic = '';
            String resultGroup = '';
            for (TopicAssignment t : topicAssignments) {
                if (sobj.get('Id') == t.EntityId) {
                    resultTopic += t.Topic.Name + ';';
                }
            }
            for (FeedItem f : groupAssignments) {
                if (sobj.get('Id') == f.Id) {
                    resultGroup = f.Parent.Name;
                    break;
                }
            }

            String snippet = highlight ?
                cspGlobalSearchHandler.highlight(query, (String)sobj.get('Body')) :
                (String)sobj.get('Body');

            searchResults.add(new Map<String, Object>{
                'type' => objectName,
                'id' => (String)sobj.get('Id'),
                'title' => (String)sobj.get('Title'),
                'views' => null,
                'comments' => (Integer)sobj.get('CommentCount'),
                'dttm' => (Datetime)sobj.get('CreatedDate'),
                'product' => '',
                'productCategory' => '',
                'topic' => String.isEmpty(topicName) ? resultTopic : topicName,
                'group' => String.isEmpty(groupName) ? resultGroup : groupName,
                'snippet' => snippet,
                'url' => '/' + networkName + '/s/question/' + (String)sobj.get('Id')
            });
        }
        return searchResults;
    }


    @AuraEnabled(cacheable=true)
    public static List<Map<String, Object>> searchEvents(String query, String product, Integer amount, Integer offset, String objectName, Boolean highlight, String excludeObject, String selectedAccId) {
        String networkName = cspGlobalSearchHandler.getNetwork();
        String contactRegion = getContactRegion();
        List<String> entitledProducts = cspProductSelection.getFlatProductList(selectedAccId);
        if (entitledProducts.size() == 0 && String.isEmpty(product)) {
            return new List<Map<String, Object>>();
        }
        String productList = '';
        // Build a string with all the products as it doesn't bind a list of strings (*sigh)
        for (Integer i = 0; i < entitledProducts.size(); i++) {
            productList += '\'' + entitledProducts.get(i) + '\'';
            if (i < entitledProducts.size() - 1) {
                productList += ',';
            }
        }

        Search.SearchResults results = Search.find(
            'FIND \'' + cspGlobalSearchHandler.sanitise(query) + '*\' ' +
            'IN ALL FIELDS RETURNING ' + objectName + '( ' +
                'Id, Title__c, Description__c, Start__c, Product__c, Name ' +
                (String.isEmpty(product) ? 'WHERE Product__c includes (' + productList + ') ' : 'WHERE Product__c includes (:product) ') +
                (String.isNotEmpty(contactRegion) ? 'AND (Region__c = \'\' OR Region__c includes (\'' + contactRegion + '\')) ' : '') +
                'LIMIT ' + ++amount + ' ' +
                'OFFSET :offset' +
            ')' + (Network.getNetworkId() != null ? ' WITH NETWORK = \'' + Network.getNetworkId() + '\'' : ''));

        List<Map<String, Object>> searchResults = new List<Map<String, Object>>();
        for (Search.SearchResult searchObject: results.get(objectName)) {
            SObject sobj = searchObject.getSObject();

            String snippet = highlight ?
                cspGlobalSearchHandler.highlight(query, (String)sobj.get('Description__c')) :
                (String)sobj.get('Description__c');

            searchResults.add(new Map<String, Object>{
                'type' => objectName,
                'id' => (String)sobj.get('Id'),
                'title' => (String)sobj.get('Title__c'),
                'views' => null,
                'dttm' => (Datetime)sobj.get('Start__c'),
                'product' => (String)sobj.get('Product__c'),
                'productCategory' => '',
                'snippet' => snippet,
                'url' => '/' + networkName + '/s/events?category=All&active=' + (String)sobj.get('Name')
            });
        }
        return searchResults;
    }

    @AuraEnabled(cacheable=true)
    public static List<Map<String, Object>> searchReleaseNotes(String query, String product, Integer amount, Integer offset, String objectName, String product_feature, Boolean highlight, String excludeObject, String selectedAccId) {
        String networkName = cspGlobalSearchHandler.getNetwork();
        String contactRegion = getContactRegion();
        List<String> entitledProducts = cspProductSelection.getFlatProductList(selectedAccId);

        Search.SearchResults results = Search.find(
            'FIND \'' + cspGlobalSearchHandler.sanitise(query) + '*\' ' +
            'IN ALL FIELDS RETURNING ' + objectName + '( ' +
                'Id, Title, ArticleTotalViewCount, LastPublishedDate, ' +
                'UrlName, Product__c, Product_Features__c, What_s_New__c ' +
                'WHERE PublishStatus = \'Online\' ' +
                (String.isEmpty(product) ? 'AND Product__c IN :entitledProducts ' : 'AND Product__c = :product ') +
                (String.isEmpty(excludeObject) ? '' : 'AND Id != :excludeObject ') +
                (String.isEmpty(product_feature) ? '' : 'AND Product_Features__c INCLUDES (:product_feature) ') +
                (String.isEmpty(contactRegion) ? '' : ' AND (Region__c = \'\' OR Region__c includes (\'' + contactRegion + '\'))') +
                'AND RecordType.DeveloperName = \'Release_Notes\' ' +
                'LIMIT ' + ++amount + ' ' +
                'OFFSET :offset ' +
            ')' + (Network.getNetworkId() != null ? ' WITH NETWORK = \'' + Network.getNetworkId() + '\'' : ''));

        List<Map<String, Object>> searchResults = new List<Map<String, Object>>();
        for (Search.SearchResult searchObject: results.get(objectName)) {
            SObject sobj = searchObject.getSObject();

            String snippet = highlight ?
                cspGlobalSearchHandler.highlight(query, (String)sobj.get('What_s_New__c')) :
                (String)sobj.get('What_s_New__c');

            searchResults.add(new Map<String, Object>{
                'type' => objectName,
                'id' => (String)sobj.get('Id'),
                'title' => (String)sobj.get('Title'),
                'views' => (Integer)sobj.get('ArticleTotalViewCount'),
                'dttm' => (Datetime)sobj.get('LastPublishedDate'),
                'product' => (String)sobj.get('Product__c'),
                'productCategory' => (String)sobj.get('Product_Features__c'),
                'snippet' => snippet,
                'url' => '/' + networkName + '/s/article/' + (String)sobj.get('UrlName')
            });
        }
        return searchResults;
    }

    @AuraEnabled
    public static List<Map<String, Object>> searchServicesCatalogue(String query, String product, Integer amount, Integer offset, String objectName, String product_feature, Boolean highlight, String excludeObject, String selectedAccId) {
        Id contactId = [SELECT ContactId FROM User WHERE Id =: Userinfo.getUserId()].ContactId;
        String networkName = cspGlobalSearchHandler.getNetwork();
        List<String> entitledProducts = cspProductSelection.getFlatProductList(selectedAccId);
        Contact[] contacts = [SELECT Region__c FROM Contact WHERE Id =: contactId];
        Contact contact;
        String region = '';

        if (contacts.size() > 0) {
            region = contacts[0].Region__c;
        }

        if (entitledProducts.size() == 0 && String.isEmpty(product)) {
            return new List<Map<String, Object>>();
        }
        String productList = '';
        // Build a string with all the products as it doesn't bind a list of strings (*sigh)
        for (Integer i = 0; i < entitledProducts.size(); i++) {
            productList += '\'' + entitledProducts.get(i) + '\'';
            if (i < entitledProducts.size() - 1) {
                productList += ',';
            }
        }

        Search.SearchResults results = Search.find(
        'FIND \'' + cspGlobalSearchHandler.sanitise(query) + '*\' ' +
        'IN ALL FIELDS RETURNING ' + objectName + '( '+ 
            'Id, Service_Title__c, Service_Description__c, Products__c, Points_Conversion__c, Premier_Only__c ' +
            (String.isEmpty(product) ? 'WHERE Products__c includes (' + productList + ') ' : 'WHERE Products__c includes (:product) ') +
            ((region != null && String.isNotBlank(region)) ? 'AND Region__c INCLUDES (:region) ' : '') +
            'LIMIT ' + ++amount + ' ' +
            'OFFSET :offset' +
        ')' + (Network.getNetworkId() != null ? ' WITH NETWORK = \'' + Network.getNetworkId() + '\'' : ''));

        List<Map<String,Object>> searchResults = new List<Map<String,Object>>();
        for (Search.SearchResult searchObject : results.get(objectName)) {
            SObject sobj = searchObject.getSObject();

            String snippet = highlight ?
                cspGlobalSearchHandler.highlight(query, (String)sobj.get('Service_Description__c')) :
                (String)sobj.get('Service_Description__c');

            searchResults.add(new Map<String,Object>{
                'type' => objectName,
                'id' => (String)sobj.get('Id'),
                'title' => (String)sobj.get('Service_Title__c'),
                'views' => null,
                'dttm' => null,
                'productCategory' => '',
                'snippet' => snippet,
                'description' => (String)sobj.get('Service_Description__c'),
                'pointsValue' => (Decimal)sobj.get('Points_Conversion__c'),
                'product' => (String)sobj.get('Products__c'),
                'premierOnly' => (Boolean)sobj.get('Premier_Only__c'),
                'url' => String.format('/{0}/s/services?serviceId={1}', new List<String>{networkName, (String)sobj.get('Id')})
            });
        }

        return searchResults;
    }

    @AuraEnabled(cacheable=true)
    public static List<Map<String, Object>> listCommunities(String product, String feature, Integer amount, Integer offset, String objectName) {
        String networkName = cspGlobalSearchHandler.getNetwork();

        String query = String.format('SELECT Id, Title, CreatedDate, CommentCount, Body FROM {0} ' +
            'ORDER BY CreatedDate DESC LIMIT {1} OFFSET {2}', new List<Object>{objectName, ++amount, offset});
        List<sObject> sobjList = Database.query(query);

        List<Map<String, Object>> listResults = new List<Map<String, Object>>();
        // todo : Use the following query for community fetching
        // for (FeedItem sobj: [
        //     SELECT Id, Title, CreatedDate, CommentCount, Body
        //     FROM FeedItem
        //     WHERE Id IN (
        //         SELECT EntityId FROM TopicAssignment
        //         WHERE EntityType = 'FeedItem'
        //     )
        //     ORDER BY CreatedDate DESC
        //     LIMIT :++amount OFFSET :offset
        // ])
        for (sObject sobj: sobjList) {
            listResults.add(new Map<String, Object>{
                'type' => objectName,
                'id' => (String)sobj.get('Id'),
                'title' => (String)sobj.get('Title'),
                'views' => (Integer)sobj.get('CommentCount'),
                'dttm' => (Datetime)sobj.get('CreatedDate'),
                'product' => '',
                'productCategory' => '',
                'snippet' => (String)sobj.get('Body'),
                'url' => String.format('/{0}/s/question/{1}', new List<String>{networkName, (String)sobj.get('Id')})
            });
        }
        return listResults;
    }

    @AuraEnabled(cacheable=true)
    public static List<Map<String, Object>> listKnowledge(String product, String product_feature, Boolean featured, Integer amount, Integer offset, String objectName) {
        String networkName = cspGlobalSearchHandler.getNetwork();
        String contactRegion = getContactRegion();
        String status = 'Online';

        String listQuery = 'SELECT Id, RecordType.DeveloperName, ArticleNumber, Title, ArticleTotalViewCount, LastPublishedDate, UrlName, Product__c, Product_Features__c, Information_Article_Body__c, Image__c, What_s_New__c FROM ' + objectName + ' ';

        listQuery += 'WHERE PublishStatus =: status ';

        if (String.isNotBlank(product)) {
            listQuery += 'AND Product__c = \'' + product + '\' ';
        }
        if (String.isNotBlank(product_feature)) {
            listQuery += 'AND Product_Features__c includes (\'' + product_feature + '\') ';
        }
        if (featured) {
            listQuery += 'AND Featured__c = TRUE ';
        }
        if (String.isNotEmpty(contactRegion)) {
            listQuery += 'AND (Region__c = \'\' OR Region__c includes (\'' + contactRegion + '\')) ';
        }

        listQuery += String.format('ORDER BY LastPublishedDate DESC LIMIT {0} OFFSET {1}', new List<Object>{++amount, offset});

        List<sObject> sobjList = Database.query(listQuery);

        List<Map<String, Object>> listResults = new List<Map<String, Object>>();
        for (SObject sobj: sobjList) {
            Knowledge__kav article = (Knowledge__kav)sobj;
            String type = article.RecordType.DeveloperName;
            String dynamicSnippet = type.equals('Release_Notes') ? (String)sobj.get('What_s_New__c') : (String)sobj.get('Information_Article_Body__c');

            listResults.add(new Map<String, Object>{
                'type' => objectName,
                'id' => (String)sobj.get('Id'),
                'number' => (String)sobj.get('ArticleNumber'),
                'title' => (String)sobj.get('Title'),
                'views' => (Integer)sobj.get('ArticleTotalViewCount'),
                'dttm' => (Datetime)sobj.get('LastPublishedDate'),
                'image' => (String)sobj.get('Image__c'),
                'product' => (String)sobj.get('Product__c'),
                'productCategory' => (String)sobj.get('Product_Features__c'),
                'snippet' => dynamicSnippet,
                'url' => String.format('/{0}/s/article/{1}', new List<String>{networkName, (String)sobj.get('UrlName')})
            });
        }
        return listResults;
    }

    private static String highlight(String term, String text) {
        if(text == null || term == null) {
            return text;
        }

        List<String> terms = cspGlobalSearchHandler.sanitise(term).split(' ');
        for(String target: terms) {
            if(target.length() > 1) {
                text = text.replaceAll('(?i)(' + target + ')', '<mark>$0</mark>');
            }
        }
        return text;
    }

    private static String sanitise(String term) {
        if(term == null) {
            return term;
        }

        return term.replaceAll('[,\'"=\\[\\]\\*\\|+>\\-;\\.\\?\\\\]', ' ');
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