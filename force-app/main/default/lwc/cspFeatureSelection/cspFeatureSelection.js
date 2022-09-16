import { LightningElement, api, track, wire } from 'lwc';
import { registerListener, unregisterListener, fireEvent } from 'c/pubsub';
import { NavigationMixin, CurrentPageReference } from 'lightning/navigation';

import getProductFeatures from '@salesforce/apex/cspProductFeatures.getProductFeatures';

export default class CspFeatureSelection extends NavigationMixin(LightningElement) {
    @api title;
    @api subtitle;
    @api displayStyle;
    @api displayIcons = false;
    @api features;
    @api sectionOpen = false;

    @track feature;
    @track product;
    @track error;
    cardTarget = '/knowledge-base';

    @wire(CurrentPageReference)
    setPageReference(pageRef) {
        this.pageRef = pageRef;

        if(this.pageRef.state && this.pageRef.state.feature) {
            this.feature = decodeURIComponent(this.pageRef.state.feature);
        }
    }

    connectedCallback() {
        registerListener('cspProductSelectionEvent', this.handleProductSelection, this);
        registerListener('cspProductFeatureSelectionEvent', this.handleFeatureSelection, this);

        this.product = JSON.parse(window.sessionStorage.getItem('selectedProduct')) || null;
        this.feature = window.sessionStorage.getItem('selectedProductFeature') || null;

        this.updateProductFeatures();
        this.sectionOpen = true;
    }

    disconnectedCallback() {
        unregisterListener('cspProductSelectionEvent', this.handleProductSelection, this);
        unregisterListener('cspProductFeatureSelectionEvent', this.handleFeatureSelection, this);
    }

    get isHorizontal() {
        return this.displayStyle == 'Horizontal';
    }

    handleSectionClick(event) {
        this.sectionOpen = !this.sectionOpen;
    }

    handleFeatureCardClick(event) {
        try {
            let selectedFeature = event.currentTarget.dataset.feature;
            if(selectedFeature === 'All Articles') {
                selectedFeature = '';
            }
            window.sessionStorage.setItem('selectedProductFeature', selectedFeature);
        } catch (e) {
            console.log(e);
        }
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: this.cardTarget
            }
        });
    }

    handleFeatureFilterClick(event) {
        try {
            const targetFeatureElement = event.currentTarget;
            const selectedFeature = targetFeatureElement.dataset.feature;
            this.feature = selectedFeature;

            const currentActiveElement = this.template.querySelector('.active');
            if (currentActiveElement == null || currentActiveElement != targetFeatureElement) {
                this.handleFeatureChange(true);
            }
        } catch (e) {
            console.log(e);
        }
    }

    handleProductSelection(event) {
        // Received an event with updated product selection
        if(event.product) {
            this.product = event.product;
            this.updateProductFeatures();
        }
    }

    handleFeatureSelection(event) {
        // Received an event with updated product selection
        if(event.feature) {
            this.feature = event.feature;

            const currentActiveElement = this.template.querySelector('.active');
            this.handleFeatureChange(false);
        }
    }

    updateProductFeatures() {
        if (!this.product || !this.product.name || this.product.name.length == 0) {
            this.features = [{
                name: 'All Articles',
                icon: 'utility:all',
                active: false
            }];
            return;
        }

        getProductFeatures({ product: this.product.name })
            .then(result => {
                this.handleProductFeaturesResponse(result);
            })
            .catch(error => {
                this.error = error;
            });
    }

    handleProductFeaturesResponse(featuresList) {
        this.features = [];
        this.features.push({
            name: 'All Articles',
            icon: 'utility:all',
            active: false
        })

        for (var i = 0, len = featuresList.length; i < len; i++) {
            this.features.push(
                {
                    name: featuresList[i],
                    icon: 'utility:summary',
                    active: false
                }
            );
        }

        this.handleFeatureChange(true);
    }

    handleFeatureChange(publish) {
        if (!this.feature || this.feature.length == 0) {
            // No feature set - default it to All Articles
            this.feature = 'All Articles';
        }

        if (!this.features.find(f => f.name == this.feature)) {
            // current feature is not in the list of valid features. Reset to All Articles
            this.feature = 'All Articles';
        }

        // Set the active value on our new feature
        const currentActiveFeature = this.features.find(f => f.active == true);
        const newFeature = this.features.find(f => f.name == this.feature);
        if (currentActiveFeature != null && currentActiveFeature != newFeature) {
            currentActiveFeature.active = false;
        }
        newFeature.active = true;
        // force a re render
        this.features = this.features.slice();

        if (publish) {
            if (this.feature == 'All Articles') {
                // publish an empty event & save to session storage
                fireEvent(this.pageRef, 'cspProductFeatureSelectionEvent', {
                    feature: ''
                });
                window.sessionStorage.setItem('selectedProductFeature', '');
            } else {
                // publish the feature event & save to session storage
                fireEvent(this.pageRef, 'cspProductFeatureSelectionEvent', {
                    feature: this.feature
                });
                window.sessionStorage.setItem('selectedProductFeature', this.feature);
            }
        }
    }
}