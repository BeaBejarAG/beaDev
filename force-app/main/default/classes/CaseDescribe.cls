public class CaseDescribe {
	@TestVisible
	private static Schema.DescribeSObjectResult thisDescribeSObjectResult {
		get {
			if (thisDescribeSObjectResult == null) {
				thisDescribeSObjectResult = Schema.SObjectType.Case;
			}

			return thisDescribeSObjectResult;
		}
		set;
	}

	@TestVisible
	private static Map<String, Schema.RecordTypeInfo> recordTypesByNameMap {
		get {
			if (recordTypesByNameMap == null) {
				recordTypesByNameMap = thisDescribeSObjectResult.getRecordTypeInfosByName();
			}

			return recordTypesByNameMap;
		}
		set;
	}

	@TestVisible
	private static Schema.RecordTypeInfo recordType_Hosting {
		get {
			if (recordType_Hosting == null) {
				recordType_Hosting = recordTypesByNameMap.get(Label.Case_Record_Type_Hosting);
			}

			return recordType_Hosting;
		}
		set;
	}

	@TestVisible
	public static Id recordTypeId_Hosting {
		get {
			if (recordTypeId_Hosting == null) {
				recordTypeId_Hosting = recordType_Hosting.getRecordTypeId();
			}

			return recordTypeId_Hosting;
		}
		private set;
	}
}