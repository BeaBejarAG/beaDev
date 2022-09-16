import { LightningElement, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

export default class CspPointsGuardianOpenQuoteRequests extends NavigationMixin(LightningElement) {
    @api caseId;
    @api reference;
    @api openQuoteRequests;
    @api handleOpenQuoteRequestClick;
    showRejectButton = true;

    handleQuoteAction(event) {
        const quoteAction = new CustomEvent(event.type);
        this.dispatchEvent(quoteAction);
        this.template.querySelector('[data-id="csp-view-popup"').hide();
    }
}