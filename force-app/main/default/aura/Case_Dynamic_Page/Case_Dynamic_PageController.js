({
    doInit : function(component, event, helper) {
        // Get the Field Member - Just Incident 
        var action = component.get("c.getFieldSetMember");
        
        action.setParams({"objectName":"Case","ThisCaseId": component.get("v.recordId")});
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var fieldSetMember = JSON.parse(response.getReturnValue());
                 //alert(JSON.stringify(fieldSetMember));
                var ListOfFields = [];
                
                for(var i in fieldSetMember){
                    ListOfFields.push({value:fieldSetMember[i], key:i});
                    // alert(JSON.stringify(fieldSetMember[i]));
                    // ListOfFields.push(fieldSetMember[i].fieldPath);
                    console.log('ListOfFields-->'+JSON.stringify(ListOfFields));
                }
                //   alert(JSON.stringify(ListOfFields));
                // component.set("v.sectionFields",ListOfFields);
                component.set("v.Sections",ListOfFields);
                
            }
            else if (state === "INCOMPLETE") {
            }
                else if (state === "ERROR") {
                    var errors = response.getError();
                    helper.showErrorMessage(component, event, errors); 
                }
        });
        $A.enqueueAction(action);
        var action1 = component.get("c.getInfoFields");
        
        action1.setParams({PageLayoutName:"Case-App layout","ThisCaseId1": component.get("v.recordId")});
        action1.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                /*alert(response.getReturnValue());
                var RetrievedFields = response.getReturnValue();
                if(RetrievedFields.length  % 2 != 0) {
                
                    RetrievedFields.push('Empty');
                        alert(RetrievedFields);
                }*/
                component.set("v.CaseInfoFields",response.getReturnValue());
            }
            else if (state === "INCOMPLETE") {
            }
                else if (state === "ERROR") {
                    var errors = response.getError();
                    helper.showErrorMessage(component, event, errors); 
                }
        });
        $A.enqueueAction(action1);
    },
    expandSection :function(component,event,helper){
        //alert(event.target.name);
        var SectionName = event.target.name;
        //    alert(SectionName);
        try{
            var ExpandableDiv =  document.getElementById(SectionName);
            // document.getElementById(SectionName).classList.remove('slds-is-open');
            // slds-section slds-is-open' : 'slds-section';
            // alert(ExpandableDiv.style.display);
            ExpandableDiv.style.display=ExpandableDiv.style.display=='none'?'block':'none';
            if( ExpandableDiv.style.display=='block')
                component.find(SectionName+"Icon").set("v.iconName","utility:switch");
            else
                component.find(SectionName+"Icon").set("v.iconName","utility:chevronright");
        }catch(err){
            console.log(err);
            helper.showErrorMessage(component, event, err); 
        }
    },
    sectionOne : function(component, event, helper) {
       helper.helperFun(component,event,'articleOne');
    },
    
    Reload : function(component,event,helper){
        
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": component.get("v.recordId")
            
        });
        navEvt.fire();
    },
    handleError: function(component, event) {
        alert('Please fill all the mandatory fields');
        //alert('Please Fill the all following necessery Fields'+'\n' +'1.Reporter Department,2.Reporter Report Manager,3.Case Origin,4.Reporter Name,5.Reporter Report Supervisor,6.Reporter Action');
        
        //console.log(event);
        //var errors = event.getParams();
        //console.log("Error Response", JSON.stringify(errors));
    },
    handleSubmit: function(component, event, helper) {
      //  var inputcmp = component.find("myRecordForm");
     //   alert(inputcmp);
      //  var value = inputcmp.getvalue("v.Sections");
      //  inputcmp.setCustomValidity('Please fill all required fields');
      
        
        
     /*   var action = component.get("Sections");
        action.setCallback(this,function(a){
            var state = a.getState();
            alert(state);
            if(state === "SUCCESS"){
                alert('Record is Created Successfully');
            } else if(state === "ERROR"){
                var errors = action.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        alert(errors[0].message);
                    }
                }
            }else if (status === "INCOMPLETE") {
                alert('No response from server or client is offline.');
            }
        });       
        $A.enqueueAction(action); */
    }
})