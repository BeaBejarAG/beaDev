import { LightningElement, track, api } from 'lwc';
import getFlexPoints from '@salesforce/apex/cspContactsHandler.getFlexPoints';
import getIsNonPointsUser from '@salesforce/apex/cspContactsHandler.getIsNonPointsUser';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class LscPointsExpiringSoon extends LightningElement {
    @api recordId = '';
    @track balances;
    @track pointsExpiringSoon = 0;
    @track showPoints = true;
    @track loading = true;

    connectedCallback() {
        this.handleIsNonPointsUser();
    }

    handleIsNonPointsUser() {
        this.loading = true;
        // validate that the selected account is not a non point user
        getIsNonPointsUser({ selectedAccountId: this.recordId })
        .then(result => {
            if (!result) {
                this.showPoints = true;
                this.retrieveFlexPoints();
            } else {
                this.showPoints = false;
            }
        })
        .catch(error => console.log(error))
        .finally(() => this.loading = false);
    }

    retrieveFlexPoints() {
        getFlexPoints({ selectedAccountId: this.recordId })
        .then(result => {
            if (result) {
                this.balances = result;
            } else {
                this.showErrorToast()
            }
        })
        .catch(error => console.log(error))
        .finally(() => this.loading = false);
    }

    showErrorToast() {
        const event = new ShowToastEvent({
            title: 'Error retrieving FlexPoints',
            message: 'Error retrieving FlexPoints - please speak to support to investigate this account',
            variant: 'error',
            mode: 'dismissable'
        });
        this.dispatchEvent(event);
    }

    get isValidRecordId() {
        return this.recordId != 'null';
    }
}