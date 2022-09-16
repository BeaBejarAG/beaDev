import { LightningElement, wire, api } from 'lwc';
import { CurrentPageReference, NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { registerListener, unregisterListener, fireEvent } from 'c/pubsub';

import getGroupMembers from '@salesforce/apex/cspCommunity.getGroupMembers';
import getGroup from '@salesforce/apex/cspCommunity.getGroup';
import getFeedDetailsCached from '@salesforce/apex/cspCommunity.getFeedDetailsCached';
import getFollowers from '@salesforce/apex/cspCommunity.getFollowers';
import follow from '@salesforce/apex/cspCommunity.follow';
import follows from '@salesforce/apex/cspCommunity.follows';
import unfollow from '@salesforce/apex/cspCommunity.unfollow';
import setIsMutedByMe from '@salesforce/apex/cspCommunity.setIsMutedByMe';
import getFeed from '@salesforce/apex/cspCommunity.getFeed';
import addMember from '@salesforce/apex/cspCommunity.addMember';
import deleteMember from '@salesforce/apex/cspCommunity.deleteMember';
import COMMUNITY_BASE_PATH from '@salesforce/community/basePath';

const NONMEMBER =  'NotAMember';
const NONMEMBER_REQUESTED = 'NotAMemberPrivateRequested';

export default class cspCommunityFeeds extends NavigationMixin(LightningElement) {
    feed = {};
    members = {};
    subscription = null;
    isMember = false;
    @api recordId;

    @wire(CurrentPageReference) pageRef;

    connectedCallback() {
        if(this.isTypeGroup) {
            this.setFeed(getGroup({ groupId: this.recordId }));
            this.setMembers();
        } else if(this.isTypeTopic) {
            this.setSubscription(true);
            this.setFeed(getFeedDetailsCached({ topicId: this.recordId }));
            this.setMembers();
        } else if(this.isTypeFeed) {
            this.setSubscription();
            this.setFeed(getFeed({ feedId: this.recordId }));
            this.setMembers();
        }
        registerListener('cspCommunityUpdateFeedDetailsEvent', this.handleUpdateFeedDetailsEvent, this);
    }

    disconnectedCallback() {
        unregisterListener('cspCommunityUpdateFeedDetailsEvent', this.handleUpdateFeedDetailsEvent, this);
    }

    async setSubscription(setMember) {
        this.subscription = await follows({ recordId: this.recordId });
        if(setMember) {
            this.isMember = this.subscription ? true : false;
        }
    }

    async setMembers() {
        if(this.isTypeGroup) {
            this.members = await getGroupMembers({ groupId: this.recordId });
            this.members.members.forEach(e => e.user = this.enrichUser(e.user));
        } else {
            this.members = await getFollowers({ recordId: this.recordId });
            this.members.followers.forEach(e => e.user = this.enrichUser(e.subscriber));
        }
    }

    async setFeed(promiseFeed) {
        const feed = JSON.parse(JSON.stringify(await promiseFeed));
        this.enrichUser(feed.owner);

        if(feed.capabilities && feed.capabilities.topics) {
            feed.capabilities.topics.items.forEach(e => e.name = this.decodeEntities(e.name));
        }
        if(this.isTypeFeed) {
            this.isMember = !feed.capabilities.mute.isMutedByMe;
        } else if(this.isTypeGroup) {
            this.isMember = !(feed.myRole === NONMEMBER || feed.myRole === NONMEMBER_REQUESTED);
        }
        feed.lastFeedElementPostDate = new Date(feed.lastFeedElementPostDate);
        feed.modifiedDate = new Date(feed.modifiedDate);
        this.feed = feed;
    }

    decodeEntities(input) {
        const element = document.createElement('textarea');
        element.innerHTML = input;
        return element.textContent;
    }

    errorCallback(e) {
        console.error(e);
        this.dispatchEvent(new ShowToastEvent({
            message: e.body ? e.body.message : e.message,
            variant: 'error'
        }));
    }

     handleShowProfile(event) {
        const rect = event.target.getBoundingClientRect();
        fireEvent(this.pageRef, 'cspProfileEvent', {
            event: {
                target: {
                    dataset: {
                        id: event.target.parentNode.parentNode.dataset.id
                    }
                },
                posY: rect.top + window.pageYOffset + 25,
                posX: rect.left + window.pageXOffset + 25
            },
            userList: this.members.members ? this.members.members : this.members.followers
        });
        event.preventDefault();
        event.stopPropagation();
    }

    enrichUser(user) {
        if(!user) {
            return;
        }

        if(user.photo.photoVersionId == null) {
            user.photo.mediumPhotoUrl = null;
        }

        const total = user.id.split('').map(x => x.charCodeAt(0)).reduce((a, b) => a + b);
        user.avatar = `slds-align-top csp-avatar access-theme-user-cat${total % 28}`;
        user.profileBox = `csp-box_profile access-theme-user-cat${total % 28}`;
        user.initials = user.displayName[0];
        user.displayName = this.decodeEntities(user.displayName);

        return user;
    }

    async handleFollow(event) {
        await follow({ recordId: this.recordId });
        this.connectedCallback();
    }

    async handleUnfollow(event) {
        await unfollow({ subscriptionId: this.subscription.Id });
        this.connectedCallback();
    }

    async handleMute(event) {
        await setIsMutedByMe({
            feedElementId: this.recordId,
            isMutedByMe: true
        });
        this.connectedCallback();
    }

    async handleUnmute(event) {
        await setIsMutedByMe({
            feedElementId: this.recordId,
            isMutedByMe: false
        });
        this.connectedCallback();
    }

    async handleJoin(event) {
        await addMember({
            groupId: event.target.value
        });
        this.connectedCallback();
        fireEvent(this.pageRef, 'cspCommunityUpdateFeedEvent', {
            action: 'join'
        });
    }

    async handleLeave(event) {
        await deleteMember({
            membershipId: event.target.value
        });
        this.isMember = false;
        this.connectedCallback();
        fireEvent(this.pageRef, 'cspCommunityUpdateFeedEvent', {
            action: 'leave'
        });
    }

    handleViewTopic(event) {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: event.target.value,
                actionName: 'view'
            }
        });
    }

    handleShare() {
        this.template.querySelector('c-csp-modal').show();
    }

    handleCopy() {
        const textArea = document.createElement("textarea");
        textArea.style.position = 'fixed';
        textArea.style.top = 0;
        textArea.style.left = 0;
        textArea.style.width = '2em';
        textArea.style.height = '2em';
        textArea.style.border = 'none';
        textArea.style.background = 'transparent';
        textArea.value = this.shareLink;

        document.body.appendChild(textArea);
        textArea.focus();
        textArea.select();

        textArea.setSelectionRange(0, 99999);
        document.execCommand("copy");

        document.body.removeChild(textArea);

        const element = this.template.querySelector('.csp-knowledge-copied');
        element.classList.remove('slds-hide');

        setTimeout(() => {
            element.classList.add('slds-hide');
        }, 3000);
    }

    async handleUpdateFeedDetailsEvent(event) {
        this.setFeed(getFeed({ feedId: this.recordId }));
        this.isMember = !this.feed.capabilities.mute.isMutedByMe;
    }

    get isTypeTopic() {
        return this.recordId.substring(0, 3) === '0TO';
    }

    get isTypeGroup() {
        return this.recordId.substring(0, 3) === '0F9';
    }

    get isTypeFeed() {
        return this.recordId.substring(0, 3) === '0D5';
    }

    get shareLink() {
        let type;

        if(this.isTypeGroup) {
            type = '/group/';
        } else if(this.isTypeTopic) {
            type = '/topic/';
        } else {
            type = '/question/'
        }

        return window.location.origin + COMMUNITY_BASE_PATH + type + this.recordId;
    }
}