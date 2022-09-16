import { LightningElement, track } from 'lwc';

export default class CspFeaturedArticles extends LightningElement {
    @track showHeading = false;
    @track showResults = true;

    handleChange(event) {
        if(event.detail > 0) {
            this.showHeading = true;
        } else {
            this.showHeading = false;
            this.showResults = false;
        }
    }
}