import { LightningElement, wire, api} from 'lwc';
import { fireEvent } from 'c/pubsub';
import { CurrentPageReference } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import getFeaturedTopics from '@salesforce/apex/cspCommunity.getFeaturedTopics';

import USER_ID from '@salesforce/user/Id';

export default class CspCommunityNavigation extends LightningElement {
    @api profileNavigation = false;
    @api recordId;
    selectedItem = '';
    featuredTopics = [];

    @wire(CurrentPageReference)
    setPageReference(pageRef) {
        this.pageRef = pageRef;
        this.selectedItem = this.pageRef.state.show;
    }

    connectedCallback() {
        if(this.profileNavigation) {
            return;
        }
        this.getTopics();
    }

    async getTopics() {
        const topics = await getFeaturedTopics();

        this.featuredTopics = topics.managedTopics.map(e => ({
            value: e.topic.id,
            label: this.decodeEntities(e.topic.name),
            id: e.id
        }))

        if(this.featuredTopics && this.featuredTopics.length > 0) {
            this.selectedItem = this.featuredTopics[0].value;
        }
    }

    handleSelected(event) {
        if(this.lastSelected === event.detail.name + this.recordId) {
            return;
        }

        let cacheable = false;

        if(this.featuredTopics && this.featuredTopics.length > 0) {
            cacheable = this.featuredTopics[0].value === event.detail.name;
        }

        this.lastSelected = event.detail.name + this.recordId;
        fireEvent(this.pageRef, 'cspCommunityNavigationEvent', {
            show: event.detail.name,
            recordId: this.recordId,
            cacheable
        });
    }

    errorCallback(e) {
        console.error(e);
        this.dispatchEvent(new ShowToastEvent({
            message: e.body ? e.body.message : e.message,
            variant: 'error'
        }));
    }

    decodeEntities(input) {
        const element = document.createElement('textarea');
        element.innerHTML = input;
        return element.textContent;
    }

    get isCurrentUser() {
        return this.recordId === USER_ID;
    }
}