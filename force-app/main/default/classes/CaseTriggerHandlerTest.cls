@isTest(SeeAllData=false)
public with sharing class CaseTriggerHandlerTest {
    @isTest
    private static void cases() {
        Case thisCase = TestUtilities.getCase();
        insert thisCase;

        Test.startTest();

        CaseTriggerHandler thisCaseTriggerHandler = new CaseTriggerHandler();
        System.assertEquals(0, thisCaseTriggerHandler.cases.size());

        thisCaseTriggerHandler.cases.add(thisCase);
        System.assertEquals(1, thisCaseTriggerHandler.cases.size());
        System.assertEquals(thisCase, thisCaseTriggerHandler.cases[0]);

        Test.stopTest();
    }

    @isTest
    private static void oldCasesMap() {
        Case thisCase = TestUtilities.getCase();
        insert thisCase;

        Test.startTest();
        
        CaseTriggerHandler thisCaseTriggerHandler = new CaseTriggerHandler();
        System.assertEquals(0, thisCaseTriggerHandler.oldCasesMap.size());

        thisCaseTriggerHandler.oldCasesMap.put(thisCase.Id, thisCase);
        System.assertEquals(1, thisCaseTriggerHandler.oldCasesMap.size());
        System.assert(thisCaseTriggerHandler.oldCasesMap.containsKey(thisCase.Id));
        System.assertEquals(thisCase, thisCaseTriggerHandler.oldCasesMap.get(thisCase.Id));

        Test.stopTest();
    }

    @isTest
    private static void afterCaseUpdate() {
        User portalAccountOwner1 = TestUtilities.createUser('Support Admin', 'System Administrator', 'test123');

        System.runAs(portalAccountOwner1) {
            Case thisCase = new Case(
                Status = 'Support Outstanding',
                Description = 'Description',
                Subject = 'Subject',
                Origin = 'Web',
                Priority = '3',
                RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('FlexPoints Redemption').getRecordTypeId(),
                RelatedProduct__c = 'Access Approve',
                Source__c = 'Support',
                CaseType__c = 'Feature request',
                Points_Estimate__c = 200
            );
            insert thisCase;
    
            List<Case> caseList = new List<Case>();
            caseList.add(thisCase);


            //Create account
			Account portalAccount1 = new Account(Name = 'TestAccount', OwnerId = portalAccountOwner1.Id);
			insert portalAccount1;

            Date requestedDate = Date.today();
            FlexPoints_Transactions__c flexPointTransactionPending = new FlexPoints_Transactions__c(
                Account__c = portalAccount1.Id,
                Transaction_Status__c = 'Pending',
                Type__c = 'Redemption',
                Points__c = 1000,
                Requested_Date__c = requestedDate,
                FlexPoint_Redemption_Case__c = thisCase.Id,
                Owner__c = UserInfo.getUserId()
            );
            insert flexPointTransactionPending;

            CaseTriggerHandler.afterCaseUpdate(caseList);

            FlexPoints_Transactions__c flexPointTransaction = [SELECT Transaction_Status__c, Status__c FROM FlexPoints_Transactions__c LIMIT 1];
            System.assertEquals(String.valueOf(thisCase.Status), flexPointTransaction.Status__c);
            System.assertEquals(String.valueOf(thisCase.Status), flexPointTransaction.Transaction_Status__c);
        }
    }

    @isTest
    private static void CaseTriggerHandler() {

        Test.startTest();

        CaseTriggerHandler thisCaseTriggerHandler = new CaseTriggerHandler();
        System.assertNotEquals(null, thisCaseTriggerHandler);

        Test.stopTest();
    }

    @isTest
    private static void getInstance() {
        CaseTriggerHandler.disableCaseTrigger = true;

        Case thisCase = TestUtilities.getCase();
        insert thisCase;

        List<Case> cases = new List<Case>();

        Map<Id, Case> oldCasesMap = new Map<Id, Case>();

        Test.startTest();
        
        CaseTriggerHandler thisCaseTriggerHandler = CaseTriggerHandler.getInstance(null, null);

        System.assertEquals(0, thisCaseTriggerHandler.cases.size());
        System.assertEquals(0, thisCaseTriggerHandler.oldCasesMap.size());

        thisCaseTriggerHandler = CaseTriggerHandler.getInstance(cases, oldCasesMap);

        System.assertEquals(0, thisCaseTriggerHandler.cases.size());
        System.assertEquals(0, thisCaseTriggerHandler.oldCasesMap.size());

        cases.add(thisCase);

        oldCasesMap.put(thisCase.Id, thisCase);

        thisCaseTriggerHandler = CaseTriggerHandler.getInstance(cases, oldCasesMap);

        System.assertEquals(cases.size(), thisCaseTriggerHandler.cases.size());
        System.assertEquals(cases[0], thisCaseTriggerHandler.cases[0]);
        System.assertEquals(oldCasesMap.size(), thisCaseTriggerHandler.oldCasesMap.size());
        System.assertEquals(oldCasesMap.get(thisCase.Id), thisCaseTriggerHandler.oldCasesMap.get(thisCase.Id));
        
        Test.stopTest();
    }

  //  @isTest
    //Private Static Void LoopKillerTest()
   // {
        //Case[] CaseList;
        
    //    Case cas1 = new Case(Status ='Support Outstanding', Priority = '1', Origin = 'Email', Subject='TestCase', SuppliedEmail='Jack@Jack.com');
    //    insert cas1;
        //CaseList.Add(cas1);
     
     //   Case cas2 = new Case(Status ='Support Outstanding', Priority = '1', Origin = 'Email', Subject='TestCase', SuppliedEmail='Jack@Jack.com');
     //   insert cas2;
        
     //   Case cas3 = new Case(Status ='Support Outstanding', Priority = '1', Origin = 'Email', Subject='TestCase', SuppliedEmail='Jack@Jack.com');
     //   insert cas3;
        
     //   Case cas4 = new Case(Status ='Support Outstanding', Priority = '1', Origin = 'Email', Subject='TestCase', SuppliedEmail='Jack@Jack.com');
     //   insert cas4;
        
     //   try{
     //  Case cas5 = new Case(Status ='Support Outstanding', Priority = '1', Origin = 'Email', Subject='TestCase', SuppliedEmail='Jack@Jack.com');
     //   insert cas5;
     //   }
     //   catch(exception e)
     //   {
     //       system.debug('Insert Case failed Due To Validation');
     //   }
     //   System.assertEquals(4, [SELECT count() FROM Case]);
  //  }
   
}