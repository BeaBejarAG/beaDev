public without sharing class cspCaseArticleHandler {
    
    @AuraEnabled(cacheable=false)
    public static List<Map<String, Object>> getCaseArticles(String caseId) {
        List<Map<String, Object>> articleMap = new List<Map<String, Object>>();
        List<CaseArticle> articles = [
            SELECT Id, KnowledgeArticleVersion.Title, KnowledgeArticleVersion.UrlName, CaseId FROM CaseArticle
            WHERE CaseId =:caseId
            AND KnowledgeArticleVersion.IsVisibleInCsp = TRUE
        ];
        for(CaseArticle article: articles) {
            articleMap.add(new Map<String, Object>{
                'title' => article.KnowledgeArticleVersion.Title,
                'url' => article.KnowledgeArticleVersion.UrlName
            });
        }

        return articleMap;
    }
}