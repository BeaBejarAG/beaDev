public with sharing class cspGlobalNavigation extends VisualEditor.DynamicPickList {
    VisualEditor.DesignTimePageContext context;
    String defaultVal = '-- none --';

    public cspGlobalNavigation(VisualEditor.DesignTimePageContext context) {
       this.context = context;
        System.debug(context);
    }

    public override VisualEditor.DataRow getDefaultValue(){
        VisualEditor.DataRow defaultValue = new VisualEditor.DataRow(
            defaultVal, 
            defaultVal
        );
        return defaultValue;
    }

    public override VisualEditor.DynamicPickListRows getValues() {
        VisualEditor.DynamicPickListRows lookupsList = new VisualEditor.DynamicPickListRows();

        String networkName;
        if (Network.getNetworkId() != null) {
            networkName = [SELECT Id, UrlPathPrefix FROM Network WHERE Id = :Network.getNetworkId()].UrlPathPrefix;
        } else {
            // Default to 'Support' if we can't retrieve the community name
            networkName = 'Support';
        }

        Map<String, String> stringMap = new Map<String, String>();
        for(NavigationLinkSet link: [
            SELECT MasterLabel, DeveloperName
            FROM NavigationLinkSet 
            WHERE Network.Name = :networkName
        ]) {
            VisualEditor.DataRow value = new VisualEditor.DataRow(
                link.MasterLabel, 
                link.DeveloperName
            );
            lookupsList.addRow(value);
        }
        
        return lookupsList;
    }
}