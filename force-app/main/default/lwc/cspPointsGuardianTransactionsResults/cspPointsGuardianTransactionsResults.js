import { LightningElement, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

export default class CspPointsGuardianTransactionsResults extends NavigationMixin(LightningElement) {
    @api transactions;
    @api handleTransactionClick;
    @api caseId;
    @api reference;

    handleQuoteAction(event) {
        const quoteAction = new CustomEvent(event.type);
        this.dispatchEvent(quoteAction);
        this.template.querySelector('[data-id="csp-view-popup"').hide();
    }
}