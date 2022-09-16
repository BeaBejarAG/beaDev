import { LightningElement, wire, api } from 'lwc';
import { getListUi } from 'lightning/uiListApi';
import { CurrentPageReference, NavigationMixin } from 'lightning/navigation';
import { registerListener, unregisterListener } from 'c/pubsub';
import getEvents from '@salesforce/apex/cspEvents.getEvents';
import getEvent from '@salesforce/apex/cspEvents.getEvent';
import EVENTS_OBJECT from '@salesforce/schema/Event__c';

import EVENT_1 from '@salesforce/contentAssetUrl/csp_event_1';
import EVENT_2 from '@salesforce/contentAssetUrl/csp_event_2';
import EVENT_3 from '@salesforce/contentAssetUrl/csp_event_3';
import EVENT_4 from '@salesforce/contentAssetUrl/csp_event_4';
import EVENT_5 from '@salesforce/contentAssetUrl/csp_event_5';
import EVENT_6 from '@salesforce/contentAssetUrl/csp_event_6';
import EVENT_7 from '@salesforce/contentAssetUrl/csp_event_7';
import EVENT_8 from '@salesforce/contentAssetUrl/csp_event_8';
import EVENT_9 from '@salesforce/contentAssetUrl/csp_event_9';
import EVENT_10 from '@salesforce/contentAssetUrl/csp_event_10';
import EVENT_11 from '@salesforce/contentAssetUrl/csp_event_11';
import EVENT_12 from '@salesforce/contentAssetUrl/csp_event_12';
import EVENT_13 from '@salesforce/contentAssetUrl/csp_event_13';
import EVENT_14 from '@salesforce/contentAssetUrl/csp_event_14';

export default class CspEventsList extends NavigationMixin(LightningElement) {
    offset = 0;
    amount = 10;
    product;
    events;
    active;
    pageRef;
    @api Feedback_URL;

    stockImages = [
        EVENT_1, EVENT_2, EVENT_3, EVENT_4, EVENT_5,
        EVENT_6, EVENT_7, EVENT_8, EVENT_9, EVENT_10,
        EVENT_11, EVENT_12, EVENT_13, EVENT_14
    ];

    @wire(CurrentPageReference)
    async setPageReference(currentPageReference) {
        this.pageRef = currentPageReference;

        if(!this.pageRef.state.category && this.pageRef.attributes.name == 'Event__c') {
            const category = 'All';
            return this.navigate({category});
        }

        this.getEvents();
    }

    constructor() {
        super();
        const product = window.sessionStorage.getItem('selectedProduct');
        this.product = product ? JSON.parse(product) : null;
    }

    async connectedCallback() {
        registerListener('cspProductSelectionEvent', this.setProduct, this);
    }

    async disconnectedCallback() {
        unregisterListener('cspProductSelectionEvent', this.setProduct, this);
    }

    async setProduct(event) {
        this.product = event.product ? event.product : null;
        this.offset = 0;
        this.getEvents();
    }

    async getEvents() {
        const results = await getEvents({
            product: !this.product || !this.product.id ? null : this.product,
            category: this.pageRef.state.category,
            offset: this.offset,
            amount: this.amount
        });

        const eventList = JSON.parse(JSON.stringify(results));

        if(!eventList) {
            this.events = this.offset > 0 ? this.events : null;
            return;
        }

        this.showMore = eventList.splice(this.amount).length > 0;

        eventList.forEach(e => {
            const image = this.stockImages[(e.name.replace('E-', '') % 14)];
            e.image = `background-image: url(${image}); background-size: cover`;

            if(this.offset > 0 && this.events && this.events.find(u => u.id == e.id)) {
                this.events.splice(this.events.findIndex(u => u.id == e.id), 1);
            }
        });

        this.events = this.offset > 0 ? this.events.concat(eventList) : eventList;

        if(this.pageRef.state.active) {
            this.active = this.events.find(e => e.name === this.pageRef.state.active);
            if(!this.active) {
                this.active = await getEvent({
                    eventId: this.pageRef.state.active,
                });
            }
            this.template.querySelector('[data-id="popup"]').show();
        }
    }

    handleLoadMore(event) {
        this.offset += this.amount;
        this.getEvents(this.product, this.pageRef.state.category);
    }

    handleViewEvent(event) {
        this.navigate({
            active: event.target.value,
            category: this.pageRef.state.category
        });
    }

    handleCloseDialog() {
        this.navigate({
            category: this.pageRef.state.category
        });
    }

    handleViewCategory(event) {
        const category = event.detail.name;

        if(category && category !== this.pageRef.state.category) {
            this.offset = 0;
            this.navigate({category});
        }
    }

    handleRegister(event) {
        window.open(event.target.value);
    }

    handleViewRecording(event) {
        window.open(event.target.value);
    }

    handleEscape(event) {
        if(event.which !== 27) {
            return;
        }
        if(this.template.querySelector('[data-id="share"]').isShowing()) {
            this.template.querySelector('[data-id="share"]').hide();
        } else {
            this.template.querySelector('[data-id="popup"]').hide();
            this.handleCloseDialog();
        }
    }

    navigate(state) {
        if(JSON.stringify(state) === JSON.stringify(this.pageRef.state)) {
            return;
        }

        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                name: 'Events__c',
            }, state
        });
    }

    handleShare() {
        this.template.querySelector('[data-id="share"]').show();
    }

    get eventUrl() {
        return document.location.href;
    }

    handleCopy() {
        const textArea = document.createElement("textarea");
        textArea.style.position = 'fixed';
        textArea.style.top = 0;
        textArea.style.left = 0;
        textArea.style.width = '2em';
        textArea.style.height = '2em';
        textArea.style.border = 'none';
        textArea.style.background = 'transparent';
        textArea.value = document.location.href;

        document.body.appendChild(textArea);
        textArea.focus();
        textArea.select();

        textArea.setSelectionRange(0, 99999);
        document.execCommand("copy");

        document.body.removeChild(textArea);

        const element = this.template.querySelector('.csp-share-copied');
        element.classList.remove('slds-hide');

        setTimeout(() => {
            element.classList.add('slds-hide');
        }, 3000);
    }

    errorCallback(error) {
        console.error(error);
    }

    @api
    get productSelected() {
        return this.product && this.product.id;
    }
}