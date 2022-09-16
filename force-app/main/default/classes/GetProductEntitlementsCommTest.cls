@IsTest
public class GetProductEntitlementsCommTest {

    @IsTest Public static void MyEntitlements()
    {
        List<ContactEntitlement__c> entitled = GetProductEntitlementsComm.MyEntitlements();

        
    }
    
        @IsTest Public Static Void CheckUser()
        {
             User NewUser = TestUtilities.CreateUserComm();
            boolean commuser = GetProductEntitlementsComm.GetCurrentUser(NewUser.Id);

        }
    
        @IsTest Public Static Void CheckPayroll()
        {
             List<Entitlement> entitled = GetProductEntitlementsComm.MyEntitlementsPayroll();
        }
}