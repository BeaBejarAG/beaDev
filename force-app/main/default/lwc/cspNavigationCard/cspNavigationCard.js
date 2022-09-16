import { LightningElement, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

export default class CspNavigationCard extends NavigationMixin(LightningElement) {
    @api heading;
    @api image;
    @api description;
    @api linkText;
    @api link;
    @api icon;
    @api active = false;

    handleClick(event) {
        if (this.active) {
            this[NavigationMixin.Navigate]({
                type: 'standard__webPage',
                attributes: {
                    url: this.link
                }
            });
        }
    }
}