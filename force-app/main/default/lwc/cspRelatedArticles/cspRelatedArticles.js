import { LightningElement, track, wire } from 'lwc';
import { registerListener, unregisterListener } from 'c/pubsub';
import { NavigationMixin, CurrentPageReference } from 'lightning/navigation';
import getArticle from '@salesforce/apex/CspKnowledge.getKnowledgeArticle';

export default class CspRelatedArticles extends LightningElement {
    @track title;
    @track excludeId;

    @wire(CurrentPageReference) pageRef;

    connectedCallback() {
        registerListener('cspProductSelectionEvent', this.setProduct, this);
        registerListener('cspCaseSelectionEvent', this.setCase, this);
    }

    disconnectedCallback() {
        unregisterListener('cspProductSelectionEvent', this.setProduct, this);
        unregisterListener('cspCaseSelectionEvent', this.setCase, this);
    }

    setProduct(event) {
        if(!this.pageRef.attributes.urlName) {
            return false;
        }

        getArticle({urlName: this.pageRef.attributes.urlName})
        .then(article => {
            this.excludeId = article.Id;
            this.title = article.Title;
        }).catch(e => {
            console.error(e);
        });
    }

    setCase(event) {
        this.excludeId = null;
        this.title = event.case.subject;
    }
}