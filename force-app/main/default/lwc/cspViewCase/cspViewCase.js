import { LightningElement, wire, api, track } from 'lwc';
import { getRecord, updateRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CurrentPageReference, NavigationMixin } from 'lightning/navigation';
import { registerListener, unregisterListener, fireEvent } from 'c/pubsub';
import { refreshApex } from '@salesforce/apex';
import ACCESS_LOGO from '@salesforce/contentAssetUrl/csp_logo_black';

import STATUS_FIELD from '@salesforce/schema/Case.Status';
import ID_FIELD from '@salesforce/schema/Case.Id';
import SOLUTION_CODE_FIELD from '@salesforce/schema/Case.SolutionCode__c';
import SOLUTION_FIELD from '@salesforce/schema/Case.Solution__c';
import CHANNEL_RESOLUTION_FIELD from '@salesforce/schema/Case.Channel_For_Resolution__c'
import SUB_ANALYSIS_FIELD from '@salesforce/schema/Case.SubAnalysis__c';
import CAUSE_FIELD from '@salesforce/schema/Case.Cause__c';

import getCaseAttachments from '@salesforce/apex/cspCaseHandler.getCaseAttachments';
import getCaseArticles from '@salesforce/apex/cspCaseArticleHandler.getCaseArticles';
import getProduct from '@salesforce/apex/cspProductSelection.getProduct';
import addCaseComment from '@salesforce/apex/cspCaseHandler.addCaseComment';
import getCaseAccess from '@salesforce/apex/cspCaseCollaboratorHandler.isCaseViewable';

export default class Example extends NavigationMixin(LightningElement) {
    @api recordId;
    @api headerView = false;
    @api modalView = false;
    @api showClose = false;
    @api showResolve = false;
    @api showClosed = false;
    @api refreshing = false;
    @api disableProductEvent = false;
    @api accountId = '';

    @track caseAccess = false;

    caseObject;
    wiredCase;
    attachments = [];
    attachedArticles = [];
    caseCloseComment;

    hasLoadedArticle = false;
    error;
    articleUrl = '';

    @wire(CurrentPageReference) pageRef;

    @wire(getRecord, {
        recordId: '$recordId',
        fields: [
            'Case.Id',
            'Case.CaseNumber',
            'Case.Subject',
            'Case.Description',
            'Case.Cause__c',
            'Case.CreatedDate',
            'Case.CreatedById',
            'Case.CreatedBy.Name',
            'Case.RecordType.Name',
            'Case.ContactId',
            'Case.Contact.Name',
            'Case.Owner.Name',
            'Case.LastModifiedDate',
            'Case.RelatedProduct__c',
            'Case.SubAnalysis__c',
            'Case.Priority',
            'Case.CaseNumber',
            'Case.Status',
            'Case.Notes__c',
            'Case.Status_Group__c',
            'Case.Type',
            'Case.User_Field_1__c',
            'Case.User_Field_2__c',
            'Case.User_Field_3__c'
        ]
    })
    setRecord(result) {
        this.wiredCase = result;
        this.accountId = window.sessionStorage.getItem('selectedAccountId');

        if (result.error) {
            this.dispatchEvent(new ShowToastEvent({
                title: 'Error loading case',
                message: result.error.body.message,
                variant: 'error'
            }));
            console.log(result.error)
        } else if (result.data) {
            getCaseAccess({caseId: result.data.id, caseContactId: result.data.fields.ContactId.value, caseCreatedById: result.data.fields.CreatedById.value}).then(accessResult => {
                this.caseAccess = accessResult;

                const priority = result.data.fields.Priority.value;
                const priorityMapping = this.impacts.find(i => i.value === priority);
                this.caseObject = {
                    id: result.data.id,
                    createdBy: {
                        id: result.data.fields.CreatedById,
                        name: result.data.fields.CreatedBy.value.fields.Name.value,
                    },
                    contact: {
                        id: result.data.fields.ContactId,
                        name: result.data.fields.Contact.value != null ? result.data.fields.Contact.value.fields.Name.value : '',
                    },
                    owner: {
                        name: result.data.fields.Owner.value.fields.Name.value,
                    },
                    subject: result.data.fields.Subject.value,
                    createdDate: new Date(result.data.fields.CreatedDate.value),
                    subAnalysis: result.data.fields.SubAnalysis__c.value,
                    product: result.data.fields.RelatedProduct__c.value,
                    impact: priorityMapping ? priorityMapping.label : '',
                    caseNumber: result.data.fields.CaseNumber.value,
                    cause: result.data.fields.Cause__c.value,
                    status: result.data.fields.Status.value,
                    statusGroup: result.data.fields.Status_Group__c.value,
                    lastModifiedDate: new Date(result.data.fields.LastModifiedDate.value),
                    type: result.data.fields.Type.value,
                    user1: result.data.fields.User_Field_1__c.value,
                    user2: result.data.fields.User_Field_2__c.value,
                    user3: result.data.fields.User_Field_3__c.value,
                    //projectSummary: result.data.fields.Notes__c.value,
                    recordType: result.data.fields.RecordType.value.fields.Name.value
                };

                if (this.headerView == false) {
                    this.showResolve = false;
                    this.showClosed = false;
                    this.showClose = this.caseObject.status != "Closed" && !this.isProjectCase;

                    this.getCaseAttachments();

                    getCaseArticles({caseId: this.recordId})
                    .then(articles => {
                        this.attachedArticles = articles;
                    }).catch(e => this.dispatchEvent(new ShowToastEvent({
                        title: 'Error loading attached articles',
                        message: e.body ? e.body.message : e.message,
                        variant: 'error'
                    })));

                    if (!this.disableProductEvent) {
                        getProduct({productName: this.caseObject.product, selectedAccId: this.accountId})
                        .then(productMap => {
                            if (productMap && productMap.name) {
                                const product = {
                                    name: productMap.name,
                                    colour: `access-theme-product-bar-cat${productMap.colour || 0}`,
                                    image: productMap.image || ACCESS_LOGO,
                                    id: productMap.id,
                                    enabledForChat: productMap.enabledForChat,
                                    enabledForOnline: productMap.enabledForOnline,
                                    enabledForPhone: productMap.enabledForPhone,
                                    liveChatButton: productMap.liveChatButton,
                                    phoneNumber: productMap.phoneNumber,
                                    successPlan: productMap.successPlan,
                                    successPlanName: productMap.successPlanName,
                                    entitlementId: productMap.entitlementId,
                                    admin: productMap.admin,
                                    enabledForCommunity: productMap.enabledForCommunity,
                                    communityRedirect: productMap.communityRedirect
                                };
                                fireEvent(this.pageRef, 'cspProductSelectionEvent', { product: product });
                            } else {
                                fireEvent(this.pageRef, 'cspProductSelectionEvent', { product: {} });
                            }
                        }).catch(e => this.dispatchEvent(new ShowToastEvent({
                            title: 'Error retrieving product for case',
                            message: e.body ? e.body.message : e.message,
                            variant: 'error'
                        })));
                    }
                }
            }).catch(e => {
                console.error(e);
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Error getting case access permission',
                    message: e.body ? e.body.message : e.message,
                    variant: 'error'
                }));
                this.caseAccess = false;
            });

            fireEvent(this.pageRef, 'cspCaseSelectionEvent', { case: this.caseObject });
        }
    }

    connectedCallback() {
        registerListener('cspCaseCommentCreatedEvent', this.handleUpdateCase, this);
        registerListener('cspAccountSelectionEvent', this.handleAccountSelection, this);
    }

    disconnectedCallback() {
        unregisterListener('cspCaseCommentCreatedEvent', this.handleUpdateCase, this);
        unregisterListener('cspAccountSelectionEvent', this.handleAccountSelection, this);
    }

    handleUpdateCase() {
        refreshApex(this.wiredCase);
    }

    handleAccountSelection(event) {
        if(!event.selectedAccountId) {
            return;
        }

        this.accountId = event.selectedAccountId;
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
    }

    handleShowClose(event) {
        if (this.caseObject.status == 'Resolved') {
            this.showConfirm = true;
        } else {
            this.showResolve = true;
        }
        this.showClose = false;
    }

    handleConfirm(event) {
        // close the case only as it's already marked as resolved
        const fields = {
            [ID_FIELD.fieldApiName]: this.recordId,
            [STATUS_FIELD.fieldApiName]: 'Closed'
        };

        this.refreshing = true;
        updateRecord({
            fields
        })
        .then(account => {
            this.showConfirm = false;
            this.showClose = false;
            this.showClosed = true;
            this.refreshing = false;
        })
        .catch(error => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error closing case',
                    message: error.body ? error.body.message : error.message,
                    variant: 'error',
                }),
            );
            this.refreshing = false;
            console.log(error)
        });
    }

    handleResolve(event) {
        let closeComment = this.template.querySelector(`[data-id="closeComment"]`);
        closeComment.blur();
        if (closeComment.checkValidity()) {
            this.caseCloseComment = event.target.value;
            // Close the case and attach the solution comment
            let fields = {
                [ID_FIELD.fieldApiName]: this.recordId,
                [SOLUTION_FIELD.fieldApiName]: closeComment.value,
                [SOLUTION_CODE_FIELD.fieldApiName]: 'Closed By Customer',
                [STATUS_FIELD.fieldApiName]: 'Closed',
                [CHANNEL_RESOLUTION_FIELD.fieldApiName]: 'Web'
            };
            if (!this.caseObject.cause) {
                fields[CAUSE_FIELD.fieldApiName] = "Unknown Cause";
            }
            if (!this.caseObject.subAnalysis && this.caseObject.product) {
                fields[SUB_ANALYSIS_FIELD.fieldApiName] = "Other";
            }

            this.refreshing = true;
            updateRecord({
                fields
            })
            .then(account => {
                addCaseComment({ caseId: this.recordId, body: 'Closed the case' })
                .then(result => {
                    fireEvent(this.pageRef, 'cspCaseClosedEvent', {
                        case: {
                            caseId: this.recordId
                        }
                    });
                    this.showResolve = false;
                    this.showClose = false;
                    this.showClosed = true;
                    this.refreshing = false;
                })
                .catch(error => {
                    this.dispatchEvent(new ShowToastEvent({
                        title: 'Error creating final case comment',
                        message: error.body ? error.body.message : error.message,
                        variant: 'error'
                    }));
                    this.refreshing = false;
                });
            })
            .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error closing case',
                        message: error.body ? error.body.message : error.message,
                        variant: 'error',
                    }),
                );
                this.refreshing = false;
                console.log(error)
            });
        } else {
            closeComment.focus();
            closeComment.blur();
        }
    }

    get impacts() {
        return [
            { value: '1', label: 'Critical'},
            { value: '2', label: 'Major'},
            { value: '3', label: 'Moderate'},
            { value: '4', label: 'Limited' }
        ];
    }

    handleViewArticle(event) {
        this.articleUrl = event.currentTarget.dataset.url;
        this.hasLoadedArticle = false;
        this.articlePopup.show();
        event.preventDefault();
    }

    /* Intercept article loaded event and hide spinner */
    handleArticleLoaded(event) {
        this.hasLoadedArticle = true;
    }

    /* Detect if escape was pressed and close modal */
    handleEscape(event) {
        if(event.which !== 27) {
            return;
        }
        this.articlePopup.hide();
    }

    handleUploadFinished(event) {
        this.getCaseAttachments();
    }

    getCaseAttachments() {
        getCaseAttachments({caseId: this.recordId})
        .then(attachments => {
            this.attachments = attachments;
        }).catch(e => this.dispatchEvent(new ShowToastEvent({
            title: 'Error loading attachments',
            message: e.body ? e.body.message : e.message,
            variant: 'error'
        })));
    }

    get isCaseClosed() {
        return this.caseObject.status === "Closed";
    }

    get isProjectCase() {
        const recordType = this.caseObject.recordType;

        return recordType === 'Project' || recordType === 'Project Manual';
    }

    get isIssueCase() {
        const recordType = this.caseObject.recordType;

        return recordType === 'Issues and Actions';
    }

    get articlePopup() {
        return this.template.querySelector('[data-id="article-popup"]');
    }
}