import { LightningElement, track, api, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CloseActionScreenEvent } from 'lightning/actions';
import { refreshApex } from '@salesforce/apex';
import { NavigationMixin } from 'lightning/navigation';

import createCancellationFeeTransaction from '@salesforce/apex/cspFlexPointsHandler.createCancellationFeeTransaction';

export default class CspCancellationFeeModal extends NavigationMixin(LightningElement) {
    @api recordId;
    @track feeAmount;
    isLoading = false;
    isProcessing = false;
    flexPointsTransaction;
    wiredflexPointsTransaction;

    @wire(getRecord, {
        recordId: '$recordId',
        fields: [
            'FlexPoints_Transactions__c.Id',
            'FlexPoints_Transactions__c.Owner__c',
            'FlexPoints_Transactions__c.Account__c',
            'FlexPoints_Transactions__c.Request_Subject__c',
            'FlexPoints_Transactions__c.FlexPoint_Redemption_Case__c',
            'FlexPoints_Transactions__c.Points__c',
            'FlexPoints_Transactions__c.Transaction_Status__c'
        ]
    })
    setRecord(result) {
        this.isLoading = true;
        this.wiredflexPointsTransaction = result;

        if (result.error) {
            this.dispatchEvent(new ShowToastEvent({
                title: 'Error loading flexpoint transaction',
                message: result.error.body.message,
                variant: 'error'
            }));

            this.isLoading = false;
        } else if (result.data) {
            this.flexPointsTransaction = {
                ownerId: result.data.fields.Owner__c.value,
                accountId: result.data.fields.Account__c.value,
                serviceName: result.data.fields.Request_Subject__c.value,
                caseId: result.data.fields.FlexPoint_Redemption_Case__c.value,
                points: result.data.fields.Points__c.value,
                status: result.data.fields.Transaction_Status__c.value
            };
            this.isLoading = false;
        }
    }

    handleFeeChange(event) {
        this.feeAmount = event.target.value;
    }

    async handleCreateCancellationFeeTransaction(event) {
        try{
            this.isProcessing = true;

            const cancellationFee = await createCancellationFeeTransaction({
                accountId: this.flexPointsTransaction.accountId,
                points: this.feeAmount,
                owner: this.flexPointsTransaction.owner,
                serviceName: this.flexPointsTransaction.serviceName,
                caseId: this.flexPointsTransaction.caseId
            });

            refreshApex(this.wiredflexPointsTransaction);

            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'Flexpoint cancellation fee transaction successfully created',
                    variant: 'success',
                }),
            );
            this.isProcessing = false;
            this.closeAction();

            this[NavigationMixin.Navigate]({
                type: 'standard__recordPage',
                attributes: {
                    recordId: cancellationFee.Id,
                    objectApiName: 'FlexPoints_Transactions__c',
                    actionName: 'view'
                }
            });

        } catch(error) {
            this.showErrorMessage('Error creating flexpoint cancellation fee transaction', error.body.message);
        } finally{() => {}};
    }

    saveAction() {
        if (this.flexPointsTransaction.status && this.flexPointsTransaction.status == 'Cancelled') {
            if (this.feeAmount !== undefined && this.feeAmount !== '') {
                if (this.feeAmount <= this.flexPointsTransaction.points) {
                    this.handleCreateCancellationFeeTransaction();
                } else {
                    this.showErrorMessage('Invalid cancellation fee amount', 'Please input a cancellation fee amount that is no more than the original points value');
                }
            } else {
                this.showErrorMessage('Invalid cancellation fee amount', 'Please input a cancellation fee amount prior to submitting');
            }
        } else {
            this.showErrorMessage('Invalid flexpoint transaction status', 'The cancellation fee can only be created for transactions with a cancelled status');
        }
    }

    showErrorMessage(title, message) {
        this.dispatchEvent(new ShowToastEvent({
            title: title,
            message: message,
            variant: 'error'
        }));
    }

    closeAction(){
        this.dispatchEvent(new CloseActionScreenEvent());
    }
}