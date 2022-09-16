import { LightningElement, wire, api } from 'lwc';
import { NavigationMixin, CurrentPageReference } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { fireEvent } from 'c/pubsub';

import getGroups from '@salesforce/apex/cspCommunity.getGroups';
import getProductList from '@salesforce/apex/cspProductSelection.getAllProducts';
import postFeedElement from '@salesforce/apex/cspCommunity.postFeedElement';
import getFeed from '@salesforce/apex/cspCommunity.getFeed';
import getMentionCompletions from '@salesforce/apex/cspCommunity.getMentionCompletions';
import postCommentToFeedElement from '@salesforce/apex/cspCommunity.postCommentToFeedElement';
import updateFeedElement from '@salesforce/apex/cspCommunity.updateFeedElement';
import updateComment from '@salesforce/apex/cspCommunity.updateComment';
import getFeaturedTopics from '@salesforce/apex/cspCommunity.getFeaturedTopics';
import reassignTopic from '@salesforce/apex/cspCommunity.reassignTopic';

import USER_ID from '@salesforce/user/Id';
import COMMUNITY_ID from '@salesforce/community/Id';
import COMMUNITY_BASE_PATH from '@salesforce/community/basePath';

import POST_ANY_TOPIC from '@salesforce/customPermission/Community_Post_Any_Topic';

export default class CspCommunityPost extends NavigationMixin(LightningElement) {
    @api hideTabs = false;
    @api feedId = null;
    @api recordId = null;
    @api body = null;
    @api subject = null;
    products = [];
    groups;
    pageRef;
    userId = USER_ID;
    communityId = COMMUNITY_ID;
    isPosting = false;
    showQuestion = true;
    showDiscussion = false;
    sharedPost;
    richTextValidity = true;
    postContent = null;
    mentionResults = {};
    rteFormats = ['bold','italic','underline','strike','list','link','image',
                    'clean','table','code','code-block','script','header'];
    mentionsShowing = false;

    @wire(CurrentPageReference)
    setCurrentPageReference(pageRef) {
        this.pageRef = pageRef;
        this.handlePageRef();
    }

    connectedCallback() {
        // editing a post or adding a comment
        if(this.feedId || this.recordId) {
            this.showQuestion = false;
        }
        this.getProductsAndGroups();
    }

    renderedCallback() {
        if(!this.focussed && this.recordId && this.richTextArea) {
            this.richTextArea.focus();
            this.focussed = true;
            this.handleRichTextBlur();
        } else if(!this.groupFocussed && this.showDiscussion && this.group) {
            this.group.focus();
            this.groupFocussed = true;
        } else if(!this.productFocussed && this.showQuestion && this.product) {
            this.product.focus();
            this.productFocussed = true;
        }
    }

    errorCallback(e) {
        this.isPosting = false;
        console.error(e);
        this.dispatchEvent(new ShowToastEvent({
            message: e.body ? e.body.message : e.message,
            variant: 'error'
        }));
    }

    async handlePageRef() {
        if(!this.pageRef) {
            return;
        }

        if(this.pageRef.state.type === 'discussion') {
            this.handleShowDiscussion();
        } else if(this.pageRef.state.type === 'question') {
            this.handleShowQuestion();
        }
        if(this.pageRef.state.topicId && this.product) {
            this.product.value = this.pageRef.state.topicId;
        }
        if(this.pageRef.state.groupId && this.group) {
            this.group.value = this.pageRef.state.groupId;
        }

        if(this.pageRef.state.sharedId) {
            this.sharedPost = await getFeed({
                feedId: this.pageRef.state.sharedId
            });
        }
    }

    async getProductsAndGroups() {
        const productResults = await getProductList();

        let products = productResults.map(e => ({
            value: e.topicId,
            label: this.decodeEntities(e.name),
            id: e.id,
            enabledForCommunity: e.enabledForCommunity
        }))
        .filter(e => e.value && e.enabledForCommunity == 'Active');

        let featuredTopics = [];
        const topics = await getFeaturedTopics();
        featuredTopics = topics.managedTopics.map(e => ({
            value: e.topic.id,
            label: this.decodeEntities(e.topic.name),
            id: e.topic.id
        }));
        featuredTopics = featuredTopics.filter(t => t.id != '0TO58000000DORaGAO' || POST_ANY_TOPIC);
        products = products.concat(featuredTopics);

        products.sort((a, b) => {
            if(a.label.toUpperCase() < b.label.toUpperCase()) {
                return -1
            }
            if(a.label.toUpperCase() > b.label.toUpperCase()) {
                return 1
            }
            return 0;
        });
        this.products = products;

        const groupResults = await getGroups();

        // filter out groups user isn't subscribed to
        this.groups = groupResults.groups
        .filter(e => e.mySubscription !== null)
        .map(e => ({
            value: e.id,
            label: this.decodeEntities(e.name),
            id: e.id
        }))
        .filter(e => e.value)

        this.handlePageRef();
    }

    async handlePostQuestion() {
        this.isPosting = true;
        const html = this.enrichRichText(this.questionBody.value);

        try {
            const results = await postFeedElement({
                feedElementId: this.product.value,
                text: html,
                subject: this.questionTitle ? this.questionTitle.value : '',
                type: 'question',
                sharedId: this.pageRef.state.sharedId
            });

            this.navigateTo(results.id);
            return;
        } catch(e) {
            this.errorCallback(e);
        } finally {
            this.isPosting = false;
        }
    }

    async handleBack() {
        history.back();
    }

    async handlePostDiscussion() {
        this.isPosting = true;
        const html = this.enrichRichText(this.discussionBody.value);

        try {
            const results = await postFeedElement({
                feedElementId: this.group.value,
                text: html,
                subject: this.discussionTitle ? this.discussionTitle.value : '',
                type: 'discussion',
                sharedId: this.pageRef.state.sharedId
            });

            this.navigateTo(results.id);
            return;
        } catch(e) {
            this.errorCallback(e);
        } finally {
            this.isPosting = false;
        }
    }

    navigateTo(recordId) {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: recordId,
                actionName: 'view'
            }
        });
    }

    enrichRichText(html) {
        if(!html) {
            return '';
        }

        // convert some standard elements
        html = html.replace(/<(\/?)strike>/gi, '<$1s>');
        html = html.replace(/<br>/gi, '\n');

        /* convert mention links into correct format */
        html = html.replace(
            /<a\s+(?:href="(?:(?!")https[a-zA-Z0-9_\-:.\/]+\/profile\/(005[{0-9a-zA-Z}]{15})*)"(?:\s?)(?:(?!>).)*\s?)+>((?:(?!<\/a>).)*)<\/a>/gis,
            (match, p1, p2, offset, string) => `{${p1}}`);

        /* convert links into correct format */
        html = html.replace(
            /<a\s+(?:href="((?:(?!").)*)"(?:\s?)(?:(?!>).)*\s?)+>((?:(?!<\/a>).)*)<\/a>/gis,
            (match, p1, p2, offset, string) => `{link:${encodeURIComponent(p1)}:${p2}}`);

        /* convert images into correct format */
        html = html.replace(
            /<img\s+(?:src="(?:(?!").)*(068[0-9A-Za-z]{12,15})(?:(?!").)*"(?:(?!>).)*\s?)+\/?>\s?(?:<\/img>)?/gis,
            (match, p1, p2, offset, string) => `{img:${p1}:${p2}}`);

        return html;
    }

    async handlePost() {
        try {
            this.isPosting = true;
            const html = this.enrichRichText(this.postContent);
            const response = await postCommentToFeedElement({
                feedElementId: this.feedId,
                text: html
            });

            this.richTextArea.value = '';
            this.richTextValidity = true;

            fireEvent(this.pageRef, 'cspCommunityUpdateFeedDetailsEvent', { });
            fireEvent(this.pageRef, 'cspCommunityNewCommentEvent', response);
            return;
        } catch(e) {
            this.errorCallback(e);
        } finally {
            this.isPosting = false;
        }
    }

    async handleUpdatePost(event) {
        try {
            this.isPosting = true;
            if(!this.postContent) {
                this.postContent = this.richTextArea.value;
            }
            const html = this.enrichRichText(this.postContent);

            if(this.recordId && this.recordId.substring(0, 3) === '0D5') {
                const response = await updateFeedElement({
                    feedElementId: this.recordId,
                    text: html,
                    subject: this.updateTitle.value,
                    sharedId: this.pageRef.state.sharedId
                });

                if(this.product && this.product.value && this.product.value != this.feedId) {
                    const selected = this.product.options.find(e => e.value === this.product.value);
                    const topicResponse = await reassignTopic({
                        feedElementId: this.recordId,
                        newTopicName: selected.label
                    });
                    response.capabilities.topics.items = topicResponse.topics;
                }

                fireEvent(this.pageRef, 'cspCommunityUpdateFeedEvent', response);
            } else if(this.recordId && this.recordId.substring(0, 3) === '0D7') {
                const response = await updateComment({
                    commentId: this.recordId,
                    text: html
                });

                fireEvent(this.pageRef, 'cspCommunityUpdateCommentEvent', response);
            }

            fireEvent(this.pageRef, 'cspCommunityUpdateFeedDetailsEvent', { });
            return;
        } catch(e) {
            this.errorCallback(e);
        } finally {
            this.isPosting = false;
        }
    }

    getCurrentWord(a, b) {
        let i = 0;
        let j = 0;
        let q = null;

        if(!a || !b) {
            return;
        }

        // determine the position of the last character changed
        while (j < b.length - 1) {
            if (a[i] != b[j] || i == a.length) {
                q = q != null ? q : j;
                break;
            } else {
                i++;
            }
            j++;
        }

        // backspace
        if(b.length < a.length) {
            q--;
        }

        // create an array of chars from either side of that position
        const startArr = b.substring(0, q + 1).split('').reverse();
        const endArr = b.substring(q).split('');

        // caclulate the word boundaries from that
        let s = 0;
        const startIdx = q - startArr.reduce((p, c, i, a) => {
            if(p === 0 && c == ' ' && s < 1) {
                // allow one space backwards in detecting the search term
                s++;
            } else if(p === 0 && !c.match(/[a-zA-Z0-9-_\.]/g)) {
                // if it's not an allowed char it's a boundary
                p = i;
                // break
                a.splice(1);
            }
            return p
        }, 0);

        // ignore calculating end boundary if it doesn't start with '@'
        if(b.charAt(startIdx) != '@') {
            return { start: 0, end: 0, word: null };
        }

        const endIdx = q + endArr.reduce((p, c, i, a) => {
            if(p === 0 && !c.match(/[a-zA-Z0-9-_\.]/g)) {
                // if it's not an allowed char it's a boundary
                p = i;
                //break
                a.splice(1);
            }
            return p
        }, 0);

        // return the current word and its position
        return { start: startIdx, end: endIdx, word: b.substring(startIdx, endIdx)};
    }

    handleMentionSelect(event) {
        const value = this.richTextArea.value;
        const path = COMMUNITY_BASE_PATH;
        const origin = document.location.origin;
        const id = event.target.value;
        const label = event.target.label;

        // create a new string with the replacement link injected inbetween
        const start = value.substring(0, this.currentWord.start);
        const middle = `<a href="${origin}/${path}/profile/${id}">@${label}</a>`;
        const end = value.substring(this.currentWord.end);

        // update the rich text editor and set the focus to the end
        this.richTextArea.value = `${start}${middle}${end}`;
        this.richTextArea.setRangeText('', this.richTextArea.value.length, this.richTextArea.value.length, 'end');

        this.mentionsShowing = false;
    }

    async handlePostContent(event) {
        this.handleValidateFields();
        this.handleShowPostGuidelines();

        const lastPostContent = this.postContent;
        this.postContent = event.target.value;

        const currentWord = this.getCurrentWord(lastPostContent, this.postContent);

        if(!currentWord) {
            return;
        }

        // prevent concurrent requests when typing fast
        if(this.mentionTimeout) {
            clearTimeout(this.mentionTimeout);
        }
        this.mentionTimeout = setTimeout(() => {
            this.fetchMentionResults(currentWord);
        }, 500);
    }

    async fetchMentionResults(currentWord) {
        // if the current word being edited is a mention canidate show the lookup
        if(currentWord.word && currentWord.word.length > 2 && currentWord.word.substring(0, 1) === '@') {
            this.currentWord = currentWord;
            this.mentionResults = JSON.parse(JSON.stringify(await getMentionCompletions({
                q: this.currentWord.word.substring(1),
                contextId: this.feedId
            })));

            this.mentionResults.mentionCompletions.map(e => {
                e.name = this.decodeEntities(e.name);
            })
            this.mentionsShowing = true;
        } else {
            this.mentionResults = [];
            this.mentionsShowing = false;
        }
    }

    handleShowDiscussion(event) {
        this.showQuestion = false;
        this.showDiscussion = true;
        if(this.questionTab) {
            this.questionTab.classList.remove('csp-box-shaded-brand_light');
            this.questionTab.classList.remove('csp-box-shaded-bottom_brand');
        }
        if(this.discussionTab) {
            this.discussionTab.classList.add('csp-box-shaded-brand_light');
            this.discussionTab.classList.add('csp-box-shaded-bottom_brand');
        }

        if(this.group) {
            this.group.focus();
        }
    }

    handleSelectDiscussion() {
        const state = {
            type: 'discussion'
        }

        if(this.pageRef.state.groupId) {
            state.groupId = this.pageRef.state.groupId;
        }

        if(this.pageRef.state.sharedId) {
            state.sharedId = this.pageRef.state.sharedId;
        }

        this.navigateToPage(state);
    }

    handleShowQuestion(event) {
        this.showQuestion = true;
        this.showDiscussion = false;
        if(this.questionTab) {
            this.questionTab.classList.add('csp-box-shaded-brand_light');
            this.questionTab.classList.add('csp-box-shaded-bottom_brand');
        }
        if(this.discussionTab) {
            this.discussionTab.classList.remove('csp-box-shaded-brand_light');
            this.discussionTab.classList.remove('csp-box-shaded-bottom_brand');
        }
        if(this.product) {
            this.product.focus();
        }
    }

    handleSelectQuestion() {
        const state = {
            type: 'question'
        }

        if(this.pageRef.state.topicId) {
            state.topicId = this.pageRef.state.topicId;
        }

        if(this.pageRef.state.sharedId) {
            state.sharedId = this.pageRef.state.sharedId;
        }

        this.navigateToPage(state);
    }


    handleViewGroups() {
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: '/groups'
            }
        });
    }

    navigateToPage(state) {
        this[NavigationMixin.Navigate]({
            type: 'standard__namedPage',
            attributes: this.pageRef.attributes,
            state
        });
    }

    handleShowPostGuidelines() {
        if(!this.mentionsShowing && this.postGuidelines) {
            this.postGuidelines.classList.remove('slds-hide');
        }
    }

    get richTextArea() {
        if(this.showQuestion) {
            return this.template.querySelector('[data-id="question-body"]');
        } else if(this.showDiscussion) {
            return this.template.querySelector('[data-id="discussion-body"]');
        } else if(this.recordId) {
            return this.template.querySelector('[data-id="update-body"]');
        } else if(this.feedId) {
            return this.template.querySelector('[data-id="feed-body"]');
        }
    }

    decodeEntities(input) {
        const element = document.createElement('textarea');
        element.innerHTML = input;
        return element.textContent;
    }

    handleValidateFields(event) {
        if(event) {
            event.currentTarget.reportValidity();
        }
        const fields = [];

        if(this.showQuestion) {
            fields.push(this.questionTitle);
            fields.push(this.product);
        } else if(this.showDiscussion) {
            fields.push(this.discussionTitle);
            fields.push(this.group);
        } else if(this.recordId && this.updateTitle) {
            fields.push(this.updateTitle);
        }

        const allValid = fields.reduce((validSoFar, inputCmp) => {
            return validSoFar && inputCmp.checkValidity();
        }, true);

        [...this.template.querySelectorAll('[data-id="submit-button"]')].forEach(e => {
            e.disabled = !allValid || !this.richTextArea.value;
        })

        this.richTextValidity = this.richTextArea.value !== '';
    }

    handleRichTextBlur(event) {
        if(!this.richTextArea.value) {
            this.richTextArea.value = '';
        }

        if(!this.richTextArea || this.richTextArea.value === undefined) {
            this.richTextValidity = true;
        }

        this.richTextValidity = this.richTextArea.value.length > 0;

        this.handleValidateFields();
    }

    get questionTab() {
        return this.template.querySelector('[data-id="question-tab"]');
    }

    get discussionTab() {
        return this.template.querySelector('[data-id="discussion-tab"]');
    }

    get questionBody() {
        return this.template.querySelector('[data-id="question-body"]');
    }

    get discussionBody() {
        return this.template.querySelector('[data-id="discussion-body"]');
    }

    get questionTitle() {
        return this.template.querySelector('[data-id="question-title"]');
    }

    get discussionTitle() {
        return this.template.querySelector('[data-id="discussion-title"]');
    }

    get updateTitle() {
        return this.template.querySelector('[data-id="update-title"]');
    }

    get product() {
        return this.template.querySelector('[data-id="product"]');
    }

    get group() {
        return this.template.querySelector('[data-id="group"]');
    }

    get postGuidelines() {
        return this.template.querySelector('.csp-popover_guidelines');
    }

    get guidelinesPath() {
        return COMMUNITY_BASE_PATH + '/guidelines';
    }

    get isComment() {
        return this.recordId && this.recordId.substring(0, 3) === '0D7';
    }

    get canPostAnyTopic() {
        return POST_ANY_TOPIC;
    }
}