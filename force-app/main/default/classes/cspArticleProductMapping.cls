global class cspArticleProductMapping implements Database.Batchable<sObject>, Database.Stateful{

    global final String query;
    global integer totalProcessed;
    global integer totalMapped;
    global integer totalError;
    global integer totalNonMatchingProduct;
    global integer totalMultiProduct;
    global integer totalAlreadyMapped;
    global integer totalNotMapped;
    global Boolean noOp;

    global Set<String> nonMatchingProducts;
    global Set<List<String>> multiProductArticles;
    global Map<String,String> errors;

    private Map<String, String> productMapping = new Map<String, String>{
        'Delta' => 'DeltaWMS',
        'RaisingIT Google Ad Grant' => 'Joyful Ad Grant',
        'RaisingIT Website Platform' => 'Joyful Website Builder',
        'ThankQ 8.6' => 'thankQ',
        'ThankQ 10 CRM' => 'thankQ',
        'Access People - HCM' => 'Access HCM People',
        'Access EarlyPay' => 'EarlyPay',
        'EnterpriSe' => 'Intersoft Enterprise',
        'Safe Saber' => 'Saber',
        'Access Profile' => 'Profile',
        'Access Procure Wizard' => 'Procure Wizard',
        'Tonic' => 'Access Tonic',
        'Collins' => 'Access Collins',
        'Safe Tempest' => 'Access Pay & Bill',
        'Select Pay' => 'Payroll',
        'Access People - HOS' => 'Access Hospitality People',
        'Early Pay' => 'EarlyPay',
        'Microdec' => 'Profile',
        'Workspace Digital Tax' => 'Access Digital Tax',
        'HCM' => 'Access HCM People',
        'ADM' => 'Access Document',
        'Payroll SE' => 'Payroll',
        'AOI' => 'Dimensions',
        'Asset Manager' => 'Dimensions',
        'aCloud Currency' => 'Dimensions'
    };private Map<String, String> featureMapping = new Map<String, String>{
        'ThankQ 8.6' => 'thankQ 8.6',
        'ThankQ 10 CRM' => 'thankQ 10 CRM',
        'Payroll SE' => 'Payroll SE - Main',
        'Select Pay' => 'Select Pay',
        'AOI' => 'AOI',
        'Asset Manager' => 'Asset Manager',
        'aCloud Currency' => 'aCloud Currency'
    };
    private List<String> ignoreList = new List<String>{
        'GDPR',
        'COVID-19 (Coronavirus)',
        'Community Help & Support',
        'All',
        'Web Services',
        'About this site',
        'Alto',
        'FMS',
        'Business Suite',
        'HCM',
        'NFP',
        'Hospitality',
        'Hosting',
        'REC',
        'EDU',
        'SCS',
        'HSC',
        'Safe Computing',
        'Access Learning Management',
        'Mobile Point of Care',
        'Access Payslip',
        'PayPoint',
        'Access Identity',
        'aCloud Communicate'
    };
    private Map<String,String> divisionMapping;
  
    global cspArticleProductMapping(String q, Boolean noOp){
        query=q;
        this.noOp = noOp;
        divisionMapping = cspProductFeatures.getDivisionsByProduct();
        totalProcessed = 0;
        totalMapped = 0;
        totalError = 0;
        totalNonMatchingProduct = 0;
        totalMultiProduct = 0;
        totalAlreadyMapped = 0;
        totalNotMapped = 0;
        nonMatchingProducts = new Set<String>();
        multiProductArticles = new Set<List<String>>();
        errors = new Map<String,String>();
    }

    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(query);
    }
   
    global void execute(Database.BatchableContext BC, List<sObject> scope) {
        for(sObject sObj : scope){
            Knowledge__kav article = (Knowledge__kav)sObj;
            processArticle(article);
            if (noOp) {
                countMultiProducts(article);
            }
        }
    }

    global void finish(Database.BatchableContext BC){
        if (noOp) {
            System.debug('No Op run complete');
            System.debug('Total number of errors : ' + totalError);
            System.debug('Total number of articles processed : ' + totalProcessed);
            System.debug('Total number of articles validated for mapping : ' + totalMapped);
            System.debug('Total number of articles with non matching product : ' + totalNonMatchingProduct);
            System.debug('Total number of articles with multiple product categories : ' + totalMultiProduct);
            System.debug('Total number of articles already mapped & therefore skipped : ' + totalAlreadyMapped);
            System.debug('Total number of articles with no categories : ' + totalNotMapped);
            System.debug('Non matching products : ');
            for(String prod : nonMatchingProducts) {
                System.debug(prod);
            }
            System.debug('Multi product articles : ');
            for (List<String> products : multiProductArticles) {
                System.debug(products);
            }
        } else {
            System.debug('Processed articles : ' + totalProcessed);
            System.debug('Successfully published articles : ' + totalMapped);
            System.debug('Errors : ' + totalError);
            System.debug('Non mapped due to non matching product : ' + totalNonMatchingProduct);
            System.debug('Skipped due to already mapped : ' + totalAlreadyMapped);
            System.debug('Errors : ');
            for (String articleId : errors.keySet()) {
                System.debug(articleId + ' : ' + errors.get(articleId));
            }
        }
    }

    private void processArticle(Knowledge__kav article) {
        if (article.DataCategorySelections != null && article.DataCategorySelections.size() > 0) {
            for(Knowledge__DataCategorySelection category : article.DataCategorySelections) {
                if (category.DataCategoryGroupName == 'Products') {
                    // Map the new product name & set the product & division values
                    String productValue = category.DataCategoryName;
                    String originalProductValue = category.DataCategoryName;
                    if (productMapping.containsKey(category.DataCategoryName)) {
                        // Make sure we map to the correct product name for product_range value set
                        productValue = productMapping.get(category.DataCategoryName);
                    }
                    if (productValue != null) {
                        if (ignoreList.contains(productValue)) {
                            // This category is marked to ignore - skip it
                            continue;
                        }

                        // Get the associated division for this product
                        String divisionValue = divisionMapping.get(productValue);
                        if (divisionValue != null) {

                            // Check the article doesn't already have the correct values:
                            if (article.Division__c == divisionValue && article.Product__c == productValue) {
                                totalAlreadyMapped++;
                                break;
                            }

                            if (!noOp) {
                                try {
                                    String draftArticleID = KbManagement.PublishingService.editOnlineArticle(article.KnowledgeArticleId, false);
                                    Knowledge__kav newVersion = [SELECT KnowledgeArticleId, PublishStatus FROM Knowledge__kav WHERE Id =: draftArticleID];
                                    newVersion.Division__c = divisionValue;
                                    newVersion.Product__c = productValue;

                                    // some articles require an extra feature adding for version number
                                    if (featureMapping.containsKey(originalProductValue)) {
                                        newVersion.Product_Features__c = featureMapping.get(originalProductValue);
                                    }

                                    update newVersion;
                                    KbManagement.PublishingService.publishArticle(newVersion.KnowledgeArticleId, true);
                                    System.debug('Successfully mapped article Id ' + article.Id + ' with product : ' + productValue);
                                    totalMapped++;
                                    break;
                                } catch (Exception e) {
                                    totalError++;
                                    System.debug('Exception attempting to update article Id ' + article.Id + ' : ' + e.getMessage());
                                    errors.put(article.Id, e.getMessage());
                                    break;
                                }
                            } else {
                                totalMapped++;
                                break;
                            }
                        } else {
                            // No division found for this product
                            nonMatchingProducts.add(productValue);
                            totalNonMatchingProduct++;
                        }
                    }
                }
            }
        } else {
            // No categories set
            totalNotMapped++;
        }
        totalProcessed++;
    }

    private void countMultiProducts(Knowledge__kav article) {
        if (article.DataCategorySelections != null && article.DataCategorySelections.size() > 1) {
            List<String> productSelections = new List<String>();
            for(Knowledge__DataCategorySelection category : article.DataCategorySelections) {
                if (category.DataCategoryGroupName == 'Products') {
                    if (!ignoreList.contains(category.DataCategoryName)) {
                        productSelections.add(category.DataCategoryName);
                    }
                }
            }
            if (productSelections.size() > 1) {
                totalMultiProduct++;
                multiProductArticles.add(productSelections);
            }
        }
    }
}