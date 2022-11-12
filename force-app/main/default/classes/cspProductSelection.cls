public without sharing class cspProductSelection {
    @AuraEnabled(cacheable=true)
    public static List<Map<String, String>> getAllProducts(String selectedAccId) {
        return cspProductSelection.getFullProductList(true, selectedAccId);
    }

    @AuraEnabled(cacheable=true)
    public static List<Map<String, String>> getProductList() {
        return cspProductSelection.getFullProductList(false, '');
    }

    @AuraEnabled(cacheable=true)
    public static List<Map<String, String>> getProductList(String selectedAccId) {
        return cspProductSelection.getFullProductList(false, selectedAccId);
    }

    private static List<Map<String, String>> getFullProductList(Boolean allProducts, String selectedAccId) {
        List<Map<String, String>> productList = cspProductSelection.getProductRoutingProducts();
        System.debug('*** selectedAccId: ' + selectedAccId);
        Boolean bypassEntitlements = FeatureManagement.checkPermission('Bypass_Entitlements_Check');
        System.debug('*** bypassEntitlements: ' + bypassEntitlements);
        if (bypassEntitlements) {
            // The current profile can see all products with no entitlement requirements
            for (Map<String,String> product : productList) {
                product.put('successPlanName', 'Internal');
                product.put('successPlan', 'Internal Staff Access');
                product.put('admin', 'true');
            }
        }
        if (bypassEntitlements || allProducts) {
            System.debug('*** productList: ' + productList);

            return productList;
        }

        List<Entitlement> accountEntitlements = cspProductSelection.getAccountEntitlements(selectedAccId);
        List<ContactEntitlement__c> contactEntitlements = cspProductSelection.getMyEntitlements(selectedAccId);
        if (accountEntitlements.size() > 0) {
            List<Map<String, String>> entitledProducts = new List<Map<String, String>>();
            for (Map<String,String> product : productList) {
                for (Entitlement accountEnt : accountEntitlements) {
                    if (product.get('name').equals(accountEnt.AssociatedProductRange__c)) {
                        product.put('entitlementId', accountEnt.Id);
                        product.put('successPlanName', accountEnt.PlanType__c);
                        product.put('successPlan', accountEnt.PlanType__c + ' Success Plan');
                        for (ContactEntitlement__c entitlement : contactEntitlements) {
                            if (product.get('name').equals(entitlement.Product__c)) {
                                product.put('admin', 'true');
                                break;
                            }
                        }
                        entitledProducts.add(product);
                        break;
                    }
                }
            }
            return entitledProducts;
        } else {
            // If the user has no entitlements, return no products
            return new List<Map<String, String>>();
        }
    }

    public static List<String> getFlatProductList(String selectedAccId) {
        List<Map<String, String>> productList = cspProductSelection.getProductList(selectedAccId);

        List<String> flatProductList = new List<String>();

        for (Map<String,String> product : productList) {
            flatProductList.add(product.get('name'));
        }
        return flatProductList;
    }

    public static List<String> getEntitledProductList(String selectedAccId) {
        List<Map<String, String>> productList = cspProductSelection.getProductList(selectedAccId);

        List<String> flatProductList = new List<String>();

        for (Map<String,String> product : productList) {
            if (product.get('admin') != null && product.get('admin').equals('true')) {
                flatProductList.add(product.get('name'));
            }
        }
        return flatProductList;
    }

    @AuraEnabled
    public static Map<String, String> getProduct(String productName, String selectedAccId) {
        List<Map<String, String>> productList = cspProductSelection.getProductList(selectedAccId);

        for (Map<String, String> product : productList) {
            if (product.get('name').equals(productName)) {
                return product;
            }
        }
        return null;
    }

    @AuraEnabled
    public static List<ContactEntitlement__c> getMyEntitlements(String selectedAccId) {
        string contactiduser = [Select contactid from User where id = :Userinfo.getUserid()].contactId;
        List<ContactEntitlement__c> objList = new List<ContactEntitlement__c>();
        for (ContactEntitlement__c entitlement : [
            SELECT Product__C, Topic_ID__c, Real_Entitlement__r.PlanType__c
            FROM ContactEntitlement__c
            WHERE Active__C = true
            AND Real_Entitlement__r.AccountId =:selectedAccId
            AND (Contact__C = :contactiduser or ContactID18__C =:contactiduser)
            order by Real_Entitlement__r.Entitlement_Level__c
        ]) {
                objList.add(entitlement);
        }
        return objList;
    }

    @AuraEnabled
    public static List<ContactEntitlement__c> getContactEntitlements(String selectedAccId, String contactId) {
        List<ContactEntitlement__c> objList = new List<ContactEntitlement__c>();
        for (ContactEntitlement__c entitlement : [
            SELECT Product__C, Topic_ID__c, Real_Entitlement__r.PlanType__c
            FROM ContactEntitlement__c
            WHERE Active__C = true
            AND Real_Entitlement__r.AccountId =:selectedAccId
            AND (Contact__C = :contactId or ContactID18__C =:contactId)
        ]) {
                objList.add(entitlement);
        }
        return objList;
    }

    @AuraEnabled
    public static List<Entitlement> getAccountEntitlements(String selectedAccId) {
        string contactiduser = [Select contactid from User where id = :Userinfo.getUserid()].contactId;
        List<Entitlement> objList = new List<Entitlement>();
        if (selectedAccId != null) {
            for (Entitlement entitlement : [
                SELECT Id, AssociatedProductRange__c, PlanType__c
                FROM Entitlement
                WHERE Active__c = true
                AND AccountId = :selectedAccId
                order by Entitlement_Level__c
            ]) {
                    objList.add(entitlement);
            }
        } else {
            String customerSuccessRole = 'Customer Success Portal Access';
            List<AccountContactRelation> accountContactRelations = [
                SELECT Account.Id FROM AccountContactRelation
                WHERE Contact.Id =: contactiduser
                AND (Roles INCLUDES (:customerSuccessRole) OR IsDirect = true)
            ];

            List<String> accountIds = new List<String>();
            for (AccountContactRelation accountContactRelation : accountContactRelations) {
                accountIds.add(accountContactRelation.Account.Id);
            }
            for (Entitlement entitlement : [
                SELECT Id, AssociatedProductRange__c, PlanType__c
                FROM Entitlement
                WHERE Active__c = true
                AND AccountId IN :accountIds
            ]) {
                    objList.add(entitlement);
            }
        }
        return objList;
    }

    @AuraEnabled
    public static List<Map<String, String>> getProductRoutingProducts() {
        List<Map<String, String>> productRoutingList = new List<Map<String, String>>();

        for(ProductRouting__c productRouting: [
            SELECT Id, Related_Product_Range__c, ImageUrl__c, ProductColour__c,
                Enabled_For_Live_Chat__c, Enabled_For_Telephony__c, Enabled_for_FlexPoints__c,
                Enabled_For_Web_Cases__c, Dedicated_Telephone_Number__c,
                Live_Chat_Button_ID__c, TopicID__c, Community_Redirect__c, Enabled_For_Community__c, Livechat_Levels__c, Phone_Plan_Availability__c
            FROM ProductRouting__c
            WHERE Related_Product_Range__c != null
            AND Visibility__c = 'Public'
            ORDER BY Related_Product_Range__c
        ]) {
            String productId = productRouting.Id;
            String productName = productRouting.Related_Product_Range__c;
            String imageUrl = productRouting.ImageUrl__c;
            String productColour = productRouting.ProductColour__c;
            String chatEnabled = productRouting.Enabled_For_Live_Chat__c;
            String phoneEnabled = productRouting.Enabled_For_Telephony__c;
            String onlineEnabled = productRouting.Enabled_For_Web_Cases__c;
            String phoneNumber = productRouting.Dedicated_Telephone_Number__c;
            String liveChatButton = productRouting.Live_Chat_Button_ID__c;
            String topicId = productRouting.TopicID__c;
            String communityRedirect = productRouting.Community_Redirect__c;
            String enabledForCommunity = productRouting.Enabled_For_Community__c;
            String livechatlevel = productRouting.Livechat_Levels__c;
            String PhonePlanAvaliblity = productRouting.Phone_Plan_Availability__c;
            String flexPointsEnabled = productRouting.Enabled_for_FlexPoints__c;
            Map<String, String> productMap = new Map<String, String>{
                'colour' => productColour != null ? productColour.replace('Colour ', '') : '',
                'id' => productId,
                'image' => imageUrl,
                'name' => productName,
                'enabledForChat' => chatEnabled,
                'enabledForPhone' => phoneEnabled,
                'enabledForOnline' => onlineEnabled,
                'phoneNumber' => phoneNumber,
                'liveChatButton' => liveChatButton,
                'topicId' => topicId,
                'communityRedirect' => communityRedirect,
                'enabledForCommunity' => enabledForCommunity,
                'livechatlevel' => livechatlevel,
                'PhonePlanAvalibility' => PhonePlanAvaliblity,
                'flexPointsEnabled' => flexPointsEnabled
            };
            productRoutingList.add(productMap);
        }
        return productRoutingList;
    }
}