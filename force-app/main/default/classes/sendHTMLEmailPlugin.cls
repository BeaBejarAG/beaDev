/********************************************************************
 * HTML Email Plugin for flow
 * Created Date: 3/1/2015
 * Created By: Jeremiah Dohn
 * Description: Use this plugin to send HTML templates from flow.
 * Input types: 
 * 				targetObjId - 
 * 					Optional - must equal contact, lead or user, this
 *             				   should be set as it will avoid hitting the apex send email limit
 *				HTML Body -
 *					Required - HTML email text
 *
 *    			Subject - 
 * 					Required - Email subject
 * 		
 * 				Other Emails -
 * 					Optional - send emails to other emails outside of your org
 * 								IMPORTANT: This can allow you to hit the 1k Emails from your org by apex
 * 				
 * 				senderAddress -
 * 					Optional - change the sender address for the email, otherwise defaults to current user
 * 
 * 				Priority -
 * 					Optional - set email priority
 * 								Values: Highest, High, Normal, Low, Lowest
 * 
 * 
 * 			Revised 3/29/15: 
 * 				Bcc & CC addresses are now able to be entered in the plugin
 * 
 * 				Sender Display name can now be set
 * 
 * 			Revised 10/7/2015:
 * 				Use orgWideEmailAddress added
 *******************************************************************/

global without sharing class sendHTMLEmailPlugin implements process.Plugin {
   
    global Process.PluginResult invoke(Process.PluginRequest request){
        
        Map<String,String> result = new Map<String,String>();
        
        String targetObjId = (String) request.inputParameters.get('Target Object Id');
        String htmlBody = (String) request.inputParameters.get('htmlBody');
        String subject = (String) request.inputParameters.get('Subject');
        String otherEmails = (String) request.inputParameters.get('Other Emails (comma-separated)');
        String senderAddress = (String) request.inputParameters.get('Sender Address');
        String priority = (String) request.inputParameters.get('Priority');
        String saveAsActivity = (String) request.inputParameters.get('Save As Activity');
        String senderDisplay = (String) request.inputParameters.get('Sender Display Name');
        String ccEmail = (String) request.inputParameters.get('CC Email Addresses (comma-separated)');
        String bccEmail = (String) request.inputParameters.get('BCC Email Addresses (comma-separated)');
        String orgWide = (String) request.inputParameters.get('OrgWideEmailAddress');
        
        Integer emailCount = 0;
        
        if(targetObjId != null) emailCount++;
        if(ccEmail != null){
            String[] ccEmailsArray = ccEmail.split(',');
            for(String s : ccEmailsArray){
                emailCount++;
            }
        }
        if(bccEmail != null) {
            String[] bccEmailsArray = bccEmail.split(',');
            for(String s : bccEmailsArray){
                emailCount++;
            }
        }
        
        system.debug('Email count : ' + emailCount);
        Messaging.reserveSingleEmailCapacity(emailCount);
        
        Messaging.SingleEmailMessage message = new  Messaging.SingleEmailMessage();
        
        if(htmlBody != null && subject != null && (targetObjId != null || otherEmails != null || bccEmail != null || ccEmail != null)){
            // Set HTML body, subject and who the email should go to
            message.setHtmlBody(htmlBody);
            message.setSubject(subject);
            
            // Set the target object Id
            if(targetObjId != null){
                message.setTargetObjectId(targetObjId);
            }
            

            // Set other emails
            if(otherEmails != null){
                String[] otherEmailsArray = otherEmails.split(',');
                message.setToAddresses(otherEmailsArray);
            }
		
			// Set Priority            
            if(priority!= null && (priority == 'Highest' || priority =='High' || priority =='Low' || priority == 'Lowest')){
                message.setEmailPriority(priority);
            }
            
            // Save as activity?
            if(saveAsActivity != null && saveAsActivity.toLowerCase() == 'true'  && targetObjId != null){
                message.setSaveAsActivity(true);
            } else {
                message.setSaveAsActivity(false);
            }
            
            // Set sender address
            if(senderAddress != null){
                message.setReplyTo(senderAddress);
            }
		
            if(orgWide != null){
                Id orgWideEmail = [SELECT Id FROM OrgWideEmailAddress WHERE Address =: orgWide].Id;
                message.SetorgWideEmailAddressId(orgWideEmail);
            }
            
            // Set sender display name
            if(senderDisplay != null){
                message.setSenderDisplayName(senderDisplay);
            }
            
            // Set cc email
            if(ccEmail != null){
                String[] ccEmailsArray = ccEmail.split(',');
                message.setCcAddresses(ccEmailsArray);
            }
            
            // Set bcc email
            if(bccEmail != null){
                String[] bccEmailsArray = bccEmail.split(',');
                message.setBccAddresses(bccEmailsArray);
            }
                
            system.debug('Email invocations before send: ' + Limits.getEmailInvocations());   
            system.debug(message);
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { message });
        }
		
        system.debug('Email invocations after send: ' + Limits.getEmailInvocations());   
        
        return new Process.PluginResult(result); 
       
    }
    
    global process.PluginDescribeResult describe() {
        Process.PluginDescribeResult result = new Process.PluginDescribeResult(); 
        result.Name = 'HTML Email Plugin';
        result.Tag = 'HTML Email Plugin';
        
        // Set description
        result.Description ='This plugin allows for sending HTML emails.';

        // Set input parameters
        result.inputParameters = new List<Process.PluginDescribeResult.InputParameter>();
        result.inputParameters.add(new Process.PluginDescribeResult.inputParameter('Target Object Id', Process.PluginDescribeResult.ParameterType.String, false));
        result.inputParameters.add(new Process.PluginDescribeResult.inputParameter('htmlBody', Process.PluginDescribeResult.ParameterType.String, true));
        result.inputParameters.add(new Process.PluginDescribeResult.inputParameter('Subject', Process.PluginDescribeResult.ParameterType.String, true));
        result.inputParameters.add(new Process.PluginDescribeResult.inputParameter('Other Emails (comma-separated)', Process.PluginDescribeResult.ParameterType.String, false));
        result.inputParameters.add(new Process.PluginDescribeResult.inputParameter('Sender Address', Process.PluginDescribeResult.ParameterType.String, false));
        result.inputParameters.add(new Process.PluginDescribeResult.inputParameter('Priority', Process.PluginDescribeResult.ParameterType.String, false));
        result.inputParameters.add(new Process.PluginDescribeResult.inputParameter('Save As Activity', Process.PluginDescribeResult.ParameterType.String, false));
        result.inputParameters.add(new Process.PluginDescribeResult.inputParameter('Sender Display Name', Process.PluginDescribeResult.ParameterType.String, false));
		result.inputParameters.add(new Process.PluginDescribeResult.inputParameter('CC Email Addresses (comma-separated)', Process.PluginDescribeResult.ParameterType.String, false));
        result.inputParameters.add(new Process.PluginDescribeResult.inputParameter('BCC Email Addresses (comma-separated)', Process.PluginDescribeResult.ParameterType.String, false));
        result.inputParameters.add(new Process.PluginDescribeResult.inputParameter('OrgWideEmailAddress', Process.PluginDescribeResult.ParameterType.String, false));
 
        return result;
        
    }
    
}