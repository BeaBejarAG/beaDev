import { LightningElement, track, api, wire } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import { fireEvent } from 'c/pubsub';

import getAccountRelations from '@salesforce/apex/cspConsultantAccountHandler.getAccountRelations';

export default class CspAccountSelection extends LightningElement {
    @api account = [];
    @track options = [];
    @track showAccountSelection = false;
    @wire(CurrentPageReference) pageRef;
    @track value = '';
    @track label = 'Select company account';
    @track showPopover = false;

    connectedCallback() {
        getAccountRelations({contactId: null})
        .then(response => {
            this.account = response;
            this.populateOptions();
        })
        .catch(error => {
            this.showAccountSelection = false;
            console.log(error);
        })
        .finally(() => {
            if (this.showPopover) {
                this.showAccountSelection = true;
                const dropdownDiv = this.template.querySelector('.csp-account-dropdown__button');
                if (dropdownDiv) {
                    dropdownDiv.click();
                }
            }
        });
    }

    errorCallback(error, stack) {
        console.log("Error : " + error + ' ' + stack);
    }


    populateOptions() {
        this.options = [];
        this.account.map(acc => {
            this.options.push({label: acc.Account.Name, value: acc.Account.Id, isDirect: acc.IsDirect});
        });
        this.showAccountSelection = (this.options.length > 1);
        const directAccount = (!this.showAccountSelection && this.account.length > 0) ? this.account.filter(acc => {return acc.IsDirect})[0].Account.Id : '';

        let selectedAccId = window.sessionStorage.getItem('selectedAccountId');
        if (this.options.filter(option => option.value === selectedAccId).length === 0) {
            selectedAccId = '';
            window.sessionStorage.removeItem('selectedAccountId');
        }

        const accountId = (!selectedAccId || selectedAccId.length === 0) ? directAccount : selectedAccId;
        this.showPopover = ((!selectedAccId || selectedAccId.length === 0) && this.showAccountSelection);
        const accountName = (accountId != '' && this.account.length > 0) ? this.account.filter(acc => {return acc.Account.Id === accountId})[0].Account.Name : 'Select company account';
        this.label = (selectedAccId) ? accountName : 'Select company account';

        if (!this.showAccountSelection) {
            window.sessionStorage.setItem('selectedAccountId', accountId);
            fireEvent(this.pageRef, 'cspAccountSelectionEvent', {
                selectedAccountId: accountId
            });
        }

        window.sessionStorage.setItem('consultantAccount', this.showAccountSelection);
        fireEvent(this.pageRef, 'cspConsultantAccountEvent', {
            consultantAccount: this.showAccountSelection
        })
    }

    accountChangeHandler(event) {
        try {
            this.value = event.detail.value;
            const selectedAccountId = event.detail.value;
            let currentAccountId = window.sessionStorage.getItem('selectedAccountId');
            if (selectedAccountId != currentAccountId) {
                window.sessionStorage.setItem('selectedAccountId', selectedAccountId);
                fireEvent(this.pageRef, 'cspAccountSelectionEvent', {
                    selectedAccountId: selectedAccountId
                });
                this.label = this.account.filter(acc => {return acc.Account.Id === this.value})[0].Account.Name;
                this.showPopover = false;
    
                // Fire an event to clear any selected product or feature
                window.sessionStorage.removeItem('selectedProduct');
                fireEvent(this.pageRef, 'cspProductSelectionEvent', { product: {} });
                window.sessionStorage.removeItem('selectedProductFeature');
                fireEvent(this.pageRef, 'cspProductFeatureSelectionEvent', {
                    feature: ''
                });
            }
        } catch (e) {
            console.log(e);
        }
	}
}