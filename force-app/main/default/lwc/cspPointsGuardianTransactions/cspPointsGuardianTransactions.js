import { LightningElement, api, track, wire } from 'lwc';
import { CurrentPageReference, NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import getFlexPointTransactions from '@salesforce/apex/cspFlexPointsTransactionsHandler.getFlexPointTransactions';
import getFlexPointRedemptionCases from '@salesforce/apex/cspCaseHandler.getFlexPointRedemptionCases';
import getIsPointsGuardian from '@salesforce/apex/cspContactsHandler.getIsPointsGuardian';
import getTransactionReference from '@salesforce/apex/cspFlexPointsTransactionsHandler.getTransactionReference';
import getOpenRequestCaseReference from '@salesforce/apex/cspCaseHandler.getOpenRequestCaseReference';
import getIsNonPointsUser from '@salesforce/apex/cspContactsHandler.getIsNonPointsUser';

import { registerListener, unregisterListener } from 'c/pubsub';

export default class CspPointsGuardianTransactions extends NavigationMixin(LightningElement) {
    showMore = true;
    showMoreCases = true;
    showPending = true;
    showConfirmed = true;
    showOpenQuoteRequests = false;
    isGuardian = false;
    isNonPointsUser = false;
    refreshing = false;
    accountId = '';
    caseId;
    reference;
    @track offset = 0;
    @track caseOffset = 0;
    @api limitAmount;
    @api caseLimitAmount;

    openQuoteRequests = [];
    pendingTransactions = [];
    confirmedTransactions = [];
    historyTransactions = [];

    @wire(CurrentPageReference) pageRef;

    constructor() {
        super();
        this.accountId = window.sessionStorage.getItem('selectedAccountId');
    }

    connectedCallback() {
        this.handleIsPointGuardian();
        this.handleIsNonPointsUser();
        registerListener('cspAccountSelectionEvent', this.handleAccountSelection, this);
    }

    disconnectedCallback() {
        unregisterListener('cspAccountSelectionEvent', this.handleAccountSelection, this);
    }


    handleAccountSelection(event) {
        if(!event.selectedAccountId) {
            return;
        }

        this.accountId = event.selectedAccountId;

        this.handleIsPointGuardian();
        this.handleIsNonPointsUser();
    }

    handleIsNonPointsUser() {
        this.refreshing = true;
        // validate that the selected account is non point user
        getIsNonPointsUser({ selectedAccountId: this.accountId })
        .then(result => {
            this.isNonPointsUser = result;
        })
        .catch(error => {
            console.log(error);
            this.handleResponseError(error);
        }).finally(() => {
            this.refreshing = false;
        })
    }

    handleIsPointGuardian() {
        this.refreshing = true;
        // validate that the selected acccount is a points guardian
        getIsPointsGuardian({ selectedAccountId: this.accountId})
        .then(response => {
            this.isGuardian = response;
        })
        .catch(error => {
            console.log(error);
            this.handleResponseError(error);
        })
        .finally(() => {
            if (this.isGuardian) {
                this.retrieveData();
            } else {
                this.refreshing = false;
            }
        })
    }

    retrieveData() {
        this.refreshing = true;
        getFlexPointTransactions({selectedAccountId: this.accountId, statusType: 'Pending', lmt: 0, ofst: 0, isTransHistory: false})
        .then(response => {
            this.pendingTransactions = response.length > 0 ? this.handleResponseData(response) : null;
            this.showPending = response.length > 0;
        })
        .catch((error) => {
            this.handleResponseError(error);
        })
        .finally(() => {this.refreshing = false;});

        getFlexPointTransactions({selectedAccountId: this.accountId, statusType: 'Confirmed', lmt: 0, ofst: 0, isTransHistory: false})
        .then(response => {
            this.confirmedTransactions = response.length > 0 ? this.handleResponseData(response) : null;
            this.showConfirmed = response.length > 0;
        })
        .catch((error) => {
            this.handleResponseError(error);
        })
        .finally(() => {this.refreshing = false;});

        this.historyTransactions = [];
        this.handleRetrieveTransactionHistory(false);
        this.handleOpenQuoteRequestClick(false);
    }

    handleResponseData(response) {
        return JSON.parse(JSON.stringify(response)).map(r => {
            r.isBroughtForward = this.isBroughtForward(r.status);
            r.isTopUp = this.isTopUp(r.status);
            r.isCancelled = this.isCancelled(r.status);
            r.isPending = this.isPending(r.status);
            r.isRedeemed = this.isRedeemed(r.status);
            r.isConfirmed = this.isConfirmed(r.status);
            r.isQuoteReceived = this.isQuoteReceived(r.status, r.points);
            r.isQuoteRequested = this.isQuoteRequested(r.status, r.points);
            r.isExpired = this.isExpired(r.status);
            r.isComplete = this.isComplete(r.status);
            r.isCancellationFee = this.isCancellationFee(r.status)
            r.isUnknown = this.isUnknown(r.status);
            if (r.isBroughtForward) {
                r.subject = 'Points Brought Forward';
            } else if (r.isTopUp) {
                r.subject = 'Points Top Up - ' + (r.type ? r.type : '');
            } else if (r.isQuoteReceived) {
                r.status = 'Quote Received';
            } else if (r.isQuoteRequested) {
                r.status = 'Quote Requested';
            } else if (r.isPending) {
                r.status = 'Requested'
            } else if (r.isConfirmed) {
                r.status = 'Booked'
            } else if (r.isCancelled) {
                r.points = 0;
            }

            if (r.type == 'Redemption' && r.points) {
                r.points = '-' + r.points;
            }
            return r;
        });
    }

    isBroughtForward(status) {
        return status == 'Brought Forward';
    }
    isTopUp(status) {
        return status == 'Top Up';
    }
    isCancelled(status) {
        return status == 'Cancelled';
    }
    isPending(status) {
        return status == 'Pending';
    }
    isRedeemed(status) {
        return status == 'Redeemed';
    }
    isConfirmed(status) {
        return status == 'Confirmed'
    }
    isQuoteReceived(status, points) {
        return (status == 'Estimate Required') && (points);
    }
    isQuoteRequested(status, points) {
        return (status == 'Estimate Required') && (!points);
    }
    isCancellationFee(status) {
        return status == 'Cancellation Fee';
    }
    isExpired(status) {
        return status == 'Expired'
    }
    isComplete(status) {
        return status == 'Delivered'
    }
    isUnknown(status) {
        return status != 'Brought Forward' &&
            status != 'Top Up' &&
            status != 'Cancelled' &&
            status != 'Pending' &&
            status != 'Redeemed' &&
            status != 'Confirmed' &&
            status != 'Estimate Required' &&
            status != 'Expired' && 
            status != 'Delivered' &&
            status != 'Cancellation Fee';
    }

    handleLoadMore() {
        this.offset = this.offset + this.limitAmount;
        this.refreshing = true;

        this.handleRetrieveTransactionHistory(true);
    }

    handleLoadMoreOpenQuoteRequestsCases() {
        this.caseOffset = this.caseOffset + this.caseLimitAmount;
        this.refreshing = true;

        this.handleOpenQuoteRequestClick(true);
    }

    @api
    handleOpenQuoteRequestClick(loadMore) {
        this.refreshing = true;
        if (!loadMore) {
            this.openQuoteRequests = [];
        }

        getFlexPointRedemptionCases({selectedAccountId: this.accountId, caseLimitAmount: this.caseLimitAmount, caseOffset: this.caseOffset})
        .then(response => {
            const data = response.length > 0 ? this.handleResponseData(response) : null;
            this.showMoreCases = !(response.length < 10);
            if (data && (JSON.stringify(data) !== JSON.stringify(this.openQuoteRequests))) {
                this.openQuoteRequests = this.openQuoteRequests.concat(data);
                this.showOpenQuoteRequests = true;
            } else {
                if (this.openQuoteRequests && this.openQuoteRequests.length == 0) {
                    this.showOpenQuoteRequests = false;
                }
            }
        })
        .catch((error) => {
            console.log(error);
            this.handleResponseError(error);
        })
        .finally(() => {this.refreshing = false;});
    }

    @api
    handleRetrieveTransactionHistory(loadMore){
        this.refreshing = true;
        if (!loadMore) {
            this.historyTransactions = [];
        }

        getFlexPointTransactions({selectedAccountId: this.accountId, statusType: null, lmt: this.limitAmount, ofst: this.offset, isTransHistory: true})
        .then(response => {
            const data = response.length > 0 ? this.handleResponseData(response) : null;
            this.showMore = !(response.length < 10);
            if (data && (JSON.stringify(data) !== JSON.stringify(this.historyTransactions))) {
                this.historyTransactions = this.historyTransactions.concat(data);
            } else {
                if (this.historyTransactions && this.historyTransactions.length == 0) {
                    this.historyTransactions = null;
                }
            }
        })
        .catch((error) => {
            console.log(error)
            this.handleResponseError(error);
        })
        .finally(() => {this.refreshing = false;});
    }

    @api
    handleTransactionClick(event) {
        this.caseId = event.currentTarget.dataset.id;
        getTransactionReference({ caseId: this.caseId })
        .then(result => {
            this.reference = result;
            this.template.querySelector('[data-id="csp-view-popup"').show();
        })
        .catch(e => this.dispatchEvent(new ShowToastEvent({
            title: 'Error loading transaction',
            message: e.body ? e.body.message : e.message,
            variant: 'error'
        })));
    }

    @api
    handleOpenQuoteCaseClick(event) {
        this.caseId = event.currentTarget.dataset.id;
        getOpenRequestCaseReference({ caseId: this.caseId })
        .then(result => {
            this.reference = result;
            this.template.querySelector('[data-id="csp-open-quote-view-popup"').show();
        })
        .catch(e => this.dispatchEvent(new ShowToastEvent({
            title: 'Error loading open request case',
            message: e.body ? e.body.message : e.message,
            variant: 'error'
        })));
    }

    handleResponseError(error) {
        this.refreshing = false;
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Error fetching transactions',
                message: error.message,
                variant: 'error',
            }),
        );
        this.error = JSON.stringify(error);
        console.log(this.error)
    }

    handleQuoteAction(event) {
        this.retrieveData();
    }
}