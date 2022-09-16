public class IncidentCreateCase {
	@TestVisible private static Integer MAXIMUM_CUSTOMERS_IMPACTED = 5000;

	@TestVisible
    public Boolean hasGlobalError {
        get {
            if (hasGlobalError == null) {
                hasGlobalError = false;
            }

            return hasGlobalError;
        }
        private set;
    }

	public Integer customersImpacted {
		get {
			return accountIds.size();
		}
	}

	@TestVisible
	public Set<Id> accountIds {
		get {
			if (accountIds == null) {
				accountIds = new Set<Id>();
			}

			return accountIds;
		}
		private set;
	}

	

	@TestVisible
    private void addGlobalError(String errorMessage) {
        hasGlobalError = true;

        if (String.isNotBlank(errorMessage)) {
	        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, errorMessage));
	    }
    }

  
}