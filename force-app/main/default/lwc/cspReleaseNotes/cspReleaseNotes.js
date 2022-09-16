import { LightningElement, api, wire } from 'lwc';
import { CurrentPageReference, NavigationMixin } from 'lightning/navigation';
import getReleaseNotes from '@salesforce/apex/cspReleaseNoteHandler.getReleaseNotes';
import { registerListener, unregisterListener } from 'c/pubsub';

export default class CspReleaseNotes extends NavigationMixin(LightningElement) {
    @api limitAmount;
    releaseNotes = [];

    showMore = false;
    releaseNoteCount = 0;
    offset = 0;

    hasLoadedArticle = false;
    error;
    articleUrl = '';

    errorCallback(error, stack) {
        console.log("Error : " + error + ' ' + stack);
    }

    @wire(CurrentPageReference) pageRef;

    constructor() {
        super();
        this.product = JSON.parse(window.sessionStorage.getItem('selectedProduct'));
    }

    connectedCallback() {
        registerListener('cspProductSelectionEvent', this.handleProductSelection, this);
        this.handleSearch(true);
    }

    disconnectedCallback() {
        unregisterListener('cspProductSelectionEvent', this.handleProductSelection, this);
    }

    handleSearch(reset) {
        if(reset) {
            this.offset = 0;
        }
        getReleaseNotes(this.getReleaseNotePayload())
        .then(response => {
            const data = this.handleResponseData(response)
            this.handleRendering(reset, data);
        })
        .catch(error => this.handleResponseError(error));
    }
    
    handleResponseData(response) {
        // Need to remove the wrapper the wire puts on in order to manipulate data
        return JSON.parse(JSON.stringify(response)).map(r => {
            r.releaseDate = new Date(r.releaseDate);
            r.status = this.statusmapping(r.releaseDate, r.postponed);
            r.isReleased = r.status == 'Released';
            r.isScheduled = r.status == 'Scheduled';
            r.requestUpdate = r.upgradeType == 'Request' && r.isReleased;
            return r;
        });
    }

    statusmapping(releaseDate, postponed) {
        if (postponed) {
            return 'Postponed';
        }
        return releaseDate > new Date() ? 'Scheduled' : 'Released';
    }

    handleResponseError(error) {
        this.error = JSON.stringify(error);
        console.log(this.error)
    }

    getReleaseNotePayload() {
        return {
            product: this.product && this.product.name ? this.product.name : null,
            amount: this.limitAmount,
            offset: this.offset
        }
    }

    handleRendering(reset, results) {
        // If there's more to retrieve then show the button
        this.showMore = results.length > this.limitAmount

        // Remove the additional result to match the amount requested
        if(results.length > this.limitAmount) {
            results.splice(this.limitAmount)
        }

        if(reset) {
            this.releaseNotes = [];
        }

        // Concatente these to existing results so that we can use offset
        // in the SOQL without exceeding 2000 results limit
        this.releaseNotes = this.releaseNotes.concat(results);
        this.offset = this.releaseNotes.length;

        this.completedSearch = this.releaseNotes.length == 0;
    }

    handleProductSelection(event) {
        // Received an event with updated product selection
        this.product = event.product;
        this.handleSearch(true);
    }

    handleLoadMore(event) {
        this.handleSearch(false);
    }

    handleWebinarClick(event) {
        const releaseNoteUrl = event.currentTarget.dataset.url;
        if (releaseNoteUrl == null) {
            return;
        }
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: releaseNoteUrl
            }
        });
    }

    handleRequestClick(event) {
        const releaseNoteUrl = event.currentTarget.dataset.url;
        if (releaseNoteUrl == null) {
            return;
        }
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: releaseNoteUrl
            }
        });
    }

    handleEscape(event) {
        if(event.which !== 27) {
            return;
        }
        this.articlePopup.hide();
    }

    /* Intercept article loaded event and hide spinner */
    handleArticleLoaded(event) {
        this.hasLoadedArticle = true;
    }

    handleSelectResult(event) {
        this.articleUrl = event.currentTarget.dataset.url.split('/').pop();
        this.hasLoadedArticle = false;
        this.articlePopup.show();
        event.preventDefault();
    }

    get articlePopup() {
        return this.template.querySelector('[data-id="article-popup"]');
    }
}