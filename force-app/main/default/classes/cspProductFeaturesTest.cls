@isTest(SeeAllData=false)
public with sharing class cspProductFeaturesTest {
    @isTest
    private static void testProductFeatures()
    {
        Test.startTest();
            List<String> resultList = cspProductFeatures.getProductFeatures('Access Approve');
        Test.stopTest();
        System.assert( resultList != null );
        System.assert( resultList.size() > 0 );
    }

    @isTest
    private static void testIncorrectProductFeatures()
    {
        Test.startTest();
            List<String> resultList = cspProductFeatures.getProductFeatures('Not A Product');
        Test.stopTest();
        System.assert( resultList != null );
        System.assert( resultList.size() == 0 );
    }

    @isTest
    private static void testGetProducts()
    {
        Test.startTest();
            Map<Object,List<String>> resultMap = cspProductFeatures.getProductsByDivision();
        Test.stopTest();
        System.assert( resultMap != null );
        System.assert( resultMap.size() > 0 );
        System.assert( resultMap.get('Business Management').size() > 0 );
    }

    @isTest
    private static void testGetFlatMap()
    {
        Test.startTest();
            Map<String,String> resultMap = cspProductFeatures.getDivisionsByProduct();
        Test.stopTest();
        System.assert( resultMap != null );
        System.assert( resultMap.size() > 0 );
        System.assert( resultMap.get('Access Approve') == 'Business Management' );
    }
}