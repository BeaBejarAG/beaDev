@isTest(SeeAllData=false)
public class NoteTriggerHandlerTest {


	@isTest
	private static void NoteTriggerHandler() {
		NoteTriggerHandler thisNoteTriggerHandler;

		Test.startTest();
		thisNoteTriggerHandler = new NoteTriggerHandler();

		System.assertNotEquals(null, thisNoteTriggerHandler);
		Test.stopTest();
	}

}