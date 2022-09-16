import { LightningElement, api, wire } from 'lwc';
import { NavigationMixin, CurrentPageReference } from 'lightning/navigation';
import { registerListener, unregisterListener } from 'c/pubsub';

import getCuratedCollections from '@salesforce/apex/cspCuratedCollectionHandler.getCuratedCollections';

export default class CspCuratedCollection extends NavigationMixin(LightningElement) {
    @api title;
    @api subtitle;
    cardTarget = '/curated-collection/';
    @api collections;

    product = null;

    @wire(CurrentPageReference)
    setCurrentPageReference(currentPageReference) {
        this.pageRef = currentPageReference;
        this.fetchCollections();
    }

    constructor() {
        super();
        let productObject = JSON.parse(window.sessionStorage.getItem('selectedProduct'));
        this.product = productObject && productObject.name ? productObject.name : '';
    }

    connectedCallback() {
        registerListener('cspProductSelectionEvent', this.handleProductSelection, this);
        this.fetchCollections();
    }

    disconnectedCallback() {
        unregisterListener('cspProductSelectionEvent', this.handleProductSelection, this);
    }

    errorCallback(error, stack) {
        console.log("Error : " + error + ' ' + stack);
    }

    handleProductSelection(event) {
        // Received an event with updated product selection
        let productObject = event.product;
        this.product = productObject && productObject.name ? productObject.name : '';
        this.fetchCollections();
    }

    fetchCollections() {
        if (!this.product) {
            this.collections = null;
            return;
        }

        getCuratedCollections({product: this.product})
        .then(response => {
            const data = this.handleResponseData(response)
            this.handleRendering(data);
        })
        .catch(error => this.handleResponseError(error));
    }

    handleResponseData(response) {
        // Need to remove the wrapper the wire puts on in order to manipulate data
        return JSON.parse(JSON.stringify(response)).map(r => {
            r.articleCount += ' articles';
            r.icon = 'utility:' + r.icon;
            return r;
        });
    }

    handleResponseError(error) {
        this.error = JSON.stringify(error);
        console.log(this.error);
    }

    handleRendering(results) {
        this.collections = results.length > 0 ? results : null;
    }

    handleCardClick(event) {
        let collectionId = event.currentTarget.dataset.id;
        if (collectionId) {
            this[NavigationMixin.Navigate]({
                type: 'standard__webPage',
                attributes: {
                    url: this.cardTarget + collectionId
                }
            });
        }
    }
}