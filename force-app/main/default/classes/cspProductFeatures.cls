public with sharing class cspProductFeatures {

    @AuraEnabled(cacheable=true)
    public static List<String> getProductFeatures(String product) {
        Map<Object,List<String>> dependValuesByControlValue = getDependentPicklistValues( Knowledge__kav.Product_Features__c );
        List<String> productFeatures = dependValuesByControlValue.get(product);
        return productFeatures != null ? productFeatures : new List<String>();
    }


    @AuraEnabled(cacheable=true)
    public static List<String> getCaseFeatures(String product) {
        Map<Object,List<String>> dependValuesByControlValue = getDependentPicklistValues( Case.SubAnalysis__c );
        List<String> caseFeatures = dependValuesByControlValue.get(product);
        return caseFeatures != null ? caseFeatures : new List<String>();
    }

    @AuraEnabled(cacheable=true)
    public static Map<Object,List<String>> getProductsByDivision() {
        Map<Object,List<String>> allProductsByDivision = getDependentPicklistValues( Knowledge__kav.Product__c );
        return allProductsByDivision != null ? allProductsByDivision : new Map<Object,List<String>>();
    }

    public static Map<String,String> getDivisionsByProduct() {
        Map<String,String> flatMap = new Map<String,String>();
        Map<Object,List<String>> divisionMap = getProductsByDivision();
        for (Object division : divisionMap.keySet()) {
            for (String product : divisionMap.get(division)) {
                flatMap.put(product, (String)division);
            }
        }
        return flatMap;
    }


    private static Map<Object,List<String>> getDependentPicklistValues( Schema.sObjectField dependToken )
    {
        Schema.DescribeFieldResult depend = dependToken.getDescribe();
        Schema.sObjectField controlToken = depend.getController();
        if ( controlToken == null ) {
            return null;
        }
        Schema.DescribeFieldResult control = controlToken.getDescribe();
        List<Schema.PicklistEntry> controlEntries = (control.getType() == Schema.DisplayType.Boolean ? null : control.getPicklistValues());

        String base64map = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
        Map<Object,List<String>> dependentPicklistValues = new Map<Object,List<String>>();
        for ( Schema.PicklistEntry entry : depend.getPicklistValues() ) if ( entry.isActive() )
        {
            if (String.isNotBlank(String.valueOf (((Map<String,Object>) JSON.deserializeUntyped( JSON.serialize( entry ) )).get( 'validFor' )))){
                List<String> base64chars = String.valueOf (((Map<String,Object>) JSON.deserializeUntyped( JSON.serialize( entry ) )).get( 'validFor' )).split( '' );
                for ( Integer index = 0; index < (controlEntries != null ? controlEntries.size() : 2); index++ )
                {
                    Object controlValue =
                    ( controlEntries == null
                    ?   (Object) (index == 1)
                    :   (Object) (controlEntries[ index ].isActive() ? controlEntries[ index ].getLabel() : null)
                    );
                    Integer bitIndex = index / 6, bitShift = 5 - Math.mod( index, 6 );
                    if  ( controlValue == null || bitIndex >= base64chars.size() || (base64map.indexOf( base64chars[ bitIndex ] ) & (1 << bitShift)) == 0 ){
                        continue;
                    }
                    if ( !dependentPicklistValues.containsKey( controlValue ) )
                    {
                        dependentPicklistValues.put( controlValue, new List<String>() );
                    }
                    dependentPicklistValues.get( controlValue ).add( entry.getLabel() );
                }
            }
        }
        return dependentPicklistValues;
    }
}