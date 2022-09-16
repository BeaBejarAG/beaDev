({
	// uses the DocuSign javascript to send a document requerst 
	// with automatically populated Signer - Primary Contact of the Quote
	sendDocu : function(component, event, helper) {
		
	var RC='';var RSL='';var RSRO='';var RROS='';var CCRM='';var CCTM='';var CCNM='';var CRCL=''; var CRL='';var OCO='';var DST='';var LA='';var CEM='';var CES='';var STB='';var SSB='';var SES='';var SEM='';var SRS='';var SCS ='';var RES='';

	var sourceId = component.get("v.recordId");

	let primaryContactEmail = component.get("v.QuoteObject").SBQQ__PrimaryContact__r.Email;
	let primaryContactFirstName = component.get("v.QuoteObject").SBQQ__PrimaryContact__r.FirstName;
	let primaryContactLastname = component.get("v.QuoteObject").SBQQ__PrimaryContact__r.LastName;

	let approver1 = 'Email~' + primaryContactEmail + ';FirstName~' + primaryContactFirstName + ';LastName~' + primaryContactLastname + ';Role~Customer;RoutingOrder~1';
	let approver2 = 'Email~' + primaryContactEmail + ';FirstName~' + primaryContactFirstName + ';LastName~' + primaryContactLastname + ';Role~Finance;RoutingOrder~2';
	CRL = approver1 + ',' + approver2;

	//********* Page Callout (Do not modify) *********//
	window.open("/apex/dsfs__DocuSign_CreateEnvelope?DSEID=0&SourceID="+sourceId+"&RC="+RC+"&RSL="+RSL+"&RSRO="+RSRO+"&RROS="+RROS+"&CCRM="+CCRM+"&CCTM="+CCTM+"&CRCL="+CRCL+"&CRL="+CRL+"&OCO="+OCO+"&DST="+DST+"&CCNM="+CCNM+"&LA="+LA+"&CEM="+CEM+"&CES="+CES+"&SRS="+SRS+"&STB="+STB+"&SSB="+SSB+"&SES="+SES+"&SEM="+SEM+"&SRS="+SRS+"&SCS="+SCS+"&RES="+RES, '_blank');
	//window.location.href = ;
	//*******************************************//
	},

	recordUpdated : function(component, event, helper) {
        var changeType = event.getParams().changeType;
        if (changeType === "LOADED") {
        } else if (changeType === "ERROR") {

        } /* also have REMOVED and CHANGED */
        
    }
})