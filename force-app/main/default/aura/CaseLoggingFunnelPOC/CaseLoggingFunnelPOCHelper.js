({
showSpinner:function(cmp){

  cmp.set("v.IsSpinner",true);

},

 hideSpinner:function(cmp){

  cmp.set("v.IsSpinner",false);

},
    
    GetFilterdProdcuts:function(cmp, productname)
    {
       var Subbiefil = cmp.get("c.GetSubs");
    var maps = cmp.get('v.DynamicList');             
                 Subbiefil.setParams({"subsinc" : maps,
                              "product" : productname
                                     });
var opts = [];
        Subbiefil.setCallback(this, function(response) {
            var state = response.getState();

            if (state === "SUCCESS") {
              var allValues = response.getReturnValue();

                if (allValues != undefined && allValues.length > 0) {
                    opts.push({
                        class: "optionClass",
                        label: "--- None ---",
                        value: ""
                    });
                }
                for (var i = 0; i < allValues.length; i++) {
                    opts.push({
                        class: "optionClass",
                        label: allValues[i],
                        value: allValues[i]
                    });
                }
                cmp.set('v.SubList', opts);
            }
            else if (state === "ERROR") {
                alert('Error : ' + JSON.stringify(errors));
            }
        });
        $A.enqueueAction(Subbiefil);
    }
    
})