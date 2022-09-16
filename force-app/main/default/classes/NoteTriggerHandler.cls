public with sharing class NoteTriggerHandler {
	public static Boolean disableNoteTrigger = false;
	public static Boolean disableCaseCommentCreation = false;

	@TestVisible
	private List<Note> notes {
		get {
			if (notes == null) {
				notes = new List<Note>();
			}

			return notes;
		}
		set;
	}

	@TestVisible
	private NoteTriggerHandler() { }

	public static NoteTriggerHandler getInstance(List<Note> notes) {
		NoteTriggerHandler handler = new NoteTriggerHandler();
		handler.notes = notes;

		return handler;
	}


	@TestVisible
	private class NoteTriggerException extends Exception { }
}