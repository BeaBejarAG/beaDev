import { LightningElement, api, wire } from 'lwc';
import { createRecord, getRecord } from 'lightning/uiRecordApi';
import { getObjectInfo, getPicklistValues } from 'lightning/uiObjectInfoApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import CASE_OBJECT from '@salesforce/schema/Case';
import OWNERID_FIELD from '@salesforce/schema/Case.OwnerId';
import IMPACT_FIELD from '@salesforce/schema/Case.Priority';
import SUBJECT_FIELD from '@salesforce/schema/Case.Subject';
import DESCRIPTION_FIELD from '@salesforce/schema/Case.Description';
import RECORDTYPEID_FIELD from '@salesforce/schema/Case.RecordTypeId';
import ORIGIN_FIELD from '@salesforce/schema/Case.Origin';
import SOURCE_FIELD from '@salesforce/schema/Case.Source__c';
import CASE_TYPE_FIELD from '@salesforce/schema/Case.CaseType__c';
import PARENT_PROJECT_FIELD from '@salesforce/schema/Case.Parent_Project__c';
import MAKE_PUBLIC_FIELD from '@salesforce/schema/Case.Make_Public__c';
import TYPE_FIELD from '@salesforce/schema/Case.Type';
import USER1_FIELD from '@salesforce/schema/Case.User_Field_1__c';
import USER2_FIELD from '@salesforce/schema/Case.User_Field_2__c';
import USER3_FIELD from '@salesforce/schema/Case.User_Field_3__c';
import USER_ID from '@salesforce/user/Id';

export default class CspIssuesAndActions extends LightningElement {
    @api recordId;
    @api recordType;
    @api showComponent;
    files = [];
    userId = USER_ID;
    creatingCase = false;
    selectIssueAction;

    @wire(getPicklistValues, { recordTypeId: '01258000000Vb44AAC', fieldApiName: TYPE_FIELD })
    typePicklistValues;

    @wire(getRecord, {
        recordId: '$recordId',
        fields: [
            'Case.RecordType.Name'
        ]
    })
    async setRecord(result) {
        if (result.error) {
            this.dispatchEvent(new ShowToastEvent({
                title: 'Error loading case',
                message: result.error.body.message,
                variant: 'error'
            }));
        } else if (result.data) {
            this.recordType = result.data.fields.RecordType.value.fields.Name.value;
            this.showComponent = this.recordType == 'Project' || this.recordType == 'Project Manual';
        }
    }

    @wire(getObjectInfo, { objectApiName: CASE_OBJECT })
    setRecordType(result) {
        if(!result.data) {
            return;
        }
        const rtis = result.data.recordTypeInfos;
        this.issuesRecordType = Object.keys(rtis).find(rti => rtis[rti].name === 'Issues and Actions');
    }

    handleCreate(event) {
        this.template.querySelector('[data-id="issue-action-popup"]').show();
    }

    errorCallback(e) {
        console.error(e);
        this.dispatchEvent(new ShowToastEvent({
            title: 'Error creating case',
            message: e.body ? e.body.message : e.message,
            variant: 'error'
        }));
    }

    async handleSubmitCase(event) {
        if (!this.handleValidation()) {
            return;
        }

        const fields = {
            [OWNERID_FIELD.fieldApiName]: this.userId,
            [SUBJECT_FIELD.fieldApiName]: this.title.value,
            [PARENT_PROJECT_FIELD.fieldApiName]: this.recordId,
            [IMPACT_FIELD.fieldApiName]: this.impact.value,
            [DESCRIPTION_FIELD.fieldApiName]: this.description.value,
            [RECORDTYPEID_FIELD.fieldApiName]: this.issuesRecordType,
            [ORIGIN_FIELD.fieldApiName]: 'Web',
            [SOURCE_FIELD.fieldApiName]: 'Support',
            [MAKE_PUBLIC_FIELD.fieldApiName]: true,
            [TYPE_FIELD.fieldApiName]: this.type.value,
            [USER1_FIELD.fieldApiName]: this.user1.value,
            [USER2_FIELD.fieldApiName]: this.user2.value,
            [USER3_FIELD.fieldApiName]: this.user3.value
        };

        this.creatingCase = true;
        window.scrollTo(0, 0);

        try {
            const caseObject = await createRecord({
                apiName: CASE_OBJECT.objectApiName,
                fields
            });

            this.caseId = caseObject.id;

            /* Move files from user to case */
            if(this.files.length > 0) {
                linkFilesToCase({
                    casenumber: this.caseId,
                    docid: this.files.map(file => file.documentId)
                });
            }

            this.template.querySelector('[data-id="issue-action-popup"]').hide();
            this.template.querySelector('c-csp-case-results').handleSearch(true, false);

        } catch(e) {
            this.errorCallback(e);
        } finally {
            this.creatingCase = false;
        }
    }

    /* Validate case inputs and show/hide the channels if all satisified */
    handleValidation() {

        if(!this.type.checkValidity()) {
            this.type.focus();
            this.type.blur();
            return false;
        }

        if(!this.impact.checkValidity()) {
            this.impact.focus();
            this.impact.blur();
            return false;
        }

        if(!this.title.checkValidity()) {
            this.title.focus();
            this.title.blur();
            return false;
        }

        if(!this.description.checkValidity()) {
            this.description.focus();
            this.description.blur();
            return false;
        }
        return true;
    }

    handleSelectCaseResult(event) {
        this.caseUrl = event.detail.url.split('/').pop();
        this.selectIssueAction = this.caseUrl;
        this.template.querySelector('[data-id="issue-action-view-popup"]').show();
        event.preventDefault();
    }

    get impactPicklist() {
        return [
            { value: '1', label: 'Critical'},
            { value: '2', label: 'Major'},
            { value: '3', label: 'Moderate'},
            { value: '4', label: 'Limited' }
        ];
    }

    get type() {
        return this.template.querySelector('[data-id="type"]');
    }

    get impact() {
        return this.template.querySelector('[data-id="impact"]');
    }

    get title() {
        return this.template.querySelector('[data-id="title"]');
    }

    get description() {
        return this.template.querySelector('[data-id="description"]');
    }

    get user1() {
        return this.template.querySelector('[data-id="user1"]');
    }

    get user2() {
        return this.template.querySelector('[data-id="user2"]');
    }

    get user3() {
        return this.template.querySelector('[data-id="user3"]');
    }
}