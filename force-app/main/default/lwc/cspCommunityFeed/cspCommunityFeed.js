import { LightningElement, api, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CurrentPageReference, NavigationMixin } from 'lightning/navigation';
import { registerListener, unregisterListener, fireEvent } from 'c/pubsub';

import getFeed from '@salesforce/apex/cspCommunity.getFeed';
import updateLikeForComment from '@salesforce/apex/cspCommunity.updateLikeForComment';
import updateLikeForFeedElement from '@salesforce/apex/cspCommunity.updateLikeForFeedElement';
import addFlagToComment from '@salesforce/apex/cspCommunity.addFlagToComment';
import addFlagToFeedElement from '@salesforce/apex/cspCommunity.addFlagToFeedElement';
import getCommentsForFeedElement from '@salesforce/apex/cspCommunity.getCommentsForFeedElement';
import updateQuestionAndAnswers from '@salesforce/apex/cspCommunity.updateQuestionAndAnswers';
import setCommentIsVerified from '@salesforce/apex/cspCommunity.setCommentIsVerified';
import deleteFeedElement from '@salesforce/apex/cspCommunity.deleteFeedElement';
import deleteComment from '@salesforce/apex/cspCommunity.deleteComment';
import setFeedElementIsClosed from '@salesforce/apex/cspCommunity.setFeedElementIsClosed';

import USER_ID from '@salesforce/user/Id';
import ACCESS_LOGO_ICON from '@salesforce/contentAssetUrl/access_logo_icon';

export default class CspCommunityFeed extends NavigationMixin(LightningElement) {
    @api feedId;
    @api hideCreateButton = false;
    feedList = {elements:[]};
    feed = {};
    isLoading = false;
    comments;
    nextPageToken;
    selectedUser = {};
    popupData = {};
    accessLogoIcon = ACCESS_LOGO_ICON;

    @wire(CurrentPageReference) pageRef;

    connectedCallback() {
        this.loadFeed();
        this.loadComments();
        registerListener('cspCommunityNewCommentEvent', this.handleNewCommentEvent, this);
        registerListener('cspCommunityUpdateCommentEvent', this.handleUpdateEvent, this);
        registerListener('cspCommunityUpdateFeedEvent', this.handleUpdateEvent, this);
    }

    disconnectedCallback() {
        unregisterListener('cspCommunityNewCommentEvent', this.handleNewCommentEvent, this);
        unregisterListener('cspCommunityUpdateCommentEvent', this.handleUpdateEvent, this);
        unregisterListener('cspCommunityUpdateFeedEvent', this.handleUpdateEvent, this);
    }

    errorCallback(e) {
        console.error(e.body ? e.body.message : e.message);
        this.dispatchEvent(new ShowToastEvent({
            message: e.body ? e.body.message : e.message,
            variant: 'error'
        }));
    }

    async loadFeed() {
        const feed = await getFeed({
            feedId: this.feedId
        });
        this.enrichFeed(feed);
    }

    async loadComments(append) {
        const comments = await getCommentsForFeedElement({
            feedElementId: this.feedId,
            nextPage: append ? this.nextPageToken : null
        });

        this.nextPageToken = comments.nextPageToken;
        this.enrichComments(comments.items, append);
    }

    enrichFeed(feed) {
        this.enrichUser(feed.actor);
        if(feed.capabilities.status) {
            feed.capabilities.status.isPendingReview = feed.capabilities.status.feedEntityStatus === 'PendingReview';
        }
        feed.menuOptions = this.getMenuOptions(feed);
        feed.menuOptionCount = feed.menuOptions.reduce((b, a) => b + (a.visible ? 1 : 0), 0);
        feed.liked = feed.capabilities.chatterLikes.myLike != null;

        const qAndA = feed.capabilities.questionAndAnswers;
        if(qAndA) {
            qAndA.questionTitle = this.decodeEntities(qAndA.questionTitle);
        } else {
            feed.header.text = this.decodeEntities(feed.header.text);
        }
        if(qAndA && qAndA.bestAnswer) {
            this.enrichUser(qAndA.bestAnswer.user);
            qAndA.bestAnswer.liked = qAndA.bestAnswer.myLike != null;
            qAndA.bestAnswer.menuOptions = this.getMenuOptions(qAndA.bestAnswer, true);
            qAndA.bestAnswer.menuOptionCount = qAndA.bestAnswer.menuOptions.reduce((b, a) => b + (a.visible ? 1 : 0), 0);
        }

        this.feed = feed;
    }

    enrichComments(comments, append) {
        const common = 'slds-box csp-post csp-box slds-var-m-bottom_small';
        const isBestClass = `${common} csp-box_shaded-green csp-box-shaded-right_green`;

        comments.forEach(e => {
            this.enrichUser(e.user);

            e.liked = e.myLike != null;
            e.menuOptions = this.getMenuOptions(e, true);
            e.menuOptionCount = e.menuOptions.reduce((b, a) => b + (a.visible ? 1 : 0), 0);
            e.isBestAnswerClass = `${common} csp-box_shaded-light`;
            e.isBestAnswer = false;

            const qAndA = this.feed.capabilities.questionAndAnswers;
            if(qAndA && qAndA.bestAnswer) {
                e.isBestAnswerClass = e.id === qAndA.bestAnswer.id ? isBestClass : e.isBestAnswerClass;
                e.isBestAnswer = e.id === qAndA.bestAnswer.id;
            }
        });

        if(append) {
            this.comments = comments.concat(this.comments);
        } else {
            this.comments = comments;
        }
    }

    enrichUser(user) {
        // strip default placeholder image
        if(user.photo.photoVersionId == null) {
            user.photo.mediumPhotoUrl = null;
        }

        // calculate colour index from palette
        const total = user.id.split('').map(x => x.charCodeAt(0)).reduce((a, b) => a + b);
        user.avatar = `slds-align-top csp-avatar access-theme-user-cat${total % 28}`;
        user.profileBox = `csp-box_profile access-theme-user-cat${total % 28}`;
        user.initials = user.displayName[0];
        user.displayName = this.decodeEntities(user.displayName);
    }

    async handleLike(event) {
        try {
            this.isLoading = true;
            await updateLikeForFeedElement({
                feedElementId: event.target.dataset.id,
                isLikedByCurrentUser: event.target.dataset.liked === 'false'
            });
            await this.loadFeed();
        } catch(e) {
            this.errorCallback(e);
        } finally {
            this.isLoading = false;
        }
    }

    async handleCommentLike(event) {
        try {
            this.isLoading = true;
            await updateLikeForComment({
                commentId: event.target.dataset.id,
                isLikedByCurrentUser: event.target.dataset.liked === 'false'
            });
            await this.loadComments();
            await this.loadFeed();
        } catch(e) {
            this.errorCallback(e);
        } finally {
            this.isLoading = false;
        }
    }

    async handleReportAbuseFeed(event) {
        this.popupData = {
            id: event.target.value,
            options: [
                { label: 'Spam', value: 'spam' },
                { label: 'Abuse or inappropriate content', value: 'abuse' }
            ],
            selected: 'spam'
        }
        this.abusePopup.show();
    }

    async handleReportAbuseComment(event) {
        this.popupData = {
            id: event.target.value,
            options: [
                { label: 'Spam', value: 'spam' },
                { label: 'Inappropriate content', value: 'abuse' }
            ],
            selected: 'spam'
        }
        this.abusePopup.show();
    }

    async handleReportAbuseSubmit(event) {
        if(event.target.value === this.feed.id) {
            return this.handleReportAbuseFeedSubmit(event);
        } else {
            return this.handleReportAbuseCommentSubmit(event);
        }
    }

    async handleReportAbuseFeedSubmit(event) {
        try {
            this.abusePopup.showLoading();
            await addFlagToFeedElement({
                feedElementId: event.target.value,
                note: this.abuseMessage.value,
                spam: this.abuseOption.value === 'spam'
            });
            await this.loadFeed();
            await this.loadComments();
            this.abusePopup.hide();
        } catch(e) {
            this.errorCallback(e);
        } finally {
            this.abusePopup.hideLoading();
        }
    }

    async handleReportAbuseCommentSubmit(event) {
        try {
            this.abusePopup.showLoading();
            await addFlagToComment({
                commentId: event.target.value,
                note: this.abuseMessage.value,
                spam: this.abuseOption.value === 'spam'
            });
            await this.loadFeed();
            await this.loadComments();
            this.abusePopup.hide();
        } catch(e) {
            this.errorCallback(e);
        } finally {
            this.abusePopup.hideLoading();
        }
    }

    async handleSelectBest(event) {
        try {
            this.isLoading = true;
            await updateQuestionAndAnswers({
                feedElementId: this.feedId,
                bestAnswerId: event.target.value
            });
            await this.loadFeed();
            await this.loadComments();
        } catch(e) {
            this.errorCallback(e);
        } finally {
            this.isLoading = false;
        }
    }

    async handleRemoveBest(event) {
        try {
            this.isLoading = true;
            await updateQuestionAndAnswers({
                feedElementId: this.feedId,
                bestAnswerId: null
            });
            await this.loadFeed();
            await this.loadComments();
        } catch(e) {
            this.errorCallback(e);
        } finally {
            this.isLoading = false;
        }
    }

    async handleDeleteElement(event) {
        this.deletePopup.showLoading();
        try {
            if(event.target.value !== this.feed.id) {
                await deleteComment({
                    commentId: event.target.value,
                });

                await this.loadComments();
                await this.loadFeed();
                this.deletePopup.hideLoading();
                this.deletePopup.hide();
                fireEvent(this.pageRef, 'cspCommunityUpdateFeedDetailsEvent', { });
            } else if(event.target.value === this.feed.id) {
                await deleteFeedElement({
                    feedElementId: event.target.value,
                });

                this[NavigationMixin.Navigate]({
                    type: 'standard__webPage',
                    attributes: {
                        url: '/community'
                    }
                });
            }
        } catch(e) {
            this.errorCallback(e);
        } finally {
            this.deletePopup.hideLoading();
        }
    }

    async handleVerifyElement(id, action) {
        try {
            this.isLoading = true;
            await setCommentIsVerified({
                commentId: id,
                isVerified: action === 'verify'
            });
            await this.loadFeed();
            await this.loadComments();
        } catch(e) {
            this.errorCallback(e);
        } finally {
            this.isLoading = false;
        }
    }

    async handleCloseElement(id, action) {
        try {
            this.isLoading = true;
            await setFeedElementIsClosed({
                feedElementId: id,
                isClosed: action === 'close'
            });
            this.loadFeed();
        } catch(e) {
            this.errorCallback(e);
        } finally {
            this.isLoading = false;
        }
    }

    handleEditElement(id) {
        const postRender = `c-csp-community-post-render[data-id="${id}"]`;
        const html = this.template.querySelector(postRender).getEditValue();
        const subject = this.feed.capabilities.questionAndAnswers ?
            this.feed.capabilities.questionAndAnswers.questionTitle : null;
        const showSubject = id === this.feed.id && subject;

        const topicId = id === this.feed.id && this.feed.capabilities.topics && this.feed.capabilities.topics.items[0] ?
            this.feed.capabilities.topics.items[0].id : null;

        this.popupData = { id, html, subject, showSubject, topicId }
        this.editPopup.show();
    }

    handleMenuSelect(event) {
        const [ id, action ] = event.detail.value.split('-');

        if(action === 'verify' || action === 'unverify') {
            this.handleVerifyElement(id, action);
        } else if(action === 'delete') {
            this.popupData = { id };
            this.deletePopup.show();
        } else if(action === 'close' || action === 'reopen') {
            this.handleCloseElement(id, action);
        } else if(action === 'edit') {
            this.handleEditElement(id);
        }
    }

    handleCancelDeleteElement(event) {
        this.deletePopup.hide();
    }

    handleEscape(event) {
        if(event.which !== 27) {
            return;
        }
        this.editPopup.hide();
        this.deletePopup.hide();
        this.abusePopup.hide();
    }

    handleReply(event) {
        window.scrollTo(0, document.body.scrollHeight);
        this.template.querySelector('.csp-feed_input').focus();
    }

    handleShowProfile(event) {
        this.sendProfileEvent(event, this.comments.concat([this.feed]), 30, 30);
    }

    handleRichTextPopover(event) {
        event.detail.record.user = JSON.parse(JSON.stringify(event.detail.record.user));
        this.enrichUser(event.detail.record.user);
        this.sendProfileEvent(event.detail.event, [event.detail.record], 0, 18);
    }

    sendProfileEvent(event, userList, padX, padY) {
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

    async handleNewCommentEvent(event) {
        this.isLoading = true;
        try {
            await this.loadComments();
        } catch(e) {
            this.errorCallback(e);
        } finally {
            this.isLoading = false;
        }
    }

    getMenuOptions(feedElement, comment) {
        const feedCap = feedElement.capabilities;
        return [
            {
                value: `${feedElement.id}-edit`,
                label: 'Edit',
                visible: (feedCap.edit && !feedCap.edit.isEditRestricted) &&
                    (!feedCap.close || !feedCap.close.isClosed)
            }, {
                value: `${feedElement.id}-delete`,
                label: 'Delete',
                visible: !feedElement.isDeleteRestricted &&
                    (!feedCap.edit || !feedCap.edit.isEditRestricted) &&
                    (!feedCap.close || !feedCap.close.isClosed)
            }, {
                value: `${feedElement.id}-${feedCap.close && feedCap.close.isClosed ? 'reopen' : 'close'}`,
                label: feedCap.close && feedCap.close.isClosed ? 'Reopen' : 'Close',
                visible: feedCap.close && feedCap.close.canContextUserUpdateIsClosed && !comment
            }, {
                value: `${feedElement.id}-${feedCap.verified && feedCap.verified.isVerified ? 'un' :''}verify`,
                label: !feedCap.verified || !feedCap.verified.isVerified ? 'Company verify' : 'Remove verification',
                visible: feedCap.verified && feedCap.verified.isVerifiableByMe &&
                    (feedCap.verified.isVerified === true || this.feed.hasVerifiedComment === false) &&
                    (!feedCap.status || feedCap.status.feedEntityStatus !== 'PendingReview') && comment
            }, {
                value: `${feedElement.id}-approve`,
                label: !feedCap.status || feedCap.status.feedEntityStatus === 'Published' ?
                    'Unapprove' : 'Approve',
                visible: feedCap.status && feedCap.status.isApprovableByMe &&
                    feedCap.status.feedEntityStatus === 'PendingReview'
            }
        ]
    }

    handleUpdateEvent(event) {
        try {
            const postRender = `c-csp-community-post-render[data-id="${event.id}"]`;
            this.isLoading = true;
            this.editPopup.hide();
            if(this.feed.capabilities.questionAndAnswers && event.capabilities.questionAndAnswers) {
                this.feed.capabilities.questionAndAnswers.questionTitle = this.decodeEntities(event.capabilities.questionAndAnswers.questionTitle);
            } else if(this.feed.header && event.header) {
                this.feed.header.text = this.decodeEntities(event.header.text);
            }
            if(this.feed.capabilities.topics && event.capabilities.topics) {
                this.feed.capabilities.topics = event.capabilities.topics;
            }
            this.template.querySelector(postRender).postBody
            this.template.querySelector(postRender).postBody = event.body;
            this.template.querySelector(postRender).processBody();

            fireEvent(this.pageRef, 'cspCommunityUpdateFeedDetailsEvent', { });
        } catch(e) {
            this.errorCallback(e);
        } finally {
            this.isLoading = false;
        }
    }

    handleLoadMore(event) {
        this.loadComments(true, this.nextPageToken);
    }

    decodeEntities(input) {
        const element = document.createElement('textarea');
        element.innerHTML = input;
        return element.textContent;
    }

    get profilePopover() {
        return this.template.querySelector('c-csp-community-profile-popover');
    }

    get editPopup() {
        return this.template.querySelector('.csp-edit-popup');
    }

    get abusePopup() {
        return this.template.querySelector('.csp-abuse-popup');
    }

    get deletePopup() {
        return this.template.querySelector('.csp-delete-popup');
    }

    get abuseMessage() {
        return this.template.querySelector('[data-id="abuse-message"]')
    }

    get abuseOption() {
        return this.template.querySelector('[data-id="abuse-option"]')
    }
}