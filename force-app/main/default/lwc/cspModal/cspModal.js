import { LightningElement, api } from 'lwc';

const CSS_CLASS = 'slds-hide';

export default class Modal extends LightningElement {
    @api showModal = false;
    @api size;
    @api padding;
    @api overflow;
    isLoading = false;
    hasHeaderString = false;
    _headerPrivate;

    @api
    set header(value) {
        this.hasHeaderString = value !== '';
        this._headerPrivate = value;
    }
    get header() {
        return this._headerPrivate;
    }

    get sizeClass() {
        if(this.size) {
            return `slds-modal slds-modal_${this.size} slds-fade-in-open`;
        }

        return "slds-modal slds-fade-in-open";
    }

    get paddingClass() {
        if (this.padding) {
            return (this.overflow ? "csp-modal-content__overflow " : "") + `slds-modal__content slds-var-p-around_${this.padding} slds-is-relative`;
        }

        return (this.overflow ? "csp-modal-content__overflow " : "") + "slds-modal__content slds-var-p-around_x-large slds-is-relative";
    }

    @api show() {
        this.showModal = true;
    }

    @api hide() {
        this.showModal = false;
    }

    @api showLoading() {
        this.isLoading = true;
    }

    @api hideLoading() {
        this.isLoading = false;
    }

    handleDialogClose() {
        //Let parent know that dialog is closed (mainly by that cross button) so it can set proper variables if needed
        const closedialog = new CustomEvent('closedialog');
        this.dispatchEvent(closedialog);
        this.hide();
    }

    handleSlotHeaderChange() {
        const headerEl = this.template.querySelector('div.slds-hide');
        if(headerEl) {
            headerEl.classList.remove(CSS_CLASS);
        }
    }

    handleSlotTaglineChange() {
        const taglineEl = this.template.querySelector('p');
        if(taglineEl) {
            taglineEl.classList.remove(CSS_CLASS);
        }
    }

    handleSlotFooterChange() {
        const footerEl = this.template.querySelector('footer');
        if(footerEl) {
            footerEl.classList.remove(CSS_CLASS);
        }
    }
}