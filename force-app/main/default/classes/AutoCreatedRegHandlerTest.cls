@isTest
public class AutoCreatedRegHandlerTest {
    @IsTest
    static void AutoRegHandlerTest1(){

        AutocreatedRegHandler1518107744368 ACRH = new AutocreatedRegHandler1518107744368();

        Auth.UserData sampleData = new Auth.UserData('testId', 'testFirst', 'testLast',
                                                     'testFirst testLast', 'testuse8888r@example.org', null, 'testuse8888r@example.org', 'en_US', 'facebook',
                                                     null, new Map<String, String>{'language' => 'en_US'});
        Test.startTest();
        ACRH.canCreateUser(sampleData);
        ACRH.createUser(null,sampleData);
        ACRH.updateUser(null,null,sampleData);
        Test.stopTest();
        
    }
    @IsTest
    static void AutoRegHandlerTest2(){

        AutocreatedRegHandler1519386784383 ACRH2 = new AutocreatedRegHandler1519386784383();

        Auth.UserData sampleData = new Auth.UserData('testId', 'testFirst', 'testLast',
                                                     'testFirst testLast', 'testuse8888r@example.org', null, 'testuse8888r@example.org', 'en_US', 'facebook',
                                                     null, new Map<String, String>{'language' => 'en_US'});
        Test.startTest();
        ACRH2.canCreateUser(sampleData);
        ACRH2.createUser(null,sampleData);
        ACRH2.updateUser(null,null,sampleData);
        Test.stopTest();
        
    }
    
    AutoCreatedRegHandlerTest() {

    }
}