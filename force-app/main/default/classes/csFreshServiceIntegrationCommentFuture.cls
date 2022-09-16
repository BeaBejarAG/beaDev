global class csFreshServiceIntegrationCommentFuture {

 @future(callout=true) 
 public static void CreateNote(string ticketId, string body) {
 integer ticketidint = Integer.valueOf(ticketid.replace(',', ''));
 string endpoint = 'https://theaccessgroup.freshservice.com/api/v2/tickets/'+ticketidint+'/notes';
 string hreqbody = '{ "body":"'+body+'", "private":false, "user_id":26002171577 }';
 String myBase64String = EncodingUtil.base64Encode(Blob.valueof('36gbS5skksnYRxrZKTj:cake'));
system.debug(hreqbody);
//BHhLKBqufW3SdWmHwar
//NkpvMm1uZzFodExqOGYxbDJuUXU6Y2FrZQ==
//26002171577 FSInt
        Http http = new Http();
        HttpRequest hrequest = new HttpRequest();
        hrequest.setEndpoint(endpoint);
        hrequest.setMethod('POST');
        hrequest.setHeader('Content-Type', 'application/json');
		hrequest.setHeader('Authorization', 'basic '+ myBase64String);
     hrequest.setBody(hreqbody);
        HttpResponse response = http.send(hrequest);
        // Parse the JSON response
        if (response.getStatusCode() != 201) {
            System.debug('The status code returned was not expected: ' +
                response.getStatusCode() + ' ' + response.getStatus());
        } else {
            System.debug(response.getBody());
        }
    	
    //check the response
    if (response.getStatusCode() == 201 && response.getStatus() == 'Created') {
ConvertLeadActionResult result = new ConvertLeadActionResult();
    Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
   Map<String,Object> dataMap = (Map<String,Object>)results.get('ticket');
   result.ticketid = (integer)dataMap.get('id');

             
     result.FSTicket = response.getBody();
     //return result;
    
    } else {
      System.debug('Callout failed: ' + response);
        
       // return null;
    }


  }

global class FSIntRequest {
    @InvocableVariable
    global string ticketId;

    @InvocableVariable
    global ID caseId;

	}

  global class ConvertLeadActionResult {
    @InvocableVariable
    global string FSTicket;

    @InvocableVariable
    global integer ticketId;

  }
}