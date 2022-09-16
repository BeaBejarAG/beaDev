/**
 * @description       : Extension Class for OrderSummary
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : PolSource
 * @last modified on  : 11-19-2021
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 **/
public with sharing class OpportunityExtension {
    private static final List<String> ADDITIONAL_FIELDS = new List<String>{'SOW_Description__c'
                                                                    , 'Competitor_Product_Lost_To__c'
                                                                    , 'Competitior_Lost_To__c'
                                                                    , 'Close_Reason__c'
                                                                    , 'CPQ_Opportunity_Deal_Type__c'
                                                                    , 'SBQQ__PrimaryQuote__r.SBQQ__StartDate__c'
                                                                    , 'SBQQ__PrimaryQuote__r.SBQQ__PaymentTerms__c'
                                                                    , 'SBQQ__PrimaryQuote__r.SBQQ__SubscriptionTerm__c'};

    private static final String MISSING_DATA_ERROR_MESSAGE = 'Please ensure that all fields from the sections \'Summary of Contract\' and \'Summary of Why We Won\' are populated.';

    private static final String UNEXPECTED_EXCEPTION_ERROR_MESSAGE = 'We encountered a problem. Contact your administrator';
    private id recId;

    public Opportunity currentOpp{
        get;
        set;
    }

    public Date primaryQuoteStartDate {
        get;
        set;
    }

    /**
     * ctor
     */
    public OpportunityExtension(ApexPages.StandardController stdController) {
        recId = stdController.getId();
        if (!Test.isRunningTest()) 
        stdController.addFields(ADDITIONAL_FIELDS);
        currentOpp = (Opportunity)stdController.getRecord();

        primaryQuoteStartDate = currentOpp.SBQQ__PrimaryQuote__r.SBQQ__StartDate__c;
    }

    /**
     * @description : On clicking submit, will hand over to sales (CPQ_Sales_Handover_Status__c = 'Completed') the opportunity
     * @return : void
     */
    public PageReference submit() {
        
        if(checkMissingData(currentOpp)){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, MISSING_DATA_ERROR_MESSAGE));
            return null;
        }

        try {
            //update Primary Quote Start date, only if it was changed by the user
            if(primaryQuoteStartDate != currentOpp.SBQQ__PrimaryQuote__r.SBQQ__StartDate__c){
                Id primQtId = currentOpp.SBQQ__PrimaryQuote__c;
                SBQQ__Quote__c qt = [select Id, SBQQ__StartDate__c from SBQQ__Quote__c where id =: primQtId];
                qt.SBQQ__StartDate__c = primaryQuoteStartDate;
                update qt;
            }

            currentOpp.CPQ_Sales_Handover_Status__c = 'Completed';
            update currentOpp;

        } catch (DmlException ex) {
            system.debug('Exception from OpportunityExtension >>> ' + ex);
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, UNEXPECTED_EXCEPTION_ERROR_MESSAGE));
            return null;
        }

        PageReference redirectPage = new PageReference('/' + recId);
        redirectPage.setRedirect(true);
        return redirectPage;
    }

    //
    //Checks for required data in order to proceed with the Submit
    //
    private Boolean checkMissingData(Opportunity currentOpp){
        Boolean missingData = false;

        if(currentOpp.Total_ABC__c == null || currentOpp.Total_Services__c == null || currentOpp.Total_SAAS__c == null ||
        currentOpp.Total_Variable__c == null ||
        currentOpp.SBQQ__PrimaryQuote__r.SBQQ__PaymentTerms__c == null ||
        currentOpp.SBQQ__PrimaryQuote__r.SBQQ__SubscriptionTerm__c == null ||
        primaryQuoteStartDate == null ||
        currentOpp.Close_Reason__c == null){
            missingData = true;
        }

        if((currentOpp.CPQ_Opportunity_Deal_Type__c == 'new logo' || currentOpp.CPQ_Opportunity_Deal_Type__c == 'cross sell')
            && (currentOpp.Competitior_Lost_To__c == null || currentOpp.Competitor_Product_Lost_To__c == null)){
            missingData = true;
        }

        return missingData;
    }
}