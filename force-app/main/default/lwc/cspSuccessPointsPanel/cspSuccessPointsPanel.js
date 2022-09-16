import { LightningElement, wire, api, track } from 'lwc';
import { NavigationMixin, CurrentPageReference } from 'lightning/navigation';
import getServiceCatalogueEntries from '@salesforce/apex/cspServiceCatalogueEntryHandler.getServiceCatalogueEntries';
import { registerListener, unregisterListener } from 'c/pubsub';

export default class CspSuccessPointsPanel extends NavigationMixin(LightningElement) {
    @api product = null;
    @track lServices = [];
    @track accountId = '';
    showPanel = false;
    title = "Here's some ways you could use FlexPoints...";
    @wire(CurrentPageReference)
    setCurrentPageReference(currentPageReference) {
        this.pageRef = currentPageReference;
        // Only read the params of a pageref that we know actually contains this component
        this.accountId = window.sessionStorage.getItem('selectedAccountId');
        this.handleRetrieveServices();
    }

    constructor() {
        super();
        this.product = JSON.parse(window.sessionStorage.getItem('selectedProduct'));
    }

    connectedCallback() {
        this.accountId = window.sessionStorage.getItem('selectedAccountId');

        registerListener('cspProductSelectionEvent', this.handleProductSelection, this);
        registerListener('cspAccountSelectionEvent', this.handleAccountSelection, this);
    }

    disconnectedCallback() {
        unregisterListener('cspProductSelectionEvent', this.handleProductSelection, this);
        unregisterListener('cspAccountSelectionEvent', this.handleAccountSelection, this);
    }

    handleAccountSelection(event) {
        if(!event.selectedAccountId) {
            return;
        }

        this.accountId = event.selectedAccountId;

        this.handleRetrieveServices();
    }

    handleProductSelection(event) {
        // Clear the services array
        this.lServices = [];
        this.pageOffset = 0;
        // Received an event with updated product selection
        this.product = event.product;
        this.handleRetrieveServices();
    }

    @api
    handleRetrieveServices() {
        getServiceCatalogueEntries(this.getServicePayload())
        .then(response => {
            this.lServices = response;
            this.showPanel = (this.lServices.length == 4);
        })
        .catch(error => {console.log(error)})
        .finally(e => {});
    }

    getServicePayload() {
        return {
            selectedAccId: this.accountId,
            product: this.product && this.product.name && this.product.name != 'All Products' ? this.product.name : null,
            lmt: 4,
            ofst: 0,
            incrementLmt: false
        }
    }

    handleButtonClick(event) {
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: '/services-landing'
            }
        });
    }

    handleSelectService(event) {
        this.serviceId = event.currentTarget.dataset.id;
        this.navigateToNewPage();
    }

    navigateToNewPage() {
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: '/services?serviceId=' + this.serviceId
            }
        });
    }
}