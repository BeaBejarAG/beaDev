import { LightningElement, api, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CurrentPageReference, NavigationMixin } from 'lightning/navigation';

import getArticle from '@salesforce/apex/CspKnowledge.getKnowledgeArticle';
import getFeedCached from '@salesforce/apex/cspCommunity.getFeedCached';
import getTopics from '@salesforce/apex/cspCommunity.getTopics';

import COMMUNITY_BASE_PATH from '@salesforce/community/basePath';
import CSP_NEWS from '@salesforce/contentAssetUrl/csp_news';
import CSP_VIEWS from '@salesforce/contentAssetUrl/csp_views';
import CSP_CLOCK from '@salesforce/contentAssetUrl/csp_clock';
import CSP_SUMMARY from '@salesforce/contentAssetUrl/csp_summary';

export default class CspCommunityPostRender extends NavigationMixin(LightningElement) {
    @api postBody = {};
    @api sharedPost = {};
    @api collapse = false;
    recordMap = {};
    output = '';

    @wire(CurrentPageReference) pageRef;

    connectedCallback() {
        this.processBody();
    }

    errorCallback(e) {
        console.error(e);
        this.dispatchEvent(new ShowToastEvent({
            message: e.body ? e.body.message : (e.message ? e.message : e),
            variant: 'error'
        }));
    }

    @api
    getEditValue() {
        const html = this.template.querySelector('[data-id="csp-copy"]').innerHTML;

        const element = document.createElement('html');
        element.innerHTML = html;

        // strip out any elements which can't be edited because they're injected
        element.querySelectorAll('.csp-no-edit').forEach(e =>
            e.parentNode.removeChild(e));

        element.querySelectorAll('.csp-hashtag').forEach(e =>
            e.parentNode.replaceChild(document.createTextNode(e.textContent), e));

        element.querySelectorAll('.csp-mention').forEach(e =>
            e.parentNode.parentNode.replaceChild(e, e.parentNode));

        return element.innerHTML;
    }

    @api
    async processBody() {
        let output = [];

        // start rendering the main post
        if(this.postBody.messageSegments) {
            output = await this.renderSegments(this.postBody, true);
        }

        // decode HTML entites so we can render this as raw HTML
        this.output = this.decodeEntities(output.join(''));
        this.template.querySelector('[data-id="csp-copy"]').innerHTML = this.output;

        // if a mention is hovered over then fire an event to the parent for it to use
        // its own existing profile popover for the user and for the position of the event
        if(this.template.querySelector('.csp-mention')) {
            this.template.querySelectorAll('.csp-mention').forEach(e => e.onmouseover = event => {
                this.dispatchEvent(new CustomEvent("csppopoverprofileevent", {
                    detail: {
                        record: {
                            user: this.recordMap[event.target.dataset.user]
                        },
                        event
                    }
                }));
                event.preventDefault();
                event.stopPropagation();
            });
        }

        if(this.template.querySelector('.csp-hashtag')) {
            this.template.querySelectorAll('.csp-hashtag').forEach(e => e.onclick = async event => {
                event.preventDefault();
                event.stopPropagation();

                const results = await getTopics({
                    topicName: event.target.dataset.tag
                });

                if(results && results.topics && results.topics.length > 0) {
                    this[NavigationMixin.Navigate]({
                        type: 'standard__webPage',
                        attributes: {
                            url: `/topic/${results.topics[0].id}`,
                        }
                    });
                } else {
                    this.dispatchEvent(new ShowToastEvent({
                        message: 'Sorry, no forums exist for this hashtag yet',
                        variant: 'warning'
                    }));
                }
            });
        }
    }

    async renderSegments(postBody, processShares) {
        const origin = document.location.origin;
        const path = COMMUNITY_BASE_PATH;
        let elements = [];

        for (let index = 0; index < postBody.messageSegments.length; index++) {
            const m = postBody.messageSegments[index];

            if(m.type == 'Text') {
                try {
                    elements.push(decodeURI(m.text).replace(/(?<=\w)(\/)/gm, "/<wbr>"))
                } catch(e) {
                    elements.push(m.text);
                }
            } else if(m.type == 'Hashtag') {
                elements.push(`<a href="#" class="csp-hashtag" data-tag="${m.tag}">${m.text}</a>`);
            } else if(m.type == 'Mention') {
                const id = m.record.id;

                // this is a mention so store the user at this point for later retrieval
                this.recordMap[id] = m.record;

                // render the mention as a link and a reference back to the user ID
                elements.push(`<span data-id="${id}">`);
                elements.push(`<a href="${origin}${path}/profile/${id}" class="csp-mention" data-user="${id}"'>`);
                elements.push(`${m.text}`);
                elements.push(`</a></span>`);
            } else if(m.type == 'InlineImage') {
                elements.push(`<img src="${m.url}">`);
            } else if(m.type === 'MarkupBegin' || m.type === 'MarkupEnd' || m.type === 'Link') {
                // standard elements
                elements = elements.concat(await this.processMarkup(m, processShares));
            } else {
                elements.push(m.text);
            }
        }

        // clamp the results if desired by wrapping the payload
        if(this.collapse) {
            elements.unshift('<div class="slds-line-clamp_large">');
            elements.push('</div>');
        }

        return elements;
    }

    async processMarkup(m, processShares) {
        const blockElements = ['b', 'p', 'u', 'ul', 'li', 'ol', 's', 'a', 'i'];
        const articlePath = `${document.location.origin}${COMMUNITY_BASE_PATH}/article/`;
        const sharePath = `${document.location.origin}${COMMUNITY_BASE_PATH}/question/`;
        let elements = [];
        let unfurlCount = 0;

        // process HTML elements, only links are handled differently
        if(blockElements.includes(m.htmlTag)) {
            elements.push(`<${m.type === 'MarkupEnd' ? `/${m.htmlTag}` :
                (m.htmlTag === 'a' ? `a target="_blank" href="${m.url}"` : m.htmlTag)}>`);
        } else if(m.type === 'Link') {
            elements.push(`<a href="${m.url}">${decodeURI(m.text).replace(/\//gm, "/<wbr>")}</a>`);
        }

        // If we find an internal link and we haven't unfurled more than 5 then get related object
        if(((m.type === 'MarkupBegin' && m.htmlTag === 'a') || m.type === 'Link') &&
            m.url.includes(articlePath) && unfurlCount < 5 && !this.linkInCurrentParagraph) {
            this.linkInCurrentParagraph = await this.getArticle(m.url.split('/').pop());
            unfurlCount++;
        }

        // If we find an internal link and we haven't unfurled more than 5 then get related object
        if(((m.type === 'MarkupBegin' && m.htmlTag === 'a') || m.type === 'Link') &&
            m.url.includes(sharePath) && unfurlCount < 5 && !this.shareInCurrentParagraph && processShares) {
            try {
                const pathMatches = m.url.match(/\/([0-9A-Z]{15,18})(?:$|\/|\?)/i);
                if(pathMatches) {
                    this.shareInCurrentParagraph = JSON.parse(JSON.stringify(await getFeedCached({
                        feedId: pathMatches[1]
                    })));
                    unfurlCount++;
                }
            } catch(e) {
                console.error(e);
            }
        }

        // Once we're at the end of the current block render the unfurled related object
        if(m.type === 'MarkupEnd' && ['p','ul'].includes(m.htmlTag) && this.shareInCurrentParagraph) {
            elements = elements.concat(await this.renderShare(this.shareInCurrentParagraph));
        }

        // Once we're at the end of the current block render the unfurled related object
        if(m.type === 'MarkupEnd' && ['p','ul'].includes(m.htmlTag) && this.linkInCurrentParagraph) {
            elements = elements.concat(await this.renderArticle(this.linkInCurrentParagraph));
        }

        return elements;
    }

    decodeEntities(input) {
        const element = document.createElement('textarea');
        element.innerHTML = input;
        return element.textContent;
    }

    async renderArticle(article) {
        this.linkInCurrentParagraph = null;

        const elements = [];
        elements.push('<div class="csp-box slds-grid slds-var-m-top_medium csp-no-edit slds-show_medium">');

        elements.push('<div class="csp-box_shaded-darker slds-size_1-of-12  slds-var-p-around_large">');
        elements.push(`<img src="${CSP_NEWS}?v=0" class="slds-var-m-right_small" style="height:16px">`);
        elements.push('</div>');

        elements.push(`<div class="slds-size_11-of-12 slds-var-p-around_medium">`);

        elements.push(`<div class="slds-var-m-bottom_small csp-text_strong">`);
        elements.push(`<a href="${COMMUNITY_BASE_PATH}/article/${article.Url}" target="_blank">${article.Title}</a>`);
        elements.push(`</div>`);

        elements.push(`<div class="slds-line-clamp_x-small">${article.DescriptionText}</div>`);

        elements.push(`<div class="slds-grid slds-var-m-top_small">`);

        elements.push(`<div class="slds-var-m-right_large">`);
        elements.push(`<img src="${CSP_VIEWS}" class="slds-var-p-right_x-small" style="height:14px;margin:0px">`);
        elements.push(`${article.Views} views`);
        elements.push('</div>');

        elements.push(`<div class="slds-var-m-right_large">`);
        elements.push(`<img src="${CSP_CLOCK}" class="slds-var-p-right_x-small" style="height:16px;margin:0px">`);
        elements.push(`${article.PublishedDate.split('T')[0]}`);
        elements.push(`</div>`);

        if(article.ProductFeatures) {
            elements.push(`<div class="">`);
            elements.push(`<img src="${CSP_SUMMARY}" class="slds-var-p-right_x-small" style="height:16px;margin:0px">`);
            elements.push(`${article.ProductFeatures.replace(/;/g,', ')}`);
            elements.push('</div>');
        }

        elements.push('</div>');
        elements.push(`</div>`);
        elements.push('</div>');
        return elements;
    }

    async renderShare(feedElement) {
        this.shareInCurrentParagraph = null;

        const output = await this.renderSegments(feedElement.body, false);
        const user = this.enrichUser(feedElement.actor ? feedElement.actor : feedElement.user);

        const elements = [];
        elements.push('<div class="csp-box csp-box-shaded-left_green slds-var-m-top_medium csp-no-edit slds-show_medium">');

        elements.push('<div class="slds-var-p-around_medium slds-grid slds-wrap">');

        elements.push(`<div class="slds-size_1-of-12 ">`);
        elements.push(`<div class="${user.avatar} slds-var-m-top_xxx-small csp-avatar_small">`);
        elements.push(`<div title="${user.displayName}" class="slds-avatar__initials">${user.initials}</div>`);
        elements.push('</div>');
        elements.push('</div>');

        elements.push(`<div class="slds-size_11-of-12">`);
        elements.push(`<div class="csp-text_strong slds-var-p-top_x-small">${user.displayName}</div>`);
        elements.push('</div>');

        elements.push(`<div class="slds-size_12-of-12 slds-var-p-top_medium">`);
        elements.push(`<div class="slds-line-clamp_small">${output.join('')}</div>`);
        elements.push(`</div>`);

        elements.push('</div>');
        elements.push('</div>');
        return elements;
    }

    async getArticle(articleUrl) {
        try {
            const article = JSON.parse(JSON.stringify(await getArticle({urlName: articleUrl})));

            // some whitespace pre-processing is required to render correctly
            const doc = new DOMParser().parseFromString(article.Description, "text/html");
            doc.documentElement.querySelectorAll('br').forEach(e => {e.outerHTML = "\n"});
            doc.documentElement.querySelectorAll('div, li, p').forEach(e => {e.outerHTML += "\n"});
            doc.documentElement.querySelectorAll('span').forEach(e => {e.outerHTML += " "});
            article.DescriptionText = doc.documentElement.innerText;

            return article;
        } catch(e) {
            console.error(e);
        }
    }

    enrichUser(user) {
        if(!user || !user.id) {
            return;
        }

        user = JSON.parse(JSON.stringify(user));

        const total = user.id.split('').map(x => x.charCodeAt(0)).reduce((a, b) => a + b);
        user.avatar = `slds-align-top csp-avatar access-theme-user-cat${total % 28}`;
        user.initials = user.displayName[0];

        return user;
    }
}