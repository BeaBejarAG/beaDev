import { LightningElement, api, wire, track } from 'lwc';
import { NavigationMixin, CurrentPageReference } from 'lightning/navigation';
import { registerListener, unregisterListener, fireEvent } from 'c/pubsub';

import getProductsByDivision from '@salesforce/apex/cspProductFeatures.getProductsByDivision';
import getProductList from '@salesforce/apex/cspProductSelection.getAllProducts';
import ACCESS_LOGO from '@salesforce/contentAssetUrl/csp_logo_black';

export default class CspProductDivisionFilter extends NavigationMixin(LightningElement) {
    @api title;
    @api subtitle;
    @api activeSections = [];
    @api sectionOpen;
    @api matrixView = false;
    @api communityVisibility = false;

    @track products;
    @track product;
    @track validDivisions = [];

    @api divisions = [];
    
    @wire(CurrentPageReference) pageRef;

    connectedCallback() {
        registerListener('cspProductSelectionEvent', this.handleProductEvent, this);

        this.polyfillEntries();
        this.sectionOpen = true;

        this.product = JSON.parse(window.sessionStorage.getItem('selectedProduct')) || {};

        const promises = [];
        promises.push(getProductsByDivision()
            .then(result =>  this.handleProductDivisionsResponse(result))
            .catch(error => this.error = error));
        promises.push(getProductList()
            .then(result => this.handleProductList(result) )
            .catch(error => this.error = error));
        Promise.all(promises).then(productDivisions => this.handleRendering(productDivisions[0], productDivisions[1]));
    }

    disconnectedCallback() {
        unregisterListener('cspProductSelectionEvent', this.handleProductEvent, this);
    }

    @api
    get allProductsSelected() {
        return this.getActiveProduct() == null;
    }
    
    handleSectionClick(event) {
        this.sectionOpen = !this.sectionOpen;
    }

    handleProductList(productList) {
        return productList;
    }

    handleProductDivisionsResponse(divisionsObject) {
        let orderedDivisions = {};
        Object.keys(divisionsObject).sort().forEach(function(key) {
            orderedDivisions[key] = divisionsObject[key];
        });
        return orderedDivisions;
    }

    handleRendering(divisions, products) {
        this.products = [];
        for (var i = 0, len = products.length; i < len; i++) {
            const colourIndex = products[i].colour && products[i].colour.length > 0 ? products[i].colour : (i % 28) + 1;
            if (!this.communityVisibility || products[i].enabledForCommunity != 'Inactive') {
                this.products.push(
                    {
                        name: products[i].name,
                        id: products[i].id,
                        active: false,
                        colour: `access-theme-product-bar-cat${colourIndex}`,
                        image: !products[i].image || products[i].image.length == 0 ? ACCESS_LOGO : products[i].image,
                        topicId: products[i].topicId,
                        admin: products[i].admin,
                        enabledForChat: products[i].enabledForChat,
                        enabledForOnline: products[i].enabledForOnline,
                        enabledForPhone: products[i].enabledForPhone,
                        liveChatButton: products[i].liveChatButton,
                        phoneNumber: products[i].phoneNumber,
                        successPlan: products[i].successPlan,
                        successPlanName: products[i].successPlanName,
                        enabledForCommunity: products[i].enabledForCommunity,
                        communityRedirect: products[i].communityRedirect,
                        entitlementId: products[i].entitlementId
                    }
                );
            }
        }

        for (const [division, products] of Object.entries(divisions)) {
            this.divisions.push(
                {
                    name: division,
                    products: this.products.filter(p => products.find(pr => pr === p.name) != null).sort((a,b) => a.name.localeCompare(b.name))
                }
            );
        }

        this.divisions = this.divisions.filter(d => d.products && d.products.length > 0).slice();
        this.handleProductSelection();
    }

    handleProductFilterClick(event) {
        try {
            const targetProductElement = event.currentTarget;
            const selectedProduct = targetProductElement.dataset.product;
            this.product = this.products.find(pr => pr.id === selectedProduct);

            const currentActiveElement = this.template.querySelector('.active');
            if (currentActiveElement == null || currentActiveElement != targetProductElement) {
                this.handleProductSelection(true);
            }
        } catch (e) {
            console.log(e);
        }
    }

    handleAllProductsClick() {
        try {
            this.product = null;

            const currentActiveElement = this.template.querySelector('.active');
            if (currentActiveElement != null) {
                this.handleProductSelection(true);
            }
        } catch (e) {
            console.log(e);
        }
    }

    handleMatrixSelect(event) {
        const selectedId = event.currentTarget.dataset.productId;
        const product = this.products.find(pr => pr.id === selectedId);
        const communityConfig = event.currentTarget.dataset.productEnabled;
        const communityRedirect = event.currentTarget.dataset.productRedirect;
        // Redirect to a custom community if necessary
        if (this.communityVisibility && communityConfig == 'Redirection') {
            this[NavigationMixin.Navigate]({
                type: 'standard__webPage',
                attributes: {
                    url: communityRedirect
                }
            });
        } else {
            try {
                window.sessionStorage.setItem('selectedProduct', JSON.stringify(product));
                fireEvent(this.pageRef, 'cspProductSelectionEvent', {
                    product
                });
            } catch (e) {
                console.log(e);
            }
        }
    }

    handleProductEvent(event) {
        // Received an event with updated product selection
        if(event.product) {
            this.product = event.product;
            this.product.brokered = false;
            this.handleProductSelection(false);
        }
    }

    handleProductSelection(publish) {
        // Set the active value on our new selected product
        var currentActiveProduct = this.getActiveProduct();
        var newProduct = this.getProduct(this.product);
        if (currentActiveProduct != null && currentActiveProduct != newProduct) {
            currentActiveProduct.active = false;
        }
        if (newProduct != null) {
            this.setActiveProduct(newProduct);
        }
        // force a re render
        this.divisions = this.divisions.slice();

        if (publish) {
            // publish the feature event & save to session storage
            fireEvent(this.pageRef, 'cspProductSelectionEvent', {
                product: this.product != null ? this.product : {} 
            });
            window.sessionStorage.setItem('selectedProduct', JSON.stringify(this.product));
        }
    }

    getActiveProduct() {
        var activeDivision = this.divisions.find(d => d.products.find(p => p.active == true) != null);
        if (activeDivision != null) {
            return activeDivision.products.find(p => p.active == true);
        }
        return null;
    }

    setActiveProduct(product) {
        if (product != null){
            var matchingDivision = this.divisions.find(d => d.products.find(p => p.id == product.id) != null);
            if (matchingDivision != null) {
                let matchingProduct = matchingDivision.products.find(p => p.id == product.id);
                matchingProduct.active = true;
                this.activeSections = [];
                this.activeSections.push(matchingDivision.name);
                this.activeSections = this.activeSections.slice();
            }
        }
    }

    getProduct(product) {
        if (product != null){
            var matchingDivision = this.divisions.find(d => d.products.find(p => p.id == product.id) != null);
            if (matchingDivision != null) {
                return matchingDivision.products.find(p => p.id == product.id);
            }
        }
        return null;
    }

    polyfillEntries() {
        if (!Object.entries) {
            Object.entries = function( obj ){
                var ownProps = Object.keys( obj ), i = ownProps.length, resArray = new Array(i); // preallocate the Array
                while (i--) {
                    resArray[i] = [ownProps[i], obj[ownProps[i]]];
                }
                return resArray;
            };
        }
    }
}