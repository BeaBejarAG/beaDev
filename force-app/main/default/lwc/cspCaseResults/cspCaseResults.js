import { LightningElement, track, wire, api } from 'lwc';
import { CurrentPageReference, NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getCases from '@salesforce/apex/cspCaseHandler.getCases';
import getCasesForProject from '@salesforce/apex/cspCaseHandler.getCasesForProject';
import getProductList from '@salesforce/apex/cspProductSelection.getProductList';
import getInACases  from '@salesforce/apex/cspCaseHandler.getInACases';
import { registerListener, unregisterListener } from 'c/pubsub';

export default class CspCaseResults extends NavigationMixin(LightningElement) {
    @track error;
    @api caseList = [];
    @api ownerFilter = 'My Cases';
    @api statusFilter = 'All status';
    @api searchText = '';
    @api limitAmount;
    @api displayOrganisationCases = false;
    @api displayCollaborationCases = false;
    @api displayProductFilter = false;
    @api displayDownloadButton = false;
    @api displayProjectCases = false;
    @api product = null;
    @api productList = null;
    @api showDownload = false;
    @api dateFrom = null;
    @api dateTo = null;
    @api refreshing = false;
    @api recordId = false;
    @api superUser = false;
    @api viewAllCases = false;
    @api ina = false;
    @api serviceUser = false;
    @api HideAllAccountCases = false;

    @track completedSearch = false;
    
    accountId = '';
    paramsLoaded = false;
    downloadCaseList = [];
    showMore = false;
    caseCount = 0;
    offset = 0;
    ownerOptions = {
        'User' : 'My Cases',
        'Organisation' : 'My Organisation\'s Cases',
        'Collaboration' : 'My Collaboration Cases'
    }

    errorCallback(error, stack) {
        console.log("Error : " + error + ' ' + stack);
    }

    @wire(getProductList)
    wiredProducts({ error, data }) {
        if (data) {
            const receivedProducts = JSON.parse(JSON.stringify(data));
            if (receivedProducts.length == 0 ) {
                return;
            }
            this.productList = [{name: 'All Products'}]
            this.productList = this.productList.concat(receivedProducts.sort((a, b) => a.name.localeCompare(b.name)));
        } else if (error) {
            this.error = error;
            this.productList = null;
        }
    }

    @wire(CurrentPageReference)
    setCurrentPageReference(currentPageReference) {
        this.pageRef = currentPageReference;
        // Only read the params of a pageref that we know actually contains this component

        this.paramsLoaded = true;
        if(this.pageRef.state.searchTerm && this.pageRef.state.searchTerm !== undefined) {
            this.searchText = decodeURI(this.pageRef.state.searchTerm);
        }
        if(this.pageRef.state.status !== undefined) {
            this.statusFilter = decodeURI(this.pageRef.state.status);
        }
        if(this.pageRef.state.owner !== undefined && this.displayOrganisationCases) {
            this.ownerFilter = decodeURI(this.pageRef.state.owner);
        }
        this.handleSearch(true, false);
    }

    constructor() {
        super();
        if (this.displayProductFilter) {
            this.product = {name: 'All Products'};
        } else {
            this.product = JSON.parse(window.sessionStorage.getItem('selectedProduct'));
        }
        this.accountId = window.sessionStorage.getItem('selectedAccountId');
        this.showCasesCheckbox = window.sessionStorage.getItem('consultantAccount') === 'true';
    }

    connectedCallback() {
        if (this.displayProductFilter) {
            this.product = {name: 'All Products'};
        } else {
            registerListener('cspProductSelectionEvent', this.handleProductSelection, this);
        }
        registerListener('cspAccountSelectionEvent', this.handleAccountSelection, this);
        registerListener('cspConsultantAccountEvent', this.handleIsConsultantAccount, this);
    }

    disconnectedCallback() {
        if (!this.displayProductFilter) {
            unregisterListener('cspProductSelectionEvent', this.handleProductSelection, this);
        }
        unregisterListener('cspAccountSelectionEvent', this.handleAccountSelection, this);
        unregisterListener('cspConsultantAccountEvent', this.handleIsConsultantAccount, this);
    }

    handleIsConsultantAccount(event) {
        if(!event.consultantAccount) {
            return;
        }

        this.showCasesCheckbox = event.consultantAccount;
    }

    handleAccountSelection(event) {
        if(!event.selectedAccountId) {
            return;
        }

        this.accountId = event.selectedAccountId;
        this.handleSearch(true, false);
    }

    @api
    handleSearch(reset, updateUrl) {
        if(reset) {
            this.offset = 0;
        }
        this.refreshing = true;
        if (this.recordId) {
            getCasesForProject(this.getProjectPayload())
            .then(response => {
                const data = this.handleResponseData(response)
                this.handleRendering(reset, data);
              })
            .catch(error => this.handleResponseError(error))
            .finally(e => this.refreshing = false);
        } else {
            getCases(this.getCasePayload())
            .then(response => {
                const data = this.handleResponseData(response)
                this.handleRendering(reset, data);
            })
            .catch(error => this.handleResponseError(error))
            .finally(e => this.refreshing = false);
        }

        if (updateUrl) {
            this.updateUrlPath();
        }
    }

    handleResponseData(response) {
        // Need to remove the wrapper the wire puts on in order to manipulate data
        return JSON.parse(JSON.stringify(response)).map(r => {
            r.created = new Date(r.created);
            r.lastModified = new Date(r.lastModified);
            r.isWithAccess = this.isWithAccess(r.statusGroup);
            r.isWithCustomer = this.isWithCustomer(r.statusGroup);
            r.isSolved = this.isSolved(r.statusGroup);
            r.isUnknown = this.isUnknown(r.statusGroup);
            return r;
        });
    }

    handleResponseError(error) {
        this.refreshing = false;
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Error fetching cases',
                message: error.message,
                variant: 'error',
            }),
        );
        this.error = JSON.stringify(error);
        console.log(this.error)
    }

    getCasePayload() {
        return {
            product: this.product && this.product.name && this.product.name != 'All Products' ? this.product.name : null,
            amount: this.limitAmount,
            offset: this.offset,
            searchTerm: this.searchText,
            status: this.statusFilter,
            myCases: this.displayProjectCases ? false : this.ownerFilter == 'My Cases',
            collaborationCases: this.displayProjectCases ? false : this.ownerFilter == 'My Collaboration Cases',
            startDate: this.dateFrom,
            endDate: this.dateTo,
            projectCases: this.displayProjectCases,
            selectedAccId: this.accountId && !this.viewAllCases ? this.accountId : null,
            superUser: this.superUser != null && this.superUser
        }
    }

    getProjectPayload() {
        return {
            caseId: this.recordId,
            amount: this.limitAmount,
            offset: this.offset,
            searchTerm: this.searchText,
            status: this.statusFilter
        }
    }

    handleRendering(reset, results) {
        // If there's more to retrieve then show the button
        this.showMore = results.length > this.limitAmount

        // Remove the additional result to match the amount requested
        if(results.length > this.limitAmount) {
            results.splice(this.limitAmount)
        }

        if(reset) {
            this.caseList = [];
        }

        // Concatente these to existing results so that we can use offset
        // in the SOQL without exceeding 2000 results limit
        this.caseList = this.caseList.concat(results);
        this.offset = this.caseList.length;

        this.completedSearch = this.caseList.length == 0;
    }

    handleProductSelection(event) {
        // Received an event with updated product selection
        this.product = event.product;
        this.handleSearch(true);
    }

    isWithAccess(status) {
        return status == 'With Access';
    }
    isWithCustomer(status) {
        return status == 'Needs Action';
    }
    isSolved(status) {
        return status == 'Solved';
    }
    isUnknown(status) {
        return status != 'Needs Action' && status != 'With Access' && status != 'Solved';
    }

    handleOwnerFilterSelect(event) {
        if (this.ownerFilter != this.ownerOptions[event.detail.value]) {
            this.ownerFilter = this.ownerOptions[event.detail.value];
            this.handleSearch(true, true);
        }
    }
    handleStatusFilterSelect(event) {
        if (this.statusFilter != event.detail.value) {
            this.statusFilter = event.detail.value;
            this.handleSearch(true, true);
        }
    }
    handleProductFilterSelect(event) {
        if (this.product != event.detail.value) {
            this.product = event.detail.value;
            this.handleSearch(true, true);
        }
    }

    handleSearchKeyPress(event) {
        this.searchText = event.target.value;
        this.handleSearch(true, true);
    }

    updateUrlPath() {
        let newState = {
            'searchTerm': this.searchText ? encodeURI(this.searchText) : undefined,
            'status': encodeURI(this.statusFilter),
            'owner': encodeURI(this.ownerFilter)
        }
        this[NavigationMixin.Navigate](this.getUpdatedPageReference(newState),true);
    }

    getUpdatedPageReference(stateChanges) {
        return Object.assign({}, this.pageRef, {
            state: Object.assign({}, this.pageRef.state, stateChanges)
        });
    }

    handleCaseClick(event) {
        const caseUrl = event.currentTarget.dataset.url;
        if (caseUrl == null) {
            return;
        }

        if(this.dispatchEvent(
            new CustomEvent("cspcaseselectresult", {
                cancelable: true,
                detail: {
                    url: caseUrl,
                    id: event.target.value,
                    title: event.target.label
                }
            })
        )) {
            this[NavigationMixin.Navigate]({
                type: 'standard__webPage',
                attributes: {
                    url: caseUrl
                }
            });
        }
    }

    toggleDownload(event) {
        this.showDownload = !this.showDownload;
        if (!this.showDownload) {
            this.dateFrom = null;
            this.dateTo = null;
            this.handleSearch(true);
        }
    }

    handleLoadMore(event) {
        this.handleSearch(false,false);
    }

    handleDateFromChange(event) {
        let fromTarget = this.template.querySelector(`[data-id="dateFrom"]`);
        fromTarget.blur();
        if (fromTarget.checkValidity()) {
            this.dateFrom = event.target.value;
            this.handleSearch(true);
        }
    }

    handleDateToChange(event) {
        let toTarget = this.template.querySelector(`[data-id="dateTo"]`);
        toTarget.blur();
        if (toTarget.checkValidity()) {
            this.dateTo = event.target.value;
            this.handleSearch(true);
        }
    }

    handleCloseDownload(event) {
        this.showDownload = false;
        this.dateFrom = null;
        this.dateTo = null;
        this.handleSearch(true);
    }

    handleDownloadClick(event) {
        this.downloadCaseList = [];
        if(this.ina==true){
            getInACases(this.getCaseDownloadPayload())
            .then(response => {
                const data = this.handleResponseData(response)
                this.downloadCaseList = data;
                this.downloadCSVFile();
            })
            .catch(error => this.handleResponseError(error));
        }
        else{
        getCases(this.getCaseDownloadPayload())
        .then(response => {
            const data = this.handleResponseData(response)
            this.downloadCaseList = data;
            this.downloadCSVFile();
        })
        .catch(error => this.handleResponseError(error));
    }
}

    handleAccountCheckBox(event) {
        const checked = event.target.checked;
        this.viewAllCases = checked;
        this.handleSearch(true, false);
    }

    getCaseDownloadPayload() {
        return {
            product: this.product && this.product.name && this.product.name != 'All Products' ? this.product.name : null,
            amount: 1000,
            offset: 0,
            searchTerm: this.searchText,
            status: this.statusFilter,
            myCases: this.displayProjectCases ? false : this.ownerFilter == 'My Cases',
            collaborationCases: this.displayProjectCases ? false : this.ownerFilter == 'My Collaboration Cases',
            startDate: this.dateFrom,
            endDate: this.dateTo,
            superUser: this.superUser != null && this.superUser,
            collaborationCases: this.displayProjectCases ? false : this.ownerFilter == 'My Collaboration Cases',
            projectCases: this.ina,
            selectedAccId: this.accountId && !this.viewAllCases ? this.accountId : null
        }
    }

    @api
    get userNotEntitled() {
        if (this.superUser || this.recordId || this.displayProjectCases) {
            // super users can see cases for all products
            return false;
        }
        // if admin = false then don't show
        if (this.product && this.product.name && this.product.name != 'All Products') {
            return !this.product.admin || this.product.admin != 'true';
        } else {
            return false;
        }
    }

    get productFilterVisible() {
        return this.displayProductFilter && this.product && this.productList && this.productList.length > 2;
    }

    get assistiveText() {
        return this.displayProjectCases ? "Search Projects..." : "Search Cases...";
    }

    downloadCSVFile() {
        let rowEnd = '\n';
        let csvString = '';
        const rowData = ['Reference', 'Account Name', 'Subject', 'Product', 'Component/Module','Priority', 'Created Date', 'Created By','Current Owner', 'Last Activity', 'Status','Date/Time Closed'];
        const rowProperties = ['reference', 'AccountName','subject', 'product','subAnalysis','priority', 'created', 'createdBy','owner', 'lastModified', 'statusGroup','closeddate'];

        // splitting using ','
        csvString += rowData.join(',');
        csvString += rowEnd;

        // main for loop to get the data based on key value
        for(let i=0; i < this.downloadCaseList.length; i++){
            let colValue = 0;

            rowProperties.forEach(rowKey => {
                // add , after every value except the first.
                if(colValue > 0){
                    csvString += ',';
                }
                // If the column is undefined, leave it as blank in the CSV file.
                let value = this.downloadCaseList[i][rowKey] === undefined ? '' : this.downloadCaseList[i][rowKey];
                // Pretty print date values
                if (value != '' && (rowKey == 'created' || rowKey == 'lastModified')) {
                    value = value.toLocaleString();
                }

                csvString += '"'+ this.sanitiseString(value) +'"';
                colValue++;
            });
            csvString += rowEnd;
        }

        // Creating anchor element to download
        let downloadElement = document.createElement('a');

        // This  encodeURI encodes special characters, except: , / ? : @ & = + $ # (Use encodeURIComponent() to encode these characters).
        downloadElement.href = 'data:text/csv;charset=utf-8,' + encodeURI(csvString);
        downloadElement.target = '_self';
        // CSV File Name
        downloadElement.download = 'Case Export.csv';
        // below statement is required if you are using firefox browser
        document.body.appendChild(downloadElement);
        // click() Javascript function to download CSV file
        downloadElement.click();
    }

    sanitiseString(cell) {
        cell = cell.replace(/"/g, '""');
        cell = cell.replace(/#/g, '');
        return cell;
    }
}