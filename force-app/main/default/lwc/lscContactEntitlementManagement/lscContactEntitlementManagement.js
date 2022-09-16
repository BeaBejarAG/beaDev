import { LightningElement, api, track, wire } from 'lwc';
import { refreshApex } from '@salesforce/apex';

import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import { getRecord } from 'lightning/uiRecordApi';
import { getRecordCreateDefaults, generateRecordInputForCreate } from 'lightning/uiRecordApi';
import GetContactsEntitlements from '@salesforce/apex/lscEntitlementHandler.GetContactEntitlements';
import GetAccountEntitlements from '@salesforce/apex/lscEntitlementHandler.GetAccountEntitlements';
import DeletedEntitlementContact from '@salesforce/apex/lscEntitlementHandler.DeleteEntContact';
import AddEntitlementContacts from '@salesforce/apex/lscEntitlementHandler.AddEntContactscon';
import getAccountRelations from '@salesforce/apex/cspConsultantAccountHandler.getAccountRelations';
import { CurrentPageReference } from 'lightning/navigation';
import { encodeDefaultFieldValues } from 'lightning/pageReferenceUtils';
import  ENTCON_OBJECT from '@salesforce/schema/EntitlementContact';
import CONTACTID_FIELD from '@salesforce/schema/Contact.Id';
import CONTACT_ACCOUNTID_FIELD from '@salesforce/schema/Contact.AccountId';

export default class LscContactEntitlementManagement extends NavigationMixin(LightningElement) {
    @api recordId;
    @track entcont;
    @track acccont;
    @track acccontrefresh;
    @track entcontrefresh;
    @track error;
    @track record;
    @track recordrefresh;
    @track acctId;
    @track loading = false;
    @track options = [];
    @track contactId;

    @wire(CurrentPageReference)
    pageRef;

    @wire(getRecordCreateDefaults, { objectApiName: ENTCON_OBJECT })
    entconCreateDefaults;

    @wire(getRecord, { recordId: '$recordId',  fields:[CONTACTID_FIELD, CONTACT_ACCOUNTID_FIELD]})
    wiredAccount(response){
        if (response.data) {
            this.recordrefresh = response;
            this.record = response.data;
            this.error = undefined;
            this.contactId = response.data.id;
            this.acctId = response.data.fields.AccountId.value;
            this.retrieveAccountRelations();
        } else if (response.error) {
            this.error = response.error;
            this.recordrefresh = response;
            this.record = undefined;
        }
    }

    @wire(GetContactsEntitlements, {ContactId: '$recordId', AccountID: "$acctId"})
    wiredEnt(response) {
        if (response.data) {
            this.entcont = response.data;
            this.entcontrefresh = response;
            this.error = undefined;
        } else if (response.error) {
            this.error = response.error;
            this.entcontrefresh = response;
            this.entcont = undefined;
        }
    }

    @wire(GetAccountEntitlements, {ContactId: '$recordId', AccountID: "$acctId"})
    wiredAccEnt(response) {
        if (response.data) {
            this.acccont = response.data;
            this.acccontrefresh = response;
            this.error = undefined;
        } else if (response.error) {
            this.error = response.error;
            this.acccontrefresh = response;
            this.acccont = undefined;
        }
    }
    
    RefreshRecords(){
        setTimeout(() => { 
        refreshApex(this.recordrefresh);
        refreshApex(this.entcontrefresh);      
        refreshApex(this.acccont);
        refreshApex(this.acccontrefresh);
        refreshApex(this.record);
    }, 1);
    }

    retrieveAccountRelations() {
        getAccountRelations({contactId: this.contactId})
        .then(response => {
            this.populateOptions(response);
        })
        .catch(error => {console.error(error)})
        .finally(() => {});
    }

    populateOptions(accounts) {
        this.options = [];
        accounts.map(acc => {
            this.options.push({label: acc.Account.Name, value: acc.Account.Id});
        });
    }

    navigatetouser(event) {
        var ConRecId = event.target.dataset.name;
        console.log(ConRecId);
    
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                objectApiName: 'entitlement',
                recordId: ConRecId,
                actionName: 'view'
            }
        });
    }

    WaitScreen(action){
        console.log(action);
        if(action = 'wait'){
            this.loading = true;
        }
        else if (action = 'finished')
        {
            console.log('false');
            this.loading = false;
        }
    }

    CreateNewCase(event) {
        var EntRecId = event.target.dataset.name;
        console.log(this.entcont);

        let obj = this.entcont.find(o => o.Id === EntRecId);

        console.log(obj.AssociatedProductRange__c);
    
        const defaultCaseValues = encodeDefaultFieldValues({
            AccountId: this.acctId,
            ContactId: this.record.fields.Id.value,
            Origin: 'Phone',
            EntitlementId: EntRecId,
            RelatedProduct__c: obj.AssociatedProductRange__c,
            CaseType__c: 'Support Issue',
            Source__c: 'Support',
            // Scratch RecordTypeId: '0128E000000pLjAQAU'
            RecordTypeId: '0124I0000002ZBIQA2'
        });
    
      //  console.log(defaultCaseValues);
    
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'Case',
                actionName: 'new'
            },
            state: { defaultFieldValues: defaultCaseValues
            }
        });
    }

    ShowToast(tsttitle, tstmessage, tstvariant){
        console.log("Inside Toast");
        
                var toastevent = new ShowToastEvent({
                    title: tsttitle,
                    message: tstmessage,
                    variant: tstvariant
                });
        this.dispatchEvent(toastevent);
            }

            RemoveFromEnitlement(event){
                console.log(this.recordId);
                console.log(event.target.dataset.name);
                this.WaitScreen('wait');
        
                DeletedEntitlementContact({conid: this.recordId, EntID: event.target.dataset.name})
                 .then(result => {
                     console.log(result);
                     if (result.includes("Delete failed")){
                        this.ShowToast('Failed', 'Please check that you have permission to compelete this action','error');
                        this.loading = false;
                     }
                     else if(result == "Success"){
                        this.ShowToast('Contact Removed', 'Contact Has Been Removed To The Entitlement','success');
                        this.loading = false;
                        this.RefreshRecords();
                     }
                     else{
                         console.log("No Ifs were hit in the creation of this log")
                     }
        
                 })
                 .catch (error => {
                    this.loading = false;
                    this.ShowToast('Failed', 'Error, please provide this to the Internal Salesforce Team '+ error.meassage,'error');
                     console.log('Error ' + error.message);
                 }); 
            }
        

    AddToEntitlement(event){
        console.log(this.recordId);
        console.log(event.target.dataset.name);
        this.WaitScreen('wait');

        AddEntitlementContacts({conid: this.recordId, EntID: event.target.dataset.name})
         .then(result => {
             console.error(result);
             if (result.includes("Insert failed")){

                if (result.includes("DUPLICATE_VALUE"))
                {
                    this.loading = false;
                    this.ShowToast('Failed', 'This user already exists on this plan','error');
                }
                else{
                this.loading = false;
                this.ShowToast('Failed', 'Unable to add contact to entitlement, please check that there is space on the plan','error');
                }
             }
             else if(result == "Success"){
                this.loading = false;
                this.ShowToast('Contact Added', 'Contact Has Been Added To The Entitlement','success');
                this.RefreshRecords();
             }
             else{
                 console.log("No Ifs were hit in the creation of this log")
             }

         })
         .catch (error => {
            this.loading = false;
            this.ShowToast('Failed', 'Error, please provide this to the Internal Salesforce Team '+ error.meassage,'error');
console.log('Error ' + error.message);
         }); 
    }

    handleChange(event) {
        this.acctId = event.detail.value;
    }

}