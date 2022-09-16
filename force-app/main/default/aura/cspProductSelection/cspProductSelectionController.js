({
    handleInit: function(component, event, helper) {
        /* TODO handle default topic/product */
        const account = window.sessionStorage.getItem('selectedAccountId');
        helper.currentAccount = account;
        component.set('v.account', helper.currentAccount);
        const product = JSON.parse(window.sessionStorage.getItem('selectedProduct'));
        let appEvent = $A.get("e.c:cspProductSelectionEvent");
        new Promise((resolve, reject) => {
            const action = component.get('c.getProductList');
            action.setParam("selectedAccId", helper.currentAccount);
            action.setCallback(this, function(response){
                const state = response.getState();
                if (state === 'SUCCESS') {
                    resolve(response.getReturnValue())
                }
                if (state === 'ERROR') {
                    reject()
                }
            });
            $A.enqueueAction(action);
        }).then(productList => {
            const products = productList.map((e, i) => {
                const colourIndex = e.colour && e.colour.length > 0 ? e.colour : (i % 28) + 1;
                e.colour = `access-theme-product-bar-cat${colourIndex}`;

                if (!e.image || e.image.length == 0) {
                    e.image = $A.get('$ContentAsset.csp_logo_black');
                }

                return e
            })

            products.sort((a, b) => a.name.localeCompare(b.name));
            component.set('v.productList', products);

            if(product != null) {
                helper.currentProduct = products.find(p => p.id === product.id) || null;
                component.set('v.product', helper.currentProduct);
            } else if (products.length == 1) {
                helper.currentProduct = productList[0];
                window.sessionStorage.setItem('selectedProduct', JSON.stringify(helper.currentProduct, (key, value) => {
                    return value ? value : null
                }));
                component.set('v.product', helper.currentProduct);
                appEvent.setParams({ product: helper.currentProduct || {} });
                appEvent.fire();
            }
        })
    },

    handleAccountSelection: function(component, message, helper) {
        // Read the message argument to get the values in the message payload
        if (message != null && message.getParam("selectedAccountId") != null && (!helper.currentAccount || helper.currentAccount != message.getParam('selectedAccountId'))) {
            helper.currentAccount = message.getParam("selectedAccountId");
        }
        if (helper.currentAccount != component.get('v.account')) {
            component.set('v.account', helper.currentAccount);
            let appEvent = $A.get("e.c:cspProductSelectionEvent");

            new Promise((resolve, reject) => {
                const action = component.get('c.getProductList');
                action.setParam("selectedAccId", helper.currentAccount);
                action.setCallback(this, function(response){
                    const state = response.getState();
                    if (state === 'SUCCESS') {
                        resolve(response.getReturnValue())
                    }
                    if (state === 'ERROR') {
                        reject()
                    }
                });
                $A.enqueueAction(action);
            }).then(productList => {
                const products = productList.map((e, i) => {
                    const colourIndex = e.colour && e.colour.length > 0 ? e.colour : (i % 28) + 1;
                    e.colour = `access-theme-product-bar-cat${colourIndex}`;

                    if (!e.image || e.image.length == 0) {
                        e.image = $A.get('$ContentAsset.csp_logo_black');
                    }

                    return e
                })

                products.sort((a, b) => a.name.localeCompare(b.name));
                component.set('v.productList', products);

                if (products.length == 1) {
                    helper.currentProduct = productList[0];
                    window.sessionStorage.setItem('selectedProduct', JSON.stringify(helper.currentProduct, (key, value) => {
                        return value ? value : null
                    }));
                    component.set('v.product', helper.currentProduct);

                    window.sessionStorage.setItem('selectedProductFeature', '');

                    appEvent.setParams({ product: helper.currentProduct || {} });
                    appEvent.fire();
                } else {
                    helper.currentProduct = null;
                    component.set('v.product', helper.currentProduct);
                }
            })
        }
    },

    handleProductSelection: function(component, message, helper) {
        // Read the message argument to get the values in the message payload
        if (message != null && message.getParam("product") != null && (!helper.currentProduct || helper.currentProduct.id != message.getParam('product').id)) {
            helper.currentProduct = message.getParam("product");
            window.sessionStorage.setItem('selectedProduct', JSON.stringify(helper.currentProduct, (key, value) => {
                return value ? value : null
            }));
        }
        if (helper.currentProduct != component.get('v.product')) {
            component.set('v.product', helper.currentProduct);
        }
    },

    handleRouteChange: function(component, event, helper) {
        component.set('v.product', helper.currentProduct);
    },

    handleMenuSelect: function(component, event, helper) {
        const productId = event.getParam('value');

        if(productId != null) {
            const productList = component.get('v.productList');

            if(productList) {
                helper.currentProduct = productList.find(p => p.id === productId) || null;
                window.sessionStorage.setItem('selectedProduct', JSON.stringify(helper.currentProduct, (key, value) => {
                    return value ? value : null
                }));
                component.set('v.product', helper.currentProduct);

                window.sessionStorage.setItem('selectedProductFeature', '');

                const appEvent = $A.get("e.c:cspProductSelectionEvent");
                appEvent.setParams({ product: helper.currentProduct || {} });
                appEvent.fire();
            }
            var buttonMenu = component.find('buttonMenu');
            if (Array.isArray(buttonMenu)) {
                buttonMenu.blur();
            }
        }
    }
})