({
    doInit: function(component,event,helper){
        var MIid = component.get("v.recordId");
        helper.sendAttendeeEmailhelper(component, MIid);
        helper.getEmailTempaltes(component, event);
    },
    
    sendListEmail: function(component,event,helper){
        var MIid = component.get("v.recordId");
        var tC = component.get("v.ContactRolesList");
        var ccadd = component.get("v.views_selected");
        var bccadd = component.get("v.views_selectedBcc");
        var getSubject = component.get("v.subject");
        var getbody = component.get("v.body");
        var t =[];
        var c =[];
        var b =[];
        if(tC.length > 0){
            for(var i = 0; i < tC.length; i++){
                t.push(tC[i]);
            }
        }
        for(var k in ccadd){
            c.push(ccadd[k].Email);
        }
        for(var k in bccadd){
            b.push(bccadd[k].Email);
        }
        var action = component.get("c.sendMailMethod");
        action.setParams({
            "toAddress" : t,
            "ccAddress" : c,
            "bccAddress" : b,
            "mSubject" : getSubject,
            "mbody" : getbody,
            "MI_ID" : MIid,
            "AttachID":component.get("v.AttachIDs")
            //	"meetingId" : component.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "message": "Email has sent successfully!",
                    "type": "success"
                });
                toastEvent.fire();
            }
            else if (state === "ERROR"){
                var errors = response.getError();
              console.log('Error'+errors[0]);
            }
        });
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": "/"+MIid
        });
        urlEvent.fire();
        
        $A.enqueueAction(action);
    },
    cancelSendingEmail: function(component,event,helper){
        var MIid = component.get("v.recordId");
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": "/"+MIid
        });
        urlEvent.fire();
    },
    
   handleFilesChange: function(component, event, helper) {
        var fileName1 = component.get("v.fileName1");
        var fileName2 = component.get("v.fileName2");
        var fileName3 = component.get("v.fileName3");
        
        if (event.getSource().getLocalId()=='fileId1') {
            if(component.find("fileId1").get("v.files").length > 0){
        	fileName1 = event.getSource().get("v.files")[0]['name'];
            helper.uploadHelper(component, event);
            component.set("v.fileName1", fileName1);
            }
        }
        else if (event.getSource().getLocalId()=='fileId2') {
              if(component.find("fileId2").get("v.files").length > 0){
        	fileName2 = event.getSource().get("v.files")[0]['name'];
            helper.uploadHelper(component, event);
            component.set("v.fileName2", fileName2);
              }
        }
        else if (event.getSource().getLocalId()=='fileId3') {
               if(component.find("fileId3").get("v.files").length > 0){
        	fileName3 = event.getSource().get("v.files")[0]['name'];
            helper.uploadHelper(component, event);
            component.set("v.fileName3", fileName3);
               }
        } else {
            alert('Please Select a Valid File');
        }
    }, 
    
    handleRemoveAnchorClick : function(component, event, helper) {
        var self = this;  
        var index = event.target.id;
        helper.removeattendee(component, index);
    },
    
    loadTemplate : function(component, event, helper) {
        helper.getTemplate(component, event);
        
    },
    
     searchForLists : function(component, event, helper) {
      
        var search_string = component.find('search_string').get("v.value");
        console.log('Search String : ' + search_string);
        if(search_string != null && search_string != '') {
            var action = component.get("c.getListViews"); 
            action.setParams({'search_string': search_string});
            action.setCallback(this, function(response){
                var state = response.getState(); 
                if(state == 'SUCCESS') {
                    var views = response.getReturnValue();
                    component.set("v.views", views);
                }
                else {
                    var errors = response.getError();
                    helper.showErrorMessage(component, event, errors);    
                }
            });
            $A.enqueueAction(action);
        }
        else {
        	component.set("v.views", []);    
        }
    },
    searchForListsBcc : function(component, event, helper) {
      
        var search_stringBcc = component.find('search_stringBcc').get("v.value");
        console.log('Search String : ' + search_stringBcc);
        if(search_stringBcc != null && search_stringBcc != '') {
            var action = component.get("c.getListViewsBcc"); 
            action.setParams({'search_stringBcc': search_stringBcc});
            action.setCallback(this, function(response){
                var state = response.getState(); 
                if(state == 'SUCCESS') {
                    var views = response.getReturnValue();
                    component.set("v.viewsBcc", views);
                }
                else {
                    var errors = response.getError();
                    helper.showErrorMessage(component, event, errors);    
                }
            });
            $A.enqueueAction(action);
        }
        else {
        	component.set("v.viewsBcc", []);    
        }
    },
    removeToView: function(component, event, helper) {
        var index = event.currentTarget.dataset.index; // Get the index from the clicked button
        
        var contactRolesList = component.get("v.ContactRolesList");
        contactRolesList.splice(index, 1); // Remove the email at the specified index
        
        component.set("v.ContactRolesList", contactRolesList); // Update the modified list in the component
    },
    removeView: function (component, event) {
        var name = event.getParam("item").name;
        var views_selected = component.get("v.views_selected");
        var view_selected = event.getParam("index");
        views_selected.splice(view_selected, 1);
        component.set("v.views_selected", views_selected);
    },
    removeViewBcc: function (component, event) {
        var name = event.getParam("item").name;
        var views_selected = component.get("v.views_selectedBcc");
        var view_selected = event.getParam("index");
        views_selected.splice(view_selected, 1);
        component.set("v.views_selectedBcc", views_selected);
    },
    ToaddressFun: function(component,event,helper){
        var enteredTo = component.get("v.EnteredAddress");
        var splittedAddresses = enteredTo.split(',');
        component.set("v.Toaddresses",splittedAddresses);
    },
     selectView : function(component, event, helper) {
        var view_name = event.currentTarget.dataset.value;
        console.log('View Name : ' + view_name);
        var views_selected = component.get("v.views_selected");
        var views = component.get("v.views");
        
        for(var i = 0; i < views.length; i++) {
            if(views[i].Name == view_name) {
                var exists = false;
                for(var j = 0; j < views_selected.length; j++) {
                    if(views_selected[j].Name == view_name) {
                        exists = true;
                        break;
                    }
                }
                if(!exists) {
                    var view = views[i];
                    var view_selected = {id:view.Id, type: 'icon', Name: view.Name, label: view.Name, iconName: 'standard:', Email: view.Email };
                    views_selected.push(view_selected);
                    break;
                }
            }
        }
            
        component.set("v.views_selected", views_selected);
         //alert(JSON.stringify( component.get("v.views_selected")));
        component.set("v.views", []);
        component.find('search_string').set("v.value", null);
    },
    selectViewBcc : function(component, event, helper) {
        var view_name = event.currentTarget.dataset.value;
        console.log('View Name : ' + view_name);
        var views_selected = component.get("v.views_selectedBcc");
        var views = component.get("v.viewsBcc");
        
        for(var i = 0; i < views.length; i++) {
            if(views[i].Name == view_name) {
                var exists = false;
                for(var j = 0; j < views_selected.length; j++) {
                    if(views_selected[j].Name == view_name) {
                        exists = true;
                        break;
                    }
                }
                if(!exists) {
                    var view = views[i];
                    var view_selected = {id:view.Id, type: 'icon', Name: view.Name, label: view.Name, iconName: 'standard:', Email: view.Email };
                    views_selected.push(view_selected);
                    break;
                }
            }
        }
            
        component.set("v.views_selectedBcc", views_selected);
        component.set("v.viewsBcc", []);
        component.find('search_stringBcc').set("v.value", null);
    },
    
     preview : function(component, event, helper) {
         document.getElementById('div2').style.display = 'block';
         document.getElementById('div1').style.display = 'none';
      
    },
    unpreview : function(component, event, helper) {
         document.getElementById('div2').style.display = 'none';
         document.getElementById('div1').style.display = 'block';
       
    }
})