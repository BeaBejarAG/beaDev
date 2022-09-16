@isTest(SeeAllData=false)
public with sharing class cspGlobalSearchHandlerTest {

    @isTest
    private static void searchKnowledge() {
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            Knowledge__kav newArticle = TestUtilities.getArticleAsADraft('New title', 'new-url-name' + Crypto.getRandomInteger());
            newArticle.Information_Article_Body__c = 'New article';
            newArticle.Division__c = 'Business Management';
            newArticle.Product__c = 'Access Approve';

            insert newArticle;
            String articleId = [SELECT KnowledgeArticleId FROM Knowledge__kav WHERE Id =: newArticle.Id].KnowledgeArticleId;
            KbManagement.PublishingService.publishArticle(articleId, true);

            User portalAccountOwner1 = TestUtilities.createUser('Support Admin', 'System Administrator', 'test123');

            Account portalAccount1 = new Account(Name = 'TestAccount', OwnerId = portalAccountOwner1.Id);
            insert portalAccount1;

            Id [] fixedSearchResults= new Id[1];
            fixedSearchResults[0] = newArticle.Id;
            Test.setFixedSearchResults(fixedSearchResults);

            List<Map<String, Object>> searchResults = cspGlobalSearchHandler.searchKnowledge('New title', 'Access Approve', 5, 0, 'Knowledge__kav', null, true, null, String.valueOf(portalAccount1.Id));

            System.assertEquals(1, searchResults.size());
            System.assert(searchResults.get(0).get('title') == newArticle.Title);
            System.assert(searchResults.get(0).get('url') == '/support/s/article/' + newArticle.UrlName);
        }
    }

    @isTest
    private static void searchReleaseNotes() {
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            Knowledge__kav newArticle = new Knowledge__kav();
            newArticle.RecordTypeId = Schema.SObjectType.Knowledge__kav.getRecordTypeInfosByName().get('Release Notes').getRecordTypeId();
            newArticle.Title = 'New title';
            newArticle.UrlName = 'new-url-name' + Crypto.getRandomInteger();
            newArticle.Information_Article_Body__c = 'New article';
            newArticle.Division__c = 'Business Management';
            newArticle.Product__c = 'Access Approve';

            insert newArticle;
            String articleId = [SELECT KnowledgeArticleId FROM Knowledge__kav WHERE Id =: newArticle.Id].KnowledgeArticleId;
            KbManagement.PublishingService.publishArticle(articleId, true);

            User portalAccountOwner1 = TestUtilities.createUser('Support Admin', 'System Administrator', 'test123');

            Account portalAccount1 = new Account(Name = 'TestAccount', OwnerId = portalAccountOwner1.Id);
            insert portalAccount1;

            Id [] fixedSearchResults= new Id[1];
            fixedSearchResults[0] = newArticle.Id;
            Test.setFixedSearchResults(fixedSearchResults);

            List<Map<String, Object>> searchResults = cspGlobalSearchHandler.searchReleaseNotes('New title', 'Access Approve', 5, 0, 'Knowledge__kav', null, true, null, String.valueOf(portalAccount1.Id));

            System.assertEquals(1, searchResults.size());
            System.assert(searchResults.get(0).get('title') == newArticle.Title);
            System.assert(searchResults.get(0).get('url') == '/support/s/article/' + newArticle.UrlName);
        }
    }

    @isTest
    private static void searchCommunities() {

        User portalAccountOwner1 = TestUtilities.createUser('Support Admin', 'System Administrator', 'test123');

		System.runAs(portalAccountOwner1) {
			//Create account
			Account portalAccount1 = new Account(Name = 'TestAccount', OwnerId = portalAccountOwner1.Id);
            insert portalAccount1;
            String accountId = [Select Id from Account where Name = 'TestAccount'].Id;
            FeedItem feed = new FeedItem();
            feed.ParentId = accountId;
            feed.Body = 'Lots of questions';
            feed.Title = 'My title';

            insert feed;

            Id [] fixedSearchResults= new Id[1];
            fixedSearchResults[0] = feed.Id;
            Test.setFixedSearchResults(fixedSearchResults);

            List<Map<String, Object>> listResults = cspGlobalSearchHandler.searchCommunities('questions', '', 1, 0, 'FeedItem', true, null, '', '');
            System.assertEquals(1, listResults.size());

            List<Map<String, Object>> missResults = cspGlobalSearchHandler.searchCommunities('questions', '', 1, 0, 'FeedItem', true, null, 'Not a topic', '');
            System.assertEquals(0, missResults.size());

            missResults = cspGlobalSearchHandler.searchCommunities('questions', '', 1, 0, 'FeedItem', true, null, '', 'Not a group');
            System.assertEquals(0, missResults.size());
        }
    }

    @isTest
    private static void searchServicesCatalogue() {

        User portalAccountOwner1 = TestUtilities.createUser('Support Admin', 'System Administrator', 'test123');

        System.runAs (portalAccountOwner1) {

            Account portalAccount1 = new Account(Name = 'TestAccount', OwnerId = portalAccountOwner1.Id);
            insert portalAccount1;

            //Create contact
            Contact contact1 = new Contact(FirstName = 'Test',
                Lastname = 'McTesty',
                Region__c = 'Europe',
                AccountId = portalAccount1.Id,
                Email = System.now().millisecond() + 'test@test.com');

            insert contact1;
            //Create our portal user
            User user1 = TestUtilities.createPortalUser('Customer Portal - Support User', contact1.Id, 'test123p');

            String accountId = [Select Id from Account where Name = 'TestAccount'].Id;

            Service_Catalogues__c serviceCatalogueEntryWithProduct = new Service_Catalogues__c();
            serviceCatalogueEntryWithProduct.Service_Description__c = 'Entry Description For Product Object';
            serviceCatalogueEntryWithProduct.Points_Conversion__c = 30000;
            serviceCatalogueEntryWithProduct.Service_Title__c = 'Catalogue Entry For Product Object';
            serviceCatalogueEntryWithProduct.Products__c = 'Access Approve';
            serviceCatalogueEntryWithProduct.Account_Journey_Stage__c = 'Applicable to all';
            serviceCatalogueEntryWithProduct.Delivered_By__c = 'Professional Services';
            serviceCatalogueEntryWithProduct.Delivery_Type__c = 'Bite Size';
            serviceCatalogueEntryWithProduct.Location__c = 'Remote';
            serviceCatalogueEntryWithProduct.Region__c = 'Asia';
            serviceCatalogueEntryWithProduct.Service_Type__c = 'Integrations';
            serviceCatalogueEntryWithProduct.User_Level__c = 'Beginner';
            serviceCatalogueEntryWithProduct.Region__c = 'Europe';

            insert serviceCatalogueEntryWithProduct;

            Id [] fixedSearchResults= new Id[1];
            fixedSearchResults[0] = serviceCatalogueEntryWithProduct.Id;
            Test.setFixedSearchResults(fixedSearchResults);

            List<Map<String, Object>> searchResults = cspGlobalSearchHandler.searchServicesCatalogue('Catalogue Entry For Product Object', 'Access Approve', 10, 0, 'Service_Catalogues__c', null, true, null, String.valueOf(portalAccount1.Id));

            System.assertEquals(1, searchResults.size());
            System.assertEquals(serviceCatalogueEntryWithProduct.Service_Title__c, searchResults.get(0).get('title'));
            String serviceCatalogueURL = String.format('/support/s/services?serviceId={0}', new List<String>{serviceCatalogueEntryWithProduct.Id});
            System.assertEquals(serviceCatalogueURL, searchResults.get(0).get('url'));
        }
    }

    @isTest
    private static void listKnowledge() {
        Knowledge__kav newArticle = TestUtilities.getArticleAsADraft('New title', 'new-url-name' + Crypto.getRandomInteger());

        insert newArticle;
        String articleId = [SELECT KnowledgeArticleId FROM Knowledge__kav WHERE Id =: newArticle.Id].KnowledgeArticleId;
        KbManagement.PublishingService.publishArticle(articleId, true);

        List<Map<String, Object>> listResults = cspGlobalSearchHandler.listKnowledge('', '', false, 1, 0, 'Knowledge__kav');

        System.assertEquals(1, listResults.size());
        System.assert(listResults.get(0).get('title') == newArticle.Title);
        System.assert(listResults.get(0).get('url') == '/support/s/article/' + newArticle.UrlName);
    }

    @isTest
    private static void listKnowledgeByProductFeature() {
        Knowledge__kav newArticle = TestUtilities.getArticleAsADraft('New title', 'new-url-name' + Crypto.getRandomInteger());
        newArticle.Division__c = 'Business Management';
        newArticle.Product__c = 'Access Approve';
        newArticle.Product_Features__c = 'Configuration';
        newArticle.Featured__c = true;

        insert newArticle;
        String articleId = [SELECT KnowledgeArticleId FROM Knowledge__kav WHERE Id =: newArticle.Id].KnowledgeArticleId;
        KbManagement.PublishingService.publishArticle(articleId, true);

        List<Map<String, Object>> listResults = cspGlobalSearchHandler.listKnowledge('Access Approve', 'Configuration', true, 1, 0, 'Knowledge__kav');

        System.assertEquals(1, listResults.size());
        System.assert(listResults.get(0).get('product') == newArticle.Product__c);
        System.assert(listResults.get(0).get('productCategory') == newArticle.Product_Features__c);
    }

    @isTest
    private static void listCommunities() {

        User portalAccountOwner1 = TestUtilities.createUser('Support Admin', 'System Administrator', 'test123');

		System.runAs(portalAccountOwner1) {
			//Create account
			Account portalAccount1 = new Account(Name = 'TestAccount', OwnerId = portalAccountOwner1.Id);
            insert portalAccount1;
            String accountId = [Select Id from Account where Name = 'TestAccount'].Id;
            FeedItem feed = new FeedItem();
            feed.ParentId = accountId;
            feed.Body = 'Lots of questions';

            insert feed;

            List<Map<String, Object>> listResults = cspGlobalSearchHandler.listCommunities('', '', 1, 0, 'FeedItem');

            System.assertEquals(1, listResults.size());
        }
    }




    @isTest
    private static void searchEvents() {
        
         User portalAccountOwner1 = TestUtilities.createUser('Support Admin', 'System Administrator', 'test123');

		System.runAs(portalAccountOwner1) {
			//Create account
			Account portalAccount1 = new Account(Name = 'TestAccount', OwnerId = portalAccountOwner1.Id);
            insert portalAccount1;
            String accountId = [Select Id from Account where Name = 'TestAccount'].Id;
            Event__c event = new Event__c();
            event.Title__c = 'A webinar title';
            event.Product__c = 'Access Approve';
            event.Description__c = 'Description of the webinar';
            insert event;

            Id [] fixedSearchResults= new Id[1];
            fixedSearchResults[0] = event.Id;
            Test.setFixedSearchResults(fixedSearchResults);

            List<Map<String, Object>> listResults = cspGlobalSearchHandler.searchEvents('webinar', 'Access Approve', 1, 0, 'Event__c', true, null, String.valueOf(portalAccount1.Id));

            System.assertEquals(1, listResults.size());
        }
    }
}