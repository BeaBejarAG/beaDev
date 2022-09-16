import { LightningElement, wire, api } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import { fireEvent } from 'c/pubsub';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CurrentPageReference, NavigationMixin } from 'lightning/navigation';

import getUserMissionsProgress from '@salesforce/apex/cspCommunity.getUserMissionsProgress';

import USER_ID from '@salesforce/user/Id';

export default class CspCommunityProfilePopover extends NavigationMixin(LightningElement) {
    @api user;
    profiles = {};
    userId = null;
    userMissions = null;
    isLoading = false;

    @wire(CurrentPageReference) pageRef;

    @wire(getRecord, {
        recordId: '$userId',
        fields: [
            'User.AboutMe'
        ]
    })
    async setRecord(result) {
        if(result.error) {
            return this.errorCallback(result.error);
        }
        if(!result.data || this.profiles[this.userId]) {
            return;
        }

        this.profiles[this.userId] = result.data.fields.AboutMe.value;
        this.user.aboutMe = result.data.fields.AboutMe.value;

        // force UI refresh
        this.user = this.user;
        if(this.reputation) {
            this.reputation.refresh();
        }
        this.isLoading = false;
    }

    errorCallback(e) {
        console.error(e);
        this.dispatchEvent(new ShowToastEvent({
            message: e.body ? e.body.message : e.message,
            variant: 'error'
        }));
    }

    @api hide(event) {
        let node = event.target;

        // iterate through parents to find boundary of the mouse events
        while(node && node.dataset && !node.dataset.id) {
            node = node.parentNode;
        }

        // if the parent container is the same ID then don't hide, the user
        // has probably moved from the trigger to the popover, or vice-versa
        if(node && node.dataset && node.dataset.id === this.user.id) {
            return;
        }

        this.profilePopover.classList.add('slds-hide');
    }

    @api async show(event, userList) {
        if(!this.user) {
            return;
        }
        this.isLoading = true;
        const previousUserId = this.user ? this.user.id : null;

        // iterate through parents to find the boundary of the mouse events
        let node = event.target;
        while(node && !node.dataset.id) {
            node = node.parentNode;
        }

        if(!node || !node.dataset.id) {
            this.isLoading = false;
            return;
        }

        // find the user that the mouse has hovered over
        const user = userList.find(e => e.user && e.user.id === node.dataset.id);
        if(user) {
            this.user = user.user;
        }

        // support the same but when it's an actor
        const actorUser = userList.find(e => e.actor && e.actor.id === node.dataset.id);
        if(actorUser) {
            this.user = actorUser.actor;
        }

        this.userId = this.user.id;
        this.user.aboutMe = this.profiles[this.user.id];

        this.setPopoverPosition(event);
        let userMissions = {};
        try {
            // use cache if it's same user
            if(this.user.id === previousUserId) {
                userMissions = this.userMissions;
            } else {
                userMissions = JSON.parse(JSON.stringify(await getUserMissionsProgress({
                    userId: this.user.id
                })));
            }
        } catch(e) {
            this.errorCallback(e);
        } finally {
            this.userMissions = userMissions;
        }

        this.isLoading = false;
        if(this.reputation) {
            this.reputation.refresh();
        }
    }

    async handleViewProfile(event) {
        this.dispatchEvent(new CustomEvent('profileviewevent', {
            detail: {
                url: `/profile/${event.target.value}`
            }
        }));
    }

    setPopoverPosition(event) {
        this.profilePopover.classList.remove('slds-hide');
        if(this.profilePopover && this.profilePopover.offsetHeight > 0) {
            this.profilePopover.style.left = event.posX + 'px';
            this.profilePopover.style.top = event.posY + 'px';
        }
    }

    get profilePopover() {
        return this.template.querySelector('.csp-popover_profile');
    }

    get reputation() {
        return this.template.querySelector('[data-id="selected-reputation"]');
    }
}