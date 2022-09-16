import { LightningElement, api, wire } from 'lwc';
import { CurrentPageReference, NavigationMixin } from 'lightning/navigation';
import getCuratedArticles from '@salesforce/apex/cspCuratedCollectionHandler.getCuratedArticles';

export default class CspCuratedArticles extends LightningElement {
    @api recordId;

    @api cardResults = [];
    @api listResults = [];

    hasLoadedArticle = false;
    error;
    articleUrl = '';

    @wire(CurrentPageReference) pageRef;

    connectedCallback() {
        this.getArticles();
    }

    getArticles() {
        getCuratedArticles({collectionId: this.recordId})
        .then(response => {
            const data = this.handleResponseData(response)
            this.handleRendering(data);
        })
        .catch(error => this.handleResponseError(error));
    }

    handleResponseData(response) {
        // Need to remove the wrapper the wire puts on in order to manipulate data
        return JSON.parse(JSON.stringify(response)).map(r => {
            r.dttm = new Date(r.dttm);
            return r;
        });
    }

    handleResponseError(error) {
        this.error = JSON.stringify(error);
        console.log(this.error);
    }

    handleRendering(results) {
        this.cardResults = results.slice(0,3);
        this.listResults = results.slice(3);
    }

    /* Intercept selection of a search result and open in modal */
    handleSelectResult(event) {
        this.articleUrl = event.detail.url.split('/').pop();
        this.hasLoadedArticle = false;
        this.articlePopup.show();
        event.preventDefault();
    }

    handleListViewClick(event) {
        this.articleUrl = event.currentTarget.dataset.url.split('/').pop();
        this.hasLoadedArticle = false;
        this.articlePopup.show();
        event.preventDefault();
    }

    /* Intercept article loaded event and hide spinner */
    handleArticleLoaded(event) {
        this.hasLoadedArticle = true;
    }

    /* Detect if escape was pressed and close modal */
    handleEscape(event) {
        if(event.which !== 27) {
            return;
        }
        this.articlePopup.hide();
    }

    @api
    get horizontalFirstFeature() {
        return this.cardResults.length != 2 && window.innerWidth > 400;
    }

    get articlePopup() {
        return this.template.querySelector('[data-id="article-popup"]');
    }
}