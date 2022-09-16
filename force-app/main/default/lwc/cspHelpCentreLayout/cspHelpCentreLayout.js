import { LightningElement, api } from 'lwc';

import KNOWLEDGE_BASE_IMAGE from '@salesforce/contentAssetUrl/accessknowledgebase';
import EVENTS_IMAGE from '@salesforce/contentAssetUrl/accessevents';
import RELEASES_IMAGE from '@salesforce/contentAssetUrl/accessreleases';

export default class CspHelpCentreLayout extends LightningElement {
    get knowledgeBaseImage() {
        return KNOWLEDGE_BASE_IMAGE;
    }

    get eventsImage() {
        return EVENTS_IMAGE;
    }

    get releasesImage() {
        return RELEASES_IMAGE;
    }
}