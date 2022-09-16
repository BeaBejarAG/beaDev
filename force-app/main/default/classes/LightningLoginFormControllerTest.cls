@IsTest
class LightningLoginFormControllerTest {

@IsTest static void LoginTest(){
    LightningLoginFormController.login('Bob@Bob.com','Password1234','www.google.com');

    LightningLoginFormController.getIsUsernamePasswordEnabled();

    LightningLoginFormController.getIsSelfRegistrationEnabled();

    LightningLoginFormController.getSelfRegistrationUrl();

    LightningLoginFormController.getForgotPasswordUrl();

    LightningLoginFormController.getAuthConfig();

    LightningLoginFormController.setExperienceId('7');
}

}