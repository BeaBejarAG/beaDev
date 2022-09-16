public class TaskTriggerHandler {
    
    public static void processTaskDescription(List<Task> lstTasks){
        Id MarketTaskRType = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Marketo Task').getRecordTypeId();
    
        //picklistValues
        List<Schema.PicklistEntry> lstTaskDivisionPicks = Task.Division__c.getDescribe().getPicklistValues();
        List<Schema.PicklistEntry> lstTaskProductInterestPicks = Task.Product_Interest__c.getDescribe().getPicklistValues();
        List<Schema.PicklistEntry> lstTaskReviewingSoftwarePicks = Task.Reviewing_Software__c.getDescribe().getPicklistValues();
        List<Schema.PicklistEntry> lstTaskExistingSoftwarePicks = Task.Existing_Software__c.getDescribe().getPicklistValues();
        List<Schema.PicklistEntry> lstTaskTimeframePicks = Task.TimeFrame__c.getDescribe().getPicklistValues();
        
        for (Task taskNew : lstTasks) {
            //Only for Marketo Tasks
            if(taskNew.RecordTypeId == MarketTaskRType ){
                if(taskNew.Description != null && taskNew.Description != ''){
                    
                    //Choose the substring for split, because the task can be saved both ways.
                    String splitToken = '';
                    if(taskNew.Description.indexOf('\r\n') > -1 && taskNew.Description.indexOf('\r\n') < 50){
                        splitToken = '\r\n';
                    }
                    if(splitToken != '\r\n' && taskNew.Description.indexOf('\n') > -1 && taskNew.Description.indexOf('\n') < 50){
                        splitToken = '\n';
                    }
                    if(splitToken == ''){
                        if (taskNew.Description.startsWith('Campaign ID')){
                            taskNew.addError('Fields missing!');
                        }
                        //Consider that there are nothing to validate
                        break;
                        
                    }
                    
                    //Split the lines by the selected substring and evaluate contents
                    List<String> lines = taskNew.Description.split(splitToken);
                    if(!lines[0].contains('Campaign ID') || !lines[1].contains('Division') || !lines[2].contains('Product') || 
                            !lines[3].contains('Reviewing Software') || !lines[4].contains('Existing Software') || !lines[5].contains('TimeFrame')){
                        taskNew.addError('Fields missing!');      
                        break;  
                    }
                    
                    if(lines != null && !lines.isEmpty()){
                        //campaign ID 
                        String campaignId = lines[0].split(': ')[1].trim();
                        if(campaignId != null && campaignId != ''){
                            Campaign c = null;
                            try{
                                c= [SELECT Id FROM Campaign WHERE Id = :campaignId];
                            } catch (Exception e){
                                taskNew.addError('Campaign not found!');
                                break;
                            }
                            if(c != null){
                                taskNew.Campaign__c = campaignId;                           
                            }else{
                                //taskNew.addError('Campaign not found!');      
                                //break;
                            }
                        }else{
                            taskNew.addError('Campaign not found!');      
                            break;
                        }
                        
                        
                        //Division
                        List<String> lsttaskDivision = lines[1].split(': ');
                        if(lsttaskDivision != null && !lsttaskDivision.isEmpty() && lsttaskDivision.size() == 2){
                            String taskDivision = lsttaskDivision.get(1).trim();
                            if(taskDivision != null && taskDivision != ''){
                                boolean foundValue = false;
                                for(Schema.PicklistEntry value : lstTaskDivisionPicks){
                                    if(value.getValue() == taskDivision){
                                        foundValue = true;
                                        break;
                                    }
                                }
                                if(foundValue){
                                    taskNew.Division__c = taskDivision;
                                }else{
                                    taskNew.addError('Division picklist value not found!');      
                                    break;
                                }
                            }else{
                                taskNew.Division__c = null;
                                break;
                            }
                        }else{
                            taskNew.Division__c = null;
                            break;
                        }
                        
                        //Product Interest
                        List<String> lsttaskProductInterest = lines[2].split(': ');
                        if(lsttaskProductInterest != null && !lsttaskProductInterest.isEmpty() && lsttaskProductInterest.size() == 2){
                            String taskProductInterest = lsttaskProductInterest.get(1).trim();
                            if(taskProductInterest != null && taskProductInterest != ''){
                                boolean foundValue = false;
                                for(Schema.PicklistEntry value : lstTaskProductInterestPicks){
                                    if(value.getValue() == taskProductInterest){
                                        foundValue = true;
                                        break;
                                    }
                                }
                                if(foundValue){
                                    taskNew.Product_Interest__c = taskProductInterest;
                                }else{
                                    taskNew.addError('Product Interest picklist value not found!');      
                                    break;
                                }
                            }else{
                                taskNew.Product_Interest__c = null;
                                break;
                            }
                        }else{
                            taskNew.Product_Interest__c = null;
                            break;
                        }
                        
                        //Reviewing Software (Reviewing_Software__c)
                        List<String> lsttaskReviewingSoftware = lines[3].split(': ');
                        if(lsttaskReviewingSoftware != null && !lsttaskReviewingSoftware.isEmpty() && lsttaskReviewingSoftware.size() == 2){
                            String taskReviewingSoftware = lsttaskReviewingSoftware.get(1).trim();
                            if(taskReviewingSoftware != null && taskReviewingSoftware != ''){
                                boolean foundValue = false;
                                for(Schema.PicklistEntry value : lstTaskReviewingSoftwarePicks){
                                    if(value.getValue() == taskReviewingSoftware){
                                        foundValue = true;
                                        break;
                                    }
                                }
                                if(foundValue){
                                    taskNew.Reviewing_Software__c = taskReviewingSoftware;
                                }else{
                                    taskNew.addError('Reviewing Software picklist value not found!');      
                                    break;
                                }
                            }else{
                                taskNew.Reviewing_Software__c = null;
                                break;
                            }
                        }else{
                            taskNew.Reviewing_Software__c = null;
                            break;
                        }
                    
                        //Existing Software (Existing_Software__c)
                        List<String> lsttaskExistingSoftware = lines[4].split(': ');
                        if(lsttaskExistingSoftware != null && !lsttaskExistingSoftware.isEmpty() && lsttaskExistingSoftware.size() == 2){
                            String taskExistingSoftware = lsttaskExistingSoftware.get(1).trim();
                            if(taskExistingSoftware != null && taskExistingSoftware != ''){
                                boolean foundValue = false;
                                for(Schema.PicklistEntry value : lstTaskExistingSoftwarePicks){
                                    if(value.getValue() == taskExistingSoftware){
                                        foundValue = true;
                                        break;
                                    }
                                }
                                if(foundValue){
                                    taskNew.Existing_Software__c = taskExistingSoftware;
                                }else{
                                    taskNew.addError('Existing Software picklist value not found!');      
                                    break;
                                }
                            }else{
                                taskNew.Existing_Software__c = null;
                                break;
                            }
                        }else{
                            taskNew.Existing_Software__c = null;
                            break;
                        }
                        
                        //Timeframe (TimeFrame__c)
                        List<String> lsttaskTimeframe = lines[5].split(': ');
                        if(lsttaskTimeframe != null && !lsttaskTimeframe.isEmpty() && lsttaskTimeframe.size() == 2){
                            String taskTimeframe = lsttaskTimeframe.get(1).trim();
                            if(taskTimeframe != null && taskTimeframe != ''){
                                boolean foundValue = false;
                                for(Schema.PicklistEntry value : lstTaskTimeframePicks){
                                    if(value.getValue() == taskTimeframe){
                                        foundValue = true;
                                        break;
                                    }
                                }
                                if(foundValue){
                                    taskNew.TimeFrame__c = taskTimeframe;
                                }else{
                                    //taskNew.addError('Timeframe picklist value not found!');      
                                    //break;
                                }
                            }else{
                               taskNew.TimeFrame__c = null;
                                break;
                            }
                        }else{
                            taskNew.TimeFrame__c = null;
                            break;
                        }
                        
                    }
                    
                    /*if(taskNew.WhoId != null && Schema.Contact.SObjectType == taskNew.WhoId.getSobjectType()){
                        taskNew.WhatId = lines[0].split(': ')[1].trim();
                    }*/
                }
            }
        }
        
    }
}