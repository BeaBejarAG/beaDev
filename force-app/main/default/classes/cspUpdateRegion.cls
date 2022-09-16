global class cspUpdateRegion implements Database.Batchable<sObject>, Database.Stateful {
    // Boolean to designate if operation is to be carried out
    // True = Run Operation; False = Skip Operation
    global Boolean runOperation;

    // Totals
    global Integer total = 0;
    global Integer totalSuccess = 0;
    global Integer totalFail = 0;
    global Integer totalOceania = 0;
    global Integer totalEurope = 0;

    public static final String REGION_OCEANIA = 'Oceania';
    public static final String REGION_EUROPE = 'Europe';

    /**
     * Default Constructor
     */
    global cspUpdateRegion() {
        this.runOperation = true;
    }

    /**
     * Constructor to set parameters
     * @param   runOperation    Boolean to decide if operation should occur    
     */
    global cspUpdateRegion(Boolean runOperation) {
        this.runOperation = runOperation;
    }

    /**
     * {@inheritDoc}
     */
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator([
            SELECT  Account.Access_Centre__c, Region__c
            FROM    Contact
        ]);
    }

    /**
     * {@inheritDoc}
     */
    global void execute(Database.BatchableContext BC, List<Contact> scope) {
        List<Contact> contactsToUpdate = new List<Contact>();
        for(Contact con : scope) {

            if(String.isNotBlank(con.Account.Access_Centre__c)) {
                con.Region__c = REGION_OCEANIA;
                totalOceania++;
            } else {
                con.Region__c = REGION_EUROPE;
                totalEurope++;
            }
            
            contactsToUpdate.add(con);
            total++; 
        }

        if(runOperation) {
            // Update with all or nothing = false (we can also get the totals from here)
            List<Database.SaveResult> updateResult =  Database.update(contactsToUpdate, false);
            for (Database.SaveResult res : updateResult) {
                if (!res.isSuccess()) {
                    totalFail++;
                } else {
                    totalSuccess++;
                }
            }
        }
    }

    /**
     * {@inheritDoc}
     */
    global void finish(Database.BatchableContext BC) {
        System.debug(
            String.format(
                '{0} total records processed (Oceania: {1}, Europe: {2}). Operation {3} with {4} successes and {5} failures .',
                new List<String> {
                    String.valueOf(total),
                    String.valueOf(totalOceania),
                    String.valueOf(totalEurope),
                    (runOperation ? 'ran' : 'skipped'),
                    (runOperation ? String.valueOf(totalSuccess) : '0'),
                    (runOperation ? String.valueOf(totalFail): '0')
                }
            )
        );
    }
}