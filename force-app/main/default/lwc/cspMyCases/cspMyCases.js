import { LightningElement, api, wire, track } from 'lwc';
import { NavigationMixin, CurrentPageReference } from 'lightning/navigation';
import { registerListener, unregisterListener } from 'c/pubsub';

import getOpenCases from '@salesforce/apex/cspCaseHandler.getOpenCases';
import getAwaitingCustomerCases from '@salesforce/apex/cspCaseHandler.getAwaitingCustomerCases';

export default class CspMyCases extends NavigationMixin(LightningElement) {
    @api componentTitle;
    @api displayStyle;
    @api targetUrl;
    @api ignoreProduct = false;
    @api superUser = false;
    @api HideAllAccountCases = false;

    @track openCases = 0;
    @track pendingCases = 0;
    @track accountId = '';

    productName = null;
    product = null;
    showCasesCheckbox = false;

    constructor() {
        super();
        let productObject = JSON.parse(window.sessionStorage.getItem('selectedProduct'));
        this.productName = productObject && productObject.name ? productObject.name : '';
        this.product = productObject;
        this.accountId = window.sessionStorage.getItem('selectedAccountId');
        this.showCasesCheckbox = window.sessionStorage.getItem('consultantAccount') === 'true';
    }

    @wire(CurrentPageReference) pageRef;

    connectedCallback() {
        if (this.ignoreProduct) {
            this.productName = null;
        } else {
            registerListener('cspProductSelectionEvent', this.handleProductSelection, this);
        }
        registerListener('cspAccountSelectionEvent', this.handleAccountSelection, this);
        registerListener('cspConsultantAccountEvent', this.handleIsConsultantAccount, this);
        this.getCases();
        this.getPendingCases();
    }

    disconnectedCallback() {
        if (!this.ignoreProduct) {
            unregisterListener('cspProductSelectionEvent', this.handleProductSelection, this);
        }
        unregisterListener('cspAccountSelectionEvent', this.handleAccountSelection, this);
        unregisterListener('cspConsultantAccountEvent', this.handleIsConsultantAccount, this);
    }

    handleIsConsultantAccount(event) {
        if(!event.consultantAccount) {
            return;
        }
        this.showCasesCheckbox = event.consultantAccount;
    }

    handleAccountSelection(event) {
        if(!event.selectedAccountId) {
            return;
        }

        this.accountId = event.selectedAccountId;
        this.getCases();
        this.getPendingCases();
    }

    getCases() {
        getOpenCases(this.getPayload())
        .then(data => {
            this.openCases = data;
        })
        .catch(error => {})
        .finally(() => {});
    }

    getPendingCases() {
        getAwaitingCustomerCases(this.getPayload())
        .then(data => {
            this.pendingCases = data;
        })
        .catch(error => {})
        .finally(() => {});
    }

    getPayload() {
        return {
            product: this.productName,
            superUser: this.superUser,
            selectedAccId: this.accountId && this.accountId != 'All Accounts' ? this.accountId : null
        }
    }

    handleAccountCheckBox(event) {
        const checked = event.target.checked;
        if (checked) {
            this.accountId = 'All Accounts';
        } else {
            this.accountId = window.sessionStorage.getItem('selectedAccountId');
        }
        this.getCases();
        this.getPendingCases();
    }

    errorCallback(error, stack) {
        console.log("Error : " + error + ' ' + stack);
    }

    handleProductSelection(event) {
        // Received an event with updated product selection
        let productObject = event.product;
        this.productName = productObject && productObject.name ? productObject.name : '';
        this.product = productObject;
        this.getCases();
        this.getPendingCases();
    }

    get isHorizontal() {
        return this.displayStyle == 'Horizontal';
    }
    
    @api
    get userNotEntitled() {
        if (this.superUser || this.ignoreProduct) {
            // super users can see cases for all products
            return false;
        }
        // if admin = false then don't show
        if (this.product && this.product.name && this.product.name != 'All Products') {
            return !this.product.admin || this.product.admin != 'true';
        } else {
            return false;
        }
    }

    handleOpenCasesClick() {
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: `${this.targetUrl}?status=Open&owner=My%2520Cases`
            }
        });
    }

    handleAwaitingCasesClick() {
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: `${this.targetUrl}?status=Needs%2520Action&owner=My%2520Cases`
            }
        });
    }

    handleCreateCaseClick() {
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: '/createcase'
            }
        });
    }

    handleAllCasesClick() {
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: this.targetUrl
            }
        });
    }
}