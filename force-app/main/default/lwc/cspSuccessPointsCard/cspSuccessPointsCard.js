import { LightningElement, api } from 'lwc';

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

export default class CspSuccessPointsCard extends LightningElement {
    @api service;

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

    getServiceModulus() {
        if (!this.service) {
            return 0;
        }
        const imageNum = this.service.Id.split('').map(x => x.charCodeAt(0)).reduce((a, b) => a + b);
        return parseInt(imageNum) % 13;
    }

    get stockImage() {
        return this.stockImages[this.getServiceModulus()];
    }
}