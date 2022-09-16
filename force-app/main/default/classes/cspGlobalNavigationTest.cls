@IsTest
class cspGlobalNavigationTest {

    @IsTest static void Navigation(){
        VisualEditor.DesignTimePageContext context = new  VisualEditor.DesignTimePageContext();
        context.entityName='Test';
        context.pageType='Data';
        
        cspGlobalNavigation csn = new cspGlobalNavigation(context);
        csn.getDefaultValue();
        csn.getValues();
    }
}