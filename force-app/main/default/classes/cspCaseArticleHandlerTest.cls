@isTest(SeeAllData=false)
public with sharing class cspCaseArticleHandlerTest {
    @testSetup static void setup() {
        Knowledge__kav newArticle = TestUtilities.getArticleAsADraft('New title', 'new-url-name' + Crypto.getRandomInteger());
        newArticle.Information_Article_Body__c = 'New article';
        newArticle.IsVisibleInCsp = true;
        newArticle.ValidationStatus = 'Validated';
        newArticle.RecordTypeId = Schema.SObjectType.Knowledge__kav.getRecordTypeInfosByName().get('KCS').getRecordTypeId();

        insert newArticle;
        String articleId = [SELECT KnowledgeArticleId FROM Knowledge__kav WHERE Id =: newArticle.Id].KnowledgeArticleId;
        KbManagement.PublishingService.publishArticle(articleId, true);
    }

    @IsTest Public Static Void GetCaseArticles() {

        User portalAccountOwner1 = TestUtilities.createUser('Support Admin', 'System Administrator', 'test123');

        System.runAs(portalAccountOwner1) {
            //Create account
            Account portalAccount1 = new Account(Name = 'TestAccount', OwnerId = portalAccountOwner1.Id);
            insert portalAccount1;
            // Create entitlement for case creation
            Entitlement ent = new Entitlement(Name = 'TestingEntitlement', 
                                                AccountId = portalAccount1.Id, 
                                                StartDate= Date.valueof(System.now().addDays(-2)), 
                                                EndDate = Date.valueof(System.now().addYears(2)));
            insert ent;
            //Create contact
            Contact contact1 = new Contact(FirstName = 'Test', 
                                            Lastname = 'McTesty', 
                                            AccountId = portalAccount1.Id, 
                                            Email = System.now().millisecond() + 'test@test.com');
            insert contact1;
            //Create our portal user
            User user1 = TestUtilities.createPortalUser('Customer Portal - Support User', contact1.Id, 'test123p');
        }
        String articleId = [SELECT KnowledgeArticleId FROM Knowledge__kav WHERE Title = 'New title'].KnowledgeArticleId;

        User u = [select Id, email, ContactId from User where alias = 'test123'];
        System.runAs(u) {
            Entitlement testEnt = [select Id, name from Entitlement where name = 'TestingEntitlement'];
            Case NewCase = CaseLogFlow.CreateNewCase('Apple1234', 'Pear123', '2', 'Dimensions', testEnt.Id);

            CaseArticle linkedArticle = new CaseArticle(CaseId = NewCase.Id, KnowledgeArticleId = articleId);
            insert linkedArticle;
            List<Map<String, Object>> caseArticles = cspCaseArticleHandler.getCaseArticles(NewCase.Id);
            System.assertEquals(1, caseArticles.size());
        }
    }
}