@isTest
public with sharing class cspReleaseNoteHandlerTest {
    @IsTest Public Static Void RetrieveCollections() {
        Knowledge__kav newArticle = TestUtilities.getArticleAsADraft('New title', 'new-url-name' + Crypto.getRandomInteger());
        newArticle.Information_Article_Body__c = 'New article';
        newArticle.Division__c = 'Business Management';
        newArticle.Product__c = 'Access Approve';
        insert newArticle;
        String articleId = [SELECT KnowledgeArticleId FROM Knowledge__kav WHERE Id =: newArticle.Id].KnowledgeArticleId;
        KbManagement.PublishingService.publishArticle(articleId, true);

        Release_Note__c note = new Release_Note__c();
        note.Version__c = '1.1.1';
        note.Product__c = 'Access Approve';
        note.Release_Date__c = Date.newInstance(1960, 2, 17);
        note.Knowledge__c = newArticle.Id;
        note.Type__c = 'Request';
        note.Postponed__c = false;
        note.Release_Details__c = 'Mobile';
        insert note;

        List<Map<String, Object>> releaseNotes = cspReleaseNoteHandler.getReleaseNotes('Access Approve', 10, 0);
        System.assert(releaseNotes.size() == 1);
        System.assert(releaseNotes[0].get('version') == '1.1.1');
        System.assert(releaseNotes[0].get('product') == 'Access Approve');
        System.assert(releaseNotes[0].get('releaseNotes') == 'New title');

        List<Map<String, Object>> noReleases = cspReleaseNoteHandler.getReleaseNotes('Not a product', 10, 0);
        System.assert(noReleases.size() == 0);
    }

    @IsTest Public Static Void TestGetContactRegion() {
        String region = cspReleaseNoteHandler.getContactRegion();
        System.assert(region == '');
    }
}