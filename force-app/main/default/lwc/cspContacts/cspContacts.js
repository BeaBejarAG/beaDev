import { LightningElement, wire, api } from 'lwc';
import getCSM from '@salesforce/apex/cspContactsHandler.getCSM';
import getAccountManager from '@salesforce/apex/cspContactsHandler.getAccountManager';
import getPlan from '@salesforce/apex/cspContactsHandler.getPlan';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { registerListener, unregisterListener } from 'c/pubsub';
import { CurrentPageReference } from 'lightning/navigation';


export default class CspContacts extends LightningElement {
    @api showFinanceCard = false;
    @api showCSMCard = false;
    @api showAMCard = false;
    @api financeDescription;
    @api financeEmail;
    @api financeMobile;
    @api financePhone;
    @api accountManagerDesc;
    @api csmDesc;
    @api accountId;

    accountManager;
    csm;
    plan;
    isPremier = false;
    isEssential = false;
    isStandard = false;
    error;

    constructor() {
        super();
        this.accountId = window.sessionStorage.getItem('selectedAccountId');
    }

    errorCallback(error, stack) {
        console.log("Error : " + error + ' ' + stack);
    }

    @wire(CurrentPageReference) pageRef;

    connectedCallback() {
        registerListener('cspAccountSelectionEvent', this.handleAccountSelection, this);
        this.handleAccountManager(this.accountId);
        this.handleGetCSM(this.accountId);
        this.handleGetPlan(this.accountId);
    }

    disconnectedCallback() {
        unregisterListener('cspAccountSelectionEvent', this.handleAccountSelection, this);
    }

    handleAccountSelection(event) {
        if(!event.selectedAccountId) {
            return;
        }

        this.accountId = event.selectedAccountId;
        this.handleAccountManager(this.accountId);
        this.handleGetCSM(this.accountId);
        this.handleGetPlan(this.accountId);
    }


    handleAccountManager(selectedAccountId) {
        getAccountManager({selectedAccId: selectedAccountId})
        .then(data => {
            this.accountManager = this.handleData(data);
        })
        .catch(error => {
            this.handleResponseError(error);
        })
        .finally(() => {})
    }

    handleGetCSM(selectedAccountId) {
        getCSM({selectedAccId: selectedAccountId})
        .then(data => {
            this.csm = this.handleData(data)
        })
        .catch(error => this.handleResponseError(error))
        .finally(() => {});
    }

    handleGetPlan(selectedAccountId) {
        getPlan({selectedAccId: selectedAccountId})
        .then(data => {
            this.plan = data.toLowerCase();
            if (this.plan === 'premier') {
                this.isPremier = true;
            } else if (this.plan === 'standard') {
                this.isStandard = true;
            } else {
                this.isEssential = true;
            }
        })
        .catch(error => this.handleResponseError(error))
        .finally(() => {});
    }

    handleData(data) {
        let obj = JSON.parse(JSON.stringify(data));
        if (data != null) {
            obj.photoUrl = data.IsProfilePhotoActive ? data.MediumPhotoUrl : '';
            obj.initials = data.Name[0];

            const total = data.Id.split('').map(x => x.charCodeAt(0)).reduce((a, b) => a + b);
            obj.avatar = `slds-float_left slds-m-right_medium slds-m-vertical_small csp-avatar access-theme-user-cat${total % 28}`;
        }
        return obj;
    }

    handleResponseError(error) {
        this.error = true;
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Error fetching contacts',
                message: error.message,
                variant: 'error',
            }),
        );
        this.error = JSON.stringify(error);
        console.log(this.error)
    }

    get isLoading() {
        return !this.accountManager && !this.plan && !this.csm && !this.error;
    }

    get cardClass() {
        return this.showFinanceCard ? 'slds-col slds-large-size_1-of-3 slds-medium-size_1-of-2 slds-small-size_1-of-1 slds-m-top_small'
            : 'slds-col slds-large-size_5-of-12 slds-medium-size_1-of-2 slds-small-size_1-of-1 slds-m-top_small';
    }
}