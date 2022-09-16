@isTest(SeeAllData=false)
public class CaseCommentTriggerHandlerTest {
	@isTest
	private static void caseComments() {
        Contact thisContact = TestUtilities.getContact();
        insert thisContact;
		Case thisCase = TestUtilities.getCase();
        thisCase.ContactId = thisContact.Id;
		insert thisCase;

		CaseComment thisCaseComment = TestUtilities.getCaseComment(thisCase.Id);
		insert thisCaseComment;

		CaseCommentTriggerHandler thisCaseCommentTriggerHandler;

		Test.startTest();
		thisCaseCommentTriggerHandler = new CaseCommentTriggerHandler();

		System.assertEquals(0, thisCaseCommentTriggerHandler.caseComments.size());

		thisCaseCommentTriggerHandler = new CaseCommentTriggerHandler();

		thisCaseCommentTriggerHandler.caseComments.add(thisCaseComment);

		System.assertEquals(1, thisCaseCommentTriggerHandler.caseComments.size());
		System.assertEquals(thisCaseComment, thisCaseCommentTriggerHandler.caseComments[0]);
		Test.stopTest();
	}

	@isTest
	private static void CaseCommentTriggerHandler() {
		CaseCommentTriggerHandler thisCaseCommentTriggerHandler;

		Test.startTest();
		thisCaseCommentTriggerHandler = new CaseCommentTriggerHandler();

		System.assertNotEquals(null, thisCaseCommentTriggerHandler);
		Test.stopTest();
	}

	@isTest
	private static void getInstance() {
        Contact thisContact = TestUtilities.getContact();
        insert thisContact;
		Case thisCase = TestUtilities.getCase();
        thisCase.ContactId = thisContact.Id;
		insert thisCase;

		CaseComment thisCaseComment = TestUtilities.getCaseComment(thisCase.Id);
		insert thisCaseComment;

		List<CaseComment> caseComments = new List<CaseComment>();
		caseComments.add(thisCaseComment);

		CaseCommentTriggerHandler thisCaseCommentTriggerHandler;

		Test.startTest();
		thisCaseCommentTriggerHandler = CaseCommentTriggerHandler.getInstance(null);

		System.assertEquals(0, thisCaseCommentTriggerHandler.caseComments.size());

		thisCaseCommentTriggerHandler = CaseCommentTriggerHandler.getInstance(caseComments);

		System.assertEquals(caseComments.size(), thisCaseCommentTriggerHandler.caseComments.size());
		System.assertEquals(caseComments[0], thisCaseCommentTriggerHandler.caseComments[0]);
		Test.stopTest();
	}

	
}