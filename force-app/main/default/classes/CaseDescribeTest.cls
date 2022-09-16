@isTest(SeeAllData=false)
public class CaseDescribeTest {
	@isTest
	private static void thisDescribeSObjectResult() {
		Test.startTest();
		CaseDescribe.thisDescribeSObjectResult = null;

		System.assertNotEquals(null, CaseDescribe.thisDescribeSObjectResult);
		Test.stopTest();
	}

	@isTest
	private static void recordTypesByNameMap() {
		Map<String, Schema.RecordTypeInfo> recordTypesByNameMap = CaseDescribe.thisDescribeSObjectResult.getRecordTypeInfosByName();

		Test.startTest();
		CaseDescribe.recordTypesByNameMap = null;

		System.assertEquals(recordTypesByNameMap.size(), CaseDescribe.recordTypesByNameMap.size());

		for (String recordTypeName : recordTypesByNameMap.keySet()) {
			System.assertEquals(recordTypesByNameMap.get(recordTypeName).getRecordTypeId(), CaseDescribe.recordTypesByNameMap.get(recordTypeName).getRecordTypeId());
		}
		Test.stopTest();
	}

	@isTest
	private static void recordType_Hosting() {
		Test.startTest();
		CaseDescribe.recordType_Hosting = null;

		System.assertEquals(CaseDescribe.recordTypesByNameMap.get(Label.Case_Record_Type_Hosting), CaseDescribe.recordType_Hosting);
		Test.stopTest();
	}

	@isTest
	private static void recordTypeId_Hosting() {
		Test.startTest();
		CaseDescribe.recordTypeId_Hosting = null;

		System.assertEquals(CaseDescribe.recordType_Hosting.getRecordTypeId(), CaseDescribe.recordTypeId_Hosting);
		Test.stopTest();
	}
}