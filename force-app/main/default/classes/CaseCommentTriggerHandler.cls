public with sharing class CaseCommentTriggerHandler {
    public static Boolean disableCaseCommentTrigger = false;
    public static Boolean disableIncidentNoteCreation = false;

    @TestVisible
    private List<CaseComment> caseComments {
        get {
            if (caseComments == null) {
                caseComments = new List<CaseComment>();
            }

            return caseComments;
        }
        set;
    }

    @TestVisible
    private CaseCommentTriggerHandler() { }

    public static CaseCommentTriggerHandler getInstance(List<CaseComment> caseComments) {
        CaseCommentTriggerHandler handler = new CaseCommentTriggerHandler();
        handler.caseComments = caseComments;

        return handler;
    }


    @TestVisible
    private class CaseCommentTriggerException extends Exception { }
}