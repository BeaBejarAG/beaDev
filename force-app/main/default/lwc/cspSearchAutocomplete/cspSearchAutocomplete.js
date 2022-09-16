import { LightningElement, wire, api, track  } from 'lwc';
import { subscribe, unsubscribe, APPLICATION_SCOPE, MessageContext } from 'lightning/messageService';
import searchKnowledge from '@salesforce/apex/cspGlobalSearchHandler.searchKnowledge';
import searchCommunities from '@salesforce/apex/cspGlobalSearchHandler.searchCommunities';
import searchServicesCatalogue from '@salesforce/apex/cspGlobalSearchHandler.searchServicesCatalogue';
import searchEvents from '@salesforce/apex/cspGlobalSearchHandler.searchEvents';
import searchReleaseNotes from '@salesforce/apex/cspGlobalSearchHandler.searchReleaseNotes';
import { NavigationMixin, CurrentPageReference } from 'lightning/navigation';
import { registerListener, unregisterListener } from 'c/pubsub';

export default class CspSearchAutocomplete extends NavigationMixin(LightningElement) {
    @api searchText;
    @api limitAmount;

    product = {};
    categories = [];
    handlerUrl;
    itemCount = 0;
    desiredCount = 3;

    @track accountId = '';

    @wire(MessageContext) messageContext;
    @wire(CurrentPageReference) pageRef;

    constructor() {
        super();
        this.accountId = window.sessionStorage.getItem('selectedAccountId');
    }

    connectedCallback() {
        this.product = JSON.parse(window.sessionStorage.getItem('selectedProduct'));
        registerListener('cspProductSelectionEvent', this.setProduct, this);
        registerListener('cspAccountSelectionEvent', this.handleAccountSelection, this);
    }

    disconnectedCallback() {
        unregisterListener('cspProductSelectionEvent', this.setProduct, this);
        unregisterListener('cspAccountSelectionEvent', this.handleAccountSelection, this);
    }

    errorCallback(error, stack) {
        console.log(error, error.message, stack);
    }

    @api
    search(searchText, handlerUrl, config) {
        const promises = [];

        this.searchText = searchText || this.searchText
        this.handlerUrl = handlerUrl || this.handlerUrl

        if(config.includeKnowledge) {
            promises.push(searchKnowledge(this.getPayload('Knowledge__kav'))
            .then(r => this.processResult(r, 'Knowledge Base', 'utility:knowledge_base')))
        }
        if(config.includeCommunity) {
                promises.push(searchCommunities(this.getPayload('FeedItem', true))
            .then(r => this.processResult(r, 'Community', 'utility:advertising')))
        }
        if(config.includeEvents) {
            promises.push(searchEvents(this.getPayload('Event__c'))
            .then(r => this.processResult(r, 'Events', 'utility:date_time')))
        }
        if(config.includeReleaseNotes) {
            promises.push(searchReleaseNotes(this.getPayload('Knowledge__kav'))
            .then(r => this.processResult(r, 'Release Notes', 'utility:setup_assistant_guide')))
        }
        if(config.includeServicesCatalogue) {
            promises.push(searchServicesCatalogue(this.getPayload('Service_Catalogues__c'))
            .then(r => this.processResult(r, 'Service Catalogue', 'utility:knowledge_base'))
            )
        }

        Promise.all(promises).then(e => this.handleRendering(e.filter(c => c.items.length > 0)));
    }

    @api
    show() {
        if(this.searchText && this.searchText.length > 2 && this.categories.length > 0) {
            this.template.querySelector('.csp-autocomplete').classList.remove('slds-hide');
         }
    }

    @api
    hide() {
        this.template.querySelector('.csp-autocomplete').classList.add('slds-hide');
    }

    handleAccountSelection(event) {
        if(!event.selectedAccountId) {
            return;
        }

        this.accountId = event.selectedAccountId;
    }

    processResult(response, category, icon) {
        response = JSON.parse(JSON.stringify(response));
        response.sort((a, b) => b.dttm - a.dttm);

        return {
            category, icon,
            children: response.length > 0,
            hasMore: response.length > this.desiredCount,
            items: response.splice(0, this.desiredCount)
        }
    }

    handleSelect(event) {
        this.redirect(event.target.value);
    }

    handleMouseDown(event) {
        event.preventDefault();
    }

    handleRendering(results) {
        this.hasMore = results.reduce((r, e) => e.hasMore ? e.hasMore : r, false);
        this.categories = results.filter(e => e !== undefined);
        if(this.categories.length > 0) {
            this.show();
        } else {
            this.hide();
        }
    }

    @api
    setProduct(event) {
        this.product = event.product;
    }

    handleViewAll(event) {
       this.redirect( `${this.handlerUrl}?term=${this.searchText}`);
    }

    redirect(url) {
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: { url }
        });
        this.hide();
    }

    getPayload(type, communityPayload) {
        if (communityPayload){
            return {
                query: this.searchText,
                highlight: false,
                excludeObject: null,
                product: this.product ? this.product.name : null,
                amount: this.desiredCount,
                offset: 0,
                objectName: type
            }
        } else {
            return {
                query: this.searchText,
                highlight: false,
                excludeObject: null,
                product: this.product ? this.product.name : null,
                amount: this.desiredCount,
                offset: 0,
                objectName: type,
                selectedAccId: this.accountId
            }
        }
    }
}