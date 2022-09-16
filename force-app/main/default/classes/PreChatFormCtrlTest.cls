@isTest(SeeAllData=false)
public class PreChatFormCtrlTest {
    
    static testmethod void testOne(){
        
        Contact newContact = new Contact();
        newContact.FirstName = 'FirstNameTest';
        newContact.LastName = 'LastNameTest';
        newContact.email = 'test@mail.com';
        insert newContact;
        PreChatFormCtrl newPreChat = new PreChatFormCtrl();
        newPreChat.email = 'test@mail.com';
        PreChatFormCtrl.getEmail('test@mail.com');
    }
    static testmethod void testtwo(){
        
        PreChatFormCtrl.getEmail('test9999@email.com');
    }
}