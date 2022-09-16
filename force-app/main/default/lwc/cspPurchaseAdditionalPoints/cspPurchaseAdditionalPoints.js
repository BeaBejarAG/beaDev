import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import createSelfGenCase from '@salesforce/apex/cspCaseHandler.createSelfGenCase';
import createAccountUpgradeSelfGenCase from '@salesforce/apex/cspCaseHandler.createAccountUpgradeSelfGenCase';

export default class CspPurchaseAdditionalPoints extends LightningElement {
    isLoading = false;
    accountId = '';
    @api contactRequest;
    @api accountUpgrades;

    constructor() {
        super();
        this.accountId = window.sessionStorage.getItem('selectedAccountId');
    }

    showSuccessToast() {
        const event = new ShowToastEvent({
            title: 'Success',
            message: 'Request submitted successfully',
            variant: 'success',
            mode: 'dismissable'
        });
        this.dispatchEvent(event);
    }

    showSubmitErrorToast() {
        const event = new ShowToastEvent({
            title: 'Error submitting request',
            message: 'Error submitting request - please raise a case',
            variant: 'error',
            mode: 'dismissable'
        });
        this.dispatchEvent(event);
    }
    
    handleSubmitApplicationClick() {
        this.isLoading = true;
        createSelfGenCase()
        .then(response => {
            if (response) {
                this.showSuccessToast();
            } else {
                this.showSubmitErrorToast();
            }
            this.handleDialogClose();
        })
        .catch(error => console.log(error))
        .finally(() => this.isLoading = false);
    }

    handleSubmitAccountUpgradeApplicationClick() {
        this.isLoading = true;
        createAccountUpgradeSelfGenCase({selectedAccountId: this.accountId})
        .then(response => {
            if (response) {
                this.showSuccessToast();
            } else {
                this.showSubmitErrorToast();
            }
            this.handleDialogClose();
        })
        .catch(error => {
            this.showSubmitErrorToast();
            console.log(error);
        })
        .finally(() => this.isLoading = false);
    }


    handleDialogClose() {
        this.dispatchEvent(new CustomEvent('cancelpointspurchase'));      
    }
}