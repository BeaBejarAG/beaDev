public class KCSLevelTriggerHandler {
    
   @future
   public static void RunKCSFlow(id userid, string level)
   {

         Map<String, Object> params1 = new Map<String, Object>();
         params1.put('UserId', userid);
         params1.put('ChosenLevel', level);
         Flow.Interview.Support_KCS_Permission_Set_Assignment calcFlow1 = new Flow.Interview.Support_KCS_Permission_Set_Assignment(params1);
         calcFlow1.start();
   }
    
}