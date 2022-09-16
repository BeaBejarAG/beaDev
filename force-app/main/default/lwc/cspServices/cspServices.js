import { LightningElement, wire, api } from 'lwc';
import { NavigationMixin, CurrentPageReference } from 'lightning/navigation';
import { registerListener, unregisterListener } from 'c/pubsub';

export default class CspServices extends NavigationMixin(LightningElement) {

    showStepProduct = true;
    @api showAll = false;

    @wire(CurrentPageReference)
    setCurrentPageReference(pageRef) {
        this.pageRef = pageRef;

        if(!pageRef.state.step) {
            return this.showStepProduct = true;
        }

        if(pageRef.state.step === 'browse') {
            return this.showStepProduct = false;
        }
    }

    connectedCallback() {
        registerListener('cspProductSelectionEvent', this.setProduct, this);
    }

    disconnectedCallback() {
        unregisterListener('cspProductSelectionEvent', this.setProduct, this);
    }

    setProduct() {
        const state = { step: 'browse' };

        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                name: `Services__c`
            },
            state
        });
    }
}