public class InputSelectOptions {

    public static String buildInputSelectOptions(List<PicklistEntry> picklistEntries) {
        List<Option> options = new List<Option>();

        for (PicklistEntry picklistEntry : picklistEntries) {
            if (picklistEntry.isActive()) {
                options.add(new Option(picklistEntry.getLabel(), picklistEntry.getValue(), picklistEntry.isDefaultValue()));
            }
        }

        return JSON.serialize(options).replace('styleClass', 'class');
    }

    public class Option {
        @AuraEnabled
        public String styleClass = 'optionClass';

        @AuraEnabled
        public String label;

        @AuraEnabled
        public String value;

        @AuraEnabled
        public Boolean selected;

        public Option(String label, String value, Boolean selected) {
            this.label = label;
            this.value = value;
            this.selected = selected;
        }
    }
}