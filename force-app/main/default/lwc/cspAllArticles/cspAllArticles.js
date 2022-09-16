import { LightningElement, api, track  } from 'lwc';

export default class CspAllArticles extends LightningElement {
    @api limitAmount;
    @api includeReleaseNotesResults;
    @api includeKnowledgeResults;
    @api includeCommunityResults;
    @api includeEventsResults;
    @api includeServicesCatalogueResults;
    @api componentTitle;

    @track show = false;

    handleChange() {
        this.show = true;
    }
}