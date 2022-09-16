import { LightningElement, api, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import getCaseAccess from '@salesforce/apex/cspCaseCollaboratorHandler.isCaseViewable';

export default class CspSupportCaseRelatedArticles extends LightningElement {
    @api recordId;
    @api recordType;
    @api hideComponent = false;

    @wire(getRecord, {
        recordId: '$recordId',
        fields: [
            'Case.Id',
            'Case.RecordType.Name',
            'Case.ContactId',
            'Case.CreatedById'
        ]
    })
    setRecord(result) {
        if (result.error) {
            this.dispatchEvent(new ShowToastEvent({
                title: 'Error loading case',
                message: result.error.body.message,
                variant: 'error'
            }));
        } else if (result.data) {
            let caseRecordData = result.data;
            getCaseAccess({caseId: result.data.id, caseContactId: result.data.fields.ContactId.value, caseCreatedById: result.data.fields.CreatedById.value}).then(result => {
                if (result) {
                    this.recordType = caseRecordData.fields.RecordType.value.fields.Name.value;
                    this.hideComponent = this.recordType == 'Project' || this.recordType == 'Project Manual';
                } else {
                    this.hideComponent = true;
                }
            }).catch(e => {
                console.error(e);
                this.hideComponent = true;
            });
        }
    }
}