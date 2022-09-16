import { LightningElement, api, wire } from 'lwc';
import { CurrentPageReference, NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { registerListener, unregisterListener, fireEvent } from 'c/pubsub';

import getGroup from '@salesforce/apex/cspCommunity.getGroup';
import getRecordFeeds from '@salesforce/apex/cspCommunity.getRecordFeeds';
import getRecordFeedsCached from '@salesforce/apex/cspCommunity.getRecordFeedsCached';
import getFeedDetails from '@salesforce/apex/cspCommunity.getFeedDetails';
import getFeedDetailsCached from '@salesforce/apex/cspCommunity.getFeedDetailsCached';
import getPinned from '@salesforce/apex/cspCommunity.getPinned';
import getPinnedCached from '@salesforce/apex/cspCommunity.getPinnedCached';
import getUnansweredFeeds from '@salesforce/apex/cspCommunity.getUnansweredFeeds';
import updatePinnedElement from '@salesforce/apex/cspCommunity.updatePinnedElement';
import deleteFeedElement from '@salesforce/apex/cspCommunity.deleteFeedElement';
import getAuthoredFeeds from '@salesforce/apex/cspCommunity.getAuthoredFeeds';
import addMember from '@salesforce/apex/cspCommunity.addMember';

import POST_ANY_TOPIC from '@salesforce/customPermission/Community_Post_Any_Topic';

import USER_ID from '@salesforce/user/Id';

const NONMEMBER_REQUESTED = 'NotAMemberPrivateRequested';
const NONMEMBER = 'NotAMember';
const PENDING_REVIEW = 'PendingReview';

export default class cspCommunityFeeds extends NavigationMixin(LightningElement) {
    @api recordId;
    @api hideCreateButton;
    @api showHeader = false;
    @api displayOnly = false;
    @api showAuthored = false;
    @api showUnanswered = false;
    @api cacheable = false;
    isLoading = false;
    feedList;
    feed = {};
    pinned;
    unpinned;
    popupData = {};
    error;
    nextPageToken;
    isMember = false;

    @wire(CurrentPageReference) pageRef;

    connectedCallback() {
        if (!this.recordId) {
            return;
        }

        this.getFeed();
        this.getPinned();
        this.getUnpinned();

        registerListener('cspCommunityUpdateFeedEvent', this.handleUpdateFeedEvent, this);
        registerListener('cspCommunityNavigationEvent', this.handleNavigationEvent, this);
    }

    disconnectedCallback() {
        unregisterListener('cspCommunityUpdateFeedEvent', this.handleUpdateFeedEvent, this);
        unregisterListener('cspCommunityNavigationEvent', this.handleNavigationEvent, this);
    }

    errorCallback(e) {
        console.error(e);
        this.dispatchEvent(new ShowToastEvent({
            message: e.body ? e.body.message : e.message,
            variant: 'error'
        }));
    }

    async getFeed() {
        if(this.isTypeTopic && this.recordId) {
            if(this.cacheable) {
                this.feed = JSON.parse(JSON.stringify(await getFeedDetailsCached({ topicId: this.recordId })))
            } else {
                this.feed = await getFeedDetails({ topicId: this.recordId })
            }
        } else if(this.isTypeGroup && this.recordId) {
            this.feed = await getGroup({ groupId: this.recordId });
        } else if(this.isTypeUser) {
            this.feed = { name: 'My feed' };
        }
        if(this.isTypeGroup && this.feed) {
            this.isMember = !(this.feed.myRole === NONMEMBER || this.feed.myRole === NONMEMBER_REQUESTED);
        }
    }

    enrichFeed() {
        if((!this.unpinned || !this.unpinned.elements) && (!this.pinned || !this.pinned.elements)) {
            return null;
        }
        let feedList = [];
        if(this.pinned && this.pinned.elements && this.pinned.elements.length) {
            feedList = this.pinned.elements.concat(this.unpinned ? this.unpinned.elements : []);
        } else {
            feedList = this.unpinned ? this.unpinned.elements : [];
        }

        feedList.forEach(e => {
            const comments = e.capabilities.comments;
            const qAndA = e.capabilities.questionAndAnswers;

            if(qAndA) {
                qAndA.questionTitle = this.decodeEntities(qAndA.questionTitle);
            } else {
                e.header.text = this.decodeEntities(e.header.text);
            }

            if(comments && comments.page.items && comments.page.items[0]) {
                comments.page.items[0].user = this.enrichUser(comments.page.items[0].user);
            }
            e.isPostByMe = e.actor.id === USER_ID;
            e.menuOptions = this.getMenuOptions(e);
            e.menuOptionCount = e.menuOptions.reduce((b, a) => b + (a.visible ? 1 : 0), 0);
            e.actor = this.enrichUser(e.actor);
            e.typeLabel = e.type === 'QuestionPost' ? 'Question' : 'Discussion';
            e.typeClass = e.type === 'QuestionPost' ? 'csp-badge_question' : 'csp-badge_discussion';
            e.feedElementClass = "slds-box csp-box slds-var-m-bottom_small slds-grid ";
            e.feedElementClass += e.isPinned ? '' : 'csp-box_shaded-light';
        });
        this.feedList = feedList;
    }

    async getUnpinned(append) {
        try {
            this.error = null;
            let unpinned = {};

            if(this.showUnanswered) {
                unpinned = await getUnansweredFeeds({
                    recordId: this.recordId,
                    pageToken: append ? this.nextPageToken : null
                });
            } else if(this.showAuthored) {
                unpinned = await getAuthoredFeeds({
                    recordId: this.recordId,
                    pageToken: append ? this.nextPageToken : null
                });
            } else {
                if(this.cacheable) {
                    unpinned = JSON.parse(JSON.stringify(await getRecordFeedsCached({
                        recordId: this.recordId,
                        pageToken: append ? this.nextPageToken : null
                    })));
                } else {
                    unpinned = await getRecordFeeds({
                        recordId: this.recordId,
                        pageToken: append ? this.nextPageToken : null
                    });
                }
            }

            this.nextPageToken = unpinned.nextPageToken;

            unpinned.elements.forEach(e => {
                e.uniqueId = e.id;
                const status = e.capabilities.status;
                if(status) {
                    status.isPendingReview = status.feedEntityStatus === PENDING_REVIEW;
                }
            });

            if(append) {
                this.unpinned.elements = this.unpinned.elements.concat(unpinned.elements)
            } else {
                this.unpinned = unpinned;
            }
        } catch(e) {
            this.unpinned = [];
            if(e.body && e.body.exceptionType === 'System.NoAccessException') {
                this.error = 'You do not have permission to view this group without joining first';
                return;
            }
            throw e;
        } finally {
            this.enrichFeed();
        }
    }

    async getPinned(reset) {
        try {
            let pinned = null;

            if(this.cacheable) {
                pinned = JSON.parse(JSON.stringify(await getPinnedCached({
                    isGroup: this.isTypeGroup,
                    subjectId: this.recordId
                })));
            } else {
                pinned = JSON.parse(JSON.stringify(await getPinned({
                    isGroup: this.isTypeGroup,
                    subjectId: this.recordId
                })));
            }

            if(!pinned || !pinned.elements || pinned.elements.length === 0) {
                this.pinned = [];
                return;
            }

            pinned.elements[pinned.elements.length - 1].isFinalPinned = true;
            pinned.elements.forEach(e => e.uniqueId = `${e.id}-pinned`);
            pinned.elements.forEach(e => e.isPinned = true);
            this.pinned = pinned;
        } catch(e) {
            this.pinned = [];
            this.errorCallback(e);
        } finally {
            this.enrichFeed();
        }
    }

    async handlePinElement(id) {
        const pinnedElement = this.feedList.find(e => e.id === id);
        await updatePinnedElement({
            isGroup: this.isTypeGroup,
            feedId: this.recordId,
            subjectId: id,
            isPinned: !pinnedElement.capabilities.pin.isPinned
        });
        this.getPinned(true);
        this.getUnpinned();
    }

    async handleDeleteElement(event) {
        try {
            this.deletePopup.showLoading();
            await deleteFeedElement({
                feedElementId: event.target.value,
            });
            await this.getPinned(true);
            await this.getUnpinned();
            this.deletePopup.hideLoading();
            this.deletePopup.hide();
        } catch(e) {
            this.errorCallback(e);
        } finally {
            this.deletePopup.hideLoading();
        }
    }

    async handleMenuSelect(event) {
        const [ id, action ] = event.detail.value.split('-');

        if(action === 'pin') {
            this.handlePinElement(id);
        } else if(action === 'delete') {
            this.popupData = { id };
            this.deletePopup.show();
        }
    }

    handleCancelDeleteElement(event) {
        this.deletePopup.hide();
    }

    handleStartQuestion(event) {
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: `/post?type=question&topicId=${this.feed.id}`
            }
        });

    }

    handleStartDiscussion(event) {
        if(!this.isMember) {
            this.joinPopup.show();
        } else {
            this[NavigationMixin.Navigate]({
                type: 'standard__webPage',
                attributes: {
                    url: `/post?type=discussion&groupId=${this.feed.id}`
                }
            });
        }
    }

    async handleJoin(event) {
        await addMember({
            groupId: event.target.value
        });

        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: `/post?type=discussion&groupId=${this.feed.id}`
            }
        });
    }

    handleEscape(event) {
        this.joinPopup.hide();
        this.deletePopup.hide();
    }

    handleViewFeed(event) {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: event.target.value,
                actionName: 'view'
            },
            state: {
                pid: this.feed.id
            }
        });
    }

    enrichUser(user) {
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

    getMenuOptions(feedElement) {
        const feedCap = feedElement.capabilities;
        return [
            {
                value: `${feedElement.id}-delete`,
                label: 'Delete',
                visible: !feedElement.isDeleteRestricted &&
                    (!feedCap.edit || !feedCap.edit.isEditRestricted)
            }, {
                value: `${feedElement.id}-pin`,
                label: !feedCap.pin || feedCap.pin.isPinned ? 'Unpin' : 'Pin',
                visible: feedCap.pin && feedCap.pin.isPinnableByMe
            }
        ];
    }

    handleUpdateFeedEvent(event) {
        if(event.action === 'join') {
            this.isMember = true;
        } else if (event.action === 'leave') {
            this.isMember = false;
        }

        this.getUnpinned();
        this.getPinned();
        this.enrichFeed();
    }

    async handleNavigationEvent(event) {
        try {
            const prevRecordId = this.recordId;

            this.cacheable = event.cacheable;
            this.showUnanswered = false;
            this.showAuthored = false;
            this.isLoading = true;

            if(event.show === 'unanswered') {
                this.showUnanswered = true;
                this.recordId = event.recordId || USER_ID;
            } else if(event.show === 'recent') {
                this.recordId = event.recordId || USER_ID;
            } else if(event.show === 'posts') {
                this.showAuthored = true;
                this.recordId = event.recordId || USER_ID;
            } else if(event.show.match(/0[0-9A-Za-z]{17}/) !== null) {
                this.recordId = event.show;
            }

            if(this.recordId && event.show) {
                this.getFeed();
                this.getPinned();
                this.getUnpinned();
                this.enrichFeed();
            }
        } catch(e) {
            this.errorCallback(e);
        } finally {
            this.isLoading = false;
        }
    }

     handleShowProfile(event) {
        this.sendProfileEventPayload(event, this.feedList, 30, 30);
    }

    handleShowProfileReply(event) {
        const list = this.feedList.concat(this.feedList.map(e => {
            const comments = e.capabilities.comments;
            if(comments && comments.page.items && comments.page.items.length) {
                const comment = comments.page.items[0];
                this.enrichUser(comment.user);
                return comment;
            }
        }));
        this.sendProfileEventPayload(event, list.filter(e => e != null), 0, 18);
    }

    handleRichTextPopover(event) {
        event.detail.record.user = JSON.parse(JSON.stringify(event.detail.record.user));
        this.enrichUser(event.detail.record.user);
        this.sendProfileEventPayload(event.detail.event, [event.detail.record], 0, 18);
    }

    sendProfileEventPayload(event, userList, padX, padY) {
        const rect = event.target.getBoundingClientRect();
        const node = event.target.parentNode;
        fireEvent(this.pageRef, 'cspProfileEvent', {
             event: {
                target: {
                    dataset: {
                        id: node.dataset.id ? node.dataset.id : node.parentNode.dataset.id
                    }
                },
                posY: rect.top + window.pageYOffset + padY,
                posX: rect.left + window.pageXOffset + padX
            },
            userList
        });
        event.preventDefault();
        event.stopPropagation();
    }

    handleLoadMore(event) {
        this.getUnpinned(true);
    }

    decodeEntities(input) {
        const element = document.createElement('textarea');
        element.innerHTML = input;
        return element.textContent;
    }

    get isTypeTopic() {
        return this.recordId.substring(0, 3) === '0TO';
    }

    get isTypeUser() {
        return this.recordId.substring(0, 3) === '005';
    }

    get isTypeGroup() {
        return this.recordId.substring(0, 3) === '0F9';
    }

    get isTypeFeed() {
        return this.recordId.substring(0, 3) === '0D5';
    }

    get joinPopup() {
        return this.template.querySelector('.csp-join-popup');
    }

    get deletePopup() {
        return this.template.querySelector('.csp-delete-popup');
    }

    get canAskQuestion() {
        // Don't allow users to post a question in Community News & Announcements unless they hold the custom perm
        return this.recordId != '0TO58000000DORaGAO' || POST_ANY_TOPIC;
    }
}