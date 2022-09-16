import { LightningElement, api, track, wire } from 'lwc';
import { refreshApex } from '@salesforce/apex';

import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import { getRecord } from 'lightning/uiRecordApi';
import GetCaseCollaborators from '@salesforce/apex/cspCaseCollaboratorHandler.getCaseCollaborators';
import RemoveCaseCollaborator from '@salesforce/apex/cspCaseCollaboratorHandler.removeCaseCollaborator';
import ValidateCaseCollaborator from '@salesforce/apex/cspCaseCollaboratorHandler.validateCaseCollaborator';
import { CurrentPageReference } from 'lightning/navigation';
import CASEID_FIELD from '@salesforce/schema/Case.Id';

export default class LscContactEntitlementManagement extends NavigationMixin(LightningElement) {
    @api recordId;
    @api showNewModal;
    @track collaborators;
    @track collaboratorsrefresh;
    @track error;
    @track record;
    @track recordrefresh;
    @track loading = false;
    @track caseId;

    @wire(CurrentPageReference)
    pageRef;

    @wire(getRecord, { recordId: '$recordId', fields: [CASEID_FIELD] })
    wiredAccount(response) {
        if (response.data) {
            this.recordrefresh = response;
            this.record = response.data;
            this.error = undefined;
            this.caseId = response.data.id;
        } else if (response.error) {
            this.error = response.error;
            this.recordrefresh = response;
            this.record = undefined;
        }
    }

    @wire(GetCaseCollaborators, { caseId: '$recordId' })
    wiredEnt(response) {
        if (response.data) {
            this.collaborators = response.data;
            this.collaboratorsrefresh = response;
            this.error = undefined;
        } else if (response.error) {
            this.error = response.error;
            this.collaboratorsrefresh = response;
            this.collaborators = undefined;
        }
    }

    RemoveCollaborator(event) {
        this.loading = true;
        RemoveCaseCollaborator({ collaboratorId: event.target.dataset.name })
            .then(() => {
                    this.ShowToast('Contact Removed', 'Contact has been removed from the case', 'success');
                    this.RefreshRecords();
            })
            .catch(error => {
                this.ShowToast('Failed', 'Error, please provide this to the Internal Salesforce Team ' + error.meassage, 'error');
                console.log('Error ' + error);
            })
            .finally(() => {
                this.loading = false;
            });
    }

    navigateToContact(event) {
        var contactId = event.target.dataset.id;
    
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                objectApiName: 'Contact',
                recordId: contactId,
                actionName: 'view'
            }
        });
    }

    createCollaborator(event) {
        const inputFields = this.template.querySelectorAll(
            'lightning-input-field'
        );
        if (inputFields) {
            inputFields.forEach(field => {
                field.reset();
            });
        }
        this.showNewModal = true;
    }

    handleCloseDialog(event){
       this.showNewModal = false;
    }

    handleSubmit(event){
        event.preventDefault();
        const parsedFields = JSON.parse(JSON.stringify((event.detail.fields)));
        const contactId = parsedFields ? parsedFields.Contact__c : '';
        const caseId = parsedFields ? parsedFields.Case__c : '';

        ValidateCaseCollaborator({ contactId: contactId, caseId: caseId })
            .then((data) => {
                if(data) {
                    this.ShowToast('Error Adding Collaborator', data, 'error');
                    this.RefreshRecords();
                } else {
                    const fields = event.detail.fields;
                    this.template.querySelector('lightning-record-edit-form').submit(fields);
                }
            })
            .catch(error => {
                this.ShowToast('Failed', 'Error, please provide this to the Internal Salesforce Team ' + error.meassage, 'error');
                console.log('Error ' + error);
            })
     }
     handleSuccess(event){
        const updatedRecord = event.detail.id;
        this.showNewModal = false;
        this.RefreshRecords();
     }

    RefreshRecords() {
        setTimeout(() => {
            refreshApex(this.recordrefresh);
            refreshApex(this.collaboratorsrefresh);
            refreshApex(this.record);
        }, 1);
    }

    ShowToast(tsttitle, tstmessage, tstvariant) {
        var toastevent = new ShowToastEvent({
            title: tsttitle,
            message: tstmessage,
            variant: tstvariant
        });
        this.dispatchEvent(toastevent);
    }

    get hasCollaborators() {
        return this.collaborators && this.collaborators.length > 0;
    }
}