@IsTest
private class ArticleContentView_ControllerTest {
    
    static testMethod void TestUpArticles()
    {
        
        Knowledge__kav kav = new Knowledge__kav();
        kav.Title = 'Test';
        kav.Information_Article_Body__c = 'Testzzz10012022';
        kav.UrlName = 'Testzzz10012022';
        insert kav;
        
        Knowledge__kav Article = ArticleContentView_Controller.getArticle(kav.id);
        system.assertNotEquals(Null,Article);
        
        Vote UpVotesempty = ArticleContentView_Controller.checkexists(Article.KnowledgeArticleId);
        system.assertEquals(Null,UpVotesempty);
        
        ArticleContentView_Controller.VoteNew(Article.KnowledgeArticleId,'Up');
        
        Vote UpVotes = ArticleContentView_Controller.checkexists(Article.KnowledgeArticleId);
        system.assertNotEquals(Null,Upvotes);
        
        integer UpVoteCount = ArticleContentView_Controller.UpVotes(Article.KnowledgeArticleId);
        system.assertEquals(1,UpVoteCount);
        
        integer HasUpVoteCount = ArticleContentView_Controller.HasUpVotes(Article.KnowledgeArticleId);
        system.assertEquals(1,HasUpVoteCount);
        
        ArticleContentView_Controller.voteexisting(UpVotes.Id,'Down');

        integer HasDownVoteCount = ArticleContentView_Controller.HasDownVotes(Article.KnowledgeArticleId);
        system.assertEquals(1,HasDownVoteCount);

}
    
        static testMethod void TestDownArticles()
    {
        
        Knowledge__kav kav = new Knowledge__kav();
        kav.Title = 'Test';
        kav.Information_Article_Body__c = 'Test';
        kav.UrlName = 'Testzzz10012022';
        insert kav;
        
        Knowledge__kav Article = ArticleContentView_Controller.getArticle(kav.id);
        system.assertNotEquals(Null,Article);
        
        Vote UpVotesempty = ArticleContentView_Controller.checkexists(Article.KnowledgeArticleId);
        system.assertEquals(Null,UpVotesempty);
        
        ArticleContentView_Controller.VoteNew(Article.KnowledgeArticleId,'Down');
        
        Vote UpVotes = ArticleContentView_Controller.checkexists(Article.KnowledgeArticleId);
        system.assertNotEquals(Null,Upvotes);
        
        integer UpVoteCount = ArticleContentView_Controller.DownVotes(Article.KnowledgeArticleId);
        system.assertEquals(1,UpVoteCount);
        
        integer HasUpVoteCount = ArticleContentView_Controller.HasDownVotes(Article.KnowledgeArticleId);
        system.assertEquals(1,HasUpVoteCount);
        
                
        ArticleContentView_Controller.voteexisting(UpVotes.Id,'Up');

        integer HasDownVoteCount = ArticleContentView_Controller.HasUpVotes(Article.KnowledgeArticleId);
        system.assertEquals(1,HasDownVoteCount);

    

}
    
    Static TestMethod void VoteCheckDescsion()
    {
        Knowledge__kav kav = new Knowledge__kav();
        kav.Title = 'Test';
        kav.Information_Article_Body__c = 'Test';
        kav.UrlName = 'Testzzz10012022';
        insert kav;
        
        Knowledge__kav Article = ArticleContentView_Controller.getArticle(kav.id);
        system.assertNotEquals(Null,Article);
        
        ArticleContentView_Controller.votedecide(Article.KnowledgeArticleId, 'Up');
        
        integer UpVoteCount = ArticleContentView_Controller.UpVotes(Article.KnowledgeArticleId);
        system.assertEquals(1,UpVoteCount);
        
        ArticleContentView_Controller.votedecide(Article.KnowledgeArticleId, 'Down');
        
        integer HasUpVoteCount = ArticleContentView_Controller.HasDownVotes(Article.KnowledgeArticleId);
        system.assertEquals(1,HasUpVoteCount);
        
    }
}