public with sharing class GetCurrentUserType {
    @AuraEnabled
public static String getUserType() {
    return UserInfo.getUserType();
}
}