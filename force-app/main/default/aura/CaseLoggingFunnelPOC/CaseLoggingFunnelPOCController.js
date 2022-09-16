({
 doInit: function(cmp) {

 //Get and set current user ID (NYI)
 var userId = $A.get("$SObjectType.CurrentUser.Id");
cmp.set("v.userID", userId);
     
//Hide any Divs we dont want to display     
$A.util.addClass(cmp.find("defaultlogcase"), "slds-hide");
$A.util.addClass(cmp.find("PPLogCase"), "slds-hide");
$A.util.addClass(cmp.find("CaseCreated"), "slds-hide");
$A.util.addClass(cmp.find("PreChatCase"), "slds-hide");
$A.util.addClass(cmp.find("ACCLogCase"), "slds-hide");
$A.util.addClass(cmp.find("ACCPreChatCase"), "slds-hide");
$A.util.addClass(cmp.find("ACPPreChatCase"), "slds-hide");
$A.util.addClass(cmp.find("ProPreChatCase"), "slds-hide"); 
$A.util.addClass(cmp.find("TQPreChatCase"), "slds-hide");
 $A.util.addClass(cmp.find("CACPreChatCase"), "slds-hide");
$A.util.addClass(cmp.find("AMMPreChatCase"), "slds-hide");
$A.util.addClass(cmp.find("WRLogCase"), "slds-hide");     
$A.util.addClass(cmp.find("MSLogCase"), "slds-hide");       
     
     
     //Try populate Subbie Mapping
     var Subbie = cmp.get("c.getDependentMap");
        Subbie.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                cmp.set('v.DynamicList', response.getReturnValue());

            }
            else if (state === "ERROR") {
                alert('Error : ' + JSON.stringify(errors));
            }
        });
        $A.enqueueAction(Subbie);
     
 //Pull through any entitlements as we need to display these to the user    
 var action = cmp.get("c.MyEntitlements");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {

                cmp.set('v.myObject', response.getReturnValue());

  cmp.set("v.IsSpinner",false);
            }
            else if (state === "ERROR") {
                alert('Error : ' + JSON.stringify(errors));
            }
        });
        $A.enqueueAction(action);

    
    
     var GetEmail = cmp.get("c.ContactEmail");
        GetEmail.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                cmp.set('v.ContactEmail', response.getReturnValue());


            }
            else if (state === "ERROR") {
                alert('Error : ' + JSON.stringify(errors));
            }
        });
        $A.enqueueAction(GetEmail);

     
          var GetContactID = cmp.get("c.ContactId");
        GetContactID.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                cmp.set('v.LCContactID', response.getReturnValue());



            }
            else if (state === "ERROR") {
                alert('Error : ' + JSON.stringify(errors));
            }
        });
        $A.enqueueAction(GetContactID);

    }
    
,
    CaseScreen: function(cmp,event){
        var selectedprd = cmp.get("v.Product");
        
        switch(selectedprd)
        {
            case "Access People Planner":
        $A.util.removeClass(cmp.find("PPLogCase"), "slds-hide");
        $A.util.addClass(cmp.find("PreChatCase"), "slds-hide"); 
                    break;
                    
            case "Access Care Compliance":
        $A.util.removeClass(cmp.find("ACCLogCase"), "slds-hide");
        $A.util.addClass(cmp.find("ACCPreChatCase"), "slds-hide"); 
                    break;
                
                    case "Access Care Planning":
        $A.util.removeClass(cmp.find("defaultlogcase"), "slds-hide");
        $A.util.addClass(cmp.find("ACPPreChatCase"), "slds-hide"); 
                    break;
                
                   case "Access Profile":
        $A.util.removeClass(cmp.find("defaultlogcase"), "slds-hide");
        $A.util.addClass(cmp.find("ProPreChatCase"), "slds-hide"); 
                    break;                   
                 case "thankQ":
        $A.util.removeClass(cmp.find("defaultlogcase"), "slds-hide");
        $A.util.addClass(cmp.find("TQPreChatCase"), "slds-hide"); 
                    break;
                                                 case "Access Care & Clinical":
        $A.util.removeClass(cmp.find("defaultlogcase"), "slds-hide");
        $A.util.addClass(cmp.find("CACPreChatCase"), "slds-hide"); 
                    break;
                
                        case "Access Medication Management":
        $A.util.removeClass(cmp.find("defaultlogcase"), "slds-hide");
        $A.util.addClass(cmp.find("AMMPreChatCase"), "slds-hide"); 
                    break;
        }

    }
,
//When a product is picked set the product and Entitlement ID so we can pull this through to the case
 handleClick: function(cmp,event,helper){

     var selectedPrd = event.getSource().get("v.label"); 
     var selectedEnt = event.getSource().get("v.value");
     var selectedPlanType = event.getSource().get("v.name"); 
     $A.util.addClass(cmp.find("pickproduct"), "slds-hide");
     cmp.set('v.Product', selectedPrd);
     cmp.set('v.EntID', selectedEnt);
 helper.GetFilterdProdcuts(cmp, selectedPrd);
//This allows us to provide different experiances per product, meaning we can show different information     
     switch(selectedPrd)
     {
                          //Access Medication Management
         case "Access Medication Management":       
        $A.util.removeClass(cmp.find("AMMPreChatCase"), "slds-hide");
             
        var accchatbutt = cmp.find('ammLC');
        var livechat = cmp.get('v.LiveChatAllowed'); 
             var LiveChatText = cmp.get('v.PPLiveChatText')
    
             if(selectedPlanType === "Essential")
             {
             accchatbutt.set('v.disabled',true);
             accchatbutt.set('v.title',"Sorry, Live Chat is not available on your current support plan"); 
             livechat = false;
             }
             else if(selectedPlanType === "Classic")
             {
             accchatbutt.set('v.disabled',true);
             accchatbutt.set('v.title',"Sorry, Live Chat is not available on your current support plan");
             cmp.set("v.PPLiveChatText","If you need immediate help, Live Chat is now available from our Community. If you’d prefer to log your case via our wizard, you can continue to do so. Just select Create Case below.");
             livechat = false;
             }
             else
             {
                 cmp.set("v.PPLiveChatText","If you need immediate help, Live Chat is now available from our Community. If you’d prefer to log your case via our wizard, you can continue to do so. Just select Create Case below.");
                   livechat= true;
             }
             cmp.set('v.LiveChatAllowed', livechat);
         break;
                          //Access Care And Clinical
         case "Access Care & Clinical":       
        $A.util.removeClass(cmp.find("CACPreChatCase"), "slds-hide");
             
        var accchatbutt = cmp.find('cacLC');
        var livechat = cmp.get('v.LiveChatAllowed'); 
             var LiveChatText = cmp.get('v.PPLiveChatText')
    
             if(selectedPlanType === "Essential")
             {
             accchatbutt.set('v.disabled',true);
             accchatbutt.set('v.title',"Sorry, Live Chat is not available on your current support plan"); 
             livechat = false;
             }
             else if(selectedPlanType === "Classic")
             {
             accchatbutt.set('v.disabled',true);
             accchatbutt.set('v.title',"Sorry, Live Chat is not available on your current support plan");
             cmp.set("v.PPLiveChatText","If you need immediate help, Live Chat is now available from our Community. If you’d prefer to log your case via our wizard, you can continue to do so. Just select Create Case below.");
             livechat = false;
             }
             else
             {
                 cmp.set("v.PPLiveChatText","If you need immediate help, Live Chat is now available from our Community. If you’d prefer to log your case via our wizard, you can continue to do so. Just select Create Case below.");
                   livechat= true;
             }
             cmp.set('v.LiveChatAllowed', livechat);
         break;
             
       ///Webroster
        case "Webroster":       
        $A.util.removeClass(cmp.find("WRLogCase"), "slds-hide");            
         break;
             
                          
             //Mintsoft
           case "MintSoft":       
        $A.util.removeClass(cmp.find("MSLogCase"), "slds-hide");
         break;
             
         case "Access People Planner":  
            
        $A.util.removeClass(cmp.find("PreChatCase"), "slds-hide");
             
        var ppchatbutt = cmp.find('ppLC');
        var livechat = cmp.get('v.LiveChatAllowed'); 
             var LiveChatText = cmp.get('v.PPLiveChatText')
    
             if(selectedPlanType === "Essential")
             {
             ppchatbutt.set('v.disabled',true);
             ppchatbutt.set('v.title',"Sorry, Live Chat is not available on your current support plan"); 
             livechat = false;
             }
             else if(selectedPlanType === "Classic")
             {
             ppchatbutt.set('v.disabled',true);
             ppchatbutt.set('v.title',"Sorry, Live Chat is not available on your current support plan");
             cmp.set("v.PPLiveChatText","The Access People Planner Live Chat Pilot has now ended");
             livechat = false;
             }
             else
             {
                   livechat= true;
             }
             cmp.set('v.LiveChatAllowed', livechat);
         break;
           // ThankQ Live Chat
           // 
           case "thankQ":  
            
        $A.util.removeClass(cmp.find("TQPreChatCase"), "slds-hide");
             
        var ppchatbutt = cmp.find('tqLC');
        var livechat = cmp.get('v.LiveChatAllowed'); 
             var LiveChatText = cmp.get('v.PPLiveChatText')
    
             if(selectedPlanType === "Essential")
             {
             ppchatbutt.set('v.disabled',true);
             ppchatbutt.set('v.title',"Sorry, Live Chat is not available on your current support plan"); 
             livechat = false;
             }
             else if(selectedPlanType === "Classic")
             {
             ppchatbutt.set('v.disabled',true);
             ppchatbutt.set('v.title',"Sorry, Live Chat is not available on your current support plan");
             
             livechat = false;
             }
             else
             {
            cmp.set("v.PPLiveChatText","If you need immediate help, Live Chat is now available from our Community. If you’d prefer to log your case via our wizard, you can continue to do so. Just select Create Case below.");

                   livechat= true;
             }
             cmp.set('v.LiveChatAllowed', livechat);
         break;  
          //Access Care Compliance Product Live Chat   
          //
          //
          //
          //
        case "Access Care Compliance":       
        $A.util.removeClass(cmp.find("ACCPreChatCase"), "slds-hide");
             
        var accchatbutt = cmp.find('acLC');
        var livechat = cmp.get('v.LiveChatAllowed'); 
             var LiveChatText = cmp.get('v.PPLiveChatText')
    
             if(selectedPlanType === "Essential")
             {
             accchatbutt.set('v.disabled',true);
             accchatbutt.set('v.title',"Sorry, Live Chat is not available on your current support plan"); 
             livechat = false;
             }
             else if(selectedPlanType === "Classic")
             {
             accchatbutt.set('v.disabled',true);
             accchatbutt.set('v.title',"Sorry, Live Chat is not available on your current support plan");
             cmp.set("v.PPLiveChatText","If you need immediate help, Live Chat is now available from our Community. If you’d prefer to log your case via our wizard, you can continue to do so. Just select Create Case below.");
             livechat = false;
             }
             else
             {
                 cmp.set("v.PPLiveChatText","If you need immediate help, Live Chat is now available from our Community. If you’d prefer to log your case via our wizard, you can continue to do so. Just select Create Case below.");
                   livechat= true;
             }
             cmp.set('v.LiveChatAllowed', livechat);
         break;
             //Access Care Planning
         case "Access Care Planning":       
        $A.util.removeClass(cmp.find("ACPPreChatCase"), "slds-hide");
             
        var accchatbutt = cmp.find('acpLC');
        var livechat = cmp.get('v.LiveChatAllowed'); 
             var LiveChatText = cmp.get('v.PPLiveChatText')
    
             if(selectedPlanType === "Essential")
             {
             accchatbutt.set('v.disabled',true);
             accchatbutt.set('v.title',"Sorry, Live Chat is not available on your current support plan"); 
             livechat = false;
             }
             else if(selectedPlanType === "Classic")
             {
             accchatbutt.set('v.disabled',true);
             accchatbutt.set('v.title',"Sorry, Live Chat is not available on your current support plan");
             cmp.set("v.PPLiveChatText","If you need immediate help, Live Chat is now available from our Community. If you’d prefer to log your case via our wizard, you can continue to do so. Just select Create Case below.");
             livechat = false;
             }
             else
             {
                 cmp.set("v.PPLiveChatText","If you need immediate help, Live Chat is now available from our Community. If you’d prefer to log your case via our wizard, you can continue to do so. Just select Create Case below.");
                   livechat= true;
             }
             cmp.set('v.LiveChatAllowed', livechat);
         break;
             
             //Profile
             case "Access Profile":       
        $A.util.removeClass(cmp.find("ProPreChatCase"), "slds-hide");
             
        var accchatbutt = cmp.find('propLC');
        var livechat = cmp.get('v.LiveChatAllowed'); 
             var LiveChatText = cmp.get('v.PPLiveChatText')
    
             if(selectedPlanType === "Essential")
             {
             accchatbutt.set('v.disabled',true);
             accchatbutt.set('v.title',"Sorry, Live Chat is not available on your current support plan"); 
             livechat = false;
             }
             else if(selectedPlanType === "Classic")
             {
             accchatbutt.set('v.disabled',true);
             accchatbutt.set('v.title',"Sorry, Live Chat is not available on your current support plan");
             cmp.set("v.PPLiveChatText","If you need immediate help, Live Chat is now available from our Community. If you’d prefer to log your case via our wizard, you can continue to do so. Just select Create Case below.");
             livechat = false;
             }
             else
             {
                 cmp.set("v.PPLiveChatText","If you need immediate help, Live Chat is now available from our Community. If you’d prefer to log your case via our wizard, you can continue to do so. Just select Create Case below.");
                   livechat= true;
             }
             cmp.set('v.LiveChatAllowed', livechat);
         break;
             
         default: 
         $A.util.removeClass(cmp.find("defaultlogcase"), "slds-hide");
         break;
     }
     

    },


    //This fires off the earch on the Useful Articles
    itemsChange : function(cmp, event, helper) {   

        var appEvent = $A.get("e.selfService:caseCreateFieldChange");
        appEvent.setParams({
            "modifiedField": "Subject",
            "modifiedFieldValue": event.getSource().get("v.value")
        });

        appEvent.fire();
    },
    //Ronseal
    handleUploadFinished: function (cmp, event) {

        var uploadedFiles = event.getParam("files");

        cmp.set("v.UpFiles",uploadedFiles );

    },
    
    startLiveChat: function (cmp, event){
                //var recordId = component.get("v.recordId");
                 var url = 'https://access-support.force.com/Support/LiveChat';
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": url
        });
        urlEvent.fire();
    },
    //Creates the case, checks for field population validation
    
    submitCase: function (cmp, event){
      //Disable button to stop double logging
        event.getSource().set("v.disabled",true);
        //show loading spinner?
        cmp.set("v.IsSpinner",true);
      
     if(event.getSource().get("v.value") == 'default')
     {
     cmp.find("CaseSubject").showHelpMessageIfInvalid();
     cmp.find("CaseDesc").showHelpMessageIfInvalid();
        var cDesc = cmp.find("CaseDesc");
        var cSubject = cmp.find("CaseSubject");
        var fSubject = cmp.find("CaseSubject").get('v.value');
        var fDesc = cmp.find("CaseDesc").get('v.value');
        var fPrio = cmp.find("CasePrio").get('v.value');
        var fEntId = cmp.get('v.EntID');
        if(typeof(fPrio) == 'undefined')
        {          
            fPrio = '3';
        }

        var fProduct = cmp.get("v.Product");
        
        
        if(cSubject.reportValidity() && cDesc.reportValidity() )
        {

            var action = cmp.get("c.CreateNewCase");
               
            action.setParams({"subject" : fSubject,
                              "description" : fDesc,
                              "priority" : fPrio,
                              "product" : fProduct,
                              "entid" : fEntId});
            
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {

                $A.util.addClass(cmp.find("defaultlogcase"), "slds-hide");
$A.util.addClass(cmp.find("PPLogCase"), "slds-hide");
$A.util.removeClass(cmp.find("CaseCreated"), "slds-hide");
    cmp.set("v.IsSpinner",false);
            cmp.set('v.caseOut', response.getReturnValue());
        var createdcase = cmp.get("v.caseOut");
  
        if(createdcase.Id != 'undefined')
        {
            var docids = [];
            var changeFiles = cmp.get("v.UpFiles");
            changeFiles.forEach(record => docids.push(record.documentId));
            var linkfile = cmp.get("c.LinkFilesToDoc");
            linkfile.setParams({"casenumber" : createdcase.Id,
                              "docid" : docids
                               });
        linkfile.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
            }
            else if (state === "ERROR") {
                var actionerror = response.getError();
                alert('Error : ' + JSON.stringify(actionerror));
            }
        });
        $A.enqueueAction(linkfile);
           
        }

            }
            else if (state === "ERROR") {
                var actionerror = response.getError();
                alert('Error : ' + JSON.stringify(actionerror));
            }
        });
        $A.enqueueAction(action);
        }
     }
        
                //Mintsoft Case Do Work
         else if(event.getSource().get("v.value") == 'MScase'){

            cmp.find("MSCaseSubject").showHelpMessageIfInvalid();
            cmp.find("MSCaseDesc").showHelpMessageIfInvalid();
            cmp.find("MSModTab").showHelpMessageIfInvalid();

        var cDesc = cmp.find("MSCaseDesc");
        var cSubject = cmp.find("MSCaseSubject");
        var cModTab = cmp.find("MSModTab");

         
        var fModTab = cmp.find("MSModTab").get('v.value');
        var fSubject = cmp.find("MSCaseSubject").get('v.value');
        var fDesc = cmp.find("MSCaseDesc").get('v.value');
        var fPrio = cmp.find("MSCasePrio").get('v.value');  
        var fEntId = cmp.get('v.EntID');

         
        if(typeof(fPrio) == 'undefined')
        {          
            fPrio = '3';
        }
        var fProduct = cmp.get("v.Product");


        if(cSubject.reportValidity() && cDesc.reportValidity() &&  cModTab.reportValidity() )
        {

            var action = cmp.get("c.CreateNewCase");
               
            action.setParams({"subject" : fSubject,
                              "description" : fDesc,
                              "priority" : fPrio,
                              "product" : fProduct,
                              "entid" : fEntId});

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                $A.util.addClass(cmp.find("defaultlogcase"), "slds-hide");
$A.util.addClass(cmp.find("MSLogCase"), "slds-hide");
$A.util.addClass(cmp.find("ACCLogCase"), "slds-hide");
$A.util.removeClass(cmp.find("CaseCreated"), "slds-hide");
             cmp.set("v.IsSpinner",false);
            cmp.set('v.caseOut', response.getReturnValue());
        var createdcase = cmp.get("v.caseOut");
  
        if(createdcase.Id != 'undefined')
        {
            var docids = [];

            var changeFiles = cmp.get("v.UpFiles");

            changeFiles.forEach(record =>docids.push(record.documentId));

            var linkfile = cmp.get("c.LinkFilesToDoc");

            linkfile.setParams({"casenumber" : createdcase.Id,
                              "docid" : docids
                               });

        linkfile.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {

            }
            else if (state === "ERROR") {
                var actionerror = response.getError();
                alert('Error : ' + JSON.stringify(actionerror));
            }
        });
        $A.enqueueAction(linkfile);
           
        }

            }
            else if (state === "ERROR") {
                var actionerror = response.getError();
                alert('Error : ' + JSON.stringify(actionerror));
            }
        });
        $A.enqueueAction(action);
        }
Alert("Not Valid");
        }
          //Webroster 
     else if(event.getSource().get("v.value") == 'wrcase'){

            cmp.find("wrCaseSubject").showHelpMessageIfInvalid();
            cmp.find("wrCaseDesc").showHelpMessageIfInvalid();
            cmp.find("wrMod").showHelpMessageIfInvalid();

        var cDesc = cmp.find("wrCaseDesc");
        var cSubject = cmp.find("wrCaseSubject");
        var cModTab = cmp.find("wrMod");

         
        var fModTab = cmp.find("wrMod").get('v.value');
        var fSubject = cmp.find("wrCaseSubject").get('v.value');
        var fDesc = cmp.find("wrCaseDesc").get('v.value');
        var fPrio = cmp.find("wrCasePrio").get('v.value');
        var fsub = cmp.find("wrMod").get('v.value');
        var fEntId = cmp.get('v.EntID');

         
        if(typeof(fPrio) == 'undefined')
        {          
            fPrio = '3';
        }
        var fProduct = cmp.get("v.Product");

        if(cSubject.reportValidity() && cDesc.reportValidity() && cModTab.reportValidity() )
        {

            var action = cmp.get("c.CreateNewCase");
               
            action.setParams({"subject" : fSubject,
                              "description" : fDesc,
                              "priority" : fPrio,
                              "product" : fProduct,
                              "Subbie" : fsub,
                              "entid" : fEntId});

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                $A.util.addClass(cmp.find("defaultlogcase"), "slds-hide");
$A.util.addClass(cmp.find("PPLogCase"), "slds-hide");
$A.util.addClass(cmp.find("WRLogCase"), "slds-hide");
$A.util.removeClass(cmp.find("CaseCreated"), "slds-hide");
             cmp.set("v.IsSpinner",false);
            cmp.set('v.caseOut', response.getReturnValue());
        var createdcase = cmp.get("v.caseOut");
  
        if(createdcase.Id != 'undefined')
        {
            var docids = [];

            var changeFiles = cmp.get("v.UpFiles");

            changeFiles.forEach(record =>docids.push(record.documentId));

            var linkfile = cmp.get("c.LinkFilesToDoc");

            linkfile.setParams({"casenumber" : createdcase.Id,
                              "docid" : docids
                               });

        linkfile.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {

            }
            else if (state === "ERROR") {
                var actionerror = response.getError();
                alert('Error : ' + JSON.stringify(actionerror));
            }
        });
        $A.enqueueAction(linkfile);
           
        }

            }
            else if (state === "ERROR") {
                var actionerror = response.getError();
                alert('Error : ' + JSON.stringify(actionerror));
            }
        });
        $A.enqueueAction(action);
        }
Alert("Not Valid");
        }
             //If this is a Care Compliance case DO WORK!   
     else if(event.getSource().get("v.value") == 'acccase'){

            cmp.find("accCaseSubject").showHelpMessageIfInvalid();
            cmp.find("accCaseDesc").showHelpMessageIfInvalid();
            cmp.find("accHomeAff").showHelpMessageIfInvalid();
            cmp.find("accMod").showHelpMessageIfInvalid();

        var cDesc = cmp.find("accCaseDesc");
        var cSubject = cmp.find("accCaseSubject");
        var cCid = cmp.find("accHomeAff");
        var cModTab = cmp.find("accMod");

         
        var fModTab = cmp.find("accMod").get('v.value');
        var fCid = cmp.find("accHomeAff").get('v.value'); 
        var fSubject = cmp.find("accCaseSubject").get('v.value');
        var fDesc = cmp.find("accCaseDesc").get('v.value');
        var fPrio = cmp.find("accCasePrio").get('v.value');
        var fsub = cmp.find("accMod").get('v.value');
        var fEntId = cmp.get('v.EntID');

         
        if(typeof(fPrio) == 'undefined')
        {          
            fPrio = '3';
        }
        var fProduct = cmp.get("v.Product");

        var fCombinedDescPP = "Home/User Affected: " + fCid + "\n" + "Issue Description: " + fDesc;

        if(cSubject.reportValidity() && cDesc.reportValidity() && cCid.reportValidity() && cModTab.reportValidity() )
        {

            var action = cmp.get("c.CreateNewCase");
               
            action.setParams({"subject" : fSubject,
                              "description" : fCombinedDescPP,
                              "priority" : fPrio,
                              "product" : fProduct,
                              "Subbie" : fsub,
                              "entid" : fEntId});

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                $A.util.addClass(cmp.find("defaultlogcase"), "slds-hide");
$A.util.addClass(cmp.find("PPLogCase"), "slds-hide");
$A.util.addClass(cmp.find("ACCLogCase"), "slds-hide");
$A.util.removeClass(cmp.find("CaseCreated"), "slds-hide");
             cmp.set("v.IsSpinner",false);
            cmp.set('v.caseOut', response.getReturnValue());
        var createdcase = cmp.get("v.caseOut");
  
        if(createdcase.Id != 'undefined')
        {
            var docids = [];

            var changeFiles = cmp.get("v.UpFiles");

            changeFiles.forEach(record =>docids.push(record.documentId));

            var linkfile = cmp.get("c.LinkFilesToDoc");

            linkfile.setParams({"casenumber" : createdcase.Id,
                              "docid" : docids
                               });

        linkfile.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {

            }
            else if (state === "ERROR") {
                var actionerror = response.getError();
                alert('Error : ' + JSON.stringify(actionerror));
            }
        });
        $A.enqueueAction(linkfile);
           
        }

            }
            else if (state === "ERROR") {
                var actionerror = response.getError();
                alert('Error : ' + JSON.stringify(actionerror));
            }
        });
        $A.enqueueAction(action);
        }
Alert("Not Valid");
        }
     //If this is a People Planner case DO WORK!   
     else if(event.getSource().get("v.value") == 'ppcase'){
            cmp.find("ppCaseSubject").showHelpMessageIfInvalid();
            cmp.find("ppCaseDesc").showHelpMessageIfInvalid();
            cmp.find("ppClientId").showHelpMessageIfInvalid();
            cmp.find("ppModTab").showHelpMessageIfInvalid();
            
        var cDesc = cmp.find("ppCaseDesc");
        var cSubject = cmp.find("ppCaseSubject");
        var cCid = cmp.find("ppClientId");
        var cModTab = cmp.find("ppModTab");
        
        var fModTab = cmp.find("ppModTab").get('v.value');
        var fCid = cmp.find("ppClientId").get('v.value'); 
        var fSubject = cmp.find("ppCaseSubject").get('v.value');
        var fDesc = cmp.find("ppCaseDesc").get('v.value');
        var fPrio = cmp.find("ppCasePrio").get('v.value');
        var fModTab = cmp.find("ppModTab").get('v.value');
        var fEntId = cmp.get('v.EntID');
        if(typeof(fPrio) == 'undefined')
        {          
            fPrio = '3';
        }

        var fProduct = cmp.get("v.Product");
        
        var fCombinedDescPP = "Client ID: " + fCid + "\n" + "Issue Description: " + fDesc;
        
        if(cSubject.reportValidity() && cDesc.reportValidity() && cCid.reportValidity() && cModTab.reportValidity() && fModTab != 'inProgress' )
        {
        
            var action = cmp.get("c.CreateNewCase");
               
            action.setParams({"subject" : fSubject,
                              "description" : fCombinedDescPP,
                              "priority" : fPrio,
                              "product" : fProduct,
                              "Subbie" : fModTab,
                              "entid" : fEntId});
            
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                $A.util.addClass(cmp.find("defaultlogcase"), "slds-hide");
$A.util.addClass(cmp.find("PPLogCase"), "slds-hide");
$A.util.removeClass(cmp.find("CaseCreated"), "slds-hide");
             cmp.set("v.IsSpinner",false);
            cmp.set('v.caseOut', response.getReturnValue());
        var createdcase = cmp.get("v.caseOut");
  
        if(createdcase.Id != 'undefined')
        {
            var docids = [];

            var changeFiles = cmp.get("v.UpFiles");

            changeFiles.forEach(record =>docids.push(record.documentId));

            var linkfile = cmp.get("c.LinkFilesToDoc");

            linkfile.setParams({"casenumber" : createdcase.Id,
                              "docid" : docids
                               });

        linkfile.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {

            }
            else if (state === "ERROR") {
                var actionerror = response.getError();
                alert('Error : ' + JSON.stringify(actionerror));
            }
        });
        $A.enqueueAction(linkfile);
           
        }

            }
            else if (state === "ERROR") {
                var actionerror = response.getError();
                alert('Error : ' + JSON.stringify(actionerror));
            }
        });
        $A.enqueueAction(action);
        }

        }

          cmp.set("v.IsSpinner",false);
        
    },
    removefile: function(cmp,event){
    var listedfiles = cmp.get("v.UpFiles");
    var selectedfile = event.getSource().get("v.value");
        listedfiles.splice(listedfiles.indexOf(selectedfile), 1);
        
        
        //Start remove from SFDC as file is attached to contact
         var action = cmp.get("c.FilesToRemove");
        action.setParams({"docid" : selectedfile
                               });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
cmp.set("v.UpFiles", listedfiles);

            }
            else if (state === "ERROR") {
                alert('Error : ' + JSON.stringify(errors));
            }
        });
        $A.enqueueAction(action);
alert('Finished Remove');
}
})