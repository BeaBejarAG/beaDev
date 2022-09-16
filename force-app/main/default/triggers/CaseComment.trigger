trigger CaseComment on CaseComment (after insert) {
    string id1 = userinfo.getProfileId();
     If(id1.contains('00e58000000Nh5B') || id1.contains('00e58000000NgDx'))
     {
     }
    Else{
	if (CaseCommentTriggerHandler.disableCaseCommentTrigger == false) {
		if (Trigger.isAfter) {
			if (Trigger.isInsert) {
				CaseCommentTriggerHandler handler = CaseCommentTriggerHandler.getInstance(Trigger.new);

				//handler.createIncidentNotes();
			}
		}
	}
    }
     }