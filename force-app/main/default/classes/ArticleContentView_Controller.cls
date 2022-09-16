public with sharing class ArticleContentView_Controller 
{
    //public String articleId {get; set;}

    @AuraEnabled
    public static Knowledge__kav getArticle(ID recordId)
    {
        Knowledge__kav article = [SELECT Id, Title, KnowledgeArticleId, Information_Article_Body__c, Solution__c FROM Knowledge__kav WHERE Id = :recordId LIMIT 1]; 
        return article;
    }
    
        @AuraEnabled
    public static integer UpVotes(ID recordId)
    {
        integer up = [SELECT count() FROM Vote WHERE ParentId = :recordId  and Type = 'Up']; 
        return up;
    }
    
            @AuraEnabled
    public static integer DownVotes(ID recordId)
    {
        integer down = [SELECT count() FROM Vote WHERE ParentId = :recordId and Type = 'Down'];  
        return down;
    }
    
            @AuraEnabled
    public static integer HasUpVotes(ID recordId)
    {
        Id userId = UserInfo.getUserId();
        integer up = [SELECT count() FROM Vote WHERE ParentId = :recordId  and Type = 'Up' and createdbyid = :userId ]; 
        return up;
    }
    
            @AuraEnabled
    public static integer HasDownVotes(ID recordId)
    {
        Id userId = UserInfo.getUserId();
        integer down = [SELECT count() FROM Vote WHERE ParentId = :recordId and Type = 'Down'  and createdbyid = :userId];  
        return down;
    }
    
    @AuraEnabled
    public static void votenew(ID recordId, string votetype)
    {
              Vote nV = new Vote();
        nV.ParentId = recordId;
        nV.Type = votetype;
         insert nV;

    }
    
        @AuraEnabled
    public static void voteexisting(ID OldRecordId, string votetype)
    {        
              Vote nD = new Vote();
              nD.id = OldRecordId;
              nD.Type = votetype;
              update nD;
    }
    
            @AuraEnabled
    public static Vote checkexists(ID recordId)
    {
        
        Id userId = UserInfo.getUserId();
        Vote[] voteid = [SELECT Id FROM Vote WHERE ParentId = :recordId and createdbyid = :userId ];
        if (voteid.size() == 0)
return null;
        
        return voteid[0];
    }
    
        @AuraEnabled
    public static void votedecide(ID recordId, string votetype)
    {
        boolean IsExisting = false;
        Vote currentvote = new Vote();
        currentvote = checkexists(recordId);
        
        if(currentvote != null)
        {
            IsExisting = true;
        }

                if(!IsExisting)
                {
                votenew(recordId, votetype);
                }
                else
                {
                voteexisting(currentvote.id, votetype);
                //votenew(recordId, votetype);
                }
            }
        
        }