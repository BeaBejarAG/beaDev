import { LightningElement, api, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CurrentPageReference, NavigationMixin } from 'lightning/navigation';

import getBreadcrumbComponent from '@salesforce/apex/cspCommunity.getBreadcrumbComponent';

export default class CspCommunityBreadcrumbs extends NavigationMixin(LightningElement) {
    @api recordId;
    items;

    @wire(CurrentPageReference)
    async setCurrentPageReference(pageRef) {
        const items = [{
            label: 'Community Home',
            value: '/community'
        }];

        if(!this.recordId) {
            return this.items = items;
        }
        const result = await getBreadcrumbComponent({ recordId: this.recordId });
        this.items = items.concat(result.map(e => ({ label: this.decodeEntities(e.name), value: e.url})));
    }

    decodeEntities(input) {
        const element = document.createElement('textarea');
        element.innerHTML = input;
        return element.textContent;
    }

    errorCallback(e) {
        console.error(e);
        this.dispatchEvent(new ShowToastEvent({
            message: e.body ? e.body.message : e.message,
            variant: 'error'
        }));
    }

    handleClick(event) {
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: event.target.value
            }
        });
    }
}