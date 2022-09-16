global class csFreshServiceIntegrationCommentCall {

  @InvocableMethod(label='Create FS Note')
   public static void invokeapexcallout(list<case> casei) {
     csFreshServiceIntegrationCommentFuture.CreateNote(casei[0].Remedyforce_Alto_Incident_Number__c, casei[0].Subject);
   }

global class FSIntRequest {
    @InvocableVariable(required=true)
    global string ticketId;

	}
}