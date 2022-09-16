import { LightningElement, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

export default class CspCreateACase extends NavigationMixin(LightningElement) {
    @api componentTitle;
    @api componentDescription;

    handleClick() {
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: '/createcase'
            }
        });
    }
}