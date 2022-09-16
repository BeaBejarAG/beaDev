global class csFreshServiceIntegration {

//Notes to Future me, or someoneelse who looks at this.
//the "Source" in FS is mapped via a number guessing based on entered values? currently 1008 is the "Support Product" item.
//The Values are controled by the flow for any hardcoded items like source.

 @InvocableMethod(label='Create FS Ticket')
  global static List<ConvertLeadActionResult> convertLeads(List<FSIntRequest> requests) {
    List<ConvertLeadActionResult> results = new List<ConvertLeadActionResult>();
    for (FSIntRequest request : requests) {
      results.add(convertLead(request));
    }
    return results;
  }

 public static ConvertLeadActionResult convertLead(FSIntRequest request) {
 string description = JSON.serialize(request.description); //from flow
 string subject = request.subject; //from flow
 string CustomerName = request.CustomerName; //customer_name_if_known
 string RelatedProduct = request.RelatedProduct; //access_product
 string CaseNumber = request.CaseNumber; //servicecloud_ticket_ref_if_known
 string UserEmail = request.UserEmail; //User using the flow
 integer urgency = request.urgency; // 1 - 4 comes from Flow
 integer source = request.source; //1008 = Product Support
 integer status = request.status; //2 = open
 string hostedclient = request.hostedclient; //Should always be yes
 string category = request.category; //Service Management (for testing)
 string SubCategory = request.SubCategory; //Service Management (for testing)
 string Item = request.Item; //Service Management (for testing)
 id CaseId = request.caseId;
     
 string hreqbody = '{ "description": '+description+', "group_id": 26000036043, "subject": "'+subject+'", "category": "'+category+'", "sub_category": "'+SubCategory+'", "item_category": "'+Item+'", "urgency":'+urgency+', "email": "'+UserEmail+'", "source":'+source+', "status": '+status+', "custom_fields":{"hosted_client":"'+hostedclient+'", "customer_name_if_known":"'+CustomerName+'", "access_product":"'+RelatedProduct+'", "servicecloud_case_id":"'+CaseId+'", "servicecloud_ticket_ref_if_known":"'+CaseNumber+'"}}';
 String myBase64String = EncodingUtil.base64Encode(Blob.valueof('36gbS5skksnYRxrZKTj:cake'));
system.debug(hreqbody);
//BHhLKBqufW3SdWmHwar
//QkhoTEtCcXVmVzNTZFdtSHdhcjpjYWtl
//https://theaccessgroup.freshservice.com/ Live
        Http http = new Http();
        HttpRequest hrequest = new HttpRequest();
        hrequest.setEndpoint('https://theaccessgroup.freshservice.com/api/v2/tickets');
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
    global string subject;

    @InvocableVariable(required=true)
    global string description;

    @InvocableVariable(required=true)
    global integer urgency;

	@InvocableVariable(required=true)
	global string CustomerName;

	@InvocableVariable(required=true)
	global string RelatedProduct;

	@InvocableVariable(required=true)
	global string CaseNumber;

	@InvocableVariable(required=true)
	global string UserEmail;

    @InvocableVariable(required=true)
    global integer source;

    @InvocableVariable(required=true)
    global integer status;

    @InvocableVariable(required=true)
    global string hostedclient;

    @InvocableVariable(required=true)
    global string category;

    @InvocableVariable(required=true)
    global string SubCategory;

    @InvocableVariable(required=true)
    global string Item;
    
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