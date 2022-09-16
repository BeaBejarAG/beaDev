import { LightningElement, wire } from 'lwc';
import { NavigationMixin, CurrentPageReference } from 'lightning/navigation';

export default class CspProductMissingAlert extends NavigationMixin(LightningElement) {

    @wire(CurrentPageReference) pageRef;

    handleLinkClick(event) {
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: '/topiccatalog'
            }
        });
    }
}