public without sharing class cspCaseArticleHandler {
    
    @AuraEnabled(cacheable=false)
    public static List<Map<String, Object>> getCaseArticles(String caseId) {
        List<Map<String, Object>> articleMap = new List<Map<String, Object>>();
        List<KnowledgeArticleVersion> articles = [
            SELECT Id, Title, UrlName FROM KnowledgeArticleVersion
            WHERE Id IN (SELECT KnowledgeArticleVersionId FROM CaseArticle WHERE CaseId =:caseId)
            AND IsVisibleInCsp = TRUE
        ];
        for(KnowledgeArticleVersion article: articles) {
            articleMap.add(new Map<String, Object>{
                'title' => article.Title,
                'url' => article.UrlName
            });
        }
        return articleMap;
    }
}