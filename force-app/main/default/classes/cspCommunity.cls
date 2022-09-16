public without sharing class cspCommunity {
    public static final Integer DEFAULT_RESULT_LIMIT = 10;
    public static final String NETWRK = Network.getNetworkId();

    @AuraEnabled
    public static ConnectApi.FeedElementPage getRecordFeeds(String recordId, String pageToken) {
        return ConnectApi.ChatterFeeds.getFeedElementsFromFeed(
            NETWRK,
            ConnectApi.FeedType.Record,
            recordId,
            1,
            ConnectApi.FeedDensity.FewerUpdates,
            pageToken,
            DEFAULT_RESULT_LIMIT,
            ConnectApi.FeedSortOrder.LastModifiedDateDesc
        );
    }

    @AuraEnabled(cacheable=true)
    public static ConnectApi.FeedElementPage getRecordFeedsCached(String recordId, String pageToken) {
        return cspCommunity.getRecordFeeds(recordId, pageToken);
    }

    @AuraEnabled
    public static ConnectApi.FeedElementPage getAuthoredFeeds(String recordId, String pageToken) {
        return ConnectApi.ChatterFeeds.getFeedElementsFromFeed(
            NETWRK,
            ConnectApi.FeedType.UserProfile,
            recordId,
            1,
            ConnectApi.FeedDensity.FewerUpdates,
            null,
            DEFAULT_RESULT_LIMIT,
            ConnectApi.FeedSortOrder.LastModifiedDateDesc,
            ConnectApi.FeedFilter.AuthoredBy
        );
    }

    @AuraEnabled
    public static ConnectApi.FeedElementPage getUnansweredFeeds(String recordId, String pageToken) {
        return ConnectApi.ChatterFeeds.getFeedElementsFromFeed(
            NETWRK,
            ConnectApi.FeedType.Record,
            recordId,
            1,
            ConnectApi.FeedDensity.FewerUpdates,
            null,
            DEFAULT_RESULT_LIMIT,
            ConnectApi.FeedSortOrder.LastModifiedDateDesc,
            ConnectApi.FeedFilter.UnansweredQuestions
        );
    }

    @AuraEnabled
    public static ConnectApi.FeedElementPage getTopicFeeds(String topicId, String pageToken) {
        return ConnectApi.ChatterFeeds.getFeedElementsFromFeed(
            NETWRK,
            ConnectApi.FeedType.Topics,
            topicId,
            1,
            ConnectApi.FeedDensity.FewerUpdates,
            null,
            DEFAULT_RESULT_LIMIT,
            ConnectApi.FeedSortOrder.LastModifiedDateDesc
        );
    }

    @AuraEnabled
    public static ConnectApi.CommentPage getCommentsForFeedElement(String feedElementId, String nextPage) {
        return !Test.isRunningTest() ? ConnectApi.ChatterFeeds.getCommentsForFeedElement(NETWRK, feedElementId, nextPage, DEFAULT_RESULT_LIMIT) : null;
    }

    @AuraEnabled
    public static ConnectApi.Comment getComment(String commentId) {
        return !Test.isRunningTest() ? ConnectApi.ChatterFeeds.getComment(NETWRK, commentId) : null;
    }

    @AuraEnabled
    public static ConnectApi.FollowerPage getFollowers(String recordId) {
        return !Test.isRunningTest() ? ConnectApi.Chatter.getFollowers(NETWRK, recordId) : null;
    }

    @AuraEnabled
    public static ConnectApi.Subscription follow(String recordId) {
        return !Test.isRunningTest() ? ConnectApi.ChatterUsers.follow(NETWRK, 'me', recordId) : null;
    }

    @AuraEnabled
    public static EntitySubscription follows(String recordId) {
        List<EntitySubscription> subscriptions = [
            SELECT Id
            FROM EntitySubscription
            WHERE ParentId =: recordId
            AND SubscriberId =: UserInfo.getUserId()
            AND NetworkId =: NETWRK
            LIMIT 1
        ];

        return subscriptions.isEmpty() ? null : subscriptions.get(0);
    }

    @AuraEnabled
    public static void unfollow(String subscriptionId) {
        if(!Test.isRunningTest()) ConnectApi.Chatter.deleteSubscription(NETWRK, subscriptionId);
    }

    @AuraEnabled
    public static ConnectApi.MuteCapability setIsMutedByMe(String feedElementId, Boolean isMutedByMe) {
        return !Test.isRunningTest() ? ConnectApi.ChatterFeeds.setIsMutedByMe(NETWRK, feedElementId, isMutedByMe) : null;
    }

    @AuraEnabled
    public static ConnectApi.Topic getFeedDetails(String topicId){
        return !Test.isRunningTest() ? ConnectApi.Topics.getTopic(NETWRK, topicId) : null;
    }

    @AuraEnabled(cacheable=true)
    public static ConnectApi.Topic getFeedDetailsCached(String topicId){
        return cspCommunity.getFeedDetails(topicId);
    }

    @AuraEnabled(cacheable=true)
    public static ConnectApi.TopicPage getTopics(String topicName){
        return !Test.isRunningTest() ? ConnectApi.Topics.getTopics(NETWRK, topicName, true) : null;
    }

    @AuraEnabled
    public static ConnectApi.ChatterGroupPage getGroups(){
        return !Test.isRunningTest() ? ConnectApi.ChatterGroups.getGroups(NETWRK) : null;
    }

    @AuraEnabled(cacheable=true)
    public static ConnectApi.ChatterGroupPage getGroupsCached(){
        return cspCommunity.getGroups();
    }

    @AuraEnabled(cacheable=true)
    public static ConnectApi.UserGroupDetailPage getGroupsForUser(String userId){
        return !Test.isRunningTest() ? ConnectApi.ChatterUsers.getUserGroups(NETWRK, userId) : null;
    }

    @AuraEnabled
    public static ConnectApi.GroupMemberPage getGroupMembers(String groupId){
        return !Test.isRunningTest() ? ConnectApi.ChatterGroups.getMembers(NETWRK, groupId) : null;
    }

    @AuraEnabled
    public static ConnectApi.ChatterGroupDetail getGroup(String groupId){
        return !Test.isRunningTest() ? ConnectApi.ChatterGroups.getGroup(NETWRK, groupId) : null;
    }

    @AuraEnabled(cacheable=true)
    public static ConnectApi.ChatterGroupDetail getGroupCached(String groupId){
        return cspCommunity.getGroup(groupId);
    }

    @AuraEnabled
    public static ConnectApi.FeedElement getFeed(String feedId) {
        return !Test.isRunningTest() ? ConnectApi.ChatterFeeds.getFeedElement(NETWRK, feedId, false) : null;
    }

    @AuraEnabled(cacheable=true)
    public static ConnectApi.FeedElement getFeedCached(String feedId) {
        return cspCommunity.getFeed(feedId);
    }

    @AuraEnabled(cacheable=true)
    public static List<WorkBadge> getUserMissionsProgress(String userId) {
        return [
            SELECT Message, Description, ImageUrl
            FROM WorkBadge
            WHERE NetworkId =: NETWRK
            AND RecipientId =: userId
        ];
    }

    @AuraEnabled
    public static ConnectApi.Comment postCommentToFeedElement(String feedElementId, String text, String sharedId) {
        ConnectApi.CommentInput input = new ConnectApi.CommentInput();
        ConnectApi.MessageBodyInput messageInput = new ConnectApi.MessageBodyInput();
        messageInput.messageSegments = ConnectApiHelper.getMessageSegmentInputs(text);
        input.body = messageInput;


        if(sharedId != null) {
            ConnectApi.CommentCapabilitiesInput commentCapabilitiesInput = new ConnectApi.CommentCapabilitiesInput();
            ConnectApi.FeedEntityShareCapabilityInput shareInput = new ConnectApi.FeedEntityShareCapabilityInput();
            shareInput.feedEntityId = sharedId;

            commentCapabilitiesInput.feedEntityShare = shareInput;
            input.capabilities = commentCapabilitiesInput;
        }

        return !Test.isRunningTest() ?  ConnectApi.ChatterFeeds.postCommentToFeedElement(NETWRK, feedElementId, input, null) : null;
    }

    @AuraEnabled
    public static ConnectApi.Comment updateComment(String commentId, String text) {
        ConnectApi.CommentInput input = new ConnectApi.CommentInput();
        ConnectApi.MessageBodyInput messageInput = new ConnectApi.MessageBodyInput();
        messageInput.messageSegments = ConnectApiHelper.getMessageSegmentInputs(text);
        input.body = messageInput;

        return !Test.isRunningTest() ? ConnectApi.ChatterFeeds.updateComment(NETWRK, commentId, input) : null;
    }

    @AuraEnabled(cacheable=true)
    public static ConnectApi.MentionCompletionPage getMentionCompletions(String q, String contextId) {
        return !Test.isRunningTest() ? ConnectApi.Mentions.getMentionCompletions(NETWRK, q, contextId, ConnectApi.MentionCompletionType.All, null, 16) : null;
    }

    @AuraEnabled
    public static ConnectApi.FeedElement postFeedElement(String feedElementId, String text, String subject, String sharedId) {

        ConnectApi.MessageBodyInput messageInput = new ConnectApi.MessageBodyInput();
        messageInput.messageSegments = ConnectApiHelper.getMessageSegmentInputs(text);

        ConnectApi.FeedItemInput input = new ConnectApi.FeedItemInput();
        input.body = messageInput;
        input.subjectId = feedElementId;
        input.feedElementType = ConnectApi.FeedElementType.FeedItem;

        ConnectApi.FeedElementCapabilitiesInput feedElementCapabilitiesInput = new ConnectApi.FeedElementCapabilitiesInput();

        if(sharedId == null) {
            ConnectApi.QuestionAndAnswersCapabilityInput questionAndAnswersCapabilityInput = new ConnectApi.QuestionAndAnswersCapabilityInput();
            questionAndAnswersCapabilityInput.questionTitle = subject;

            feedElementCapabilitiesInput.questionAndAnswers = questionAndAnswersCapabilityInput;
        } else if(sharedId != null) {
            ConnectApi.FeedEntityShareCapabilityInput shareInput = new ConnectApi.FeedEntityShareCapabilityInput();
            shareInput.feedEntityId = sharedId;

            feedElementCapabilitiesInput.feedEntityShare = shareInput;
        }

        input.capabilities = feedElementCapabilitiesInput;

        ConnectApi.FeedElement item = !Test.isRunningTest() ? ConnectApi.ChatterFeeds.postFeedElement(NETWRK, input) : null;

        if(feedElementId.substring(0, 3) == '0TO') {
            ConnectApi.Topics.assignTopic(
                NETWRK,
                item.id,
                feedElementId
            );
        }

        return item;
    }

    @AuraEnabled
    public static ConnectApi.TopicPage reassignTopic(String feedElementId, String newTopicName) {
        ConnectApi.TopicNamesInput topicNamesInput = new ConnectApi.TopicNamesInput();
        topicNamesInput.topicNames = new List<String> {
            newTopicName
        };
        return !Test.isRunningTest() ? ConnectApi.Topics.reassignTopicsByName(NETWRK, feedElementId, topicNamesInput) : null;
    }


    @AuraEnabled
    public static ConnectApi.FeedElement updateFeedElement(String feedElementId, String text, String subject, String sharedId) {
        ConnectApi.MessageBodyInput messageInput = new ConnectApi.MessageBodyInput();
        messageInput.messageSegments = ConnectApiHelper.getMessageSegmentInputs(text);

        ConnectApi.FeedItemInput input = new ConnectApi.FeedItemInput();
        input.body = messageInput;

        ConnectApi.FeedElementCapabilitiesInput feedElementCapabilitiesInput = new ConnectApi.FeedElementCapabilitiesInput();

        if(sharedId == null) {
            ConnectApi.QuestionAndAnswersCapabilityInput questionAndAnswersCapabilityInput = new ConnectApi.QuestionAndAnswersCapabilityInput();
            questionAndAnswersCapabilityInput.questionTitle = subject;

            feedElementCapabilitiesInput.questionAndAnswers = questionAndAnswersCapabilityInput;
        } else if(sharedId != null) {
            ConnectApi.FeedEntityShareCapabilityInput shareInput = new ConnectApi.FeedEntityShareCapabilityInput();
            shareInput.feedEntityId = sharedId;

            feedElementCapabilitiesInput.feedEntityShare = shareInput;
        }

        input.capabilities = feedElementCapabilitiesInput;

        return !Test.isRunningTest() ? ConnectApi.ChatterFeeds.updateFeedElement(NETWRK, feedElementId, input) : null;
    }

    @AuraEnabled
    public static ConnectApi.ChatterLikePage updateLikeForFeedElement(String feedElementId, Boolean isLikedByCurrentUser) {
        return !Test.isRunningTest() ? ConnectApi.ChatterFeeds.updateLikeForFeedElement(NETWRK, feedElementId, isLikedByCurrentUser) : null;
    }

    @AuraEnabled
    public static ConnectApi.ChatterLikePage updateLikeForComment(String commentId, Boolean isLikedByCurrentUser) {
        return !Test.isRunningTest() ? ConnectApi.ChatterFeeds.updateLikeForComment(NETWRK, commentId, isLikedByCurrentUser) : null;
    }

    @AuraEnabled
    public static ConnectApi.PinnedFeedElements getPinned(Boolean isGroup, String subjectId) {
        ConnectApi.FeedType feedType = isGroup ? ConnectApi.FeedType.Record : ConnectApi.FeedType.Topics;
        return !Test.isRunningTest() ? ConnectApi.ChatterFeeds.getPinnedFeedElementsFromFeed(NETWRK, feedType, subjectId) : null;
    }

    @AuraEnabled(cacheable=true)
    public static ConnectApi.PinnedFeedElements getPinnedCached(Boolean isGroup, String subjectId) {
        return cspCommunity.getPinned(isGroup, subjectId);
    }

    @AuraEnabled
    public static ConnectApi.PinCapability updatePinnedElement(Boolean isGroup, String feedId, String subjectId, Boolean isPinned) {
        ConnectApi.PinCapabilityInput pinInput = new ConnectApi.PinCapabilityInput();
        pinInput.isPinned = isPinned;
        pinInput.entityId = subjectId;

        ConnectApi.FeedType feedType = isGroup ? ConnectApi.FeedType.Record : ConnectApi.FeedType.Topics;

        return !Test.isRunningTest() ? ConnectApi.ChatterFeeds.updatePinnedFeedElements(NETWRK, feedType, feedId, pinInput) : null;
    }

    @AuraEnabled
    public static ConnectApi.ModerationFlags addFlagToComment(String commentId, Boolean spam, String note) {
        ConnectApi.CommunityFlagVisibility visibility = ConnectApi.CommunityFlagVisibility.SelfAndModerators;
        ConnectApi.CommunityFlagType feedType = spam ? ConnectApi.CommunityFlagType.FlagAsSpam : ConnectApi.CommunityFlagType.FlagAsInappropriate;
        return !Test.isRunningTest() ? ConnectApi.CommunityModeration.addFlagToComment(NETWRK, commentId, feedType, visibility, note) : null;
    }

    @AuraEnabled
    public static ConnectApi.ModerationCapability addFlagToFeedElement(String feedElementId, Boolean spam, String note) {
        ConnectApi.CommunityFlagVisibility visibility = ConnectApi.CommunityFlagVisibility.SelfAndModerators;
        ConnectApi.CommunityFlagType feedType = spam ? ConnectApi.CommunityFlagType.FlagAsSpam : ConnectApi.CommunityFlagType.FlagAsInappropriate;
        return !Test.isRunningTest() ? ConnectApi.CommunityModeration.addFlagToFeedElement(NETWRK, feedElementId, feedType, visibility, note) : null;
    }

    @AuraEnabled
    public static ConnectApi.GroupMembershipRequest requestGroupMembership(String groupId) {
        return !Test.isRunningTest() ? ConnectApi.ChatterGroups.requestGroupMembership(NETWRK, groupId) : null;
    }

    @AuraEnabled
    public static CollaborationGroupMember addMember(String groupId) {
        CollaborationGroupMember member = new CollaborationGroupMember(
            CollaborationGroupId = groupId,
            CollaborationRole = 'Standard',
            MemberId = UserInfo.getUserId()
        );
        insert member;
        return member;
    }

    @AuraEnabled
    public static ConnectApi.GroupMember addMemberWithRole(String groupId) {
        ConnectApi.GroupMembershipType type = ConnectApi.GroupMembershipType.StandardMember;
        return !Test.isRunningTest() ? ConnectApi.ChatterGroups.addMemberWithRole(NETWRK, groupId, 'me', type) : null;
    }

    @AuraEnabled
    public static void deleteMember(String membershipId) {
        if(!Test.isRunningTest()) ConnectApi.ChatterGroups.deleteMember(NETWRK, membershipId);
    }

    @AuraEnabled
    public static ConnectApi.QuestionAndAnswersCapability updateQuestionAndAnswers(String feedElementId, String bestAnswerId) {
        ConnectApi.QuestionAndAnswersCapabilityInput qaInput = new ConnectApi.QuestionAndAnswersCapabilityInput();
        qaInput.bestAnswerId = bestAnswerId;

        return !Test.isRunningTest() ? ConnectApi.QuestionAndAnswers.updateQuestionAndAnswers(NETWRK, feedElementId, qaInput) : null;
    }

    @AuraEnabled
    public static ConnectApi.VerifiedCapability setCommentIsVerified(String commentId, Boolean isVerified) {
        return !Test.isRunningTest() ? ConnectApi.ChatterFeeds.setCommentIsVerified(NETWRK, commentId, isVerified) : null;
    }

    @AuraEnabled
    public static void deleteFeedElement(String feedElementId) {
        if(!Test.isRunningTest()) ConnectApi.ChatterFeeds.deleteFeedElement(NETWRK, feedElementId);
    }

    @AuraEnabled
    public static void deleteComment(String commentId) {
        if(!Test.isRunningTest()) ConnectApi.ChatterFeeds.deleteComment(NETWRK, commentId);
    }

    @AuraEnabled
    public static ConnectApi.CloseCapability setFeedElementIsClosed(String feedElementId, Boolean isClosed) {
        return !Test.isRunningTest() ? ConnectApi.ChatterFeeds.setFeedElementIsClosed(NETWRK, feedElementId, isClosed) : null;
    }

    @AuraEnabled(cacheable=true)
    public static ConnectApi.FeedEntityIsEditable isFeedElementEditableByMe(String feedElementId) {
        return !Test.isRunningTest() ? ConnectApi.ChatterFeeds.isFeedElementEditableByMe(NETWRK, feedElementId) : null;
    }

    @AuraEnabled(cacheable=true)
    public static ConnectApi.FeedEntityIsEditable isCommentEditableByMe(String commentId) {
        return !Test.isRunningTest() ? ConnectApi.ChatterFeeds.isCommentEditableByMe(NETWRK, commentId) : null;
    }

    @AuraEnabled(cacheable=true)
    public static string getContentVersionId(String contentDocumentId){
        ContentVersion ver = [
            SELECT Id
            FROM ContentVersion
            WHERE ContentDocumentId =: contentDocumentId
        ];
        return ver.Id;
    }

    @AuraEnabled(cacheable=false)
    public static ConnectApi.Photo setPhoto(String fileId) {
        return !Test.isRunningTest() ? ConnectApi.UserProfiles.setPhoto(NETWRK, 'me', fileId, null) : null;
    }

    @AuraEnabled(cacheable=false)
    public static void updateRegion(String contactId, String region) {
        Contact c = [SELECT Region__c FROM Contact WHERE Id = :Id.valueOf(contactId)];
        c.Region__c = region;
        update c;
    }

    @AuraEnabled(cacheable=false)
    public static void deletePhoto() {
        if(!Test.isRunningTest()) ConnectApi.UserProfiles.deletePhoto(NETWRK, 'me');
    }

    @AuraEnabled(cacheable=true)
    public static ConnectApi.ManagedTopicCollection getFeaturedTopics() {
        return !Test.isRunningTest() ? ConnectApi.ManagedTopics.getManagedTopics(NETWRK, ConnectApi.ManagedTopicType.Featured) : null;
    }

    @AuraEnabled(cacheable=true)
    public static List<Map<String, String>> getBreadcrumbComponent(String recordId) {
        List<Map<String, String>> results = new List<Map<String, String>>();
        if(recordId.substring(0, 3) == '0TO') {
            List<ProductRouting__c> routing = [
                SELECT Id
                FROM ProductRouting__c
                WHERE TopicId__c =: recordId
                LIMIT 1
            ];

            if(!routing.isEmpty()) {
                results.add(new Map<String, String>{
                    'name' => 'Products',
                    'url' => '/topiccatalog'
                });
            }
        }
        if(recordId.substring(0, 3) == '0F9') {
            results.add(new Map<String, String>{
                'name' => 'Groups',
                'url' => '/groups'
            });
        }
        if(recordId.substring(0, 3) == '0D5') {
            List<CollaborationGroupFeed> feed = [
                SELECT Parent.Id, Parent.Name
                FROM CollaborationGroupFeed
                WHERE Id =: recordId
                LIMIT 1
            ];

            if(!feed.isEmpty()) {
                results.add(new Map<String, String>{
                    'name' => 'Groups',
                    'url' => '/groups'
                });
                results.add(new Map<String, String>{
                    'name' => feed[0].Parent.Name,
                    'url' => '/group/' + feed[0].Parent.Id
                });
            } else {
                List<TopicAssignment> topics = [
                    SELECT Topic.Name, Topic.Id
                    FROM TopicAssignment
                    WHERE EntityId =: recordId
                    AND NetworkId =: NETWRK
                    LIMIT 1
                ];
                if(!topics.isEmpty()) {
                    List<ProductRouting__c> routing = [
                        SELECT Id
                        FROM ProductRouting__c
                        WHERE TopicId__c =: topics[0].Topic.Id
                        LIMIT 1
                    ];

                    if(!routing.isEmpty()) {
                        results.add(new Map<String, String>{
                            'name' => 'Products',
                            'url' => '/topiccatalog'
                        });
                    }
                    results.add(new Map<String, String>{
                        'name' => topics[0].Topic.Name,
                        'url' => '/topic/' + topics[0].Topic.Id
                    });
                }
            }
        }

        return results;
    }

    @AuraEnabled(cacheable=false)
    public static void changePassword(String newPassword, String confirmPassword, String oldPassword) {
        if(!Test.isRunningTest()) Site.changePassword(newPassword, confirmPassword, oldPassword);
    }
}