import { LightningElement, wire, track, api } from 'lwc';
import { getRecord, updateRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CurrentPageReference, NavigationMixin } from 'lightning/navigation';
import { registerListener, unregisterListener } from 'c/pubsub';
import { refreshApex } from '@salesforce/apex';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';

import getUserMissionsProgress from '@salesforce/apex/cspCommunity.getUserMissionsProgress';
import getGroupsForUser from '@salesforce/apex/cspCommunity.getGroupsForUser';
import getContentVersionId from '@salesforce/apex/cspCommunity.getContentVersionId';
import setPhoto from '@salesforce/apex/cspCommunity.setPhoto';
import updateRegion from '@salesforce/apex/cspCommunity.updateRegion';
import deletePhoto from '@salesforce/apex/cspCommunity.deletePhoto';
import changePassword from '@salesforce/apex/cspCommunity.changePassword';
import follow from '@salesforce/apex/cspCommunity.follow';
import follows from '@salesforce/apex/cspCommunity.follows';
import unfollow from '@salesforce/apex/cspCommunity.unfollow';

import CONTACT_OBJECT from '@salesforce/schema/Contact';
import ID_FIELD from '@salesforce/schema/User.Id';
import ABOUTME_FIELD from '@salesforce/schema/User.AboutMe';
import REGION_FIELD from '@salesforce/schema/Contact.Region__c';

import USER_ID from '@salesforce/user/Id';
import COMMUNITY_BASE_PATH from '@salesforce/community/basePath';

export default class CspCommunityProfile extends NavigationMixin(LightningElement) {
    @api recordId;
    @api showBanner = false;
    isLoading = false;
    isMember = false;
    user = {profileBox: null};
    showProfile = false;
    showRecent = false;
    showPosts = false;
    showUnanswered = false;
    showBadges = false;
    showGroups = false;
    showArticles = false;
    showPassword = false;
    showProducts = false;
    showArticles = false;
    hasLoadedFile = false;
    contentDocumentLink = null;
    contentVersionId = null;
    contentDocumentId = null;
    newState = {};
    subscription = {};

    @track region;

    @wire(CurrentPageReference)
    setCurrentPageReference(pageRef) {
        this.recordId = location.pathname.split('/').pop();
        this.pageRef = pageRef;

        if(this.showBanner || pageRef.attributes.recordId != this.recordId) {
            return;
        }

        const restricted = ['profile', 'password', 'articles', 'products'];
        if(!pageRef.state.show) {
            this.redirectToState({
                show: USER_ID === this.recordId ? 'profile' : 'posts'
            })
        } else if(pageRef.state.show === 'logout' && USER_ID === this.recordId) {
            const base = COMMUNITY_BASE_PATH.substring(0, COMMUNITY_BASE_PATH.length - 1);
            document.location.href = `${base}secur/logout.jsp`
        } else if(USER_ID === this.recordId) {
            this.showProfile = pageRef.state.show === 'profile';
            this.showPassword = pageRef.state.show === 'password';
            this.showProducts = pageRef.state.show === 'products';
            this.showArticles = pageRef.state.show === 'articles';
        } else {
            if(restricted.includes(pageRef.state.show)) {
                this.redirectToState({
                    show: 'posts'
                })
            }
        }

        this.showRecent = pageRef.state.show === 'recent';
        this.showPosts = pageRef.state.show === 'posts';
        this.showUnanswered = pageRef.state.show === 'unanswered';
        this.showBadges = pageRef.state.show === 'badges';
        this.showGroups = pageRef.state.show === 'groups';
    }

    @wire(getObjectInfo, { objectApiName: CONTACT_OBJECT })
    objectInfo;

    @wire(getPicklistValues, {recordTypeId: '$objectInfo.data.defaultRecordTypeId', fieldApiName: REGION_FIELD})
    RegionPicklistValues;

    handleRegionChange(event) {
        this.region = event.detail.value;
    }

    handleNavigationEvent(event) {
        const state = {
            show: event.show
        }

        if(state == this.newState || !state.show) {
            return;
        }
        this.newState = state;
        this.redirectToState(state);
    }

    redirectToState(state) {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: this.pageRef.attributes,
            state
        });
    }

    @wire(getRecord, {
        recordId: '$recordId',
        fields: [
            'User.Id',
            'User.Name',
            'User.AboutMe',
            'User.Email',
            'User.IsProfilePhotoActive',
            'User.MediumPhotoUrl',
            'User.CreatedDate',
            'User.Contact.Region__c'
        ]
    })
    async setRecord(result) {
        this.wiredUser = result;

        if(result.error) {
            return this.errorCallback(result.error);
        }
        if(!result.data) {
            return;
        }
       
        const user = {
            id: result.data.fields.Id.value,
            name: result.data.fields.Name.value,
            createdDate: result.data.fields.CreatedDate.value,
            hasPhoto: result.data.fields.IsProfilePhotoActive.value,
            initials: result.data.fields.Name.value.substring(0, 1),
            photo: result.data.fields.MediumPhotoUrl.value,
            aboutMe: result.data.fields.AboutMe.value,
            email: result.data.fields.Email.value,
            isCurrentUser: result.data.fields.Id.value == USER_ID,
            region: result.data.fields.Contact.value ? result.data.fields.Contact.value.fields.Region__c.value : '',
            hasContact: result.data.fields.Contact.value != null,
            contactId: result.data.fields.Contact.value ? result.data.fields.Contact.value.id : ''
        }

        if(!user.hasPhoto) {
            user.photo = null;
        }

        const total = user.id.split('').map(x => x.charCodeAt(0)).reduce((a, b) => a + b);
        user.avatar = `slds-align-top csp-avatar csp-avatar_large access-theme-user-cat${total % 28}`;
        user.profileBox = `csp-box_profile access-theme-user-cat${total % 28}`;

        try {
            user.groups = JSON.parse(JSON.stringify(await getGroupsForUser({
                userId: this.recordId
            })));
            user.groups.groups.forEach(e => {
                e.memberCountLabel = `${e.memberCount} members`;
                e.name = this.decodeEntities(e.name);
                e.description = this.decodeEntities(e.description);
            });
        } catch(e) {
            user.groups = [];
            this.errorCallback(e);
        }

        try {
            user.missions = JSON.parse(JSON.stringify(await getUserMissionsProgress({
                userId: user.id
            })));
        } catch(e) {
            user.missions = [];
            this.errorCallback(e);
        }

        this.user = user;
    }

    errorCallback(e) {
        console.error(e);
        this.dispatchEvent(new ShowToastEvent({
            message: e.body ? e.body.message : (e.message ? e.message : e),
            variant: 'error'
        }));
    }

    async connectedCallback() {
        this.recordId = location.pathname.split('/').pop();
        this.subscription = await follows({ recordId: this.recordId });
        this.isMember = this.subscription ? true : false;
        if(!this.showBanner) {
            registerListener('cspCommunityNavigationEvent', this.handleNavigationEvent, this);
        }
    }

    disconnectedCallback() {
        this.recordId = null;
        unregisterListener('cspCommunityNavigationEvent', this.handleNavigationEvent, this);
    }

    async handleUpdateProfile(event) {
        try {
            this.isLoading = true;
            const fields = {
                [ID_FIELD.fieldApiName]: USER_ID,
                [ABOUTME_FIELD.fieldApiName]: this.aboutMe.value,
                
            };

            if(this.contentDocumentId) {
                await setPhoto({fileId: this.contentDocumentId});
            }

            setTimeout(async e => {
                
                await updateRecord({
                    fields
                });
                if (this.user.hasContact) {
                    await updateRegion({
                        contactId: this.user.contactId,
                        region: this.region
                    });
                }

                await refreshApex(this.wiredUser);
            }, 2000);

            this.handleCancelFileUpload(event);
        } catch(e) {
            this.errorCallback(e);
        } finally {
            this.isLoading = false;
            this.dispatchEvent(new ShowToastEvent({
                message: 'Profile has been updated successfully',
                variant: 'success'
            }));
        }
    }

    async handleUpdatePassword(event) {
        if(this.template.querySelector('[data-id="new-password"]').value != this.template.querySelector('[data-id="confirm-password"]').value) {
            return this.dispatchEvent(new ShowToastEvent({
                message: 'Sorry, your new password does not match',
                variant: 'error'
            }));
        }

        try {
             await changePassword({
                newPassword: this.template.querySelector('[data-id="new-password"]').value,
                confirmPassword: this.template.querySelector('[data-id="confirm-password"]').value,
                oldPassword: this.template.querySelector('[data-id="old-password"]').value
            });
        } catch(e) {
            return this.dispatchEvent(new ShowToastEvent({
                message: e.body.message,
                variant: 'error'
            }));
        }

        this.dispatchEvent(new ShowToastEvent({
            message: 'Your passsword has been changed',
            variant: 'success'
        }));
        this.template.querySelector('[data-id="old-password"]').value = '';
        this.template.querySelector('[data-id="new-password"]').value = '';
        this.template.querySelector('[data-id="confirm-password"]').value = '';
    }

    async handleSelectFile(event) {
        const path = COMMUNITY_BASE_PATH.split('/')[1];

        this.contentDocumentId = event.detail.files[0].documentId;
        this.contentVersionId = await getContentVersionId({contentDocumentId: this.contentDocumentId});
        this.contentDocumentLink = `/${path}/sfc/servlet.shepherd/version/download/${this.contentVersionId}`;

        this.hasLoadedFile = true;
    }

    handleCancelFileUpload(event) {
        this.hasLoadedFile = false;
        this.contentVersionId = null;
        this.contentDocumentId = null;
        this.contentDocumentLink = null;
    }

    async handleRemovePhoto(event) {
        try {
            await deletePhoto();
            await refreshApex(this.wiredUser);
        } catch(e) {
            this.errorCallback(e);
        }
    }

    handleViewGroup(event) {
        this.navigateTo(event.currentTarget.dataset.id);
    }

    navigateTo(recordId) {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId,
                actionName: 'view'
            }
        });
    }

    decodeEntities(input) {
        const element = document.createElement('textarea');
        element.innerHTML = input;
        return element.textContent;
    }

    async handleFollow(event) {
        const followResult = await follow({ recordId: this.recordId });
        this.subscription = { Id: followResult.id };
        this.isMember = true;
    }

    async handleUnfollow(event) {
        await unfollow({ subscriptionId: this.subscription.Id });
        this.isMember = false;
    }

    get isCurrentUser() {
        return USER_ID === this.recordId;
    }

    get aboutMe() {
        return this.template.querySelector('[data-id="about-me"]');
    }

    get photoUrl() {
        return (this.user.photo == null ? '' : `${this.contentDocumentLink || this.user.photo}?v=${new Date().getTime()}` );
    }

    get acceptedImageFormats() {
        return ['.jpg', '.png', '.gif', '.jpeg'];
    }

    get showFeed() {
        return this.showPosts || this.showRecent || this.showUnanswered;
    }
}