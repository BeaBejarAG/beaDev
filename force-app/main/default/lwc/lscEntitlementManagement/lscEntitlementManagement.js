import { LightningElement, api, track, wire } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import { deleteRecord } from 'lightning/uiRecordApi';
import { updateRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import { getRecord } from 'lightning/uiRecordApi';
import GetEntitlementContacts from '@salesforce/apex/lscEntitlementHandler.GetEntitlementContacts';
import GetAccountContacts from '@salesforce/apex/lscEntitlementHandler.GetAccountContacts';
import GetAccountContactsFiltered from '@salesforce/apex/lscEntitlementHandler.GetAccountContactsFliterd';
import DeletedEntitlementContacts from '@salesforce/apex/lscEntitlementHandler.DeleteEntContacts';
import AddEntitlementContacts from '@salesforce/apex/lscEntitlementHandler.AddEntContacts';
import { CurrentPageReference } from 'lightning/navigation';
import { encodeDefaultFieldValues } from 'lightning/pageReferenceUtils';




export default class LscEntitlementManagement extends NavigationMixin(LightningElement) {
    @api recordId;
    @track record;
    @track recordrefresh;
    @track entcont;
    @track active;
    @track entcontnew;
    @track entcontrefresh;
    @track error;
    @track popModal = false;
    @track acccont;
    @track acccontrefresh;
    @track AddContId = [];
    @track pageRef;
    @track loaded = true;
    @track accountId;
    @track sfdcBaseURL;
    @track queryTerm;
    @track warningmessage;

    renderedCallback() {
        this.sfdcBaseURL = window.location.origin;
    }

    @wire(CurrentPageReference)
    pageRef;


    @wire(getRecord, { recordId: '$recordId', fields:['Entitlement.Name','Entitlement.EndDate','Entitlement.RemainingAuthorisedContacts__c','Entitlement.AccountId','Entitlement.AssociatedProductRange__c']})
    wiredAccount(response){
        if (response.data) {
            this.recordrefresh = response;
            this.record = response.data;
            this.error = undefined;
            console.log(response.data);
            this.accountId = this.record.fields.AccountId.value;
            var today = new Date();
            var entdate = new Date(response.data.fields.EndDate.value);
            var AuthContacts = response.data.fields.RemainingAuthorisedContacts__c.value;
            today.setHours(0,0,0,0);
            //entdate = response.data.fields.EndDate.value;
                if(entdate >= today)
                {                    
                    console.log(AuthContacts);
                        if( AuthContacts <= 0)
                        {
                            this.warningmessage = "There is no space remaining on this Entitlement, please remove contacts in order to add a new one";
                            this.active = true;
                        }
                        else{
                            this.active = false;
                        }
                }
                else{
                    this.active = true;
                    this.warningmessage = "It is not possible to add new Contacts to an Expired Entitlement";
                }
        } else if (response.error) {
            this.error = response.error;
            this.recordrefresh = response;
            this.record = undefined;
        }
    }

    get name() {
        return this.record.fields.Name.value;
    }

    @wire(GetEntitlementContacts, {EntId: '$recordId'})
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


    
 navigatetouser(event) {
    var ConRecId = event.target.dataset.name;

    this[NavigationMixin.Navigate]({
        type: 'standard__recordPage',
        attributes: {
            objectApiName: 'Contact',
            recordId: ConRecId,
            actionName: 'view'
        }
    });
}

CreateNewCase(event) {
    var ConRecId = event.target.dataset.name;

    const defaultCaseValues = encodeDefaultFieldValues({
        AccountId: this.accountId,
        ContactId: ConRecId,
        Origin: 'Phone',
        EntitlementId: this.recordId,
        RelatedProduct__c: this.record.fields.AssociatedProductRange__c.value,
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

    modalClick(){
        console.log(this.accountId);

        
        GetAccountContacts({EntId: this.recordId, AccId: this.accountId})
        .then(result => {
            console.log("Result" + result);
            this.acccont = result;
        })
        .catch(error => {
            this.error = error;
        });        

        this.popModal=true;
        this.AddContId = [];
        

    }

    handleKeyUp(evt) {
        const isEnterKey = evt.keyCode === 13;
        if (isEnterKey) {
            this.queryTerm = evt.target.value;
            if(this.queryTerm.length > 0){   
                GetAccountContactsFiltered({EntId: this.recordId, AccId: this.accountId, filter: this.queryTerm})
                .then(result => {
                    console.log("Result" + result);
                    this.acccont = result;
                })
                .catch(error => {
                 this.error = error;
                }); 
            }
            else if(this.queryTerm.length == 0){
                    GetAccountContacts({EntId: this.recordId, AccId: this.accountId})
                    .then(result => {
                        console.log("Result" + result);
                        this.acccont = result;
                    })
                    .catch(error => {
                        this.error = error;
                    });  
                 
                }
            }  
    }

    stopModal(){
        this.popModal=false;
        this.AddContId = [];
    }

    removeContactClick(event){
        this.loaded = false;
        var Entcontactid = event.target.dataset.name;
        var Success;
        

        Success = DeletedEntitlementContacts({EntContID:  Entcontactid});
        if (Success = true){
        this.ShowToast('Deleted', 'Contact Has Been Removed From Entitlement', 'success');
        this.RefreshRecords();
        }
       else {
            this.ShowToast('Deleted', 'Contact Has Been Removed From Entitlement', 'success'); 
        }
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

    RefreshRecords(){
        setTimeout(() => { 
        refreshApex(this.recordrefresh);
        refreshApex(this.entcontrefresh);      
        refreshApex(this.acccont);
        this.loaded = true;
    }, 2000);
    }

    PopConIdClick(event){


        var Entcontactid = event.target.dataset.name;

        if(event.target.checked)
        {
            this.AddContId.push(Entcontactid);
        }
        else
        {
        for( var i = 0; i < this.AddContId.length; i++){ 
            if ( this.AddContId[i] === Entcontactid){
                this.AddContId.splice(i, 1); 
            }};
        }

    }

    AddConIdClick(){
    if(this.AddContId.length > 0){
        AddEntitlementContacts({ContactIds:  this.AddContId, EntID: this.recordId});
        if(this.AddContId.length == 1){
          this.ShowToast('Added', 'Contact Has Been Added To The Entitlement', 'success');
        }
        else{
            this.ShowToast('Added', 'Contacts Have Been Added To The Entitlement', 'success');
        }
        this.loaded = false;
        this.RefreshRecords();
        this.popModal = false;
        }
    }
    

}