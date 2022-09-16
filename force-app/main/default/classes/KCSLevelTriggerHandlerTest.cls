@IsTest
public with sharing class KCSLevelTriggerHandlerTest {
    
    @IsTest Public Static Void KCSPermAssign(){
        
        User newUser = new User();
        newUser = TestUtilities.internaladminuser();
        
        KCSLevelTriggerHandler.RunKCSFlow(newUser.Id,'Ready');
    }
    
}