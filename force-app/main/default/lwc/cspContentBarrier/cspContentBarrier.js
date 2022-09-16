import { LightningElement, api, wire } from 'lwc';
import { CurrentPageReference, NavigationMixin } from 'lightning/navigation';

export default class CspContentBarrier extends NavigationMixin(LightningElement) {
    @api title;
    @api barrierDetail1;
    @api barrierDetail2;

    @wire(CurrentPageReference) pageRef;

    handleSignInClick() {
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: '/login/?startURL=' + encodeURI(window.location.pathname)
            }
        });
    }

    handleRegisterClick() {
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: '/register'
            }
        });
    }
}