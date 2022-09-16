/************************************************************************************
 * Class Name: CaseTriggerHandler
 * Purpose: Handle actions on a case trigger
 * Author: Nick Palin
 * Release Version: 3
 * Release Code Coverage: Unkown
 * Notes: Please copy the template line below if you make changes, please mark the version change (Every push to Prod is a new version), Anotate any changed lines with your version and what was changed 
 * Also please ensure any test code is at least the same code coverage as the release code coverage.
 * This was originaly created by a 3rd party so missing annotations.
 * Changed By: YOURNAME Date: THISDATE Reason\Changes: YOUR REASON Version: PREV+1
 * Changed By: Chris Lewis Date: 02/08/2018 Reason\Changes: Added Loop Killer and This annotation section Version: 2
 * *********************************************************************************/
public with sharing class CaseTriggerHandler {
	public static Boolean disableCaseTrigger = false;
	public static Boolean disableIncidentClosure = false;

	@TestVisible
	private List<Case> cases {
		get {
			if (cases == null) {
				cases = new List<Case>();
			}

			return cases;
		}
		set;
	}

	@TestVisible
	private Map<Id, Case> oldCasesMap {
		get {
			if (oldCasesMap == null) {
				oldCasesMap = new Map<Id, Case>();
			}

			return oldCasesMap;
		}
		set;
	}

	@TestVisible
	private CaseTriggerHandler() { }

	public static CaseTriggerHandler getInstance(List<Case> cases, Map<Id, Case> oldCasesMap) {
		CaseTriggerHandler handler = new CaseTriggerHandler();
		handler.cases = cases;
		handler.oldCasesMap = oldCasesMap;

		return handler;
	}

    public static void completeMilestone(List<Id> caseIds, 
            String milestoneName, DateTime complDate) {  
        List<CaseMilestone> cmsToUpdate = [select Id, completionDate
            from CaseMilestone cm
            where caseId in :caseIds and cm.MilestoneType.Name=:milestoneName 
            and completionDate = null limit 1];
        if (cmsToUpdate.isEmpty() == false){
            for (CaseMilestone cm : cmsToUpdate){
                cm.completionDate = complDate;
            }
            update cmsToUpdate;
        }
    }

    public static void afterCaseInsert(List<Case> caseList) {
        updateFlexPointsTransactions(caseList);
    }

    public static void afterCaseUpdate(List<Case> caseList) {
        updateFlexPointsTransactions(caseList);
    }

    private static void updateFlexPointsTransactions(List<Case> caseList) {
        for (Case c : caseList) {
            String recordTypeId = String.valueOf(Schema.SObjectType.Case.getRecordTypeInfosByName().get('FlexPoints Redemption').getRecordTypeId());
            if (c.RecordTypeId == recordTypeId) {
                List<FlexPoints_Transactions__c> flexPointsTransactionsList = [SELECT Id, Transaction_Status__c FROM FlexPoints_Transactions__c WHERE FlexPoint_Redemption_Case__c =: c.Id];
                List<FlexPoints_Transactions__c> transactionsToUpdate = new List<FlexPoints_Transactions__c>();
                for (FlexPoints_Transactions__c flexPoint : flexPointsTransactionsList) {
                    if (flexPoint.Transaction_Status__c != c.Status) {
                        flexPoint.Transaction_Status__c = c.Status;
                        transactionsToUpdate.add(flexPoint);
                    }
                }
                if (transactionsToUpdate != null && transactionsToUpdate.isEmpty() == false) {
                    update transactionsToUpdate;
                }
            }
        }
    }
    
    public void CloseAllMilestones()
    {
        for (Case thisCase : cases) {
            Case oldCase = oldCasesMap.get(thisCase.Id);
            if(thisCase.EntitlementId != null 
            && oldCase.Status != 'Closed' 
            && thisCase.Status == 'Closed') {
                Map<String, Object> params = new Map<String, Object>();
                params.put('UpdateAction', 'First Response');
                params.put('IncommingCase', thisCase);
                Flow.Interview.Support_Profiles_Update_Milestones calcFlow = new Flow.Interview.Support_Profiles_Update_Milestones(params);
                calcFlow.start();
                
                Map<String, Object> params1 = new Map<String, Object>();
                params1.put('UpdateAction', 'Next Reply');
                params1.put('IncommingCase', thisCase);
                Flow.Interview.Support_Profiles_Update_Milestones calcFlow1 = new Flow.Interview.Support_Profiles_Update_Milestones(params1);
                calcFlow1.start();
                    
                Map<String, Object> params2 = new Map<String, Object>();
                params2.put('UpdateAction', 'Closed');
                params2.put('IncommingCase', thisCase);
                Flow.Interview.Support_Profiles_Update_Milestones calcFlow2 = new Flow.Interview.Support_Profiles_Update_Milestones(params2);
                calcFlow2.start();
            }
        }
    }
    
    /******************************
     * Email Loop Killer will not process new e-mail from the same email with the same subject and the previous email was less than 5 minutes ago
     * ****************************/
    public void CaseLoopKiller(Case[] c) {
        case[] check = 
            [select ID, CreatedDate, subject from Case where
            SuppliedEmail = :c[0].SuppliedEmail and
            subject = :c[0].subject and
            isclosed = false and
            recordtypeid = '012580000006HfdAAE'               
            order by CreatedDate desc];
        system.debug(c[0].SuppliedEmail);
        system.debug(c[0].subject);
        if(c[0].Subject != null) {
            //We have a subject, proceed.
            if(c[0].subject.contains('[ ref:')){
                //No Errors.  Email should be attached to the case.
            } else {
                if(check.size() > 3){
                    if((check[0].createddate.addMinutes(5) > System.now()) &&
                        check[0].subject.contains(c[0].subject)){
                        c[0].addError('Case cannot be saved. Four Cases with same Subject and same Web Email cannot be created within five minutes.');
                        //Loop Was Killed.
                    } else {
                        //New Case should be created now!
                    }
                }
            }
        }
    }

    public void ThisShouldntRunOnSave()
    {
      system.debug('WHYHAVEYOURUN');  
    }
	
}