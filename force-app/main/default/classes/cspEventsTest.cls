@isTest
public with sharing class cspEventsTest {
    @testSetup
    static void testSetup() {
        insert new Event__c(
            Title__c = 'test',
            Description__c = 'Testing',
            Product__c = 'Access Approve',
            Start__c = Date.today().addDays(2)
        );

        insert new Event__c(
            Title__c = 'test',
            Description__c = 'Testing',
            Product__c = 'Access Capture',
            Success_Plan__c = 'Premier',
            Start__c = Date.today().addDays(1)
        );

        insert new Event__c(
            Title__c = 'test',
            Description__c = 'Testing',
            Product__c = 'Access Approve',
            Duration__c = 60,
            Success_Plan__c = 'Premier',
            Start__c = Date.today().addDays(-2)
        );
    }

    @isTest
    public static void itShouldReturnEventsForProduct() {
        System.Test.startTest();

        List<Map<String, Object>> results = cspEvents.getEvents(new Map<String, Object> {
            'name' => 'Access Approve',
            'id' => '123456789'
        }, 'All', 0, 10);

        System.Test.stopTest();

        System.assertEquals(2, results.size(), 'There should be two results in Access Approve with category all');
    }

    @isTest
    public static void itShouldReturnFutureEventsForProduct() {
        System.Test.startTest();

        List<Map<String, Object>> results = cspEvents.getEvents(new Map<String, Object> {
            'name' => 'Access Capture',
            'id' => '123456789'
        }, 'All', 0, 10);

        System.Test.stopTest();

        System.assertEquals(true, (Boolean)results.get(0).get('future'), 'The event should be marked as future');
    }

    @isTest
    public static void itShouldReturnEventsForCategory() {
        System.Test.startTest();

        List<Map<String, Object>> results = cspEvents.getEvents(new Map<String, Object> {
            'name' => 'Access Approve',
            'id' => '123456789'
        }, 'previous_webinars', 0, 10);

        System.Test.stopTest();

        System.assertEquals(2, results.size(), 'There should be a result in previous webinars');
    }

    @isTest
    public static void itShouldReturnNotEventsForCategory() {
        System.Test.startTest();

        List<Map<String, Object>> results = cspEvents.getEvents(new Map<String, Object> {
            'name' => 'Access CRM',
            'id' => '123456789'
        }, 'All', 0, 10);

        System.Test.stopTest();

        System.assertEquals(null, results, 'There should be no results for Access CRM');
    }

    @isTest
    public static void itShouldReturnPremierEvents() {
        System.Test.startTest();

        List<Map<String, Object>> results = cspEvents.getEvents(new Map<String, Object> {
            'name' => 'Access Capture',
            'id' => '123456789'
        }, 'upcoming_webinars', 0, 10);


        System.Test.stopTest();

        System.assertEquals(true, (Boolean)results.get(0).get('premier'), 'The second event should be marked as a premier event');
    }

    @isTest
    public static void itShouldReturnAnEvent() {
        System.Test.startTest();
        System.debug([SELECT Id, Name FROM Event__c]);

        Map<String, Object> results = cspEvents.getEvent([SELECT Name FROM Event__c LIMIT 1].Name);

        System.Test.stopTest();

        System.assertEquals('test', (String)results.get('title'), 'The event should have a title of test');
    }

    @IsTest Public Static Void TestGetContactRegion() {
        String region = cspEvents.getContactRegion();
        System.assert(region == '');
    }
}