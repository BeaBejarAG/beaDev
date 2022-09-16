import { LightningElement, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

import ACCESS_LOGO_WHITE from '@salesforce/contentAssetUrl/accessfreedomlogowhite';

export default class CspGlobalFooter extends NavigationMixin(LightningElement) {
    @api logo = ACCESS_LOGO_WHITE;

    @api footerLinks = [
        {
            name: 'Raising Support Cases',
            icon: 'utility:description',
            url: '/create-a-case',
            target: '_self',
            internal: true
        },
        {
            name: 'Portal Guidelines',
            icon: 'utility:description',
            url: '/guidelines',
            target: '_self',
            internal: true
        },
        {
            name: 'Privacy Policy',
            icon: 'utility:lock',
            url: 'https://www.theaccessgroup.com/privacy-and-legal/',
            target: '_blank'
        },
        {
            name: 'The Access Group',
            icon: 'utility:new_window',
            url: 'https://www.theaccessgroup.com/',
            target: '_blank'
        }
    ]

    @api moreFromAccessLinks = [
        {
            name: 'Service Status',
            icon: 'utility:wifi',
            url: '/service-status',
            target: '_blank'
        },
        {
            name: 'Information Security Hub',
            icon: 'utility:identity',
            url: '/gdpr-hub',
            target: '_blank'
        },
        {
            name: 'Payroll Year End',
            icon: 'utility:file',
            url: 'https://pages.theaccessgroup.com/2021-Yearend-hub.html',
            target: '_blank'
        },
        {
            name: 'Access Product Downloads',
            icon: 'utility:download',
            url: '/access-connect',
            target: '_blank'
        }
    ]

    handleLinkClick(event) {
        const url = event.currentTarget.dataset.url;
        var fullURL = '/Support/s' + url;

        if(url.startsWith('http')){
            fullURL = url;
        }

        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: fullURL
            }
        });
    }

}