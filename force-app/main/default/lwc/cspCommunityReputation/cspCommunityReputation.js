import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class CspCommunityReputation extends LightningElement {
    @api levelName;
    @api levelNumber;
    @api horizontal = false;
    levelStars = [];

    connectedCallback() {
        this.setReputation();
    }

    setReputation() {
        this.levelStars = [];
        for(let i = 0; i < (this.levelNumber - 2) % 4; i++) {
            this.levelStars.push({id: i});
        }

        this.levelClass = `csp-reputation_${this.levelName.toLowerCase()}`;
    }

    @api
    refresh() {
        this.setReputation();
    }

    errorCallback(e) {
        console.error(e);
        this.dispatchEvent(new ShowToastEvent({
            message: e.body ? e.body.message : e.message,
            variant: 'error'
        }));
    }

    get reputationClass() {
        const vertical = `slds-show_inline-block slds-var-m-top_xxx-small csp-reputation slds-nowrap`;
        return `${vertical} ${this.horizontal ? 'csp-reputation_horizontal' : ''}`;
    }

    get typePaddingClass() {
        return this.horizontal ? '' : 'slds-var-p-top_xxx-small slds-var-p-bottom_xx-small';
    }
}