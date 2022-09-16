import { LightningElement, track, api, wire } from 'lwc';
import { NavigationMixin, CurrentPageReference } from 'lightning/navigation';
import { fireEvent } from 'c/pubsub';

import getProductList from '@salesforce/apex/cspProductSelection.getProductList';
import ACCESS_LOGO from '@salesforce/contentAssetUrl/csp_logo_black';
import { registerListener, unregisterListener } from 'c/pubsub';

export default class CspProductSelectionMatrix extends NavigationMixin(LightningElement) {
    @api errorMessage;
    @api displayStyle = "Two column";
    @api showAll = false;
    @api disableAccountProducts = false;
    @api communityVisibility = false;

    @track products;
    @track viewAllProducts = false;

    @api productTarget = '/help-centre';
    @track refreshing = true;

    @wire(CurrentPageReference) pageRef;
    
    constructor() {
        super();
        const accountId = window.sessionStorage.getItem('selectedAccountId');
        this.getProducts(accountId);
    }

    /* Load product from session and add listener */
    connectedCallback() {
        registerListener('cspAccountSelectionEvent', this.handleAccountSelection, this);
    }

    /* Remove listener */
    disconnectedCallback() {
        unregisterListener('cspAccountSelectionEvent', this.handleAccountSelection, this);
    }

    handleAccountSelection(event) {
        if(!event.selectedAccountId) {
            return;
        }

        const accountId = event.selectedAccountId;
        this.getProducts(accountId);
    }

    getProducts(selectedAccountId) {
        this.products = [];
        this.refreshing = true;
        getProductList({selectedAccId: selectedAccountId})
        .then(data => {
            const receivedProducts = JSON.parse(JSON.stringify(data));
            if (receivedProducts.length == 0 ) {
                this.products = null;
                return;
            }
            this.products = receivedProducts.map((e, i) => {
                const colourIndex = e.colour && e.colour.length > 0 ? e.colour : (i % 28) + 1;
                e.colour = `access-theme-product-bar-cat${colourIndex}`;

                if (!e.image || e.image.length == 0) {
                    e.image = ACCESS_LOGO;
                }
                return e
            })
            .filter(product => !this.communityVisibility || product.enabledForCommunity != 'Inactive')
            .sort((a, b) => a.name.localeCompare(b.name));

        }).catch(error => {
            this.error = error;
            this.products = null;
        })
        .finally(() => {this.refreshing = false;})
    }

    get buttonIcon() {
        return this.viewAllProducts ? "utility:arrowup" : "utility:arrowdown";
    }

    get productMatrixClass() {
        let classList = 'slds-col access-product-matrix';
        classList += this.viewAllProducts ? " is-open" : "";
        classList += this.moreProducts && !this.showAll ? " slds-border_bottom" : "";
        classList += this.showAll ? " access-product-matrix__show-all" : "";
        classList += this.compact ? " access-product-matrix__compact" : "";
        classList += this.oneColumn ? " access-product-matrix__one-column" : "";
        classList += this.oneColumn || this.compact ? "" : " slds-var-m-horizontal_xx-large";
        return classList;
    }

    get faderClass() {
        if (!this.moreProducts) {
            return "";
        }
        return this.viewAllProducts ? "" : "access-product-matrix__fader";
    }

    get gridClass() {
        if(this.compact) {
            return 'slds-size_1-of-1 slds-medium-size_1-of-2 slds-large-size_3-of-12';
        } else if(this.oneColumn) {
            return 'slds-size_1-of-1';
        } else {
            return 'slds-size_1-of-1 slds-large-size_1-of-2';
        }
    }

    get wrapperClass() {
        return this.compact ? '' : 'slds-var-p-top_x-large';
    }

    handleExpandClick() {
        this.viewAllProducts = !this.viewAllProducts;
    }

    handleProductSelect(event) {
        const communityConfig = event.currentTarget.dataset.productEnabled;
        const communityRedirect = event.currentTarget.dataset.productRedirect;
        if (this.communityVisibility && communityConfig == 'Redirection'){
            this[NavigationMixin.Navigate]({
                type: 'standard__webPage',
                attributes: {
                    url: communityRedirect
                }
            });
        } else {
            try {
                const selectedId = event.currentTarget.dataset.productId;
                const product = this.products.find(pr => pr.id === selectedId);
                window.sessionStorage.setItem('selectedProduct', JSON.stringify(product));
                fireEvent(this.pageRef, 'cspProductSelectionEvent', {
                    product
                });
            } catch (e) {
                console.log(e);
            }
    
            if(this.productTarget) {
                this[NavigationMixin.Navigate]({
                    type: 'standard__webPage',
                    attributes: {
                        url: this.productTarget
                    }
                });
            }
        }
    }

    get moreProducts() {
        return this.products != null && this.products.length > 4;
    }

    get oneColumn() {
        return this.displayStyle === 'One column';
    }

    get twoColumn() {
        return this.displayStyle === 'Two column';
    }

    get compact() {
        return this.displayStyle === 'Compact';
    }
}