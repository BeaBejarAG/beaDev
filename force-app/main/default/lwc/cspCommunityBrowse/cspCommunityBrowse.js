import { LightningElement, wire, api } from 'lwc';
import { CurrentPageReference, NavigationMixin } from 'lightning/navigation';
import { registerListener, unregisterListener } from 'c/pubsub';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import getGroups from '@salesforce/apex/cspCommunity.getGroups';

export default class CspCommunityBrowse extends NavigationMixin(LightningElement) {
    @api displayStyle;
    @api displayType;
    @api showAll = false;
    memberGroups;
    groups;

    @wire(CurrentPageReference) pageRef;

    async connectedCallback() {
        if(this.showGroups) {
            this.handleGetGroups()
        }
        registerListener('cspProductSelectionEvent', this.handleProductSelection, this);
    }

    errorCallback(e) {
        console.error(e);
        this.dispatchEvent(new ShowToastEvent({
            message: e.body ? e.body.message : e.message,
            variant: 'error'
        }));
    }

    disconnectedCallback() {
        unregisterListener('cspProductSelectionEvent', this.handleProductSelection, this);
    }

    handleViewGroup(event) {
        this.navigateTo(event.currentTarget.dataset.id);
    }

    handleProductSelection(event) {
        this.navigateTo(event.product.topicId);
    }

    navigateTo(recordId) {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId,
                actionName: 'view'
            }
        });
    }

    handleViewProducts() {
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: '/topiccatalog'
            }
        });
    }

    handleViewGroups() {
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: '/groups'
            }
        });
    }

    async handleGetGroups(event) {
        if(this.groups) {
            return false;
        }
        this.groups = JSON.parse(JSON.stringify(await getGroups({})));
        this.groups.groups.forEach(e => {
            e.memberCountLabel = `${e.memberCount} members`;
            e.name = this.decodeEntities(e.name);
            e.description = this.decodeEntities(e.description);
        });

        /* TODO - find more scalable way of filtering user's groups */
        this.memberGroups = this.groups.groups.filter(e => e.mySubscription !== null);
    }

    decodeEntities(input) {
        const element = document.createElement('textarea');
        element.innerHTML = input;
        return element.textContent;
    }

    get showProductsAndGroups() {
        return this.displayType === 'All';
    }

    get showProducts() {
        return this.displayType === 'Products';
    }

    get showGroups() {
        return this.displayType === 'Groups';
    }
}