global class AutocreatedRegHandler1518107744368 implements Auth.RegistrationHandler{
    global boolean canCreateUser(Auth.UserData data) {
        return false;
    }
    
    global User createUser(Id portalId, Auth.UserData data){
        return null;
    }
    
    global void updateUser(Id userId, Id portalId, Auth.UserData data){
    }
}