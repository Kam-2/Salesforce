({
    sendHelper: function(component, getEmail,getccAddr,getbccAddr, getSubject, getbody,MIid) {
        var action = component.get("c.sendMailMethod");
        action.setParams({
            'toAddress': getEmail, 
            'ccAddress' : getccAddr,
            'bccAddress' : getbccAddr,
            'mSubject': getSubject,
            'mbody': getbody,
            'MI_ID' : MIid
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                component.set("v.mailStatus", true);
            }
        });
        $A.enqueueAction(action);
    },
    
    sendAttendeeEmailhelper: function(component, MIid) {
        var getListEmail = component.get("c.sendMailMethodCommitteeMembers");
        var MIid = component.get("v.recordId");
        // alert(meetingid);
        getListEmail.setParams({
            'CommitteeID' : MIid
        });
        getListEmail.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                component.set("v.ContactRolesList", storeResponse);
            }
        });
        $A.enqueueAction(getListEmail);
    },
    
    MAX_FILE_SIZE: 4500000, //Max file size 4.5 MB 
    CHUNK_SIZE: 750000,      //Chunk Max size 750Kb 
    
    uploadHelper: function(component, event) {
        // start/show the loading spinner   
        //component.set("v.showLoadingSpinner", true);
        // get the selected files using aura:id [return array of files]
        //var fileInput = component.find("fileId").get("v.files");
        var fileInput = event.getSource().get("v.files");
        // get the first file using array index[0]  
        var file = fileInput[0];
        var self = this;
        // check the selected file size, if select file size greter then MAX_FILE_SIZE,
        // then show a alert msg to user,hide the loading spinner and return from function  
        if (file.size > self.MAX_FILE_SIZE) {
            component.set("v.showLoadingSpinner", false);
            component.set("v.fileName", 'Alert : Your file is larger than 5MB');
            //component.set("v.fileName", 'Alert : File size cannot exceed ' + self.MAX_FILE_SIZE + ' bytes.\n' + ' Selected file size: ' + file.size);
            return;
        }
        // create a FileReader object 
        var objFileReader = new FileReader();
        // set onload function of FileReader object   
        objFileReader.onload = $A.getCallback(function() {
            var fileContents = objFileReader.result;
            var base64 = 'base64,';
            var dataStart = fileContents.indexOf(base64) + base64.length;
            fileContents = fileContents.substring(dataStart);
            // call the uploadProcess method 
            self.uploadProcess(component, file, fileContents); 
        });
        objFileReader.readAsDataURL(file);
    },
    
    uploadProcess: function(component, file, fileContents) {
        // set a default size or startpostiton as 0 
        var startPosition = 0;
        // calculate the end size or endPostion using Math.min() function which is return the min. value   
        var endPosition = Math.min(fileContents.length, startPosition + this.CHUNK_SIZE);
        // start with the initial chunk, and set the attachId(last parameter)is null in begin
        this.uploadInChunk(component, file, fileContents, startPosition, endPosition, '');
    },
    
    uploadInChunk: function(component, file, fileContents, startPosition, endPosition, attachId) {
        // call the apex method 'saveChunk'
        var getchunk = fileContents.substring(startPosition, endPosition);
        var action = component.get("c.saveChunk");
        // var getListEmail1 = component.get("c.sendMailMethodAttendees");
        var ParentId = component.get("v.recordId"); 
        console.log('ParentId'+ParentId);
        action.setParams({
            parentId: ParentId,
            fileName: file.name,
            base64Data: encodeURIComponent(getchunk),
            contentType: file.type,
            fileId: attachId
        });
        // set call back 
        //   alert('Test');
        action.setCallback(this, function(response) {
            // store the response / Attachment Id   
            //  alert('Test');
             var AttachIDsList = component.get("v.AttachIDs");
            attachId = response.getReturnValue();
            console.log('Attachment'+attachId);
            // alert(attachId);
            component.set("v.ThisAttachmentID",attachId);
            AttachIDsList.push(attachId);
            component.set("v.AttachIDs",AttachIDsList);
            var state = response.getState();
            // alert(state);
            if (state === "SUCCESS") {
                // update the start position with end postion
                startPosition = endPosition;
                endPosition = Math.min(fileContents.length, startPosition + this.CHUNK_SIZE);
                // alert(startPosition);
                // check if the start postion is still less then end postion 
                // then call again 'uploadInChunk' method , 
                // else, diaply alert msg and hide the loading spinner
                if (startPosition < endPosition) {
                    this.uploadInChunk(component, file, fileContents, startPosition, endPosition, attachId);
                } else {
                    alert('File successfully uploaded!');
                    component.set("v.showLoadingSpinner", false);
                }
                // handel the response errors        
            } else if (state === "INCOMPLETE") {
                alert("From server: " + response.getReturnValue());
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + errors[0].message);
                        alert('Error');
                    }
                } else {
                    console.log("Unknown error");
                    alert('Error');
                }
            }
        });
        // enqueue the action
        $A.enqueueAction(action);
    },
    /* When remove an attendee from the list */
    removeattendee : function(component, index) {
        var attend = component.get("v.ContactRolesList");
        attend.splice(index, 1);
        component.set("v.ContactRolesList", attend);
    },
    getEmailTempaltes : function(component, event) {
        var action = component.get("c.getTemplates");
        //action.setParams({"divisionId":selectedDivision});
        
        action.setCallback(this,function(response){
            var loadResponse = response.getReturnValue();
            console.log('templates..!',loadResponse);
            
            if(!$A.util.isEmpty(loadResponse)){
                
                component.set('v.templates',loadResponse);
                
            }
        });
        $A.enqueueAction(action);
    },
    
    getTemplate : function(component, event) {
        
        var templId = component.get("v.selTempl");
        component.set("v.showLoader", true);
        if(!$A.util.isEmpty(templId)){
            
            var action = component.get("c.getTemplateDetails");
            action.setParams({"templteId":templId});
            
            action.setCallback(this,function(response){
                component.set("v.showLoader", false);
                var responseVal = response.getReturnValue();
                console.log('responseVal..@getTemplate ',responseVal);
                
                if(!$A.util.isEmpty(responseVal)){
                    
                    component.set("v.templDetail",responseVal);
                    if(!$A.util.isEmpty(responseVal.Subject)){
                    	component.set("v.subject",responseVal.Subject);
                    }
                    //alert(JSON.stringify(responseVal));
                    if(!$A.util.isEmpty(responseVal.Body)){
                        responseVal.Body = responseVal.Body.replace(/\n/g, "<br />");
                        component.set("v.body",responseVal.Body);
                        if(!$A.util.hasClass(component.find("emailBodyDiv"), "slds-hide")){
                            
                            $A.util.addClass(component.find("emailBodyDiv"), 'slds-hide'); 
                        }
                    }
                }
                
            });
            $A.enqueueAction(action);
        }
        else {
            component.set("v.showLoader", true);
            component.set("v.subject","");
            component.set("v.body","");
            if($A.util.hasClass(component.find("emailBodyDiv"), "slds-hide")){
                
                $A.util.removeClass(component.find("emailBodyDiv"), 'slds-hide');
            }
        }
    },
})