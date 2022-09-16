import { LightningElement, wire, api } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CurrentPageReference, NavigationMixin } from 'lightning/navigation';
import { fireEvent } from 'c/pubsub';
import getCaseAttachments from '@salesforce/apex/cspCaseHandler.getCaseAttachments';
import getFlexPoints from '@salesforce/apex/cspContactsHandler.getFlexPoints';
import createQuoteApprovalTransaction from '@salesforce/apex/cspFlexPointsHandler.createQuoteApprovalTransaction';
import updateCase from '@salesforce/apex/cspFlexPointsHandler.updateCase';
import rejectCase from '@salesforce/apex/cspFlexPointsHandler.rejectCase';
import { refreshApex } from '@salesforce/apex';

export default class CspViewFlexPointsCase extends NavigationMixin(LightningElement) {
    @api caseId;
    @api showRejectButton = false;
    isLoading = false;
    flexPointsCase;
    attachments = [];
    isProcessing = false;
    remainingPoints = 0;
    accountId = '';
    wiredflexPointsCase;

    @wire(CurrentPageReference) pageRef;

    @wire(getRecord, {
        recordId: '$caseId',
        fields: [
            'Case.Id',
            'Case.CaseNumber',
            'Case.Description',
            'Case.CreatedDate',
            'Case.RecordType.Name',
            'Case.RelatedProduct__c',
            'Case.Owner.Name',
            'Case.Journey_Stage__c',
            'Case.Delivered_By__c',
            'Case.Location__c',
            'Case.Service_Description__c',
            'Case.Service_Outcomes__c',
            'Case.Service_Prerequisites__c',
            'Case.Service_Title__c',
            'Case.Service_Type__c',
            'Case.User_Level__c',
            'Case.Contact.Name',
            'Case.LastModifiedDate',
            'Case.Points_Estimate__c',
            'Case.Account__c',
            'Case.Points_Value__c'
        ]
    })
    setRecord(result) {
        this.isLoading = true;
        this.wiredflexPointsCase = result;

        if (result.error) {
            this.dispatchEvent(new ShowToastEvent({
                title: 'Error loading case',
                message: result.error.body.message,
                variant: 'error'
            }));

            this.isLoading = false;
        } else if (result.data) {
            this.flexPointsCase = {
                owner: result.data.fields.Owner.value.fields.Name.value,
                createdDate: new Date(result.data.fields.CreatedDate.value),
                product: result.data.fields.RelatedProduct__c.value,
                caseNumber: result.data.fields.CaseNumber.value,
                recordType: result.data.fields.RecordType.value.fields.Name.value,
                journeyStage: result.data.fields.Journey_Stage__c.value,
                location: result.data.fields.Location__c.value,
                serviceDesc: result.data.fields.Service_Description__c.value,
                serviceOutcomes: result.data.fields.Service_Outcomes__c.value,
                servicePrerequisites: result.data.fields.Service_Prerequisites__c.value,
                serviceTitle: result.data.fields.Service_Title__c.value,
                serviceType: result.data.fields.Service_Type__c.value != null ? result.data.fields.Service_Type__c.value.replaceAll(';', ', ') : '',
                userLevel: result.data.fields.User_Level__c.value,
                contactName: result.data.fields.Contact.value != null ? result.data.fields.Contact.value.fields.Name.value : '',
                pointsEstimate: result.data.fields.Points_Estimate__c.value,
                accountId: result.data.fields.Account__c.value,
                ownerId: result.data.fields.Owner.value.id,
                pointsValue: result.data.fields.Points_Value__c.value
            };
            this.getCaseAttachments();
            this.isLoading = false;
        }
    }

    constructor() {
        super();
        this.accountId = window.sessionStorage.getItem('selectedAccountId');
        this.handleGetFlexPoints();
    }

    getCaseAttachments() {
        getCaseAttachments({ caseId: this.caseId })
        .then(attachments => {
            this.attachments = attachments;
        }).catch(e => this.dispatchEvent(new ShowToastEvent({
            title: 'Error loading attachments',
            message: e.body ? e.body.message : e.message,
            variant: 'error'
        })));
    }

    handleGetFlexPoints() {
        getFlexPoints({selectedAccountId: this.accountId})
        .then(response => {
            this.remainingPoints = response.availablePoints;
        })
    }

    handleViewAttachment(event) {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                pageName: 'filePreview',
                recordId: event.target.value,
                objectApiName: 'ContentVersion',
                actionName: 'view'
            },
            state: {
                selectedRecordId: event.target.value
            }
        })
    };

    handleUploadFinished(event) {
        this.getCaseAttachments();
    }

    async handleQuoteApproval(event) {
        try {
            this.isProcessing = true;

            await createQuoteApprovalTransaction({
                accountId: this.flexPointsCase.accountId,
                points: this.flexPointsCase.pointsEstimate,
                owner: this.flexPointsCase.ownerId,
                caseId: this.caseId
            });

            await updateCase({
                caseId: this.caseId,
                points: this.flexPointsCase.pointsEstimate
            });

            refreshApex(this.wiredflexPointsCase);

            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'Quote approved',
                    variant: 'success',
                }),
            );

            fireEvent(this.pageRef, 'cspServiceAppiledForEvent', { });
        } catch(error) {
            console.log(console.error(error))
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error whilst approving quote',
                    message: error.body ? error.body.message : error.message,
                    variant: 'error',
                }),
            );
        } finally {
            const quoteApproval = new CustomEvent('quoteapproval');
            this.dispatchEvent(quoteApproval);
            this.isProcessing = false;
        };
    }

    async handleQuoteReject(event) {
        try {
            this.isProcessing = true;

            await rejectCase({
                caseId: this.caseId,
            });

            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'Quote rejected',
                    variant: 'success',
                }),
            );
        } catch (error) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error whilst rejecting quote',
                    message: error.body ? error.body.message : error.message,
                    variant: 'error',
                }),
            );
        } finally {
            const quoteReject = new CustomEvent('quotereject');
            this.dispatchEvent(quoteReject);
            this.isProcessing = false;
        }
    }

    get approveQuote() {
        return this.flexPointsCase.pointsEstimate && !this.flexPointsCase.pointsValue;
    }

    get getPointsValue() {
        return this.approveQuote ? this.flexPointsCase.pointsEstimate : this.flexPointsCase.pointsValue;
    }

    get pendingQuote() {
        return !this.flexPointsCase.pointsEstimate && !this.flexPointsCase.pointsValue;
    }

    get handleDisableSubmit() {
        return !(this.flexPointsCase.pointsEstimate <= this.remainingPoints);
    }
}