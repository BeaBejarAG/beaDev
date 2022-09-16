import { LightningElement, wire, api, track  } from 'lwc';
import { CurrentPageReference, NavigationMixin } from 'lightning/navigation';
import searchKnowledge from '@salesforce/apex/cspGlobalSearchHandler.searchKnowledge';
import searchCommunities from '@salesforce/apex/cspGlobalSearchHandler.searchCommunities';
import searchServicesCatalogue from '@salesforce/apex/cspGlobalSearchHandler.searchServicesCatalogue';
import searchEvents from '@salesforce/apex/cspGlobalSearchHandler.searchEvents';
import searchReleaseNotes from '@salesforce/apex/cspGlobalSearchHandler.searchReleaseNotes';
import { registerListener, unregisterListener } from 'c/pubsub';
import listKnowledge from '@salesforce/apex/cspGlobalSearchHandler.listKnowledge';
import listCommunities from '@salesforce/apex/cspGlobalSearchHandler.listCommunities';
import getGroupsCached from '@salesforce/apex/cspCommunity.getGroupsCached';
import getProductList from '@salesforce/apex/cspProductSelection.getAllProducts';
import USER_ID from '@salesforce/user/Id';

export default class CspSearchResults extends NavigationMixin(LightningElement) {
    @api limitAmount;
    @api searchText;
    @api showTabs = false;
    @api includeReleaseNotesResults = false;
    @api includeKnowledgeResults = false;
    @api includeCommunityResults = false;
    @api includeEventsResults = false;
    @api includeServicesCatalogueResults = false;
    @api featuredLayout = false;
    @api articlesListView = false;
    @api suppressHighlighting = false;
    @api suppressProduct = false;
    @api suppressMoreButton = false;
    @api suppressNoResults = false;
    @api excludeObject = null;
    @api showFeatureFilter = false;
    @api showProductFilter = false;
    @api feature = '';
    @api ignoreProduct = false;
    @api showTypeIcons = false;
    @api communityFilters = false;
    @api defaultTab = '';
    @api groupList = [];
    @api topicList = [];
    @api group = 'All Groups';
    @api topic = 'All Products';

    @track userId = USER_ID || "";
    @track completedSearch = false;
    @track error;
    @track accountId = '';

    id;
    product = null;
    type = "ALL";
    showMore = false;
    tmpMap = {};
    offsetMap = {};
    resultList = [];

    @wire(CurrentPageReference)
    setCurrentPageReference(currentPageReference) {
        this.pageRef = currentPageReference;

        if(this.pageRef.state.term !== undefined) {
            this.searchText = decodeURI(this.pageRef.state.term);
            this.handleSearch(true);
        } else if(this.searchText) {
            this.handleSearch(true);
        }
    }

    constructor() {
        super();
        this.product = JSON.parse(window.sessionStorage.getItem('selectedProduct'));
        if (!this.ignoreProduct) {
            this.topic = this.product && this.product.name ? this.product.name : 'All Products';
        }
        this.feature = window.sessionStorage.getItem('selectedProductFeature');
        this.accountId = window.sessionStorage.getItem('selectedAccountId');
    }

    async connectedCallback() {
        if (this.ignoreProduct) {
            this.topic = 'All Products';
        }
        registerListener('cspProductSelectionEvent', this.handleProductSelection, this);
        registerListener('cspProductFeatureSelectionEvent', this.handleProductFeatureSelection, this);
        registerListener('cspSearchEvent', this.handleSearchString, this);
        if (this.featuredLayout || this.articlesListView) {
            this.handleSearch(true);
        }

        this.groupList = [{name: 'All Groups'}];
        this.groupList = this.groupList.concat(JSON.parse(JSON.stringify(await getGroupsCached({}))).groups.filter(g => g.mySubscription !== null || g.visibility != 'PrivateAccess'));
        this.groupList.forEach(e => {
            if (e.name != 'All Groups') {
                e.memberCountLabel = `${e.memberCount} members`;
                e.name = this.decodeEntities(e.name);
                e.description = this.decodeEntities(e.description);
            }
        });

        this.topicList = [{name: 'All Products'}];
        this.topicList = this.topicList.concat(JSON.parse(JSON.stringify(await getProductList({selectedAccId: this.accountId}))).filter(p => p.enabledForCommunity != 'Inactive' && p.enabledForCommunity != 'Redirection'));
        registerListener('cspAccountSelectionEvent', this.handleAccountSelection, this);
    }

    disconnectedCallback() {
        unregisterListener('cspProductSelectionEvent', this.handleProductSelection, this);
        unregisterListener('cspProductFeatureSelectionEvent', this.handleProductFeatureSelection, this);
        unregisterListener('cspSearchEvent', this.handleSearchString, this);
        unregisterListener('cspAccountSelectionEvent', this.handleAccountSelection, this);
    }

    async handleAccountSelection(event) {
        if(!event.selectedAccountId) {
            return;
        }

        this.accountId = event.selectedAccountId;
        this.topicList = [{name: 'All Products'}];
        this.topicList = this.topicList.concat(JSON.parse(JSON.stringify(await getProductList({selectedAccId: this.accountId}))).filter(p => p.enabledForCommunity != 'Inactive' && p.enabledForCommunity != 'Redirection'));
    }


    @api
    handleSearch(reset) {


        if (this.articlesListView) {
            this.handleListView(reset);
            return;
        }

        const promises = [];
        if(reset) {
            this.offsetMap = {};
        }

        if(!this.searchText || this.searchText.length < 2) {
            this.completedSearch = this.resultList.length == 0;
            return;
        }

        if((this.type === "KNOWLEDGE" || this.type === "ALL") && this.includeKnowledgeResults) {
            promises.push(searchKnowledge(this.getSearchPayload('Knowledge__kav'))
            .then(response => this.handleResponseData(response))
            .catch(error => this.handleResponseError(error)));
        }

        if((this.type === "COMMUNITY" || this.type === "ALL")  && this.includeCommunityResults) {
            promises.push(searchCommunities(this.getSearchPayload('FeedItem', true))
            .then(response => this.handleResponseData(response))
            .catch(error => this.handleResponseError(error)));
        }

        if((this.type === "EVENTS" || this.type === "ALL")  && this.includeEventsResults) {
            promises.push(searchEvents(this.getSearchPayload('Event__c'))
            .then(response => this.handleResponseData(response))
            .catch(error => this.handleResponseError(error)));
        }

        if((this.type === "RELEASENOTES" || (this.type === "ALL" && !this.includeKnowledgeResults))  && this.includeReleaseNotesResults) {
            promises.push(searchReleaseNotes(this.getSearchPayload('Knowledge__kav'))
            .then(response => this.handleResponseData(response))
            .catch(error => this.handleResponseError(error)));
        }

        if((this.type === "SERVICESCATALOGUE" || this.type === "ALL") && this.includeServicesCatalogueResults) {
            promises.push(searchServicesCatalogue(this.getSearchPayload('Service_Catalogues__c'))
            .then(response => this.handleResponseData(response))
            .catch(error => this.handleResponseError(error)));
        }
        Promise.all(promises).then(e => this.handleRendering(reset, e.reduce((acc, val) => acc.concat(val), [])));
    }

    handleListView(reset) {
        const promises = [];
        if(reset) {
            this.offsetMap = {};
        }

        if((this.type === "KNOWLEDGE" || this.type === "ALL") && this.includeKnowledgeResults) {
            promises.push(listKnowledge(this.getListPayload('Knowledge__kav'))
            .then(response => this.handleResponseData(response))
            .catch(error => this.handleResponseError(error)));
        }

        if((this.type === "COMMUNITY" || this.type === "ALL")  && this.includeCommunityResults) {
            promises.push(listCommunities(this.getListPayload('FeedItem'))
            .then(response => this.handleResponseData(response))
            .catch(error => this.handleResponseError(error)));
        }

        Promise.all(promises).then(e => this.handleRendering(reset, e.reduce((acc, val) => acc.concat(val), [])));
    }

    handleResponseData(response) {
        // Need to remove the wrapper the wire puts on in order to manipulate data
        return JSON.parse(JSON.stringify(response)).map(r => {
            r.snippet = r.snippet == undefined ? '' : r.snippet;
            r.dttm = r.dttm ? new Date(r.dttm) : null;
            r.icon = this.getTypeIcon(r.type, r.recordType);
            r.productCategories = r.productCategory ? r.productCategory.split(";").slice(0,3) : null;
            r.products = r.product ? r.product.split(";").slice(0,3) : null;
            r.topics = r.topic ? r.topic.split(";").slice(0,3) : null;
            r.community = r.type == 'FeedItem';
            return r;
        });
    }

    handleRendering(reset, results) {
        Object.keys(this.tmpMap).map(e => {
            this.tmpMap[e] = 0;
        });

        // If there's more to retrieve then show the button
        this.showMore = results.length > this.limitAmount && !this.suppressMoreButton

        // Have a consistent sort so that all results will be shown
        results.sort((a, b) => b.dttm - a.dttm)

        // Remove the additional result to match the amount requested
        if(results.length > this.limitAmount) {
            results.splice(this.limitAmount)
        }

        // Store counts of each type to increment offsets with later on
        results.forEach(e => {
            this.tmpMap[e.type] = this.tmpMap[e.type] + 1 || 1;
        })

        if(reset) {
            this.resultList = [];
        }

        results.forEach(result => {
            const doc = new DOMParser().parseFromString(result.snippet, "text/html");
            doc.documentElement.querySelectorAll('br').forEach(e => {e.outerHTML = "\n"});
            doc.documentElement.querySelectorAll('div, li, p').forEach(e => {e.outerHTML += "\n"});
            doc.documentElement.querySelectorAll('span').forEach(e => {e.outerHTML += " "});
            result.snippet = doc.documentElement.innerText;

            if(!this.suppressHighlighting && this.searchText) {
                this.searchText.split(' ').forEach(term => {
                    if(term.length > 1 && result.snippet) {
                        const re = new RegExp(term, "ig");
                        result.snippet = result.snippet.replace(re, '<mark>$&</mark>');
                    }
                });
            }
        })

        // Concatente these to existing results so that we can use offset
        // in the SOQL without exceeding 2000 results limit
        this.resultList = this.resultList.concat(results);

        this.completedSearch = this.resultList.length == 0;

        this.dispatchEvent(new CustomEvent("cspsearcheventcomplete", {
            detail: this.resultList.length
         }));
    }

    handleLoadMore(event) {
        // Set the new offsets and force a new call to Apex controller
        Object.keys(this.tmpMap).map(e => {
            this.offsetMap[e] = this.offsetMap[e] ?
                this.tmpMap[e] + this.offsetMap[e] : this.tmpMap[e];
        });
        this.handleSearch();
    }

    handleSearchString(event) {
        // Received an event with updated search text
        if(event.searchText) {
            this.searchText = event.searchText;
            this.handleSearch(true);
        }
    }

    handleProductSelection(event) {
        // Received an event with updated product selection
        if(this.product == null || this.product.id != event.product.id) {
            this.feature = '';
        }
        this.product = event.product;
        if (!this.ignoreProduct) {
            this.topic = this.product && this.product.name ? this.product.name : 'All Products';
            this.group = 'All Groups';
        }
        this.handleSearch(true);
    }

    handleProductFeatureSelection(event) {
        // Received an event with updated product selection
        this.feature = event.feature;
        this.handleSearch(true);
    }

    handleFeatureClick(event) {
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: `/knowledge-base?feature=${event.target.value}`
            }
        });
    }

    handleSearchTab(event) {
        // Received an event with updated tab selection
        if(this.type !== event.target.value) {
            this.type = event.target.value;
            if (this.type == 'All') {
                this.group = 'All Groups';
            }
            this.handleSearch(true);
        }
    }

    handleResultClick(event) {
        if(this.dispatchEvent(
            new CustomEvent("cspsearchselectresult", {
                cancelable: true,
                detail: {
                    url: event.target.value,
                    title: event.target.label
                }
            })
        )) {
            this[NavigationMixin.Navigate]({
                type: 'standard__webPage',
                attributes: {
                    url: event.target.value
                }
            });
         }
    }

    handleGroupFilterSelect(event) {
        const selectedGroup = event.detail.value;
        if (this.group != selectedGroup) {
            this.group = selectedGroup;
            if (this.group != 'All Groups') {
                this.topic = 'All Products';
            }
            this.handleSearch(true);
        }
    }

    handleTopicFilterSelect(event) {
        const selectedTopic = event.detail.value;
        if (this.topic != selectedTopic) {
            this.topic = selectedTopic;
            if (this.topic != 'All Products') {
                this.group = 'All Groups';
            }
            this.handleSearch(true);
        }
    }

    handleResponseError(error) {
        this.error = JSON.stringify(error);
    }

    getSearchPayload(type, communityPayload) {
        const searchProduct = this.product && this.product.name && !this.ignoreProduct ? this.product.name : null;
        const searchFeature = this.feature && this.type != 'RELEASENOTES' ? this.feature : '';
        if (communityPayload) {
            return {
                query: this.searchText,
                product: searchProduct,
                product_feature: searchFeature,
                amount: this.limitAmount || 10,
                offset: this.offsetMap[type] || 0,
                highlight: !this.suppressHighlighting,
                excludeObject: this.excludeObject,
                objectName: type,
                groupName: this.group == 'All Groups' ? '' : this.group,
                topicName: this.topic == 'All Products' ? '' : this.topic
            }
        }
        return {
            query: this.searchText,
            product: searchProduct,
            product_feature: searchFeature,
            amount: this.limitAmount || 10,
            offset: this.offsetMap[type] || 0,
            highlight: !this.suppressHighlighting,
            excludeObject: this.excludeObject,
            objectName: type,
            selectedAccId: this.accountId
        }
    }

    getListPayload(type) {
        return {
            product: this.product && this.product.name ? this.product.name : null,
            product_feature: this.feature || '',
            featured: this.featuredLayout,
            amount: this.limitAmount || 10,
            offset: this.offsetMap[type] || 0,
            objectName: type
        }
    }

    getTypeIcon(contentType, recordType) {
        switch (contentType) {
            case 'Knowledge__kav':
                return recordType == 'Release_Notes' ? 'utility:setup_assistant_guide' : 'utility:knowledge_base';
            case 'FeedItem':
                return 'utility:quip';
            case 'Event__c':
                return 'utility:date_time';
            case 'Release_Note__c':
                return 'utility:setup_assistant_guide';
            case 'Service_Catalogues__c':
                return 'utility:service_territory_policy';
            default:
                return '';
          }
    }

    decodeEntities(input) {
        const element = document.createElement('textarea');
        element.innerHTML = input;
        return element.textContent;
    }

    get featuredList() {
        return this.resultList.slice(0, 3);
    }

    @api
    get typeIconsVisible() {
        return this.type == 'ALL' && this.showTypeIcons ;
    }

    @api
    get horizontalFirstFeature() {
        return this.featuredList.length != 2 && window.innerWidth > 400;
    }

    @api
    get displayFeatureFilter() {
        return this.type == 'KNOWLEDGE' && this.showFeatureFilter;
    }

    @api
    get displayProductFilter() {
        if (this.showProductFilter) {
            if (this.type == 'KNOWLEDGE') {
                return true;
            }
            if (this.type == 'ALL' && !(this.includeCommunityResults || this.includeEventsResults || this.includeReleaseNotesResults)) {
                return true;
            }
        }
        return false;
    }

    @api
    get displayCommunityFilters() {
        if (this.communityFilters) {
            if (this.type == 'COMMUNITY') {
                return true;
            }
            if (this.type == 'ALL' && !(this.includeKnowledgeResults || this.includeEventsResults || this.includeReleaseNotesResults)) {
                return true;
            }
        }
        return false;
    }

    @api
    get resultsClass() {
        return this.displayFeatureFilter || this.displayProductFilter || this.displayCommunityFilters ? 'slds-size_1-of-1 slds-medium-size_9-of-12 slds-p-horizontal_x-small' : 'slds-size_1-of-1 slds-p-horizontal_x-small';
    }
}