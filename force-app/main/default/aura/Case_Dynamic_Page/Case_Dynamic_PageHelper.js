({
    showErrorMessage : function(component, event, errors) {
        var message = '';
        if(errors && Array.isArray(errors) && errors.length > 0) {
            for (var i = 0; i < errors.length; i++) { 
                message = message + 'Error' + (i + 1) + ':' + errors[i].message;
            }
        }
        
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": "Error!",
            "message": message,
            "type": "error"
        });
        toastEvent.fire();
    },
    helperFun : function(component,event,secId) {
	  var acc = component.find(secId);
        	for(var cmp in acc) {
        	$A.util.toggleClass(acc[cmp], 'slds-show');  
        	$A.util.toggleClass(acc[cmp], 'slds-hide');  
       }
	},
})