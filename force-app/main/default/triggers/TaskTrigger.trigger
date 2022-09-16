trigger TaskTrigger on Task (before insert) {
    
    //Copies the content of the description into the appropriate fields
    if(trigger.isBefore && trigger.isInsert){
        TaskTriggerHandler.processTaskDescription(trigger.new);
    }
    
    
}