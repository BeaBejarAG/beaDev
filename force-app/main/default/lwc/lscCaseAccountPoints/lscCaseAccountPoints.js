import { LightningElement, api, wire, track } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class LscCaseAccountPoints extends LightningElement {
    @api recordId = '';
    @track accountId = '';
    
    @wire(getRecord, {
        recordId: '$recordId',
        fields: [
            'Case.Account__c'
        ]
    })
    setRecord({error, data}) {
        if (error) {
            this.errorCallback(error.body);
        } else if (data) {
            this.accountId = data.fields.Account__c.value;
        }
    }

    get showPointsComponent() {
        return (this.accountId != null && this.accountId != '');
    }

    /* Log any errors */
    errorCallback(error, stack) {
        console.error(error.message, error.stack);
        this.dispatchEvent(new ShowToastEvent({
            message: error.message,
            variant: 'error'
        }));
    }
}