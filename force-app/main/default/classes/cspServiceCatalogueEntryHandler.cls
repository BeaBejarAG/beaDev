public with sharing class cspServiceCatalogueEntryHandler {
    @AuraEnabled(cacheable=true)
    public static List<Service_Catalogues__c> getServiceCatalogueEntries(String selectedAccId, String product, Integer lmt, Integer ofst, Boolean incrementLmt,
        String serviceType, String userLevel, String journeyLevel, String deliveryType, String deliveredBy, String location, Boolean premierOnly){
        if (incrementLmt) {
            ++lmt;
        }

        User currentUser = [SELECT ContactId FROM User WHERE Id =: Userinfo.getUserId()];
        List<String> entitledProducts = cspProductSelection.getFlatProductList(selectedAccId);

        String productList = '';
        for (Integer i = 0; i < entitledProducts.size(); i++) {
            productList += '\'' + entitledProducts.get(i) + '\'';
            if (i < entitledProducts.size() - 1) {
                productList += ',';
            }
        }

        if (entitledProducts.size() == 0 && String.isEmpty(product)) {
            return new List<Service_Catalogues__c>();
        }

        String listQuery = 'SELECT Service_Title__c, Service_Type__c, Service_Description__c, Points_Conversion__c, Premier_Only__c, Estimate_Required__c FROM Service_Catalogues__c WHERE Service_Title__c != null' + ' ';

        if (product != null && String.isNotBlank(product)) {
            listQuery += 'AND Products__c includes (\'' + product + '\') ';
        } else {
            listQuery += 'AND Products__c includes (' + productList + ') ';
        }

        if (String.isNotBlank(serviceType)) {
            listQuery += 'AND Service_Type__c includes (\'' + serviceType + '\') ';
        }

        if (String.isNotBlank(userLevel)) {
            listQuery += 'AND User_Level__c =: userLevel ';
        }

        if (String.isNotBlank(journeyLevel)) {
            listQuery += 'AND Account_Journey_Stage__c =: journeyLevel ';
        }

        if (String.isNotBlank(deliveryType)) {
            listQuery += 'AND Delivery_Type__c =: deliveryType ';
        }

        if (String.isNotBlank(deliveredBy)) {
            listQuery += 'AND Delivered_By__c includes (\'' + deliveredBy + '\') ';
        }

        if (String.isNotBlank(location)) {
            listQuery += 'AND Location__c =: location ';
        }

        if (premierOnly != null && premierOnly) {
            listQuery += 'AND Premier_Only__c =: premierOnly ';
        }

        if (currentUser != null && String.isNotBlank(currentUser.ContactId)) {
            Id contactId = currentUser.ContactId;
            String region = [SELECT Region__c FROM Contact WHERE Id =: contactId].Region__c;

            if (region != null && String.isNotBlank(region)) {
                listQuery += 'AND Region__c INCLUDES (:region) ';
            }
        } 

        listQuery += String.format('LIMIT {0} OFFSET {1}', new List<Object>{lmt, ofst});

        List<sObject> sobjList = Database.query(listQuery);
        return sobjList;
    }

    @AuraEnabled(cacheable=true)
    public static Service_Catalogues__c getServiceCatalogue(String serviceCatalogueId) {
        User currentUser = [SELECT ContactId FROM User WHERE Id =: Userinfo.getUserId()];

        String query = 'SELECT Service_Title__c, Service_Description__c, Points_Conversion__c, Premier_Only__c, Service_Prerequisites__c, Delivery_Type__c, Account_Journey_Stage__c, Service_Type__c, Service_Outcomes__c, Estimate_Required__c FROM Service_Catalogues__c WHERE  Id =: serviceCatalogueId' + ' ';

        if (currentUser != null && String.isNotBlank(currentUser.ContactId)) {
            Id contactId = currentUser.ContactId;
            String region = [SELECT Region__c FROM Contact WHERE Id =: contactId].Region__c;

            if (region != null && String.isNotBlank(region)) {
                query += 'AND Region__c INCLUDES (:region)';
            }
        }
        Service_Catalogues__c serviceCatalogue = Database.query(query);
        serviceCatalogue.Service_Type__c = serviceCatalogue.Service_Type__c.replaceAll(';', ', ');

        return serviceCatalogue;
    }

    @AuraEnabled(cacheable=true)
    public static Map<String, String> getRelatedProduct(String serviceCatalogueId, String selectedAccId){
        List<String> entitledProducts = cspProductSelection.getFlatProductList(selectedAccId);

        Service_Catalogues__c serviceCatalogue = [SELECT Products__c FROM Service_Catalogues__c WHERE Id =: serviceCatalogueId];
        List<String> products = serviceCatalogue.Products__c.split(';');

        Integer index = 0;
        String relatedProduct = '';
        
        if (products.size() > 0) {
            for (String product : products) {
                if (entitledProducts.contains(product)) {
                    relatedProduct = product;
                }
            }
        }

        return cspProductSelection.getProduct(relatedProduct, selectedAccId);
    }
}