import { LightningElement, api, track, wire } from 'lwc';
import getServiceCatalogue from '@salesforce/apex/cspServiceCatalogueEntryHandler.getServiceCatalogue';
import getFlexPoints from '@salesforce/apex/cspContactsHandler.getFlexPoints';
import createNewCase from '@salesforce/apex/cspFlexPointsHandler.createNewCase';
import requestAQuote from '@salesforce/apex/cspFlexPointsHandler.requestAQuote';
import { CurrentPageReference, NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getIsNonPointsUser from '@salesforce/apex/cspContactsHandler.getIsNonPointsUser';
import getAccountManager from '@salesforce/apex/cspContactsHandler.getAccountManager';
import getPointsGuardians from '@salesforce/apex/cspContactsHandler.getPointsGuardians';
import getPlan from '@salesforce/apex/cspContactsHandler.getPlan';
import { registerListener, unregisterListener, fireEvent } from 'c/pubsub';

const CSS_HIDDEN_CLASS = 'slds-hide';

export default class CspServicesCatalogueModal extends NavigationMixin(LightningElement) {
    @api showModal = false;
    @api size;
    @api serviceId;
    @api isGuardian;
    pageRef;
    isLoading = false;
    showApplication = false;
    showSubmitted = false;
    showServiceDetails = true;
    remainingPoints = 0;
    flexPoints = {};
    @track textInput = '';
    @track service = {};
    @track product;
    @track entitlementId;
    @track premierPlanType;
    isNonPointsUser = false;
    isPremier = false;
    accountId;
    accountManager;
    pointGuardians;
    errorMsg;

    @wire(CurrentPageReference)
    async setPageReference(currentPageReference) {
        this.pageRef = currentPageReference;

        this.getServiceCatalogue();
        this.isPremierPlan();
        this.handleUser();
    }

    constructor() {
        super();
        this.accountId = window.sessionStorage.getItem('selectedAccountId');
        const productObj = JSON.parse(window.sessionStorage.getItem('selectedProduct'));
        if (productObj != null && productObj.name != null && productObj.name != '') {
            this.product = productObj.name;
            this.entitlementId = productObj.entitlementId;
            this.premierPlanType = (productObj.successPlanName === 'Premier');
        } else {
            this.product = 'All Products';
            this.premierPlanType = false;
        }
    }

    connectedCallback() {
        this.handleGetFlexPoints();
        registerListener('cspProductSelectionEvent', this.handleProductSelection, this);
        registerListener('cspAccountSelectionEvent', this.handleAccountSelection, this);
    }

    disconnectedCallback() {
        unregisterListener('cspProductSelectionEvent', this.handleProductSelection, this);
        unregisterListener('cspAccountSelectionEvent', this.handleAccountSelection, this);
    }

    handleGetFlexPoints() {
        getFlexPoints({selectedAccountId: this.accountId})
        .then(response => {
            this.flexPoints = response;
            this.remainingPoints = response.availablePoints;
        })
    }

    handleProductSelection(event) {
        // Received an event with updated product selection
        if (event.product != null && event.product.name != null && event.product.name != '') {
            this.product = event.product.name;
        } else {
            this.product = 'All Products';
        }    

        if (event.product != null && event.product.entitlementId) {
            this.entitlementId = event.product.entitlementId;
        } else {
            this.entitlementId = '';
        }

        if (event.product != null && event.product.successPlanName) {
            this.premierPlanType = (event.product.successPlanName === 'Premier');
        } else {
            this.premierPlanType = false;
        }
    }

    handleAccountSelection(event) {
        if(!event.selectedAccountId) {
            return;
        }

        this.accountId = event.selectedAccountId;
        this.handleGetFlexPoints();
    }

    async getServiceCatalogue() {
        this.showLoading();
        if(this.pageRef.state.serviceId) {
            this.service = await getServiceCatalogue({
                serviceCatalogueId: this.pageRef.state.serviceId,
            });
            if (this.service) {
                this.show();
            }
        }
        this.hideLoading();
    }

    handleUser() {
        // isGuardian is updated in CspServiceCatalogueServices whenever a new account is selected.
        if (this.isGuardian) return;

        getIsNonPointsUser({ selectedAccountId: this.accountId })
        .then(result => {
            this.isNonPointsUser = result;
            if (this.isNonPointsUser) {
                this.handleAccountManager();
            } else {
                this.handlePointsGuardians();
            }
        })
        .catch(error => console.log(error));
    }

    isPremierPlan() {
        getPlan({ selectedAccId: this.accountId })
        .then(data => this.isPremier = data.toLowerCase() === 'premier')
        .catch(error => console.log(error))
    }

    handleAccountManager() {
        getAccountManager({ selectedAccId: this.accountId })
        .then(data => this.accountManager = this.handleAccountManagerData(data))
        .catch(() => this.errorMsg = 'An error occurred whilst fetching account manager');
    }

    handlePointsGuardians() {
        getPointsGuardians({ selectedAccountId: this.accountId })
        .then(data => this.pointGuardians = this.handlePointGuardiansData(data))
        .catch(() => this.errorMsg = 'An error occurred whilst fetching point guardians');
    }

    handleAccountManagerData(data) {
        let obj = JSON.parse(JSON.stringify(data));
        obj.photoUrl = data.IsProfilePhotoActive ? data.MediumPhotoUrl : '';
        obj.initials = data.Name[0];

        const total = data.Id.split('').map(x => x.charCodeAt(0)).reduce((a, b) => a + b);
        obj.avatar = `slds-float_left slds-m-right_medium slds-m-vertical_small csp-avatar_small access-theme-user-cat${total % 28}`;

        return obj;
    }

    handlePointGuardiansData(data) {
        return JSON.parse(JSON.stringify(data)).map((obj, i) => {
            obj.photoUrl = obj.IsProfilePhotoActive ? obj.MediumPhotoUrl : '';
            obj.initials = obj.Contact.Name[0];

            const total = obj.Id.split('').map(x => x.charCodeAt(0)).reduce((a, b) => a + b);
            obj.avatar = `slds-float_left slds-m-right_medium slds-m-vertical_small csp-avatar_small access-theme-user-cat${total % 28}`;

            return obj;
        });
    }

    get sizeClass() {
        if(this.size) {
            return `slds-modal slds-modal_${this.size} slds-fade-in-open`;
        }

        return "slds-modal slds-fade-in-open";
    }

    show() {
        this.showModal = true;
    }

    hide() {
        this.showApplication = false;
        this.showSubmitted = false;
        this.showServiceDetails = true;
        this.showModal = false;
        this.textInput = '';
    }

    showLoading() {
        this.isLoading = true;
    }

    hideLoading() {
        this.isLoading = false;
    }

    handleDialogClose() {
        const closedialog = new CustomEvent('closedialog');
        this.dispatchEvent(closedialog);
        this.hide();
        this.navigateToServicesPage();
    }

    handleSlotHeaderChange() {
        const headerEl = this.template.querySelector('div.slds-hide');
        if(headerEl) {
            headerEl.classList.remove(CSS_HIDDEN_CLASS);
        }
    }

    handleSlotTaglineChange() {
        const taglineEl = this.template.querySelector('p');
        if(taglineEl) {
            taglineEl.classList.remove(CSS_HIDDEN_CLASS);
        }
    }

    handleSlotFooterChange() {
        const footerEl = this.template.querySelector('footer');
        if(footerEl) {
            footerEl.classList.remove(CSS_HIDDEN_CLASS);
        }
    }

    get handleDisableQuoteRequest() {
        return !(this.remainingPoints > 0);
    }

    get handleDisableSubmit() {
        return !(this.service.Points_Conversion__c <= this.remainingPoints);
    }

    handleApplyForService() {
        if (this.service) {
            if (this.service.Points_Conversion__c <= this.remainingPoints) {
                this.showServiceDetails = false;
                this.showApplication = true;
                this.showSubmitted = false;
            } else {
                this.showInsufficientToast();
            }
        }
    }

    handleRequestAService() {
        if (this.service) {
            this.showServiceDetails = false;
            this.showApplication = true;
            this.showSubmitted = false;
        }
    }

    handleSubmitService() {
        if (this.textInput.length == 0) {
            this.showNoInputToast();
        } else {
            this.handleCreateNewCase();
        }
    }

    handleRequestAQuote() {
        if (this.textInput.length == 0) {
            this.showNoInputToast();
        } else {
            this.handleCreateCaseQuoteRequest();
        }
    }

    handleBrowseOurServices() {
        this.hide();
        this.navigateToServicesPage();
    }

    handleInputChange(event) {
        this.textInput = event.target.value;
    }

    navigateToServicesPage() {
        var state = {};
        const paramsPageRef = this.pageRef.state;

        for (const [key, value] of Object.entries(paramsPageRef)) {
            if (value != '' && key != 'serviceId') {
                Object.assign(state, {[key]: value});
            }
        }

        this[NavigationMixin.Navigate](this.getUpdatedPageReference(state),true);
    }

    getUpdatedPageReference(stateChanges) {
        return Object.assign({}, this.pageRef, {
            state: stateChanges
        });
    }

    navigateToFlexPointsPage() {
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: '/flexpoints'
            }
        });
    }

    showSuccessToast() {
        const event = new ShowToastEvent({
            title: 'Success',
            message: 'Request submitted successfully',
            variant: 'success',
            mode: 'dismissable'
        });
        this.dispatchEvent(event);
        fireEvent(this.pageRef, 'cspServiceAppiledForEvent', { });
    }

    showErrorToast() {
        const event = new ShowToastEvent({
            title: 'Error submitting request',
            message: 'Error submitting request - please raise a case',
            variant: 'error',
            mode: 'dismissable'
        });
        this.dispatchEvent(event);
    }

    showInsufficientToast() {
        const event = new ShowToastEvent({
            title: 'Unable to apply for service',
            message: 'Insufficient remaining points',
            variant: 'error',
            mode: 'dismissable'
        });
        this.dispatchEvent(event);
    }

    showNoInputToast() {
        const event = new ShowToastEvent({
            title: 'Text field empty',
            message: 'Please input data into the text field',
            variant: 'error',
            mode: 'dismissable'
        });
        this.dispatchEvent(event);
    }

    get premierService() {
        // Customers wthout premier plan cannot request a premier only service
        return this.service.Premier_Only__c && !this.premierPlanType;
    }

    get isAllProductSelected() {
        return this.product === 'All Products'
    }

    get showRequest() {
        return this.service.Estimate_Required__c;
    }

    handleCreateNewCase() {
        this.showLoading();
        createNewCase({description: this.textInput, subject: this.service.Service_Title__c, priority: '4', 
        product: this.product, serviceId: this.service.Id, entitlementId: this.entitlementId, accountId: this.accountId, points: this.service.Points_Conversion__c})
        .then(response => {
            if (response) {
                this.showSuccessToast();
                this.showServiceDetails = false;
                this.showApplication = false;
                this.showSubmitted = true;
            } else {
                this.showErrorToast();
            }
        })
        .catch(error => {
            this.showErrorToast();
            console.log(error);
        })
        .finally(() => {
            this.hideLoading();
            fireEvent(this.pageRef, 'cspServiceAppiledForEvent', { });
        })
    }

    handleCreateCaseQuoteRequest() {
        this.showLoading();
        requestAQuote({description: this.textInput, subject: this.service.Service_Title__c, priority: '4',
        product: this.product, serviceId: this.service.Id, entitlementId: this.entitlementId, points: this.service.Points_Conversion__c, accountId: this.accountId})
        .then(response => {
            if (response) {
                this.showSuccessToast();
                this.showServiceDetails = false;
                this.showApplication = false;
                this.showSubmitted = true;
            } else {
                this.showErrorToast();
            }
        })
        .catch(error => {
            this.showErrorToast();
            console.log(error);
        })
        .finally(() => {this.hideLoading()})
    }

    handleAccountUpgrade() {
        this.handleDialogClose();
        this.template.querySelector('[data-id="csp-account-upgrade-popup"').show();
    }

    handleCancelAccountUpgrade() {
        this.template.querySelector('[data-id="csp-account-upgrade-popup"').hide();
    }

    get hasPreReqs() {
        return this.service.Service_Prerequisites__c;
    }
}