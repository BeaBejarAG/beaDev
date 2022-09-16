import { LightningElement, track, wire, api } from 'lwc';
import getIsPointsGuardian from '@salesforce/apex/cspContactsHandler.getIsPointsGuardian';
import getFlexPoints from '@salesforce/apex/cspContactsHandler.getFlexPoints';
import { registerListener, unregisterListener } from 'c/pubsub';
import { CurrentPageReference, NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class CspFlexPointsBalance extends NavigationMixin(LightningElement) {
    @track balances;
    isLoading = false;
    @track accountId = '';
    @track displayFlexPoints = false;
    @api showHeader = false;

    @wire(CurrentPageReference) pageRef;

    constructor() {
        super();
        this.accountId = window.sessionStorage.getItem('selectedAccountId');
        this.handlePointGuardian();
        this.handleRetrieveFlexPointsBalance();
    }

    connectedCallback() {
        registerListener('cspAccountSelectionEvent', this.handleAccountSelection, this);
        registerListener('cspServiceAppiledForEvent', this.handleServiceAppliedFor, this);

    }

    disconnectedCallback() {
        unregisterListener('cspAccountSelectionEvent', this.handleAccountSelection, this);
        unregisterListener('cspServiceAppiledForEvent', this.handleServiceAppliedFor, this);
    }

    handleServiceAppliedFor(event) {
        this.handlePointGuardian();
        this.handleRetrieveFlexPointsBalance();
    }

    handleAccountSelection(event) {
        if(!event.selectedAccountId) {
            return;
        }

        this.accountId = event.selectedAccountId;
        this.handlePointGuardian();
        this.handleRetrieveFlexPointsBalance();
    }

    showLoading() {
        this.isLoading = true;
    }

    hideLoading() {
        this.isLoading = false;
    }

    handlePointGuardian() {
        getIsPointsGuardian({selectedAccountId: this.accountId})
            .then(result => this.displayFlexPoints = result)
            .catch(error => console.log(error))
            .finally(() => {});
    }

    handleRetrieveFlexPointsBalance() {
        this.showLoading();
        getFlexPoints({selectedAccountId: this.accountId})
        .then(response => {
            if (response) {
                this.balances = response;
            } else {
                this.showErrorToast()
            }
        })
        .catch(error => console.log(error))
        .finally(() => {this.hideLoading()});
    }

    showErrorToast() {
        const event = new ShowToastEvent({
            title: 'Error retrieving FlexPoints',
            message: 'Error retrieving FlexPoints - please raise a case',
            variant: 'error',
            mode: 'dismissable'
        });
        this.dispatchEvent(event);
    }

    get currentBalance() {
        return this.confirmedPoints + this.pendingPoints + this.availablePoints;
    }

    handleClick() {
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                name: `FlexPoints__c`
            }
        });
    }

    get pointsPopup() {
        return this.template.querySelector('.csp-purchase-additional-points-popup');
    }

    handleCancelPointsPurchase() {
        this.template.querySelector('[data-id="csp-purchase-additional-points-popup"').hide();
    }

    handleContactTeamClick() {
        this.template.querySelector('[data-id="csp-purchase-additional-points-popup"').show();
    }
}