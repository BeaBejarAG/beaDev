import { LightningElement, wire, api, track } from 'lwc';
import { CurrentPageReference, NavigationMixin } from 'lightning/navigation';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';

import SERVICE_CATALOGUE_OBJECT from '@salesforce/schema/Service_Catalogues__c';
import SERVICE_TYPE_FIELD from '@salesforce/schema/Service_Catalogues__c.Service_Type__c';
import USER_LEVEL_FIELD from '@salesforce/schema/Service_Catalogues__c.User_Level__c';
import JOURNEY_STAGE_FIELD from '@salesforce/schema/Service_Catalogues__c.Account_Journey_Stage__c';
import DELIVERY_TYPE_FIELD from '@salesforce/schema/Service_Catalogues__c.Delivery_Type__c';
import DELIVERY_BY_FIELD from '@salesforce/schema/Service_Catalogues__c.Delivered_By__c';
import LOCATION_FIELD from '@salesforce/schema/Service_Catalogues__c.Location__c';

import getServiceCatalogueEntries from '@salesforce/apex/cspServiceCatalogueEntryHandler.getServiceCatalogueEntries';
import getRelatedProduct from '@salesforce/apex/cspServiceCatalogueEntryHandler.getRelatedProduct';
import getIsPointsGuardian from '@salesforce/apex/cspContactsHandler.getIsPointsGuardian';
import { registerListener, unregisterListener } from 'c/pubsub';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import ACCESS_LOGO from '@salesforce/contentAssetUrl/csp_logo_black';
import { fireEvent } from 'c/pubsub';

export default class CspServiceCatalogueServices extends NavigationMixin(LightningElement) {
    pageRef;
    pageOffset = 0;
    refreshing = true;
    showMore = false;
    servicesEmpty = true;
    flexPointsEnabled = true;
    filterOptions = {serviceType: '', userLevel: '', journeyLevel: '', deliveryType: '', deliveredBy: '', location: '', premierOnly: ''};
    @track services = [];
    @api displayProductFilter = false;
    @api product = null;
    @api limit = 4;
    @track serviceId = null;
    @track isGuardian = false;
    @track accountId = '';

    @api displayFilters = false;
    @api state;
    serviceType = '';
    userLevel = '';
    journeyLevel = '';
    deliveryType = '';
    deliveredBy = '';
    location = '';
    premierOnly = '';

    serviceTypeLabel = 'Service type';
    userLevelLabel = 'User level';
    journeyLevelLabel = 'Journey level';
    deliveryTypeLabel = 'Delivery type';
    deliveredByLabel = 'Delivered by';
    locationLabel = 'Location';
    premierOnlyLabel = 'All Services';

    serviceTypeList = [];
    userLevelList = [];
    journeyLevelList = [];
    deliveryTypeList = [];
    deliveredByList = [];
    locationList = [];
    premierOnlyList = [{label: 'Premier Only', value: true}, {label: 'All Services', value: false}];

    @wire(getObjectInfo, { objectApiName: SERVICE_CATALOGUE_OBJECT })
    objectInfo;

    @wire(getPicklistValues, {recordTypeId: '$objectInfo.data.defaultRecordTypeId', fieldApiName: SERVICE_TYPE_FIELD})
    setServiceType(serviceTypes) {
        this.serviceTypeList = [{label: 'All Service Types', value: 'All Service Types'}]
        if (serviceTypes.data) {
            this.serviceTypeList = this.serviceTypeList.concat(serviceTypes.data.values);
        }
    }

    @wire(getPicklistValues, {recordTypeId: '$objectInfo.data.defaultRecordTypeId', fieldApiName: USER_LEVEL_FIELD})
    setUserLevelType(userLevel) {
        this.userLevelList = [{label: 'All User Levels', value: 'All User Levels'}]
        if (userLevel.data) {
            this.userLevelList = this.userLevelList.concat(userLevel.data.values);
        }
    }

    @wire(getPicklistValues, {recordTypeId: '$objectInfo.data.defaultRecordTypeId', fieldApiName: JOURNEY_STAGE_FIELD})
    setJourneyLevelType(journeyLevel) {
        this.journeyLevelList = [{label: 'All Journey Levels', value: 'All Journey Levels'}]
        if (journeyLevel.data) {
            this.journeyLevelList = this.journeyLevelList.concat(journeyLevel.data.values);
        }
    }

    @wire(getPicklistValues, {recordTypeId: '$objectInfo.data.defaultRecordTypeId', fieldApiName: DELIVERY_TYPE_FIELD})
    setDeliveryTypeType(deliveryType) {
        this.deliveryTypeList = [{label: 'All Delivery Types', value: 'All Delivery Types'}]
        if (deliveryType.data) {
            this.deliveryTypeList = this.deliveryTypeList.concat(deliveryType.data.values);
        }
    }

    @wire(getPicklistValues, {recordTypeId: '$objectInfo.data.defaultRecordTypeId', fieldApiName: DELIVERY_BY_FIELD})
    setDeliveredByType(deliveryBy) {
        this.deliveredByList = [{label: 'All Delivered By', value: 'All Delivered By'}]
        if (deliveryBy.data) {
            this.deliveredByList = this.deliveredByList.concat(deliveryBy.data.values);
        }
    }

    @wire(getPicklistValues, {recordTypeId: '$objectInfo.data.defaultRecordTypeId', fieldApiName: LOCATION_FIELD})
    setLocationType(location) {
        this.locationList = [{label: 'All Locations', value: 'All Locations'}]
        if (location.data) {
            this.locationList = this.locationList.concat(location.data.values);
        }
    }

    @wire(CurrentPageReference)
    setCurrentPageReference(currentPageReference) {
        this.services = [];
        this.pageRef = currentPageReference;

        // If no state property, set display filter to true
        if(Object.keys(this.pageRef.state).length === 0) {
            this.state = null;
            this.displayFilters = true;
        }

        // Set state to browse to determine which components to display
        if(this.pageRef.state.step === 'browse') {
            return this.state = 'browse';
        }
        // Only read the params of a pageref that we know actually contains this component
        this.handlePreselectedFilters();
    }

    constructor() {
        super();
        this.product = JSON.parse(window.sessionStorage.getItem('selectedProduct'));
        this.accountId = window.sessionStorage.getItem('selectedAccountId');
    }

    connectedCallback() {
        const prod = JSON.parse(window.sessionStorage.getItem('selectedProduct'));
        if (prod) {
            this.flexPointsEnabled = (prod.flexPointsEnabled === 'Available' || Object.keys(prod).length === 0) ? true : false;
        }

        this.handlePointGuardian();
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
        this.handlePointGuardian();
    }

    handlePointGuardian() {
        getIsPointsGuardian({selectedAccountId: this.accountId})
            .then(result => this.isGuardian = result)
            .catch(error => console.log(error))
            .finally(() => {});
    }

    handlePreselectedFilters() {
        this.filterOptions = {serviceType: '', userLevel: '', journeyLevel: '', deliveryType: '', deliveredBy: '', location: '', premierOnly: ''}
        const params = this.pageRef.state;

        for (const [key, value] of Object.entries(params)) {
            if (key != 'serviceId') {
                this.filterOptions[key] = value;
            }
        }
        this.setPreselectedFilterValues();
        this.handleRetrieveServicesWithFilter();
    }

    setPreselectedFilterValues() {
        this.serviceType = this.filterOptions.serviceType != '' ? this.filterOptions.serviceType : this.serviceType;
        this.serviceTypeLabel = this.filterOptions.serviceType != '' ? this.truncateValue(this.filterOptions.serviceType) : this.serviceTypeLabel;

        this.userLevel = this.filterOptions.userLevel != '' ? this.filterOptions.userLevel : this.userLevel;
        this.userLevelLabel = this.filterOptions.userLevel != '' ? this.truncateValue(this.filterOptions.userLevel) : this.userLevelLabel;

        this.journeyLevel = this.filterOptions.journeyLevel != '' ? this.filterOptions.journeyLevel : this.journeyLevel;
        this.journeyLevelLabel = this.filterOptions.journeyLevel != '' ? this.truncateValue(this.filterOptions.journeyLevel) : this.journeyLevelLabel;

        this.deliveryType = this.filterOptions.deliveryType != '' ? this.filterOptions.deliveryType : this.deliveryType;
        this.deliveryTypeLabel = this.filterOptions.deliveryType != '' ? this.truncateValue(this.filterOptions.deliveryType) : this.deliveryTypeLabel;

        this.deliveredBy = this.filterOptions.deliveredBy != '' ? this.filterOptions.deliveredBy : this.deliveredBy;
        this.deliveredByLabel = this.filterOptions.deliveredBy != '' ? this.truncateValue(this.filterOptions.deliveredBy) : this.deliveredByLabel;

        this.location = this.filterOptions.location != '' ? this.filterOptions.location : this.location;
        this.locationLabel = this.filterOptions.location != '' ? this.truncateValue(this.filterOptions.location) : this.locationLabel;

        const premierValue = (this.filterOptions.premierOnly != '' ? (this.filterOptions.premierOnly != 'All Services') : false);
        this.premierOnly = premierValue;
        this.premierOnlyLabel = this.premierOnly ? 'Premier Only' : 'All Services';
    }

    loadMoreServices() {
        this.pageOffset += this.limit;
        this.handleRetrieveServicesWithFilter();
    }

    handleProductSelection(event) {
        // Clear the services array
        this.services = [];
        this.pageOffset = 0;
        // Received an event with updated product selection
        this.product = event.product;
        this.flexPointsEnabled = (this.product.flexPointsEnabled === 'Available' || Object.keys(this.product).length === 1) ? true : false;
        this.handleRetrieveServicesWithFilter();
    }

    @api
    handleRetrieveServicesWithFilter() {
        this.refreshing = true;
        getServiceCatalogueEntries(this.getServicePayload())
        .then(response => {
            this.handleRenderingWithFilter(response);
        })
        .catch(error => {
            this.refreshing = false;
            this.showErrorToast();

            console.log(error);
        })
        .finally(e => this.refreshing = false);
    }

    getServicePayload() {
        return {
            selectedAccId: this.accountId,
            product: this.product && this.product.name && this.product.name != 'All Products' ? this.product.name : null,
            lmt: this.limit,
            ofst: this.pageOffset,
            incrementLmt: true,
            serviceType: this.serviceType && this.serviceType != 'All Service Types' ? this.serviceType : '',
            userLevel: this.userLevel && this.userLevel != 'All User Levels' ? this.userLevel : '',
            journeyLevel: this.journeyLevel && this.journeyLevel != 'All Journey Levels' ? this.journeyLevel : '',
            deliveryType: this.deliveryType && this.deliveryType != 'All Delivery Types' ? this.deliveryType : '',
            deliveredBy: this.deliveredBy && this.deliveredBy != 'All Delivered By' ? this.deliveredBy : '',
            location: this.location && this.location != 'All Locations' ? this.location : '',
            premierOnly: this.premierOnly
        }
    }

    showErrorToast() {
        const event = new ShowToastEvent({
                title: 'An error occurred',
                message: 'Unable to retrieve services',
                variant: 'error',
                mode: 'dismissable'
        });
        this.dispatchEvent(event);
    }

    handleSelectService(event) {
        this.serviceId = event.currentTarget.dataset.id;
        const prod = JSON.parse(window.sessionStorage.getItem('selectedProduct'));
        if (Object.keys(prod).length === 0) {
            this.refreshing = true;
            getRelatedProduct({serviceCatalogueId: this.serviceId, selectedAccId: this.accountId})
            .then(response => {
                var product = response;
                const colour = `access-theme-product-bar-cat${product.colour}`;
                product = {...product, colour: colour};
                if (!product.image || product.image.length == 0) {
                    product = {...product, image: ACCESS_LOGO};
                }
                window.sessionStorage.setItem('selectedProduct', JSON.stringify(product));
                fireEvent(this.pageRef, 'cspProductSelectionEvent', {
                    product: product
                })
                this.refreshing = false;
                this.navigateToNewPage();
            }).catch(error => this.navigateToNewPage())
            .finally(() => {this.refreshing = false;});
        } else {
            this.navigateToNewPage();
        }
    }

    navigateToServicesPageWithFilters() {
        var state = {};

        for (const [key, value] of Object.entries(this.filterOptions)) {
            if (value != '') {
                Object.assign(state, {[key]: value});
            }
        }

        this[NavigationMixin.Navigate](this.getUpdatedPageReference(state),true);
    }

    getUpdatedPageReference(stateChanges) {
        return Object.assign({}, this.pageRef, {
            state: stateChanges
        });
    }


    navigateToNewPage() {
        var state = {serviceId: this.serviceId};
        for (const [key, value] of Object.entries(this.filterOptions)) {
            if (value != '') {
                Object.assign(state, {[key]: value});
            }
        }

        this[NavigationMixin.Navigate](this.getUpdatedPageReference(state),true);
    }

    handleRenderingWithFilter(results) {
        // If there's more to retrieve then show the button
        this.showMore = results.length > this.limit;

        // Remove the additional result to match the amount requested
        if(results.length > this.limit) {
            results = results.slice(0, this.limit);
        }

        this.services = this.services.concat(results);
        this.servicesEmpty = (this.services.length == 0);
    }

    getFilterPayLoad() {
        return {
            serviceType: this.serviceType,
            userLevel: this.userLevel,
            journeyLevel: this.journeyLevel,
            deliveryType: this.deliveryType,
            deliveredBy: this.deliveredBy,
            location: this.location,
            premierOnly: this.premierOnly
        }
    }

    truncateValue (selectedValue) {
        let value = selectedValue;
        if (selectedValue.length > 16) {
            value = selectedValue.substring(0, 17) + '...';
        }
        return value;
    }

    serviceTypeFilterSelectHandler(event) {
        try {
            this.pageOffset = 0;
            this.serviceTypeLabel = this.truncateValue(event.detail.value);
            this.serviceType = event.detail.value;
            this.filterOptions.serviceType = this.serviceType != 'All Service Types' ? this.serviceType : '';
            this.navigateToServicesPageWithFilters();
        } catch(error) {
            console.log(error);
        }
    }

    userLevelFilterSelectHandler(event) {
        try {
            this.pageOffset = 0;
            this.userLevelLabel = this.truncateValue(event.detail.value);
            this.userLevel = event.detail.value;
            this.filterOptions.userLevel = this.userLevel != 'All User Levels' ? this.userLevel : '';
            this.navigateToServicesPageWithFilters();
        } catch(error) {
            console.log(error);
        }
    }

    journeyLevelFilterSelectHandler(event) {
        try {
            this.pageOffset = 0;
            this.journeyLevelLabel = this.truncateValue(event.detail.value);
            this.journeyLevel = event.detail.value;
            this.filterOptions.journeyLevel = this.journeyLevel != 'All Journey Levels' ? this.journeyLevel : '';
            this.navigateToServicesPageWithFilters();
        } catch(error) {
            console.log(error);
        }
    }

    deliveryTypeFilterSelectHandler(event) {
        try {
            this.pageOffset = 0;
            this.deliveryTypeLabel = this.truncateValue(event.detail.value);
            this.deliveryType = event.detail.value;
            this.filterOptions.deliveryType = this.deliveryType != 'All Delivery Types' ? this.deliveryType : '';
            this.navigateToServicesPageWithFilters();
        } catch(error) {
            console.log(error);
        }
    }

    deliveredByFilterSelectHandler(event) {
        try {
            this.pageOffset = 0;
            this.deliveredByLabel = this.truncateValue(event.detail.value);
            this.deliveredBy = event.detail.value;
            this.filterOptions.deliveredBy = this.deliveredBy != 'All Delivered By' ? this.deliveredBy : '';
            this.navigateToServicesPageWithFilters();
        } catch(error) {
            console.log(error);
        }
    }

    locationFilterSelectHandler(event) {
        try {
            this.pageOffset = 0;
            this.locationLabel = this.truncateValue(event.detail.value);
            this.location = event.detail.value;
            const filter = this.location != 'All Locations' ? this.location : '';
            this.filterOptions.location = filter;
            this.navigateToServicesPageWithFilters();
        } catch(error) {
            console.log(error);
        }
    }

    premierOnlyFilterSelectHandler(event) {
        try {
            this.premierOnly = event.detail.value;
            this.pageOffset = 0;

            if (this.premierOnly) {
                this.premierOnlyLabel = 'Premier Only';
            } else {
                this.premierOnlyLabel = 'All Services';
            }
            this.filterOptions.premierOnly = this.premierOnlyLabel != 'All Services' ? this.premierOnlyLabel : '';
            this.navigateToServicesPageWithFilters();
        } catch(error) {
            console.log(error);
        }
    }

    journeyLevelFilterSelectBestServicesHandler(event) {
        try {
            this.pageOffset = 0;
            this.services = [];
            this.journeyLevelLabel = event.detail.value;
            this.journeyLevel = event.detail.value;
            this.filterOptions.journeyLevel = this.journeyLevel != 'All Journey Levels' ? this.journeyLevel : '';
        } catch(error) {
            console.log(error);
        }
    }

    userLevelFilterSelectBestServicesHandler(event) {
        try {
            this.pageOffset = 0;
            this.services = [];
            this.userLevelLabel = event.detail.value;
            this.userLevel = event.detail.value;
            this.filterOptions.userLevel = this.userLevel != 'All User Levels' ? this.userLevel : '';
        } catch(error) {
            console.log(error);
        }
    }

    serviceTypeFilterSelectBestServicesHandler(event) {
        try {
            this.pageOffset = 0;
            this.services = [];
            this.serviceTypeLabel = event.detail.value;
            this.serviceType = event.detail.value;
            this.filterOptions.serviceType = this.serviceType != 'All Service Types' ? this.serviceType : '';
        } catch(error) {
            console.log(error);
        }
    }

    /**
     * @description Navigate to services page with state property. Updated this.state to be empty
     */
    handleServices() {
        var state = {};
        for (const [key, value] of Object.entries(this.filterOptions)) {
            if (value != '') {
                Object.assign(state, {[key]: value});
            }
        }
        this.state = '';
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                name: `Services__c`
            },
            state
        });
    }
}