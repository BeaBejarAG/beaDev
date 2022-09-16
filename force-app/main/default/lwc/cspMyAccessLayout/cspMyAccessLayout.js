import { LightningElement, wire } from 'lwc';
import { registerListener, unregisterListener } from 'c/pubsub';
import { CurrentPageReference } from 'lightning/navigation';

import KNOWLEDGE_BASE_IMAGE from '@salesforce/contentAssetUrl/accessknowledgebase';
import EVENTS_IMAGE from '@salesforce/contentAssetUrl/accessevents';
import RELEASES_IMAGE from '@salesforce/contentAssetUrl/accessreleases';
import SERVICES_IMAGE from '@salesforce/contentAssetUrl/accessflexpointsservices';
import FLEXPOINTS_IMAGE from '@salesforce/contentAssetUrl/accessflexpoints';
import getIsPointsGuardian from '@salesforce/apex/cspContactsHandler.getIsPointsGuardian';

export default class CspMyAccessLayout extends LightningElement {

    isPointsGuardian = false;
    accountId;

    @wire(CurrentPageReference) pageRef;

    constructor() {
        super();
        this.accountId = window.sessionStorage.getItem('selectedAccountId');
    }

    connectedCallback() {
        registerListener('cspAccountSelectionEvent', this.handleAccountSelection, this);
        this.handlePointsGuardian();
    }

    disconnectedCallback() {
        unregisterListener('cspAccountSelectionEvent', this.handleAccountSelection, this);
    }

    handleAccountSelection(event) {
        if(!event.selectedAccountId) {
            return;
        }

        this.accountId = event.selectedAccountId;
        this.handlePointsGuardian();
    }

    handlePointsGuardian() {
        getIsPointsGuardian({ selectedAccountId: this.accountId })
        .then(result => this.isPointsGuardian = result)
        .catch(error => console.log(error))
    }

    get knowledgeBaseImage() {
        return KNOWLEDGE_BASE_IMAGE;
    }

    get eventsImage() {
        return EVENTS_IMAGE;
    }

    get releasesImage() {
        return RELEASES_IMAGE;
    }

    get servicesImage() {
        return SERVICES_IMAGE;
    }

    get flexPointsImage() {
        return FLEXPOINTS_IMAGE;
    }
}