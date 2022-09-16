import { LightningElement, wire, track } from 'lwc';
import getSupportAnalysts from '@salesforce/apex/cspSupportAnalystsHandler.getSupportAnalysts';
import ACCESS_LOGO from '@salesforce/contentAssetUrl/csp_logo_black';
import { registerListener, unregisterListener } from 'c/pubsub';
import { CurrentPageReference } from 'lightning/navigation';

export default class CspSupportAnalysts extends LightningElement {

    supportAnalysts;
    isLoading = true;
    @track accountId = '';

    @wire(CurrentPageReference) pageRef

    constructor() {
        super();
        this.accountId = window.sessionStorage.getItem('selectedAccountId');
    }

    connectedCallback() {
        registerListener('cspAccountSelectionEvent', this.handleAccountSelection, this);
        this.retrieveSupportAnalysis();
    }

    disconnectedCallback() {
        unregisterListener('cspAccountSelectionEvent', this.handleAccountSelection, this);
    }

    handleAccountSelection(event) {
        if(!event.selectedAccountId) {
            return;
        }

        this.accountId = event.selectedAccountId;
        this.retrieveSupportAnalysis();
    }

    retrieveSupportAnalysis() {
        getSupportAnalysts({selectedAccId: this.accountId})
        .then((data) => {
            this.isLoading = false;
            this.supportAnalysts = JSON.parse(JSON.stringify(data)).map((e, i) => {
                const colourIndex = (i % 28) + 1;
                e.colour = `access-theme-product-bar-cat${colourIndex}`;
                e.image = ACCESS_LOGO;

                if (e.NamedAgentEntitlement__c) {
                    e.photoUrl = e.NamedAgentEntitlement__r.IsProfilePhotoActive ? e.NamedAgentEntitlement__r.MediumPhotoUrl : '';
                    e.initials = e.NamedAgentEntitlement__r.Name[0];

                    const total = e.NamedAgentEntitlement__c.split('').map(x => x.charCodeAt(0)).reduce((a, b) => a + b);
                    e.avatar = `csp-avatar_small access-theme-user-cat${total % 28}`;
                }

                return e
            });
        }).catch((error) => {
            this.isLoading = false;
            console.log(error);
        }).finally(() => {this.isLoading = false});
    }
}