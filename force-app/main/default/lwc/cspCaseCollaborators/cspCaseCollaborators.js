import { LightningElement, api, track, wire } from 'lwc';
import { refreshApex } from '@salesforce/apex';

import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import { getRecord } from 'lightning/uiRecordApi';
import GetCaseCollaborators from '@salesforce/apex/cspCaseCollaboratorHandler.getCaseCollaborators';
import AddCaseCollaborator from '@salesforce/apex/cspCaseCollaboratorHandler.addCaseCollaborator';
import RemoveCaseCollaborator from '@salesforce/apex/cspCaseCollaboratorHandler.removeCaseCollaborator';
import ValidateCaseCollaborator from '@salesforce/apex/cspCaseCollaboratorHandler.validateCaseCollaborator';
import CanContactEdit from '@salesforce/apex/cspCaseCollaboratorHandler.canAddCollaborators';
import GetPotentialCollaborators from '@salesforce/apex/cspCaseCollaboratorHandler.getPotentialCollaboratorsByCase';
import { CurrentPageReference } from 'lightning/navigation';
import CASEID_FIELD from '@salesforce/schema/Case.Id';

export default class CspCaseCollaborators extends LightningElement {
    @api recordId;
    @api showNewModal;
    @api canEdit = false;
    @track potentialCollaborators;
    @track potentialCollaboratorsrefresh;
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
            this.collaborators = this.handleResponseData(response.data);
            this.collaboratorsrefresh = response;
            this.error = undefined;
        } else if (response.error) {
            this.error = response.error;
            this.collaboratorsrefresh = response;
            this.collaborators = undefined;
        }
    }

    @wire(GetPotentialCollaborators, { caseId: '$recordId' })
    wiredPotentialCollaborators(response) {
        if (response.data) {
            this.potentialCollaborators = this.handleResponseData(response.data);
            this.potentialCollaboratorsrefresh = response;
            this.error = undefined;
        } else if (response.error) {
            this.error = response.error;
            this.potentialCollaboratorsrefresh = response;
            this.potentialCollaborators = undefined;
        }
    }

    @wire(CanContactEdit, { caseId: '$recordId' })
    wiredAccount(response) {
        if (response.data) {
            this.error = undefined;
            this.canEdit = response.data;
        } else if (response.error) {
            this.error = response.error;
            this.recordrefresh = response;
            this.record = undefined;
        }
    }

    connectedCallback() {
        this.RefreshRecords();
    }

    handleResponseData(response) {
        // Need to remove the wrapper the wire puts on in order to manipulate data
        return JSON.parse(JSON.stringify(response)).map(r => {
            r.photoUrl = r.isPhotoActive ? r.photoUrl : '';
            r.initials = (r.first ? r.first.substring(0, 1).toUpperCase() : '') + (r.last ? r.last.substring(0, 1).toUpperCase() : '');
            const total = r.id.split('').map(x => x.charCodeAt(0)).reduce((a, b) => a + b);
            r.avatar = `slds-float_left slds-m-horizontal_small slds-m-vertical_small csp-portal-member__avatar access-theme-user-cat${total % 28}`;
            return r;
        });
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
                console.log(error);
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

    addCollaborator() {
        this.showNewModal = true;
    }

    createCollaborator(event) {
        this.loading = true;
        AddCaseCollaborator({ contactId: event.target.dataset.name, caseId: this.recordId })
            .then(() => {
                    this.ShowToast('Collaborator Added', 'Contact has been added to the case', 'success');
                    this.RefreshRecords();
            })
            .catch(error => {
                this.ShowToast('Failed', 'Error, please provide this to the Internal Salesforce Team ' + error.meassage, 'error');
                console.log(error);
            })
            .finally(() => {
                this.loading = false;
            });
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
            refreshApex(this.potentialCollaboratorsrefresh);
            refreshApex(this.record);
            refreshApex(this.canEdit);
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

    handleEscape(event) {
        if(event.which !== 27) {
            return;
        }
        this.showNewModal = false;
    }

    @api
    get hasCollaborators() {
        return this.collaborators && this.collaborators.length > 0;
    }
    @api
    get hasPotentialCollaborators() {
        return this.potentialCollaborators && this.potentialCollaborators.length > 0;
    }
}