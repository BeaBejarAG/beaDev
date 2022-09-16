import { LightningElement, api, wire, track } from 'lwc';
import { NavigationMixin, CurrentPageReference } from 'lightning/navigation';
import { fireEvent } from 'c/pubsub';
import USER_ID from '@salesforce/user/Id';

import FEATURE_1 from '@salesforce/contentAssetUrl/accessfeatureimage1';
import FEATURE_2 from '@salesforce/contentAssetUrl/accessfeatureimage2';
import FEATURE_3 from '@salesforce/contentAssetUrl/accessfeatureimage3';
import FEATURE_4 from '@salesforce/contentAssetUrl/accessfeatureimage4';
import FEATURE_5 from '@salesforce/contentAssetUrl/accessfeatureimage5';
import FEATURE_6 from '@salesforce/contentAssetUrl/accessfeatureimage6';
import FEATURE_7 from '@salesforce/contentAssetUrl/accessfeatureimage7';
import FEATURE_8 from '@salesforce/contentAssetUrl/accessfeatureimage8';
import FEATURE_9 from '@salesforce/contentAssetUrl/accessfeatureimage9';
import FEATURE_10 from '@salesforce/contentAssetUrl/accessfeatureimage10';
import FEATURE_11 from '@salesforce/contentAssetUrl/accessfeatureimage11';
import FEATURE_12 from '@salesforce/contentAssetUrl/accessfeatureimage12';
import FEATURE_13 from '@salesforce/contentAssetUrl/accessfeatureimage13';

export default class CspArticleCard extends NavigationMixin(LightningElement) {
    @api direction;
    @api article;
    @api showProduct = false;
    @track userId = USER_ID || "";

    @wire(CurrentPageReference) pageRef;

    stockImages = [
        FEATURE_1,
        FEATURE_2,
        FEATURE_3,
        FEATURE_4,
        FEATURE_5,
        FEATURE_6,
        FEATURE_7,
        FEATURE_8,
        FEATURE_9,
        FEATURE_10,
        FEATURE_11,
        FEATURE_12,
        FEATURE_13,
    ];

    getArticleModulus() {
        if (!this.article || !this.article.number || this.article.number.length === 0) {
            return 0;
        }
        return parseInt(this.article.number) % 13;
    }

    get componentStyle() {
        if (this.article.image) {
            let imageMatches = this.article.image.match("<img[^>]+src=\"([^\">]+)\"");
            if (imageMatches.length > 1) {
                let src = imageMatches[1].replace(/&amp;/g, "&");
                return `background-image:url(${src});`;
            }
        }
        
        return `background-image:url(${this.stockImages[this.getArticleModulus()]});`;
    }

    get isHorizontal() {
        return this.direction == 'horizontal';
    }

    get stockImage() {
        return this.stockImages[this.getArticleModulus()];
    }

    handleclick(event){
        let selectedFeature = event.target.dataset.feature;
        if(selectedFeature != null) {
            return;
        }
        if(this.dispatchEvent(
            new CustomEvent("cspfeatureselectarticle", {
                cancelable: true,
                detail: {
                    url: this.article.url,
                    title: this.article.title
                }
            })
        )) {
            this[NavigationMixin.Navigate]({
                type: 'standard__webPage',
                attributes: {
                    url: this.article.url
                }
            });
         }
    }

    handleFeatureClick(event) {
        fireEvent(this.pageRef, 'cspProductFeatureSelectionEvent', {
            feature: event.target.value
        });

        event.stopPropagation();
        event.preventDefault();
    }
}