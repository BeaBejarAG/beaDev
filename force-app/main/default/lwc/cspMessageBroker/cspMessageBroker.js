import { LightningElement, api, wire } from 'lwc';
import { NavigationMixin, CurrentPageReference } from 'lightning/navigation';
import { registerListener, unregisterListener, fireEvent } from 'c/pubsub';

export default class CspMessageBroker extends NavigationMixin(LightningElement) {
    @wire(CurrentPageReference) pageRef;

    connectedCallback() {
        registerListener('cspProductSelectionEvent', this.addListener, this);
        registerListener('cspAccountSelectionEvent', this.addAccountListener, this);
        registerListener('cspProfileEvent', this.addProfileListener, this);
    }

    disconnectedCallback() {
        unregisterListener('cspProductSelectionEvent', this.addListener, this);
        unregisterListener('cspAccountSelectionEvent', this.addAccountListener, this);
        unregisterListener('cspProfileEvent', this.addProfileListener, this);
    }

    addListener(event)  {
        if(event.product.brokered) {
            return;
        }
        event.product.brokered = true;
        this.dispatchEvent(new CustomEvent('productselection', {
            detail: {
                product: event.product
            }
        }));
    }

    addAccountListener(event)  {
        this.dispatchEvent(new CustomEvent('accountselection', {
            detail: {
                selectedAccountId: event.selectedAccountId
            }
        }));
    }

    addProfileListener(event)  {
        this.dispatchEvent(new CustomEvent('profileevent', {
            detail: {
                event: event.event,
                userList: event.userList
            }
        }));
    }

    @api
    setProduct(product) {
        if(product.brokered) {
            return;
        }
        fireEvent(this.pageRef, 'cspProductSelectionEvent', {
            product
        });
    }

    @api
    setSearch(searchText) {
        fireEvent(this.pageRef, 'cspSearchEvent', {
            searchText
        });
    }
}