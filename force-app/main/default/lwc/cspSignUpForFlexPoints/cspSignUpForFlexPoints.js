import { LightningElement, wire, api } from 'lwc';
import { CurrentPageReference, NavigationMixin } from 'lightning/navigation';

import ACCESS_FLEX_POINTS_SIGN_UP_HEADER from '@salesforce/contentAssetUrl/FlexPoints';
import getIsPointsGuardian from '@salesforce/apex/cspContactsHandler.getIsPointsGuardian';
import getIsNonPointsUser from '@salesforce/apex/cspContactsHandler.getIsNonPointsUser';
import { registerListener, unregisterListener } from 'c/pubsub';
export default class CspSignUpForFlexPoints extends NavigationMixin(LightningElement) {
    accountId;
    isPointsGuardian = false;
    isNonPointsUser = false;
    @api flexPointsTitle;
    @api flexPointsDesc;

    @wire(CurrentPageReference) pageRef;
    
    constructor() {
        super();
        this.accountId = window.sessionStorage.getItem('selectedAccountId');
    }

    connectedCallback() {
        this.handleUser();
        registerListener('cspAccountSelectionEvent', this.handleAccountSelection, this);
    }

    renderedCallback() {
        const title = this.template.querySelector('.csp-sign-up-flex-points-title');
        if (title) {
            title.innerHTML = this.flexPointsTitle != null ? this.flexPointsTitle.replace('FlexPoints', '<span class="csp-sign-up-flex-points-title-span">FlexPoints</span>') : '';
        }
    }

    disconnectedCallback() {
        unregisterListener('cspAccountSelectionEvent', this.handleAccountSelection, this);
    }

    handleAccountSelection(event) {
        if(!event.selectedAccountId) {
            return;
        }

        this.accountId = event.selectedAccountId;
        this.handleUser();
    }

    handleUser() {
        getIsPointsGuardian({ selectedAccountId: this.accountId })
            .then(result => {this.isPointsGuardian = result;
                console.log('isPointsGuardian', result);
            
            })
            .catch(error => console.log(error));

        if (this.isPointsGuardian) return;

        getIsNonPointsUser({ selectedAccountId: this.accountId })
        .then(result => {
            this.isNonPointsUser = result;
        })
        .catch(error => console.log(error));
        this.isNonPointsUser = true;
    }

    handleFindOutMore() {
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: 'https://www.theaccessgroup.com/flexpoints'
            }
        });
    }

    get accessPeopleImage() {
        return ACCESS_FLEX_POINTS_SIGN_UP_HEADER;
    }
}