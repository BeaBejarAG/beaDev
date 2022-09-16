import { LightningElement, wire } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import getIsPointsGuardian from '@salesforce/apex/cspContactsHandler.getIsPointsGuardian';
import getIsNonPointsUser from '@salesforce/apex/cspContactsHandler.getIsNonPointsUser';
import getAccountManager from '@salesforce/apex/cspContactsHandler.getAccountManager';
import getPointsGuardians from '@salesforce/apex/cspContactsHandler.getPointsGuardians';
import { registerListener, unregisterListener } from 'c/pubsub';

export default class CspFlexPointsContacts extends LightningElement {

    accountId;
    accountManager;
    pointsGuardians
    isNonPointsUser = false;
    showContacts = false;
    errorMsg;

    @wire(CurrentPageReference) pageRef;

    constructor() {
        super();
        this.accountId = window.sessionStorage.getItem('selectedAccountId');
    }

    connectedCallback() {
        registerListener('cspAccountSelectionEvent', this.handleAccountSelection, this);
        this.handleUserContacts();
    }

    disconnectedCallback() {
        unregisterListener('cspAccountSelectionEvent', this.handleAccountSelection, this);
    }

    handleAccountSelection(event) {
        if(!event.selectedAccountId) {
            return;
        }

        this.accountId = event.selectedAccountId;
        this.handleUserContacts();
    }

    async handleUserContacts() {
        this.showContacts = false;
        this.accountManager = null;
        this.pointsGuardians = null;
        this.isNonPointsUser = false;

        const isPointsGuardian = await getIsPointsGuardian({ selectedAccountId: this.accountId });
        if (isPointsGuardian) return;

        this.showContacts = true;
        this.isNonPointsUser = await getIsNonPointsUser({ selectedAccountId: this.accountId });
        if (!this.isNonPointsUser) {
            try {
                const data = await getPointsGuardians({ selectedAccountId: this.accountId });
                this.pointsGuardians = this.handlePointsGuardiansData(data);
                return;
            } catch(e) {
                this.errorMsg = 'An error occurred whilst fetching points guardians';
            }
        }

        try {
            const data = await getAccountManager({ selectedAccId: this.accountId });
            this.accountManager = this.handleAccountManagerData(data);
        } catch(e) {
            this.errorMsg = 'An error occurred whilst fetching account manager';
        }
    }

    handlePointsGuardiansData(data) {
        return JSON.parse(JSON.stringify(data)).map((obj, i) => {
            obj.photoUrl = obj.IsProfilePhotoActive ? obj.MediumPhotoUrl : '';
            obj.initials = obj.Contact.Name[0];

            const total = obj.Id.split('').map(x => x.charCodeAt(0)).reduce((a, b) => a + b);
            obj.avatar = `slds-float_left slds-m-right_medium slds-m-vertical_small csp-avatar_small access-theme-user-cat${total % 28}`;

            return obj;
        });
    }

    handleAccountManagerData(data) {
        let obj = JSON.parse(JSON.stringify(data));
        obj.photoUrl = data.IsProfilePhotoActive ? data.MediumPhotoUrl : '';
        obj.initials = data.Name[0];

        const total = data.Id.split('').map(x => x.charCodeAt(0)).reduce((a, b) => a + b);
        obj.avatar = `slds-float_left slds-m-right_medium slds-m-vertical_small csp-avatar_small access-theme-user-cat${total % 28}`;

        return obj;
    }
}