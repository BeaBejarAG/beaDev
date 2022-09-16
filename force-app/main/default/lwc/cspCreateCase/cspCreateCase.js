import { LightningElement, wire, api, track } from 'lwc';
import { NavigationMixin, CurrentPageReference } from 'lightning/navigation';
import { registerListener, unregisterListener, fireEvent } from 'c/pubsub';
import { createRecord, getRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';

import getCaseFeatures from '@salesforce/apex/cspProductFeatures.getCaseFeatures';
import linkFilesToCase from '@salesforce/apex/CaseLogFlow.LinkFilesToDoc';
import getCaseContacts from '@salesforce/apex/cspCaseHandler.getCaseContacts';
import GetServiceAccounts from '@salesforce/apex/cspCaseHandler.GetServiceAccounts';
import getProductList from '@salesforce/apex/cspProductSelection.getProductList';

import AddCaseCollaborators from '@salesforce/apex/cspCaseCollaboratorHandler.addCaseCollaborators';
import GetPotentialCollaborators from '@salesforce/apex/cspCaseCollaboratorHandler.getPotentialCollaborators';

import CASE_OBJECT from '@salesforce/schema/Case';
import IMPACT_FIELD from '@salesforce/schema/Case.Priority';
import STATUS_FIELD from '@salesforce/schema/Case.Status';
import SUBJECT_FIELD from '@salesforce/schema/Case.Subject';
import DESCRIPTION_FIELD from '@salesforce/schema/Case.Description';
import PRODUCT_FIELD from '@salesforce/schema/Case.RelatedProduct__c';
import SUBANALYSIS_FIELD from '@salesforce/schema/Case.SubAnalysis__c';
import RECORDTYPEID_FIELD from '@salesforce/schema/Case.RecordTypeId';
import ORIGIN_FIELD from '@salesforce/schema/Case.Origin';
import SOURCE_FIELD from '@salesforce/schema/Case.Source__c';
import CASE_TYPE_FIELD from '@salesforce/schema/Case.CaseType__c';
import ENTITLEMENT_FIELD from '@salesforce/schema/Case.EntitlementId';
import SERVICEACCOUNT_FIELD from '@salesforce/schema/Case.Service_Account__c';

import USER_ID from '@salesforce/user/Id';
import EMAIL_FIELD from '@salesforce/schema/User.Email';
import CONTACT_ID from '@salesforce/schema/User.ContactId';
import REGION_FIELD from '@salesforce/schema/User.Contact.Region__c';

import PLAN_IMAGE_1 from '@salesforce/contentAssetUrl/csp_case_plan_1';
import PLAN_IMAGE_2 from '@salesforce/contentAssetUrl/csp_case_plan_2';
import PLAN_IMAGE_3 from '@salesforce/contentAssetUrl/csp_case_plan_3';

const AVAILABLE_CHANNELS = 3;

export default class CspCreateCase extends NavigationMixin(LightningElement) {
    showStepProduct = true;
    showStepOne = false;
    showStepTwo = false;
    showStepThree = false;
    showCaseClosed = false;
    hasLoadedArticle = false;
    planImage1 = PLAN_IMAGE_1;
    planImage2 = PLAN_IMAGE_2;
    planImage3 = PLAN_IMAGE_3;
    userId = USER_ID;
    contactId;
    region;
    productRoutingId;
    caseContactNumbers;
    pageRef = {state: {}};
    creatingCase = false;
    articleUrl = '';
    validationMessage = '';
    product = {}; 
    accountId; 
    features = [];
    @api serviceaccounts;
    channels = new Set();
    selectedChannel;
    files = [];
    chatLabel = 'Offline';
    communityRecordType;
    supportRecordType;

    @track collaborators = [];
    @track potentialCollaborators = [];

    @api caseNumber;
    @api superUser = false;
    @api serviceUser = false;
    @api caseId;
    @api showCollabModal = false;

    @api get isCaseContactNumbersRetrieved() {
        return (this.caseContactNumbers && this.caseContactNumbers.length != 0);
    }

    /* Use page reference state to determine step */
    @wire(CurrentPageReference)
    setCurrentPageReference(pageRef) {
        this.pageRef = pageRef;

        /* TODO: Need to use another mechanism not tied to page */
        if(pageRef.attributes.name != 'create_case__c') {
            return;
        }

        this.showStepProduct = false;
        this.showStepOne = false;
        this.showStepTwo = false;
        this.showStepThree = false;
        this.showCaseClosed = false;

        if(!pageRef.state.step || pageRef.state.step == 'product') {
            return this.showStepProduct = true;
        }

        if(pageRef.state.step === '1') {
            return this.showStepOne = true;
        }

        if(!pageRef.state.title) {
            return this.redirectToStep('1');
        }

        if(pageRef.state.step === '2') {
            return this.showStepTwo = true;
        }

        if(!this.caseId) {
            return this.redirectToStep('2');
        }

        if(pageRef.state.step === '3') {
            return this.showStepThree = true;
        }
    }

    /* Load case once created to get case number */
    @wire(getRecord, {
        recordId: '$caseId',
        fields: [
            'Case.CaseNumber',
            'Case.Subject'
        ]
    })
    setRecord({error, data}) {
        if (error) {
            this.errorCallback(error.body);
        } else if (data) {
            this.caseNumber = data.fields.CaseNumber.value;
        }
    }

    @wire(getRecord, {
        recordId: USER_ID,
        fields: [EMAIL_FIELD, CONTACT_ID, REGION_FIELD]
    }) wireuser({
        error,
        data
    }) {
        if (error) {
           console.error(error);
        } else if (data) {
            this.userEmail = data.fields.Email.value;
            this.contactId = data.fields.ContactId.value;
            this.region = data.fields.Contact.value.fields.Region__c.value;
        }
    }

    @wire(getObjectInfo, { objectApiName: CASE_OBJECT })
    setRecordType(result) {
        if(!result.data) {
            return;
        }
        const rtis = result.data.recordTypeInfos;
        this.communityRecordType = Object.keys(rtis).find(rti => rtis[rti].name === 'Community');
        this.supportRecordType = Object.keys(rtis).find(rti => rtis[rti].name === 'Support');
    }

    @wire(getCaseContacts, {
        productRoutingId: "$productRoutingId",
        region: "$region"
    }) wireCaseContactNumbers({
        error,
        data
    }) {
        if (error) {
        console.error(error);
        } else if (data) {
            this.caseContactNumbers = data;
        }     
    }

    @wire(GetServiceAccounts, {
        AccountId: "0013M00000ckPflQAE"
        }) wireGetServiceAccounts({
            error,
            data
        }) {
            if (error) {
            console.error(error);
            } else if (data) {
                this.serviceaccounts = data.map(record => ({ value: record.Account.Name, label: record.Account.Name }));
                //this.serviceaccounts = data;
            // for(let key in data) {
                    // Preventing unexcepted data
                //  if (data.hasOwnProperty(key)) { // Filtering the data in the loop
                //      console.log("Key+ "+ data[key].Account.Name);
                //       this.serviceaccounts.push({label: data[key].Account.Name, value:data[key].Account.Name});
                        //this.serviceaccounts.push(data[key].Account.Name);
                        //this.objects.push({value:result[key], key:key});
            //     }
            //  }
                console.log(this.serviceaccounts);
        // }     
        }
    }


    value = 'inProgress';



    @wire(GetPotentialCollaborators, { product: '$product.name', accountId: '$accountId' })
    wiredPotentialCollaborators(response) {
        if (response.data) {
            console.log(response.data);
            this.potentialCollaborators = this.handleResponseData(response.data);
            this.error = undefined;
        } else if (response.error) {
            this.error = response.error;
            this.potentialCollaborators = undefined;
        }
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

    /* Load product from session and add listener */
    connectedCallback() {
        const product = JSON.parse(window.sessionStorage.getItem('selectedProduct'));
        const account = window.sessionStorage.getItem('selectedAccountId');
        this.accountId = account;
        getProductList({selectedAccId: account}).then(result => {
            // Match the session selected product, if none is found, reset to "All Products" (null)
            const foundProduct = result.find(p => p.id === product.id) || null;
            if (!foundProduct) {
                fireEvent(this.pageRef, 'cspProductSelectionEvent', { product: {} });
            } else {
                this.setProduct({product: foundProduct});
            }
        }).catch(error => {
            this.errorCallback(error.body);
        });

        registerListener('cspProductSelectionEvent', this.setProduct, this);

        window.document.addEventListener('chatStatus', e => {
            this.chatStatus = e.detail;
        }, true);
    }

    /* Remove listener */
    disconnectedCallback() {
        unregisterListener('cspProductSelectionEvent', this.setProduct, this);
    }

    /* Set focus and validation after step has rendered */
    renderedCallback() {
        if(this.showStepOne && !this.shownStepOne) {
            this.title.focus();
            this.shownStepOne = true;
            this.shownStepTwo = false;
        }
        if(this.showStepTwo && !this.shownStepTwo) {
            this.description.focus();
            this.shownStepOne = false;
            this.shownStepTwo = true;
            this.handleValidation();
        }
    }

    /* Log any errors */
    errorCallback(error, stack) {
        console.error(error.message, error.stack);
        this.dispatchEvent(new ShowToastEvent({
            message: error.message,
            variant: 'error'
        }));
    }

    /* Handle submission of step one */
    handleStepOne(event) {
        this.caseId = null;
        this.redirectToStep('2');
        event.preventDefault();
    }

    /* Handle submission of step two */
    handleStepTwo(event) {
        this.selectedChannel = event.target.name;

        if (this.selectedChannel == 'phone') {
            this.telConfirmPopup.hide();
        }

        let fields = {
            [SUBJECT_FIELD.fieldApiName]: this.title.value,
            [IMPACT_FIELD.fieldApiName]: this.impact.value,
            [PRODUCT_FIELD.fieldApiName]: this.product.name,
            [DESCRIPTION_FIELD.fieldApiName]: this.description.value,
            [SUBANALYSIS_FIELD.fieldApiName]: this.feature.value,
            [RECORDTYPEID_FIELD.fieldApiName]: this.isChatCase ? this.supportRecordType : this.communityRecordType,
            [ORIGIN_FIELD.fieldApiName]: this.isChatCase ? 'Live Chat' : (this.isPhoneCase ? 'Web - Phone' : 'Web'),
            [SOURCE_FIELD.fieldApiName]: 'Support',
            [CASE_TYPE_FIELD.fieldApiName]: 'Support issue',
            [ENTITLEMENT_FIELD.fieldApiName]: this.product.entitlementId,
            [SERVICEACCOUNT_FIELD.fieldApiName]: this.SelServiceAccount,
        };

        if (this.isPhoneCase) {
            fields[STATUS_FIELD.fieldApiName] = 'Customer Outstanding';
        }

        this.creatingCase = true;
        window.scrollTo(0, 0);

        createRecord({
            apiName: CASE_OBJECT.objectApiName,
            fields
        })
        .then(caseObject => {
            this.caseId = caseObject.id;

            /* Move files from user to case */
            if(this.files.length > 0) {
                linkFilesToCase({
                    casenumber: this.caseId,
                    docid: this.files.map(file => file.documentId)
                });
            }
        })
        .catch(error => this.errorCallback(error.body))
        .finally(e => {
            AddCaseCollaborators({ contactIdList: this.collaborators.map(c => c.id), caseId: this.caseId })
                .then(() => {
                    // creation has worked
                    console.log('finished');
                })
                .catch(error => {
                    console.log(error);
                })
                .finally(() => {
                    this.redirectToStep('3');
                    this.creatingCase = false;
                });
        })

        event.preventDefault();
    }

    handleSelectTel(event) {
        this.telConfirmPopup.show();
    }

    handleHideTel(event) {
        this.telConfirmPopup.hide();
    }

    handleServAcc(event) {
        this.SelServiceAccount = event.detail.value;
        this.handleValidation(event);
    }

    /* Redirect to another step */
    redirectToStep(step) {
        const state = {step: step};

        if(this.title && this.title.value) {
            state.title = this.title.value;
        }

        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                name: `create_case__c`
            },
            state
        });
    }

    /* Update current product, reset feature picklist and revalidate */
    setProduct(event) {
        if((!event.product || !event.product.id)) {
            this.redirectToStep('product');
            return;
        }

        if (!event.product.admin || event.product.admin != 'true') {
            // Users should only be able to pick products for which they have an entitlement
            this.redirectToStep('product');
            return;
        }

        if(this.product.id === event.product.id) {
            if (this.showStepProduct) {
                this.redirectToStep('1');
            }
            return;
        }

        this.product = event.product;
        this.productRoutingId = this.product.id;

        if((this.showStepProduct || this.showStepThree) && this.product.id) {
            this.redirectToStep('1');
        }

        const previous = this.feature ? this.feature.value : null;

        this.features = [];
        if(this.feature && this.feature.value) {
            this.feature.value = null;
            this.handleValidation(event);
        }

        getCaseFeatures({ product: this.product.name })
        .then(result => {
            this.features = result.map(feature => ({
                value: feature,
                label: feature
            }));

            /* Reset features and revalidate */
            this.feature.value = null;
            this.handleValidation(event);

            /* Don't mark field as invalid if never selected */
            if(previous != null) {
                this.feature.reportValidity();
            }
        })
        .catch(error => {
            this.error = error;
        });
    }

    /* Handle update of impact picklist */
    handleImpactSelect(event) {
        this.handleValidation(event);
        this.calculateChannel();
    }

    /* Handle update of feature selection picklist */
    handleFeatureSelect(event) {
        this.handleValidation(event);
        this.calculateChannel();
    }

    /* Handle update of title input */
    handleTitleChange(event) {
        if(!this.searchResultsComponent) {
            return;
        }

        this.searchResultsComponent.searchText = this.title.value;
        this.searchResultsComponent.handleSearch(true);
        this.handleValidation(event);
    }

    /* Files have been uploaded to user */
    handleUploadFinished(event) {
        this.files = this.files.concat(event.detail.files);
    }

    /* Remove file from list */
    handleDeleteFile(event) {
        if (event.currentTarget.dataset.id != null){
            this.files = this.files.filter(f => f.documentId != event.currentTarget.dataset.id);
        }
    }

    /* Validate case inputs and show/hide the channels if all satisfied */
    handleValidation(event) {
        this.validationMessage = '';

        if(this.planOptions) {
            this.planOptions.classList.add('slds-hide');
        }

        if(!this.title || !this.title.checkValidity()) {
            this.validationMessage = 'Please enter a title';
            return;
        }

        if(!this.description || !this.description.checkValidity()) {
            this.validationMessage = 'Please enter a description';
            return;
        }
        if(this.serviceUser){

       if(!this.SelServiceAccount){
           this.validationMessage = 'Please select a service account';
            return;
         }
        }

        if(!this.feature || !this.feature.checkValidity()) {
            this.validationMessage = 'Please select a product area';
            return;
        }

        if(!this.impact || !this.impact.checkValidity()) {
            this.validationMessage = 'Please select a business impact';
            return;
        }



        this.planOptions.classList.remove('slds-hide');
    }

    /* Calculate which channels are available */
    calculateChannel() {
        this.channels = new Set([
            this.setChannelAvailable(this.phoneChannel),
            this.setChannelAvailable(this.chatChannel),
            this.setChannelAvailable(this.onlineChannel)
        ]);
        //checks if livechat is available.
        if(this.product.enabledForChat === 'Not Available') {
            this.setChannelHidden(this.chatChannel);
        } else if(this.chatLabel === 'Offline') {
            this.setChannelOffline(this.chatChannel);
        }


        if(this.product.PhonePlanAvalibility == null)
        {
        if(this.product.enabledForPhone === 'Offline') {
            this.setChannelOffline(this.phoneChannel);
        } else if(this.product.enabledForPhone === 'Not Available') {
            this.setChannelHidden(this.phoneChannel);
        }

            if(this.product.successPlanName === 'Essential') {
                if (!this.hiddenChannel(this.phoneChannel)) {
                    this.setChannelUnavailable(this.phoneChannel);
                }
        
            }
        }
        else
        {
            var PlanLevel = this.product.PhonePlanAvalibility;
            if(!PlanLevel.includes(this.product.successPlanName)){
            this.setChannelUnavailable(this.phoneChannel); 
                }
        }



        if(this.product.enabledForOnline === 'Not Available') {
            this.setChannelHidden(this.onlineChannel);
        }

        if(this.product.livechatlevel == null)
        {

            if(this.product.successPlanName === 'Classic') {
                if (!this.hiddenChannel(this.chatChannel)) {
                this.setChannelUnavailable(this.chatChannel);
            }
            }

            if(this.product.successPlanName === 'Essential') {
                if (!this.hiddenChannel(this.chatChannel)) {
                this.setChannelUnavailable(this.chatChannel);
            }
            //  if (!this.hiddenChannel(this.phoneChannel)) {
            //      this.setChannelUnavailable(this.phoneChannel);
           //       }
              }
        }
        else
        {
            var PlanLevel = this.product.livechatlevel;
            if(!PlanLevel.includes(this.product.successPlanName)){
            this.setChannelUnavailable(this.chatChannel); 
                }
            
        }
								  

														  
													 
														  
		 

	 


        this.setRecommended(this.product.successPlanName, this.impact.value);
    }



    /* Enable a given channel in the UI and register it as active */
    setChannelAvailable(channel) {
        channel.parentNode.classList.remove('slds-hide');
        channel.classList.remove('csp-case-plan_box-inactive');
        channel.classList.remove('csp-case-plan_box-offline');

        channel.querySelector('.csp-case-plan_plan-copy').classList.add('slds-hide');
        channel.querySelector('.csp-case-plan_plan-button').disabled = false;

        this.channels.add(channel);
        return channel;
    }

    /* Disable a given channel in the UI and deregister it as active */
    setChannelUnavailable(channel) {
        channel.parentNode.classList.remove('slds-hide');
        channel.classList.add('csp-case-plan_box-inactive');
        channel.classList.remove('csp-case-plan_box-offline');

        channel.querySelector('.csp-case-plan_badge').label = 'Option Unavailable';
        channel.querySelector('.csp-case-plan_plan-copy').classList.remove('slds-hide');
        channel.querySelector('.csp-case-plan_plan-button').disabled = true;

        this.channels.delete(channel);
        return channel;
    }

    setChannelHidden(channel) {
        channel.parentNode.classList.add('slds-hide');

        this.channels.delete(channel);
        return channel;
    }

    setChannelOffline(channel) {
        channel.parentNode.classList.remove('slds-hide');
        channel.classList.add('csp-case-plan_box-offline');

        channel.querySelector('.csp-case-plan_badge').label = 'Option Offline';
        channel.querySelector('.csp-case-plan_plan-button').disabled = true;
        return channel;
    }

    /* Set the recommended channel fromif available */
    setRecommended(successPlan, impact) {
        this.template.querySelectorAll('.csp-case-plan_recommended').forEach(e => {
            e.classList.add('slds-hide');
        })

        if(!this.recommendations[successPlan]) {
            return;
        }

        const channels = this.recommendations[successPlan][impact];
        if(!channels) {
            return;
        }

        const channel = channels.reduce((e, c) => !e && this.allowedChannel(c) ? c : e, null);
        this.recommendChannel(channel);
    }

    /* Check if the channel is available */
    allowedChannel(channel) {
        return !channel.classList.contains('csp-case-plan_box-offline') &&
            !channel.classList.contains('csp-case-plan_box-inactive');
    }

    /* Check if the channel is hidden */
    hiddenChannel(channel) {
        return channel.parentNode.classList.contains('slds-hide');
    }

    /* Make the recommended label visible */
    recommendChannel(channel) {
        if(!channel) {
            return;
        }

        const label = channel.querySelector('.csp-case-plan_recommended');
        if(label) {
            label.classList.remove('slds-hide');
        }
    }

    /* Show search results component if results were found */
    handleSearchResult(event) {
        if(!this.searchResults) {
            return;
        }

        if(event.detail > 0) {
            this.searchResults.classList.remove('slds-hide');
        } else {
            this.searchResults.classList.add('slds-hide');
        }
    }

    /* Intercept selection of a search result and open in modal */
    handleSelectResult(event) {
        this.articleUrl = event.detail.url.split('/').pop();
        this.hasLoadedArticle = false;
        this.sentiment = '';
        this.articlePopup.show();
        event.preventDefault();
    }

    /* Intercept article loaded event and hide spinner */
    handleArticleLoaded(event) {
        this.hasLoadedArticle = true;
    }

    /* Store sentiment if given for when modal closes */
    handleArticleFeedback(event) {
        this.sentiment = event.detail;
    }

    /* Intercept modal closing and if positive feedback show close modal */
    handleCloseDialog(event) {
        if(this.sentiment === 'Positive') {
            this.closeCasePopup.show();
        }
    }

    /* Detect if escape was pressed and close modal */
    handleEscape(event) {
        if(event.which !== 27) {
            return;
        }
        this.articlePopup.hide();

        if(this.sentiment === 'Positive') {
            this.closeCasePopup.show();
        }
    }

    /* Detect if escape was pressed and close modal */
    handleTelConfirmEscape(event) {
        if(event.which !== 27) {
            return;
        }
        this.telConfirmPopup.hide();
    }

    /* Handle close case request from modal and show confirmation */
    handleCloseCase(event) {
        this.showStepOne = false;
        this.showStepTwo = false;
        this.showStepThree = false;
        this.showCaseClosed = true;
    }

    /* Close the modal if request is to continue with case */
    handleContinueCase(event) {
        this.closeCasePopup.hide();
    }

    /* Create new case requests redirect to step 1 */
    handleCreateCase(event) {
        this.files.length = 0;
        if(!this.product || !this.product.id) {
            this.redirectToStep('product');
        } else {
            this.redirectToStep('1');
        }
    }

    handleAddCollaborator() {
        this.showCollabModal = true;
    }
    handleCloseCollabDialog(event){
       this.showCollabModal = false;
    }
    createCollaborator(event) {
        let addedCollaborator = this.potentialCollaborators.find(c => c.id == event.target.dataset.name);
        this.collaborators.push(addedCollaborator);
        this.potentialCollaborators = this.potentialCollaborators.filter(c => c.id != event.target.dataset.name);
        console.log(this.collaborators.map(c => c.id));
    }
    removeCollaborator(event) {
        let removedCollaborator = this.collaborators.find(c => c.id == event.target.dataset.name);
        this.potentialCollaborators.push(removedCollaborator);
        this.collaborators = this.collaborators.filter(c => c.id != event.target.dataset.name);
    }

    /* Redirect to new case */
    handleViewCase(event) {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.caseId,
                actionName: 'view',
            }
        });

        event.preventDefault();
    }

    get impacts() {
        return [
            { value: '4', label: 'Limited - I have a question about how to do something or a minor error' },
            { value: '3', label: 'Moderate - A feature I am using is not working as expected'},
            { value: '2', label: 'Major - A major feature has stopped working'},
            { value: '1', label: 'Critical - My system is not available'}
        ];
    }
    get recommendations() {
        return {
            Classic: {
                1: [this.phoneChannel, this.onlineChannel],
                2: [this.onlineChannel],
                3: [this.chatChannel, this.onlineChannel],
                4: [this.chatChannel, this.onlineChannel]
            },
            Standard: {
                1: [this.phoneChannel],
                2: [this.onlineChannel],
                3: [this.onlineChannel],
                4: [this.chatChannel, this.onlineChannel]
            },
            Premier: {
                1: [this.phoneChannel],
                2: [this.phoneChannel],
                3: [this.onlineChannel],
                4: [this.chatChannel, this.onlineChannel]
            },
            Internal: {
                1: [this.phoneChannel],
                2: [this.phoneChannel],
                3: [this.onlineChannel],
                4: [this.chatChannel, this.onlineChannel]
            }
        }
    }
    get impact() {
        return this.template.querySelector('[data-id="impact"]');
    }
    get feature() {
        return this.template.querySelector('[data-id="feature"]');
    }
    get title() {
        return this.template.querySelector('[data-id="title"]');
    }
    get description() {
        return this.template.querySelector('[data-id="description"]');
    }
    get searchResults() {
        return this.template.querySelector('[data-id="search-results"]');
    }
    get searchResultsComponent() {
        return this.template.querySelector('c-csp-search-results');
    }
    get planOptions() {
        return this.template.querySelector('[data-id="case-options"]');
    }
    get articlePopup() {
        return this.template.querySelector('[data-id="article-popup"]');
    }
    get closeCasePopup() {
        return this.template.querySelector('[data-id="close-case-popup"]');
    }
    get telConfirmPopup() {
        return this.template.querySelector('[data-id="tel-confirm-popup"]');
    }
    get phoneChannel() {
        return this.template.querySelector('.csp-case-plan_phone')
    }
    get chatChannel() {
        return this.template.querySelector('.csp-case-plan_chat')
    }
    get onlineChannel() {
        return this.template.querySelector('.csp-case-plan_online')
    }
    get chatIframe() {
        return this.template.querySelector('.csp-iframe');
    }
    get isChatCase() {
        return this.selectedChannel === "chat";
    }
    get isOnlineCase() {
        return this.selectedChannel === "online";
    }
    get isPhoneCase() {
        return this.selectedChannel === "phone";
    }
    set chatStatus(status) {
        this.chatLabel = status;
        this.calculateChannel();
    }
    get chatUrl() {
        const params = [
            `buttonId=${this.product.liveChatButton ? this.product.liveChatButton : ''}`,
            `ContactEmail=${this.userEmail ? this.userEmail : ''}`,
            `EntitlementID=${this.product.entitlementId ? this.product.entitlementId : ''}`,
            `ContactID=${this.contactId}`,
            `CaseID=${this.caseId && this.isChatCase ? this.caseId : ''}`
        ]
        return `/Support/LiveChat?${params.join('&')}`;
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