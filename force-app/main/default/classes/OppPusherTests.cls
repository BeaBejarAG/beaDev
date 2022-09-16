@isTest
private class OppPusherTests {
//* private static sObject[] OpptyList; 
 //private static List<Opportunity> testOpptys = new List<Opportunity>();

   // static testMethod void myOppUnitTest() {
        // TO DO: implement unit test
        // create an oppty
     //   Opportunity oTestOppty=createOppty('testOppty');
        // change the month pushcount+1
       // oTestOppty.CloseDate=date.newinstance(2015,12,11);
        //Opportunity oTestUpdateOppty=[select Id from Opportunities where Id=oTestOppty.Id]
        //update oTestOppty;
        //Opportunity oReadOppty=[select Id,PushCount__c from Opportunity where id=:oTestOppty.Id];
        //System.debug(oReadOppty.PushCount__c);
        //System.assert(oReadOppty.PushCount__c==1);
        // make it later this month, no change
        //oTestOppty.CloseDate=date.newinstance(2015,12,31);
        //update oTestOppty;
        //oReadOppty=[select Id,PushCount__c from Opportunity where id=:oTestOppty.Id];
        //System.debug(oReadOppty.PushCount__c);
        //System.assert(oReadOppty.PushCount__c==1);
        // make it next year, but an earlier month, pushcount+1
        //oTestOppty.CloseDate=date.newInstance(2016, 1,1);
        //update oTestOppty;
        //oReadOppty=[select Id,PushCount__c from Opportunity where id=:oTestOppty.Id];
        //S/ystem.debug(oReadOppty.PushCount__c);
        //System.assertEquals(oReadOppty.PushCount__c, 2);
        // don't change the date, no change
        //oTestOppty.CloseDate=date.newInstance(2016,1,1);
        //update oTestOppty;
       //oReadOppty=[select Id,PushCount__c from Opportunity where id=:oTestOppty.Id];
        //System.debug(oReadOppty.PushCount__c);
        //System.assertEquals(oReadOppty.PushCount__c,2);
        
        // test bulk update
        //integer i;
        //for(i=1;i<199;i++){
            
       // }
        
        //clean up
        //cleanOpptys();
    //}
    
    //private static Opportunity createOppty(String sOppName) {
      //  Opportunity oNewOpp= new Opportunity(name= sOppName,closedate= date.newinstance(2015,11,11),stagename='Prospecting');
    //  List<Opportunity> testLocalOpptys = new List<Opportunity>();
    //  testLocalOpptys=(List<Opportunity>)OpptyList;
    //  testLocalOpptys.add(oNewOpp);
    //  OpptyList=testLocalOpptys;
    //insert oNewOpp;
      //  testOpptys.add(oNewOpp);
        //return oNewOpp;
    //}
    
    
   // private static void cleanOpptys() {
     //   for(Opportunity oIterator : testOpptys) {
       //     delete oIterator;
            
      //  }
        //testOpptys.clear();
    //}
    
  
}