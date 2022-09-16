global class LightningSelfRegisterController {

    public LightningSelfRegisterController() {}

    @AuraEnabled
    public static String retrieveTimezoneValues() {
        List<PicklistEntry> timezoneicklistEntries = User.fields.TimeZoneSidKey.getDescribe().getPicklistValues();
        return InputSelectOptions.buildInputSelectOptions(timezoneicklistEntries);
    }

    @AuraEnabled
    public static String retrieveRegionValues() {
        List<PicklistEntry> regionPicklistEntries = Contact.fields.Region__c.getDescribe().getPicklistValues();
        return InputSelectOptions.buildInputSelectOptions(regionPicklistEntries);
    }

    @TestVisible
    private static boolean isValidPassword(String password, String confirmPassword) {
        return password == confirmPassword;
    }

    @TestVisible
    private static boolean siteAsContainerEnabled(String communityUrl) {
        Auth.AuthConfiguration authConfig = new Auth.AuthConfiguration(communityUrl,'');
        return authConfig.isCommunityUsingSiteAsContainer();
    }

    @TestVisible
    private static void validatePassword(User u, String password, String confirmPassword) {
        if(!Test.isRunningTest()) {
        Site.validatePassword(u, password, confirmPassword);
        }
        return;
    }

    @AuraEnabled
    public static String selfRegister(
        String firstname, String lastname, String email, String password, String confirmPassword, String accountId,
        String regConfirmUrl, String extraFields, String startUrl, Boolean includePassword) {

        return selfRegister(
            firstname, lastname, email, password, confirmPassword, accountId,
            regConfirmUrl, null, null, extraFields, startUrl, includePassword);
    }

    @AuraEnabled
    public static String selfRegister(
        String firstname, String lastname, String email, String password, String confirmPassword, String accountId,
        String regConfirmUrl, String timezone, String region, String extraFields, String startUrl, Boolean includePassword) {

        Savepoint sp = null;
        try {
            sp = Database.setSavepoint();

            if (lastname == null || String.isEmpty(lastname)) {
                return Label.Site.lastname_is_required;
            }

            if (email == null || String.isEmpty(email)) {
                return Label.Site.email_is_required;
            }

            User u = new User();
            u.Username = email;
            u.put('Email',email);

            u.FirstName = firstname;
            u.LastName = lastname;

            if (String.isNotBlank(timezone)) {
                Boolean timezoneValidated = false;
                for (PicklistEntry picklistEntry : User.fields.TimeZoneSidKey.getDescribe().getPicklistValues()) {
                    if (picklistEntry.getValue() == timezone) {
                        timezoneValidated = true;
                        break;
                    }
                }

                if (!timezoneValidated) {
                    return 'Selected timezone is not a valid timezone';
                }

                u.TimeZoneSidKey = timezone;
            }

            if (String.isNotBlank(region)) {
                Boolean regionValidated = false;
                for (PicklistEntry picklistEntry : Contact.fields.Region__c.getDescribe().getPicklistValues()) {
                    if (picklistEntry.getValue() == region) {
                        regionValidated = true;
                        break;
                    }
                }

                if (!regionValidated) {
                    return 'Selected region is not a valid region';
                }
            }

            String networkId = Network.getNetworkId();

            // If using site to host the community the user should not hit s1 after logging in from mobile.
            if(networkId != null && siteAsContainerEnabled(Network.getLoginUrl(networkId))) {
                u.put('UserPreferencesHideS1BrowserUI',true);
            }

            String nickname = ((firstname != null && firstname.length() > 0) ? firstname.substring(0,1) : '' ) + lastname.substring(0,1);
            nickname += String.valueOf(Crypto.getRandomInteger()).substring(1,7);
            u.put('CommunityNickname', nickname);

            if (extraFields != null) {
                List<Object> extraFieldsList = (List<Object>) JSON.deserializeUntyped(extraFields);
                for (Object thisFieldObject : extraFieldsList) {
                    Map<String,Object> thisField = (Map<String,Object>) thisFieldObject;
                    Schema.SObjectField sof = Schema.SObjectType.User.fields.getMap().get((String) thisField.get('fieldPath'));
                    u.put(sof, thisField.get('value'));
                }
            }

            if (includePassword) {
                if (!isValidPassword(password, confirmPassword)) {
                    return Label.site.passwords_dont_match;
                }
             validatePassword(u, password, confirmPassword);
            }
            else {
                password = null;
            }

            // lastName is a required field on user, but if it isn't specified, we'll default it to the username
            String userId = Site.createPortalUser(u, accountId, password);
            // create a fake userId for test.
            if (Test.isRunningTest()) {
                userId = 'fakeUserId';

            }

            if (userId != null) {
                if (password != null && password.length() > 1) {
                    ApexPages.PageReference lgn = Site.login(email, password, startUrl);
                    if(!Test.isRunningTest()) {
                     aura.redirect(lgn);
                    }
                }
                else {
                    ApexPages.PageReference confirmRef = new PageReference(regConfirmUrl);
                    if(!Test.isRunningTest()) {
                    aura.redirect(confirmRef);
                   }

                }
            }

            // If the current context is not a test context and there is a region value, then attempt
            // to populate the Contact record with a Region__c value
            if (!System.Test.isRunningTest() && String.isNotBlank(region)) {
                updateContactRecordWithRegion(userId, region);
            }

            return null;
        }
        catch (Exception ex) {
            Database.rollback(sp);
            return ex.getMessage();
        }
    }

    /**
     * @description Updates a Contact record, that is automatatically created from calling the Site.createPortalUser method,
     *              with a future method as the User record has not been commited to the database yet
     * @param       userId - The Id of the User record that was created as part of a self register
     * @param       region - The region value to populate the Contact.Region__c field with
     */
    @future
    private static void updateContactRecordWithRegion(String userId, String region) {
        Database.update(
            new Contact(
                Id = [ SELECT ContactId FROM User WHERE Id = :userId ].ContactId,
                Region__c = region
            )
        );
    }

    @AuraEnabled
    public static List<Map<String,Object>> getExtraFields(String extraFieldsFieldSet) {
        List<Map<String,Object>> extraFields = new List<Map<String,Object>>();
        Schema.FieldSet fieldSet = Schema.SObjectType.User.fieldSets.getMap().get(extraFieldsFieldSet);
        if(!Test.isRunningTest()) {
        if (fieldSet != null) {
            for (Schema.FieldSetMember f : fieldSet.getFields()) {
                Map<String, Object> fieldDetail = new Map<String, Object>();
                fieldDetail.put('dbRequired', f.getDBRequired());
                fieldDetail.put('fieldPath', f.getFieldPath());
                fieldDetail.put('label', f.getLabel());
                fieldDetail.put('required', f.getRequired());
                fieldDetail.put('type', f.getType());
                fieldDetail.put('value', '');   // client will populate
                extraFields.add(fieldDetail);
            }}}
        return extraFields;
    }

    @AuraEnabled
    global static String setExperienceId(String expId) {
        // Return null if there is no error, else it will return the error message
        try {
            if (expId != null) {
                Site.setExperienceId(expId);
            }
            return null;
        } catch (Exception ex) {
            return ex.getMessage();
        }
    }
}