import { LightningElement, api  } from 'lwc';

import { NavigationMixin } from 'lightning/navigation';

export default class CspAskTheCommunity extends NavigationMixin(LightningElement) {
    @api assistiveText;
    @api buttonText;
    @api target;
    @api displayAssistiveText = false;

    handleclick(){
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: this.target
            }
        });
    }
}