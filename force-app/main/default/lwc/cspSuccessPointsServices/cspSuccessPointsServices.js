import { LightningElement, api } from 'lwc';

export default class CspSuccessPointsServices extends LightningElement {
    @api service;

    get showQuote() {
        return this.service.Estimate_Required__c;
    }

    get serviceType() {
        return this.service.Service_Type__c.replaceAll(';', ', ');
    }
}