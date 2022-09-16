public with sharing class cspCaseCount {
    @AuraEnabled(cacheable=true)
    public static Integer getOpenCases() {
        List<String> validRecordTypes = new List<String>{'Support', 'Parent Case'};
        String closedStatus = 'Closed';
        Integer caseCount = [SELECT COUNT() FROM Case WHERE Status !=:closedStatus AND RecordType.Name IN :validRecordTypes];
        return caseCount;
    }

    @AuraEnabled(cacheable=true)
    public static Integer getAwaitingCustomerCases() {
        List<String> outstandingStatuses = new List<String>{'Customer Outstanding', 'Awaiting Fix Confirmation', 'Resolved'};
        Integer caseCount = [SELECT COUNT() FROM Case WHERE Status IN :outstandingStatuses];
        return caseCount;
    }
}