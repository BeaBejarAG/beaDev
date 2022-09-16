@isTest(SeeAllData=true)
public class RHX_TEST_ContentVersion {
	static testMethod void RHX_Testmethod() {
        List<sObject> sourceList = [SELECT Id 
			FROM ContentVersion LIMIT 1];
        if(sourceList.size() == 0) {
            sourceList.add(
                    new ContentVersion()
            );
        }
    	rh2.ParentUtil.UpsertRollupTestRecords( sourceList );
    }
}