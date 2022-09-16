@isTest
private class cspCommunityTest {
    @IsTest
    static void itShouldReturnFeedElements() {
        Topic topic = new Topic(Name = 'Test product');
        insert topic;

        // given two feed elements on a feed
        ConnectApi.FeedElementPage testPage = new ConnectApi.FeedElementPage();
        List<ConnectApi.FeedItem> testItemList = new List<ConnectApi.FeedItem>();
        testItemList.add(new ConnectApi.FeedItem());
        testItemList.add(new ConnectApi.FeedItem());
        testPage.elements = testItemList;

        ConnectApi.ChatterFeeds.setTestGetFeedElementsFromFeed(
            null,
            ConnectApi.FeedType.Record,
            topic.Id,
            1,
            ConnectApi.FeedDensity.FewerUpdates,
            null,
            cspCommunity.DEFAULT_RESULT_LIMIT,
            ConnectApi.FeedSortOrder.LastModifiedDateDesc,
            testPage
        );

        System.Test.startTest();

        // when the feed is requested
        ConnectApi.FeedElementPage results = cspCommunity.getRecordFeeds(topic.Id, null);

        // there should be two feed elements
        System.assertEquals(2, results.elements.size(), 'Feed should have two elements');
        System.Test.stopTest();
    }

    @IsTest
    static void itShouldReturnAuthoredFeedElements() {
        Topic topic = new Topic(Name = 'Test product');
        insert topic;

        // given two feed elements on a feed
        ConnectApi.FeedElementPage testPage = new ConnectApi.FeedElementPage();
        List<ConnectApi.FeedItem> testItemList = new List<ConnectApi.FeedItem>();
        testItemList.add(new ConnectApi.FeedItem());
        testItemList.add(new ConnectApi.FeedItem());
        testPage.elements = testItemList;

        ConnectApi.ChatterFeeds.setTestGetFeedElementsFromFeed(
            null,
            ConnectApi.FeedType.UserProfile,
            topic.Id,
            1,
            ConnectApi.FeedDensity.FewerUpdates,
            null,
            cspCommunity.DEFAULT_RESULT_LIMIT,
            ConnectApi.FeedSortOrder.LastModifiedDateDesc,
            ConnectApi.FeedFilter.AuthoredBy,
            testPage
        );

        System.Test.startTest();

        // when the feed is requested
        ConnectApi.FeedElementPage results = cspCommunity.getAuthoredFeeds(topic.Id, null);

        // there should be two feed elements
        System.assertEquals(2, results.elements.size(), 'Feed should have two elements');
        System.Test.stopTest();
    }

    @IsTest
    static void itShouldReturnUnansweredFeedElements() {
        Topic topic = new Topic(Name = 'Test product');
        insert topic;

        // given two feed elements on a feed
        ConnectApi.FeedElementPage testPage = new ConnectApi.FeedElementPage();
        List<ConnectApi.FeedItem> testItemList = new List<ConnectApi.FeedItem>();
        testItemList.add(new ConnectApi.FeedItem());
        testItemList.add(new ConnectApi.FeedItem());
        testPage.elements = testItemList;

        ConnectApi.ChatterFeeds.setTestGetFeedElementsFromFeed(
            null,
            ConnectApi.FeedType.Record,
            topic.Id,
            1,
            ConnectApi.FeedDensity.FewerUpdates,
            null,
            cspCommunity.DEFAULT_RESULT_LIMIT,
            ConnectApi.FeedSortOrder.LastModifiedDateDesc,
            ConnectApi.FeedFilter.UnansweredQuestions,
            testPage
        );

        System.Test.startTest();

        // when the feed is requested
        ConnectApi.FeedElementPage results = cspCommunity.getUnansweredFeeds(topic.Id, null);

        // there should be two feed elements
        System.assertEquals(2, results.elements.size(), 'Feed should have two elements');
        System.Test.stopTest();
    }

    @IsTest
    static void itShouldReturnTopicFeedElements() {
        Topic topic = new Topic(Name = 'Test product');
        insert topic;

        // given two feed elements on a feed
        ConnectApi.FeedElementPage testPage = new ConnectApi.FeedElementPage();
        List<ConnectApi.FeedItem> testItemList = new List<ConnectApi.FeedItem>();
        testItemList.add(new ConnectApi.FeedItem());
        testItemList.add(new ConnectApi.FeedItem());
        testPage.elements = testItemList;

        ConnectApi.ChatterFeeds.setTestGetFeedElementsFromFeed(
            null,
            ConnectApi.FeedType.Topics,
            topic.Id,
            1,
            ConnectApi.FeedDensity.FewerUpdates,
            null,
            cspCommunity.DEFAULT_RESULT_LIMIT,
            ConnectApi.FeedSortOrder.LastModifiedDateDesc,
            testPage
        );

        System.Test.startTest();

        // when the feed is requested
        ConnectApi.FeedElementPage results = cspCommunity.getTopicFeeds(topic.Id, null);

        // there should be two feed elements
        System.assertEquals(2, results.elements.size(), 'Feed should have two elements');
        System.Test.stopTest();
    }

    @IsTest
    static void itShouldPaginateFeedElements() {
        String nextPageToken = 'token-1';

        Topic topic = new Topic(Name = 'Test product');
        insert topic;

        // given two feed elements on a feed
        ConnectApi.FeedElementPage firstPage = new ConnectApi.FeedElementPage();
        List<ConnectApi.FeedItem> firstPageList = new List<ConnectApi.FeedItem>();
        for(Integer i = 0; i < 10; i++) {
            firstPageList.add(new ConnectApi.FeedItem());
        }
        firstPage.elements = firstPageList;

        ConnectApi.FeedElementPage secondPage = new ConnectApi.FeedElementPage();
        List<ConnectApi.FeedItem> secondPageList = new List<ConnectApi.FeedItem>();
        for(Integer i = 0; i < 10; i++) {
            secondPageList.add(new ConnectApi.FeedItem());
        }
        secondPage.elements = secondPageList;

        ConnectApi.ChatterFeeds.setTestGetFeedElementsFromFeed(
            null,
            ConnectApi.FeedType.Record,
            topic.Id,
            1,
            ConnectApi.FeedDensity.FewerUpdates,
            null,
            cspCommunity.DEFAULT_RESULT_LIMIT,
            ConnectApi.FeedSortOrder.LastModifiedDateDesc,
            firstPage
        );

        ConnectApi.ChatterFeeds.setTestGetFeedElementsFromFeed(
            null,
            ConnectApi.FeedType.Record,
            topic.Id,
            1,
            ConnectApi.FeedDensity.FewerUpdates,
            nextPageToken,
            cspCommunity.DEFAULT_RESULT_LIMIT,
            ConnectApi.FeedSortOrder.LastModifiedDateDesc,
            secondPage
        );

        System.Test.startTest();

        // when the feed is requested
        ConnectApi.FeedElementPage firstPageResults = cspCommunity.getRecordFeeds(topic.Id, null);
        ConnectApi.FeedElementPage secondPageResults = cspCommunity.getRecordFeeds(topic.Id, firstPage.nextPageToken);

        // there should be three pages
        System.assertEquals(cspCommunity.DEFAULT_RESULT_LIMIT, firstPageResults.elements.size(), 'There should be a first page of results');
        System.assertEquals(cspCommunity.DEFAULT_RESULT_LIMIT, secondPageResults.elements.size(), 'There should be a second page of results');
        System.Test.stopTest();
    }

    @IsTest(SeeAllData=true)
    static void itShouldWorkAsExpected() {
        // we can't test these
        cspCommunity.getCommentsForFeedElement(null, null);
        cspCommunity.getComment(null);
        cspCommunity.getFeedDetails(null);
        cspCommunity.getFeedDetailsCached(null);
        cspCommunity.getGroupMembers(null);
        cspCommunity.getGroup(null);
        cspCommunity.getGroupCached(null);
        cspCommunity.getGroups();
        cspCommunity.getGroupsCached();
        cspCommunity.getGroupsForUser(null);
        cspCommunity.getFeed(null);
        cspCommunity.getFeedCached(null);
        cspCommunity.getFollowers(null);
        cspCommunity.unfollow(null);
        cspCommunity.follow(null);
        cspCommunity.setIsMutedByMe(null, true);
        cspCommunity.updateLikeForComment(null, null);
        cspCommunity.updateLikeForFeedElement(null, null);
        cspCommunity.getPinned(false, null);
        cspCommunity.getPinnedCached(false, null);
        cspCommunity.getMentionCompletions(null, null);
        cspCommunity.postFeedElement('123', '', '', null);
        cspCommunity.postFeedElement('123', '', '', '');
        cspCommunity.updateFeedElement('', '', '', null);
        cspCommunity.updateFeedElement('', '', '', '');
        cspCommunity.updateComment(null, '');
        cspCommunity.postCommentToFeedElement('', '', null);
        cspCommunity.postCommentToFeedElement('', '', '');
        cspCommunity.updateLikeForComment(null, null);
        cspCommunity.updatePinnedElement(false, null, null, null);
        cspCommunity.addFlagToComment(null, true, null);
        cspCommunity.addFlagToFeedElement(null, true, null);
        cspCommunity.requestGroupMembership(null);
        cspCommunity.addMemberWithRole(null);
        cspCommunity.deleteMember(null);
        cspCommunity.updateQuestionAndAnswers(null, null);
        cspCommunity.setCommentIsVerified(null, null);
        cspCommunity.deleteFeedElement(null);
        cspCommunity.deleteComment(null);
        cspCommunity.setFeedElementIsClosed(null, null);
        cspCommunity.isFeedElementEditableByMe(null);
        cspCommunity.isCommentEditableByMe(null);
        cspCommunity.setPhoto(null);
        cspCommunity.deletePhoto();
        cspCommunity.follows(null);
        cspCommunity.getUserMissionsProgress(null);
        cspCommunity.changePassword(null, null, null);
        cspCommunity.getFeaturedTopics();
        cspCommunity.getTopics(null);
        cspCommunity.reassignTopic(null, null);
    }
}