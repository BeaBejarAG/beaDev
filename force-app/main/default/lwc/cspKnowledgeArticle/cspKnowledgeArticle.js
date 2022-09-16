import { LightningElement, track, api, wire } from 'lwc';
import { NavigationMixin, CurrentPageReference } from 'lightning/navigation';
import { createRecord, updateRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { fireEvent } from 'c/pubsub';
import getArticle from '@salesforce/apex/CspKnowledge.getKnowledgeArticle';
import getProduct from '@salesforce/apex/cspProductSelection.getProduct';
import ACCESS_LOGO from '@salesforce/contentAssetUrl/csp_logo_black';
import USER_ID from '@salesforce/user/Id';
import { registerListener, unregisterListener } from 'c/pubsub';

import FEEDBACK_OBJECT from '@salesforce/schema/Knowledge_Feedback__c';
import ID_FIELD from '@salesforce/schema/Knowledge_Feedback__c.Id';
import SENTIMENT_FIELD from '@salesforce/schema/Knowledge_Feedback__c.Sentiment__c';
import ARTICLE_FIELD from '@salesforce/schema/Knowledge_Feedback__c.Knowledge_Article__c';
import PRODUCT_FIELD from '@salesforce/schema/Knowledge_Feedback__c.Product__c';
import FEEDBACK_FIELD from '@salesforce/schema/Knowledge_Feedback__c.Feedback__c';
import communityBasePath from '@salesforce/community/basePath';

export default class CspKnowledgeArticle extends NavigationMixin(LightningElement) {
    @track article = {};
    @track showSentimentRequest = true;
    @track showFeedbackRequest = false;
    @track showFeedbackResponse = false;
    @track userId = USER_ID || 0;
    @track feedbackId;
    @api articleLink;
    @api showBody;
    @api showTitle;
    @api showFeedbackComponent;
    @api showProduct;
    @api urlName;
    @api displayModal = false;

    @track accountId = '';

    @wire(CurrentPageReference)
    setCurrentPageReference(currentPageReference) {
        this.pageRef = currentPageReference;

        if(!this.pageRef.attributes.urlName || this.pageRef.attributes.urlName.length === 0) {
            if(this.urlName) {
                return this.getArticle(this.urlName);
            }
            return false;
        }

        this.getArticle(this.pageRef.attributes.urlName);
    }

    constructor() {
        super();
        this.accountId = window.sessionStorage.getItem('selectedAccountId');
    }

    connectedCallback() {
       //this.articleLink = window.location.origin + communityBasePath + '/article/' +  article.urlName;
       registerListener('cspAccountSelectionEvent', this.handleAccountSelection, this);
    }

    disconnectedCallback() {
        unregisterListener('cspAccountSelectionEvent', this.handleAccountSelection, this);
    }

    handleAccountSelection(event) {
        if(!event.selectedAccountId) {
            return;
        }

        this.accountId = event.selectedAccountId;
    }

    errorCallback(error, stack) {
        console.error(error.message, error.stack);
    }

    getArticle(url) {
        getArticle({urlName: url})
        .then(article => {
            this.article = article;
            this.articleLink = window.location.origin + communityBasePath + '/article/' +  this.article.Url;
            getProduct({productName: this.article.ProductName, selectedAccId: this.accountId})
                .then(productMap => {
                    if (productMap && productMap.name) {
                        const product = {
                            name: productMap.name,
                            colour: `access-theme-product-bar-cat${productMap.colour || 0}`,
                            image: productMap.image || ACCESS_LOGO,
                            id: productMap.id,
                            enabledForChat: productMap.enabledForChat,
                            enabledForOnline: productMap.enabledForOnline,
                            enabledForPhone: productMap.enabledForPhone,
                            liveChatButton: productMap.liveChatButton,
                            phoneNumber: productMap.phoneNumber,
                            successPlan: productMap.successPlan,
                            successPlanName: productMap.successPlanName,
                            entitlementId: productMap.entitlementId,
                            admin: productMap.admin,
                            enabledForCommunity: productMap.enabledForCommunity,
                            communityRedirect: productMap.communityRedirect
                        };
                        if (!this.displayModal) {
                            fireEvent(this.pageRef, 'cspProductSelectionEvent', { product: product });
                            window.sessionStorage.setItem('selectedProduct', JSON.stringify(product));
                        }
                    } else {
                        if (!this.displayModal) {
                            fireEvent(this.pageRef, 'cspProductSelectionEvent', { product: {} });
                        }
                    }
                    fireEvent(this.pageRef, 'cspProductFeatureSelectionEvent', { feature: null });
                    window.sessionStorage.setItem('selectedProductFeature', "");
                    this.dispatchEvent(new CustomEvent('csparticleloaded'));
                }).catch(e => this.dispatchEvent(new ShowToastEvent({
                    title: 'Error retrieving product for article',
                    message: e.body ? e.body.message : e.message,
                    variant: 'error'
                })));
        })
        .catch(error => this.dispatchEvent(
            new ShowToastEvent({
                title: 'Error loading knowledge article',
                message: error.body ? error.body.message : error.message,
                variant: 'error',
            }),
        ));
    }

    get categories() {
        if(!this.article.ProductFeatures) {
            return [];
        }
        return this.article.ProductFeatures.split(";")
    }

    get publishedDate() {
        return new Date(this.article.PublishedDate);
    }

    get isReleaseNote() {
        if (!this.article) {
            return false;
        }
        return this.article.RecordType == 'Release_Notes';
    }

    handleFeatureClick(event) {
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: `/knowledge-base?feature=${event.target.value}`
            }
        });
    }

    handleTitleClick(event) {
        console.log(this.urlName);
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: '/article/' + this.urlName
            }
        });
    }

    handleSentiment(event) {
        const fields = {
            [SENTIMENT_FIELD.fieldApiName]: event.target.value,
            [ARTICLE_FIELD.fieldApiName]: this.article.Id,
            [PRODUCT_FIELD.fieldApiName]: this.article.ProductName
        };

        this.dispatchEvent(new CustomEvent('cspsubmittedarticlefeedback', {
            detail: event.target.value
        }));

        createRecord({
            apiName: FEEDBACK_OBJECT.objectApiName,
            fields
        })
        .then(feedback => {
            this.feedbackId = feedback.id;
            this.showSentimentRequest = false;
            this.showFeedbackRequest = true;
        })
        .catch(error => this.dispatchEvent(
            new ShowToastEvent({
                title: 'Error creating feedback',
                message: error.message,
                variant: 'error',
            }),
        ));
    }

    handleFeedback(event) {
        const feedback = this.template.querySelector('lightning-textarea').value;

        const fields = {
            [ID_FIELD.fieldApiName]: this.feedbackId,
            [FEEDBACK_FIELD.fieldApiName]: feedback
        };

        updateRecord({
            fields
        })
        .then(account => {
            this.feedbackId = account.id;
            this.showFeedbackRequest = false;
            this.showFeedbackResponse = true;
        })
        .catch(error => this.dispatchEvent(
            new ShowToastEvent({
                title: 'Error creating feedback',
                message: error.message,
                variant: 'error',
            }),
        ));
    }

    handlePrint() {
        window.print();
    }

    handleShare() {
        this.template.querySelector('c-csp-modal').show();
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
        textArea.value = this.articleLink;

        document.body.appendChild(textArea);
        textArea.focus();
        textArea.select();

        textArea.setSelectionRange(0, 99999);
        document.execCommand("copy");

        document.body.removeChild(textArea);

        const element = this.template.querySelector('.csp-knowledge-copied');
        element.classList.remove('slds-hide');

        setTimeout(() => {
            element.classList.add('slds-hide');
        }, 3000);
    }
}