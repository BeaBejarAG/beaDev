import { LightningElement, wire, api, track } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import { registerListener, unregisterListener, fireEvent } from 'c/pubsub';
import { CurrentPageReference, NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import getCaseComments from '@salesforce/apex/cspCaseHandler.getCaseComments';
import addCaseComment from '@salesforce/apex/cspCaseHandler.addCaseComment';
import getCaseAccess from '@salesforce/apex/cspCaseCollaboratorHandler.isCaseViewable';

export default class Example extends NavigationMixin(LightningElement) {
    @api recordId;
    @api isClosed = false;
    @track caseAccess = false;
    comments = [];
    refreshing = false;

    @wire(CurrentPageReference) pageRef;

    @wire(getRecord, {
        recordId: '$recordId',
        fields: [
            'Case.Id',
            'Case.RecordType.Name',
            'Case.IsClosed', 
            'Case.ContactId',
            'Case.CreatedById'
        ]
    })
    setRecord(result) {
        if (result.error) {
            this.dispatchEvent(new ShowToastEvent({
                title: 'Error loading case',
                message: result.error.body.message,
                variant: 'error'
            }));
            console.log(result.error);
        } else if (result.data) {
            getCaseAccess({caseId: result.data.id, caseContactId: result.data.fields.ContactId.value, caseCreatedById: result.data.fields.CreatedById.value}).then(result => {
                this.caseAccess = result;
            }).catch(e => {
                console.error(e);
                this.caseAccess = false;
            });
            this.isClosed = result.data.fields.IsClosed.value;
            this.recordType = result.data.fields.RecordType.value.fields.Name.value;
        }
    }

    connectedCallback() {
        registerListener('cspCaseClosedEvent', this.getCaseComments, this);
        this.getCaseComments();
    }

    disconnectedCallback() {
        unregisterListener('cspCaseClosedEvent', this.getCaseComments, this);
    }

    getCaseComments() {
        getCaseComments({ caseId: this.recordId })
        .then(result => {
            this.comments = result.map(c => {
                if (c.Solution) {
                    return c;
                }

                const total = c.CreatedBy.Id.split('').map(x => x.charCodeAt(0)).reduce((a, b) => a + b);

                c.CreatedBy.Initial = c.CreatedBy.Name.substring(0, 1);
                c.CreatedBy.AvatarClass = `slds-align-top csp-avatar access-theme-user-cat${total % 28}`;

                const photo = c.CreatorFullPhotoUrl;
                if(photo.includes('/profilephoto/005/F') || photo.includes('default_profile_200_v2')) {
                    c.CreatorFullPhotoUrl = null;
                }
                return c;
            });

            this.refreshing = false;
        })
        .catch(error => {
            this.dispatchEvent(new ShowToastEvent({
                title: 'Error loading case',
                message: error.body ? error.body.message : error.message,
                variant: 'error'
            }));
            this.refreshing = false;
            console.log(error);

        });
    }

    handleAddComment(event) {
        if(!this.commentBody) {
            return this.dispatchEvent(new ShowToastEvent({
                title: 'Error creating comment',
                message: 'Please enter the details of your comment',
                variant: 'error'
            }));
        }
        this.refreshing = true;
        addCaseComment({ caseId: this.recordId, body: this.commentBody })
        .then(result => {
            this.commentBody = '';
            this.getCaseComments();
            fireEvent(this.pageRef, 'cspCaseCommentCreatedEvent', {
                comment: {
                    caseId: this.recordId,
                    body: this.commentBody
                }
            });
        })
        .catch(error => {
            this.dispatchEvent(new ShowToastEvent({
                title: 'Error adding comment',
                message: error.body ? error.body.message : error.message,
                variant: 'error'
            }));
            this.refreshing = false;
            console.log(error);
        });
    }

    handleCreateCase(event) {
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: '/createcase'
            }
        });
    }

    get isProjectCase() {
        return this.recordType === 'Project' || this.recordType === 'Project Manual';
    }

    get isIssueCase() {
        return this.recordType === 'Issues and Actions';
    }

    get commentBody() {
        return this.template.querySelector('.csp-case_comment').value
    }
    set commentBody(value) {
        this.template.querySelector('.csp-case_comment').value = value
    }

    get isFlexPointsRedemptionRecordType() {
        return this.recordType === 'FlexPoints Redemption';
    }
}