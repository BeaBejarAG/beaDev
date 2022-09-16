@IsTest
public class Assign_PermissionsTest {
    
    @IsTest public static void KCSTest(){

        KCS_Level__c KCS = new KCS_Level__c();
       // KCS.KCS_User__c = newuser.Id;
        KCS.Key_Field__c = 'Ready';
        
        insert KCS;
    }
}