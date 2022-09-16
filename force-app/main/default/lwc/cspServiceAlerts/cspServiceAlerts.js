import { LightningElement, wire, track } from 'lwc';
import { registerListener, unregisterListener } from 'c/pubsub';
import { NavigationMixin, CurrentPageReference } from 'lightning/navigation';

import getservicealerts from '@salesforce/apex/CommunityAlerts.GetServiceStatus';
import GetProductNotification from '@salesforce/apex/CommunityAlerts.GetProductNotification';

export default class CspServiceAlerts extends LightningElement {
product = {};
@track notifications;
pageRef = {state: {}};
@track alerts;
@track showNoti;

    /* Use page reference state to determine step */
    @wire(CurrentPageReference)
    setCurrentPageReference(pageRef) {
        this.pageRef = pageRef;
        console.log(pageRef);
        if(this.pageRef.attributes.name == 'create_case__c')
        {
            this.showNoti = false;
        }
        else{
            this.showNoti = true;
        }

    }

    connectedCallback() {
        console.log("Connected Callback");
        const product = window.sessionStorage.getItem('selectedProduct');
        if(product) {
            this.setProduct({product: JSON.parse(product)});

        }



        registerListener('cspProductSelectionEvent', this.setProduct, this);
    }

   disconnectedCallback() {
        unregisterListener('cspProductSelectionEvent', this.setProduct, this);
    }


    setProduct(event) {
        console.log("hit set");
        this.product = event.product;
        if(this.product)
        {
            console.log("inside this");
            if(this.product.name){
                console.log("inside that");
                this.GetAlerts(this.product.name);
                this.GetNotifications(this.product.name);
            }
            else{
                console.log("else");
                this.notifications = null;
                this.alerts = null;
            }
        
        }

       
    }

    GetAlerts(currprod){
        getservicealerts({product: currprod})
        .then(result => {
            this.alerts = result;

        })
        .catch (error => {
            console.log('Error ' + error.message);
        }); 

    }

    GetNotifications(currprod){
        GetProductNotification({product: currprod})
        .then(result => {
            this.notifications = result;

        })
        .catch (error => {
            console.log('Error ' + error.message);
        }); 

    }





}