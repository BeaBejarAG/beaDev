global class csFreshServiceIntegrationGetTicket {

//Notes to Future me, or someoneelse who looks at this.
//the "Source" in FS is mapped via a number guessing based on entered values? currently 1008 is the "Support Product" item.
//The Values are controled by the flow for any hardcoded items like source.

 @InvocableMethod(label='Get FS Ticket')
  global static List<ConvertLeadActionResult> convertLeads(List<FSIntRequest> requests) {
    List<ConvertLeadActionResult> results = new List<ConvertLeadActionResult>();
    for (FSIntRequest request : requests) {
      results.add(convertLead(request));
    }
    return results;
  }

 public static ConvertLeadActionResult convertLead(FSIntRequest request) {
 string ticketId = request.ticketId; //from flow
 integer ticketidint = Integer.valueOf(ticketid.replace(',', ''));
 string RID = '';
 string AID = '';
 //string hreqbody = '{ "description": "'+description+'", "group_id": 26000036043, "subject": "'+subject+'", "category": "'+category+'", "urgency":'+urgency+', "email": "'+UserEmail+'", "source":'+source+', "status": '+status+', "custom_fields":{"hosted_client":"'+hostedclient+'", "customer_name_if_known":"'+CustomerName+'", "access_product":"'+RelatedProduct+'", "servicecloud_ticket_ref_if_known":"'+CaseNumber+'"}}';
 String myBase64String = EncodingUtil.base64Encode(Blob.valueof('36gbS5skksnYRxrZKTj:cake'));

//BHhLKBqufW3SdWmHwar
//QkhoTEtCcXVmVzNTZFdtSHdhcjpjYWtl
        Http http = new Http();
        HttpRequest hrequest = new HttpRequest();
        hrequest.setEndpoint('https://theaccessgroup.freshservice.com/api/v2/tickets/'+ticketidint);
        hrequest.setMethod('GET');
        hrequest.setHeader('Content-Type', 'application/json');
		hrequest.setHeader('Authorization', 'basic '+ myBase64String);
    // hrequest.setBody(hreqbody);
        HttpResponse response = http.send(hrequest);
        // Parse the JSON response
        if (response.getStatusCode() == 404)
        {
 System.debug('Ticket Not Found: ' +
                response.getStatusCode() + ' ' + response.getStatus());
ConvertLeadActionResult errorresult = new ConvertLeadActionResult();
errorresult.error = 'Invalid Ticket ID';
            return errorresult;
}
       else if (response.getStatusCode() != 201) {
            System.debug('The status code returned was not expected: ' +
                response.getStatusCode() + ' ' + response.getStatus());
        } else {
            System.debug(response.getBody());
        }
    	RID = response.getStatus();
    //check the response
    if (response.getStatusCode() == 200 && response.getStatus() == 'OK') {
   ConvertLeadActionResult result = new ConvertLeadActionResult();
   Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
   Map<String,Object> dataMap = (Map<String,Object>)results.get('ticket');
   result.ticketid = (integer)dataMap.get('id');
   Long responderid = (Long)dataMap.get('responder_id');
   integer Statusnum = (integer)dataMap.get('status');
   string createdatstr = (string)dataMap.get('created_at');
   string updatedatstr = (string)dataMap.get('updated_at');

    Map<String, Object> customfields = (Map<String, Object>)dataMap.get('custom_fields');

   result.resolution = (string)customfields.get('resolution');
  result.ServiceCloudCase = (string)customfields.get('servicecloud_ticket_ref_if_known');
        
        system.debug(responderid);

             
     result.FSTicket = response.getBody();

  switch on Statusnum {
    when 2 {
	result.status = 'Open';
    }	
    when 3 {		
    result.status = 'Pending';
    }
    when 4 {		
    result.status = 'Resolved';
    }
    when 5 {		
    result.status = 'Closed';
    }
    when else {		  
        result.status = '';
    }
}

        if(createdatstr != ''){
			String testDateString = createdatstr.replace('T',' ');
			testDateString = testDateString.replace('Z',' ');
			//testDateString = testDateString.replace('-','/');
			DateTime testDate = DateTime.valueOf(testDateString);
			result.createdat = testDate;
			//System.debug('xxx'+convertedDate);
            //result.createdat = DateTime.parse(createdatstr);
        }    
        if(updatedatstr != ''){
			String testDateString = updatedatstr.replace('T',' ');
			testDateString = testDateString.replace('Z',' ');
			//testDateString = testDateString.replace('-','/');
			DateTime testDate = DateTime.valueOf(testDateString);
			result.updatedat = testDate;
        }
        if(responderid != null){
            system.debug('Inside Responder Id');
        Http httprid = new Http();
        HttpRequest hrequestrid = new HttpRequest();
        hrequestrid.setEndpoint('https://theaccessgroup.freshservice.com/api/v2/agents/'+responderid);
        hrequestrid.setMethod('GET');
        hrequestrid.setHeader('Content-Type', 'application/json');
		hrequestrid.setHeader('Authorization', 'basic '+ myBase64String);
    // hrequest.setBody(hreqbody);
        HttpResponse responserid = httprid.send(hrequestrid);
        // Parse the JSON response
        if (responserid.getStatusCode() != 201) {
            System.debug('The status code returned was not expected: ' +
                responserid.getStatusCode() + ' ' + responserid.getStatus());
        } else {
            System.debug(responserid.getBody());
        }
 Map<String, Object> resultsrid = (Map<String, Object>) JSON.deserializeUntyped(responserid.getBody());
   Map<String,Object> dataMaprid = (Map<String,Object>)resultsrid.get('agent');
               result.ResponderEmail = (string)dataMaprid.get('email');
   AID = responserid.getStatus();         
        }
        
            system.debug(RID + ' ' + AID);
        if(RID == 'OK'){
            Http httprid = new Http();
        HttpRequest hrequestrid = new HttpRequest();
        hrequestrid.setEndpoint('https://theaccessgroup.freshservice.com/api/v2/tickets/'+ticketidint);
        hrequestrid.setMethod('PUT');
        hrequestrid.setHeader('Content-Type', 'application/json');
		hrequestrid.setHeader('Authorization', 'basic '+ myBase64String);
        hrequestrid.setBody('{"custom_fields":{"servicecloud_case_id":"'+request.CaseId+'", "servicecloud_ticket_ref_if_known":"'+request.CaseNumber+'"}}');
        HttpResponse responserid = httprid.send(hrequestrid);
        // Parse the JSON response
        if (responserid.getStatusCode() != 201) {
            System.debug('The status code returned was not expected: ' +
                responserid.getStatusCode() + ' ' + responserid.getStatus());
        } else {
            System.debug(responserid.getBody());
        }
System.debug(responserid.getBody());
        }



     return result;
    
    } else {
      System.debug('Callout failed: ' + response);
    ConvertLeadActionResult result = new ConvertLeadActionResult();
    Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());



             
     result.FSTicket = response.getBody();
     return result;
    }


  }

global class FSIntRequest {
    @InvocableVariable(required=true)
    global string ticketId;

    @InvocableVariable(required=true)
    global Id CaseId;

    @InvocableVariable(required=true)
    global string CaseNumber;

	}

  global class ConvertLeadActionResult {
    @InvocableVariable
    global string FSTicket;

    @InvocableVariable
	global string error;

    @InvocableVariable
    global integer ticketId;

    @InvocableVariable
    global Long responderid;

    @InvocableVariable
    global string Status;

    @InvocableVariable
    global datetime createdat;

    @InvocableVariable
    global string resolution;

    @InvocableVariable
    global datetime updatedat;

    @InvocableVariable
    global string ServiceCloudCase;

    @InvocableVariable
    global string ResponderEmail;


  }

}