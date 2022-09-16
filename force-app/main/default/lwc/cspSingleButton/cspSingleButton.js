import { LightningElement, wire, api } from 'lwc';
import { CurrentPageReference, NavigationMixin } from 'lightning/navigation';

export default class CspSingleButton extends NavigationMixin(LightningElement) {
    @api urlTarget;
    @api buttonLabel;
    @api internal = false;

    @wire(CurrentPageReference) pageRef;
    
    handleClick(event) {
        if (this.internal) {
            this[NavigationMixin.Navigate]({
                type: 'standard__webPage',
                attributes: {
                    url: '/Support/s' + this.urlTarget
                }
            });
        } else {
            this[NavigationMixin.Navigate]({
                type: 'standard__webPage',
                attributes: {
                    url: this.urlTarget
                }
            });
        }
    }
}