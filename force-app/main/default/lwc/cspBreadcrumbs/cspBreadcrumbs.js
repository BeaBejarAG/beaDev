import { LightningElement, api, track, wire  } from 'lwc';
import { registerListener, unregisterListener } from 'c/pubsub';

import { NavigationMixin, CurrentPageReference } from 'lightning/navigation';

export default class CspBreadcrumbs extends NavigationMixin(LightningElement) {
    @api displayProduct = false;
    @api displaySubNavItem = false;
    @api displayFeature = false;
    @api subNavItemName;
    @api subNavLink;

    @track feature;
    @track product;

    @wire(CurrentPageReference) pageRef;

    connectedCallback() {
        registerListener('cspProductSelectionEvent', this.handleProductSelection, this);
        registerListener('cspProductFeatureSelectionEvent', this.handleProductFeatureSelection, this);

        const sessionProduct = JSON.parse(window.sessionStorage.getItem('selectedProduct')) || null;
        if (sessionProduct != null && sessionProduct.name != null && sessionProduct.name != '') {
            this.product = sessionProduct.name;
        } else {
            this.product = 'All Products';
        }
        this.feature = window.sessionStorage.getItem('selectedProductFeature') || "All Articles";
    }

    disconnectedCallback() {
        unregisterListener('cspProductSelectionEvent', this.handleProductSelection, this);
        unregisterListener('cspProductFeatureSelectionEvent', this.handleProductFeatureSelection, this);
    }

    handleProductSelection(event) {
        // Received an event with updated product selection
        if (event.product != null && event.product.name != null && event.product.name != '') {
            this.product = event.product.name;
        } else {
            this.product = 'All Products';
        }
    }

    handleProductFeatureSelection(event) {
        // Received an event with updated product selection
        this.feature = event.feature || "All Articles";
    }

    handlePortalClick(){
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: '/'
            }
        });
    }

    handleProductClick(){
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: '/help-centre'
            }
        });
    }

    handleSubNavClick(){
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: this.subNavLink
            }
        });
    }
}