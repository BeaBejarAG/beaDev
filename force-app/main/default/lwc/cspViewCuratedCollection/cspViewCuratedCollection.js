import { LightningElement, wire, api } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CurrentPageReference, NavigationMixin } from 'lightning/navigation';

export default class CspViewCuratedCollection extends NavigationMixin(LightningElement) {
    @api recordId;
    @api titleView;
    collectionObject;
    wiredCollection;

    @wire(CurrentPageReference) pageRef;

    @wire(getRecord, {
        recordId: '$recordId',
        fields: [
            'Curated_Collection__c.Name',
            'Curated_Collection__c.Description__c',
            'Curated_Collection__c.Utility_Icon__c'
        ]
    })
    setRecord(result) {
        this.wiredCollection = result;

        if (result.error) {
            this.dispatchEvent(new ShowToastEvent({
                title: 'Error loading case',
                message: result.error.body.message,
                variant: 'error'
            }));
        } else if (result.data) {
            this.collectionObject = {
                title: result.data.fields.Name.value,
                description: result.data.fields.Description__c.value,
                icon: 'utility:' + result.data.fields.Utility_Icon__c.value,
            };
        }
    }
}