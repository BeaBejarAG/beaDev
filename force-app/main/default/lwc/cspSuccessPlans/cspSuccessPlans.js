import { api, track, LightningElement, wire } from 'lwc';
import { NavigationMixin, CurrentPageReference } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { fireEvent } from 'c/pubsub';
import { registerListener, unregisterListener } from 'c/pubsub';
import getContactsForAccount from '@salesforce/apex/cspSuccessPlanHandler.getContactsForAccount';

export default class CspSuccessPlans extends LightningElement {
    @api essentialTagline;
    @api standardTagline;
    @api premierTagline;
    @api essentialPlanDetailsString;
    @api standardPlanDetailsString;
    @api premierPlanDetailsString;
    @api searchText = '';
    @api limitAmount;
    @api refreshing = false;
    @api contactList = [];

    @api completedSearch = false;
    
    showStepProduct = true;
    product = null;
    levelFilter = 'All';
    showMore = false;
    contactCount = 0;
    offset = 0;
    accountId = '';

    @api essentialPlanDetails = [
        {
            name: "Support Services",
            details: [
                "Unlimited Problem Resolution Support via online Success Portal",
                "9am-5pm Service Hours",
                "2 Named Support Contacts",
                "P1 – 2 hr response time"
            ]
        },
        {
            name: "Advisory Services",
            details: [
                "Product Knowledge Base",
                "Online User Community"
            ]
        },
        {
            name: "Knowledge",
            details: [
                "Library of Recorded Webinars"
            ]
        }
    ];
    @api standardPlanDetails = [
        {
            name: "Support Services",
            details: [
                "Telephone Support",
                "Live chat (*where available)",
                "Extended Support Hours 8am-6pm",
                "4 Named Support Contacts",
                "P1 – 1hr response time",
                "P2 – 2hr response time"
            ]
        },
        {
            name: "Advisory Services",
            details: [
                "Task based ‘How to’ Advice and Guidance - online",
                "Access to a wealth of Knowledge Base articles",
                "Online User Communities"
            ]
        },
        {
            name: "Knowledge",
            details: [
                "Product E-Learning – 4 users (*where available)",
                "Success Webinar programme"
            ]
        },
        {
            name: "Success Services",
            details: [
                "Access to a team of Customer Success Managers"
            ]
        }
    ];
    @api premierPlanDetails = [
        {
            name: "Support Services",
            details: [
                "Telephone Support",
                "Live chat (*where available)",
                "Extended Support Hours 8am-6pm",
                "8 Named Support Contacts",
                "Named Technical Support Engineer for each product",
                "P1 – 1hr response time",
                "P2 – 2hr response time"
            ]
        },
        {
            name: "Advisory Services",
            details: [
                "Task based ‘How to’ Advice and Guidance – online & telephone",
                "Access to a wealth of Knowledge Base articles",
                "Online User Communities"
            ]
        },
        {
            name: "Knowledge",
            details: [
                "Product E-Learning – unlimited users (*where available)",
                "Success Webinar programme"
            ]
        },
        {
            name: "Success Services",
            details: [
                "Designated Customer Success Manager",
                "Access to a portfolio of Proactive Services",
                "Product Group Roadmap Briefings specific to Premier customers",
                "VIP Treatment at Access World"
            ]
        }
    ];

    @wire(CurrentPageReference) pageRef;

    constructor() {
        super();
        this.accountId = window.sessionStorage.getItem('selectedAccountId');
    }

    /* add listener */
    connectedCallback() {
        if (this.essentialPlanDetailsString) {
            try {
                this.essentialPlanDetails = JSON.parse(this.essentialPlanDetailsString);
            } catch(err) {
                console.log('Essential plan details parse failed: ' + err.message);
            }
        }
        if (this.standardPlanDetailsString) {
            try {
                this.standardPlanDetails = JSON.parse(this.standardPlanDetailsString);
            } catch(err) {
                console.log('Standard plan details parse failed: ' + err.message);
            }
        }
        if (this.premierPlanDetailsString) {
            try {
                this.premierPlanDetails = JSON.parse(this.premierPlanDetailsString);
            } catch(err) {
                console.log('Premier plan details parse failed: ' + err.message);
            }
        }
        registerListener('cspAccountSelectionEvent', this.handleAccountSelection, this);
        registerListener('cspProductSelectionEvent', this.setProduct, this);
    }

    /* Remove listener */
    disconnectedCallback() {
        unregisterListener('cspProductSelectionEvent', this.setProduct, this);
    }

    errorCallback(error, stack) {
        console.error(error.message, error.stack);
    }

    handleAccountSelection(event) {
        if(!event.selectedAccountId) {
            return;
        }

        this.accountId = event.selectedAccountId;
        this.showStepProduct = true;
    }

    /* Update current product, reset feature picklist and revalidate */
    setProduct(event) {
        if ((!event.product || !event.product.id)) {
            return;
        }
        this.product = event.product;

        if (this.product.id) {
            this.showStepProduct = false;
            this.levelFilter = "All";
            this.handleSearch(true);
        }
    }

    resetProduct(event) {
        this.showStepProduct = true;
        fireEvent(this.pageRef, 'cspProductSelectionEvent', { product: {} });
    }

    handleViewPlan(event) {
        this.planPopup.show();
    }

    /* Detect if escape was pressed and close modal */
    handleEscape(event) {
        if (event.which !== 27) {
            return;
        }
        this.planPopup.hide();
    }

    @api
    handleSearch(reset) {
        if(reset) {
            this.offset = 0;
        }
        this.refreshing = true;

        getContactsForAccount(this.getContactPayload())
        .then(response => {
            const data = this.handleResponseData(response)
            this.handleRendering(reset, data);
        })
        .catch(error => this.handleResponseError(error))
        .finally(e => this.refreshing = false);
    }

    getContactPayload() {
        return {
            product: this.product && this.product.name && this.product.name != 'All Products' ? this.product.name : null,
            amount: this.limitAmount,
            offset: this.offset,
            searchTerm: this.searchText,
            level: this.levelFilterValue,
            selectedAccId: this.accountId
        }
    }

    handleResponseData(response) {
        // Need to remove the wrapper the wire puts on in order to manipulate data
        return JSON.parse(JSON.stringify(response)).map(r => {
            r.photoUrl = r.isPhotoActive ? r.photoUrl : '';
            r.initials = (r.first ? r.first.substring(0, 1).toUpperCase() : '') + (r.last ? r.last.substring(0, 1).toUpperCase() : '');
            r.levelList = r.level.split(';').map(l => {
                return this.getLevelObject(l);
            });
            const total = r.id.split('').map(x => x.charCodeAt(0)).reduce((a, b) => a + b);
            r.avatar = `slds-float_left slds-m-horizontal_small slds-m-vertical_small csp-portal-member__avatar access-theme-user-cat${total % 28}`;
            return r;
        });
    }

    handleResponseError(error) {
        this.refreshing = false;
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Error fetching contacts',
                message: error.message,
                variant: 'error',
            }),
        );
        this.error = JSON.stringify(error);
        console.log(this.error)
    }

    handleRendering(reset, results) {
        // If there's more to retrieve then show the button
        this.showMore = results.length > this.limitAmount

        // Remove the additional result to match the amount requested
        if(results.length > this.limitAmount) {
            results.splice(this.limitAmount)
        }

        if(reset) {
            this.contactList = [];
        }

        // Concatente these to existing results so that we can use offset
        // in the SOQL without exceeding 2000 results limit
        this.contactList = this.contactList.concat(results);
        this.offset = this.contactList.length;

        this.completedSearch = this.contactList.length == 0;
    }

    handleSearchKeyPress(event) {
        this.searchText = event.target.value;
        this.handleSearch(true);
    }

    handleLevelFilterSelect(event) {
        if (this.levelFilter != event.detail.value) {
            this.levelFilter = event.detail.value;
            this.handleSearch(true);
        }
    }

    handleLoadMore(event) {
        event.target.blur();
        this.handleSearch(false);
    }

    getLevelObject(level) {
        return {
            label: this.getLevelFilterLabel(level),
            description: this.getLevelFilterDescription(level)
        }
    }
    getLevelFilterLabel(level) {
        if (level.includes('Support')) {
            return 'Support Member';
        }
        if (level.includes('Super')) {
            return 'Super Member';
        }
        if (level.includes('Read')) {
            return 'Read Only';
        }
        if (level.includes('Profile Unassigned')) {
            return 'Awaiting Confirmation';
        }
        return 'Read Only';
    }
    getLevelFilterDescription(level) {
        if (level.includes('Support')) {
            return 'These portal members can do all that a Read Only member can, plus can raise cases for this product';
        }
        if (level.includes('Super')) {
            return 'These portal members can view and contribute on all cases raised by other members within their organisation';
        }
        if (level.includes('Read')) {
            return 'These portal members have access to knowledge, event and release note content, but cannot raise a case for this product. They can also browse our Community';
        }
        if (level.includes('Profile Unassigned')) {
            return 'These portal members have registered, but their profiles have not been enabled just yet. Our team will get that sorted soon';
        }
        return 'These portal members have access to knowledge, event and release note content, but cannot raise a case for this product. They can also browse our Community';
    }

    get internalPlan() {
        return this.product && this.product.successPlanName && this.product.successPlanName.includes('Internal');
    }
    get classicPlan() {
        return this.product && this.product.successPlanName && this.product.successPlanName.includes('Classic');
    }
    get essentialPlan() {
        return this.product && this.product.successPlanName && this.product.successPlanName.includes('Essential');
    }
    get standardPlan() {
        return this.product && this.product.successPlanName && this.product.successPlanName.includes('Standard');
    }
    get premierPlan() {
        return this.product && this.product.successPlanName && this.product.successPlanName.includes('Premier');
    }
    get planPopup() {
        return this.template.querySelector('[data-id="plan-popup"]');
    }
    get popupSize() {
        if (this.internalPlan) {
            return 'large';
        }
        if (this.premierPlan) {
            return 'small';
        }
        return 'medium';
    }
    get levelFilterValue() {
        switch (this.levelFilter) {
            case "All":
                return ""
            case "Super Member":
                return "Super"
            case "Support Member":
                return "Support"
            case "Read Only":
                return "Read Only"
            case "Awaiting Confirmation":
                return "Profile Unassigned"
            default:
                return "";
        }
    }
}