import { LightningElement,api,wire,track} from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';	
import { NavigationMixin } from 'lightning/navigation';
import casestyle from '@salesforce/resourceUrl/Casecss';
import uploadFiles from '@salesforce/apex/DynamicFieldSetController.uploadFiles'
import getObjectFields from '@salesforce/apex/DynamicFieldSetController.getObjectFields';
import Vfpageurl from '@salesforce/label/c.VFURL';


const MAX_FILE_SIZE = 20097152;
export default class DynamicFieldSet extends NavigationMixin(LightningElement) {



@api recordId;
@api objectName;
@api caserecid;
    formFields = [];
    boolVisible = false;
    caseinfo= true;
    locationinfo =false;
    savedFieldValues = {}; 
    latitude;
    lattitude;
    longitude;
    address;
    file;
    fileData;
    fileData1;
    fileData2;
    @api messageFromVF;
    @track filesData = [];
    filesData2 = [];
    css=casestyle;
    customsettingname='CaseCustomSetting';
    sfdcBaseURL;
    a_Record_URL;
    fullvfurl;
    allurl;
    a_Record_URLs;
    activeSections = ['A', 'C'];
    activeSectionsMessage = '';

label = {
        Vfpageurl,
    };



@wire(getObjectFields, { objectName: 'Case', fieldSetName:'$customsettingname'})
wiredFields({ error, data }) {
    if (data) {
        this.formFields = data;
        console.log('d'+JSON.stringify(data));
    } else if (error) {
        console.error('Error fetching fields:', error);
    }
}


renderedCallback() {
        this.sfdcBaseURL = window.location.origin;
        console.log(this.sfdcBaseURL);
    }


connectedCallback() {
window.addEventListener("message", (message) => {
        console.log('origin'+message.origin);
        
        //handle the message
        if (message.data.name === "EmbedVflwc") {
            
            this.messageFromVF = message.data.payload;
            //console.log('ass'+this.messageFromVF);
            
            //console.log("Message from payload: " + JSON.stringify(this.messageFromVF.latitude));

       }
        this.lattitude = this.messageFromVF.latitude;
        this.longitude= this.messageFromVF.longitude;
        this.address= this.messageFromVF.autocompleteValue;
        //console.log("Latitude:", latitude);
        //console.log("Longitude:", longitude);
        //console.log("Autocomplete Value:", autocompleteValue);
    });
    

}

// Handle accordion section
handleSectionToggle(event) {
        const openSections = event.detail.openSections;

        if (openSections.length === 0) {
            this.activeSectionsMessage = 'All sections are closed';
        } else {
            this.activeSectionsMessage =
                'Open sections: ' + openSections.join(', ');
        }
}

openfileUpload(event) {
    const file = event.target.files[0]
    var reader = new FileReader()
    reader.onload = () => {
        var base64 = reader.result.split(',')[1]
        this.fileData = {
            'filename': file.name,
            'base64': base64,
            
        }
        console.log('files'+this.fileData)
    }
    reader.readAsDataURL(file)
}

// To upload attachment in File section
handleFileUploaded(event) {
        if (event.target.files.length > 0) {
            for(var i=0; i< event.target.files.length; i++){
                if (event.target.files[i].size > MAX_FILE_SIZE) {
                    this.showToast('Error!', 'error', 'File size exceeded the upload size limit.');
                    return;
                }
                let file = event.target.files[i];
                let reader = new FileReader();
                reader.onload = e => {
                    var fileContents = reader.result.split(',')[1]
                    this.filesData.push({'fileName':file.name, 'fileContent':fileContents});
                };
                reader.readAsDataURL(file);
            }
        }
    }



showNotification(message, variant) {
    const evt = new ShowToastEvent({
        'message': message,
        'variant': variant
    });
    this.dispatchEvent(evt);
}


// To hide/show case information
casessinfo(){
    event.preventDefault();
    this.template.querySelector('[data-path="caseinfo"]').classList.add('slds-is-active');
    this.template.querySelector('[data-path="locinfo"]').classList.remove('slds-is-active')
    this.template.querySelector('[data-id="caseinfo"]').classList.remove('slds-hide');
    this.template.querySelector('[data-id="locinfo"]').classList.add('slds-hide');
    this.template.querySelector('[data-path="locinfo"]').classList.add('slds-is-incomplete');
}

// To hide/show location information
locate(){
    event.preventDefault();
    this.handleClickNext();     
}

// To move to location section
handleClickNext(){
    this.template.querySelector('[data-id="caseinfo"]').classList.add('slds-hide');
    this.template.querySelector('[data-id="caseinfo"]').classList.add('slds-is-complete');
    this.template.querySelector('[data-id="locinfo"]').classList.remove('slds-hide');
    this.template.querySelector('[data-path="caseinfo"]').classList.remove('slds-is-active');
    this.template.querySelector('[data-path="caseinfo"]').classList.remove('slds-is-current');
    this.template.querySelector('[data-path="caseinfo"]').classList.add('slds-is-incomplete');
    this.template.querySelector('[data-path="locinfo"]').classList.add('slds-is-active');
    //this.template.querySelector('[data-path="locinfo"]').classList.add('slds-is-current');
    this.template.querySelector('[data-path="locinfo"]').classList.remove('slds-is-incomplete');
}

// To hide/show location section
handleClickBack(){

    this.template.querySelector('[data-id="caseinfo"]').classList.remove('slds-hide');
    this.template.querySelector('[data-id="locinfo"]').classList.add('slds-hide');
    this.template.querySelector('[data-path="caseinfo"]').classList.add('slds-is-active');
    this.template.querySelector('[data-path="locinfo"]').classList.remove('slds-is-active');
     this.template.querySelector('[data-path="locinfo"]').classList.add('slds-is-incomplete');
}


// Button to  Go back to list view
handlebacktolist(){
    const filterName = 'Recent';
        const url = `/lightning/o/Case/list?filterName=${filterName}`;
        

this[NavigationMixin.Navigate]({
       type: 'standard__objectPage',
        attributes: {
            objectApiName: 'case', // Replace with the API name of the object
            actionName: 'list',
        },
        state: {       
        filterName: 'Recent' 
    }
    });
}

// Removes the uploaded file
removeReceiptImage(event) {
        var index = event.currentTarget.dataset.id;
        this.filesData.splice(index, 1);
    }

// Submit to save public asset record and attachments
onSubmitHandler(event) {

   event.preventDefault();
   const inputFields = this.template.querySelectorAll('lightning-input-field');

   inputFields.forEach(field => {
        const fieldName = field.fieldName;
    const value = field.value;
    
    // Now you can save these values to a data property or an array for later use

    this.savedFieldValues[fieldName] = value;
});
// Get data from submitted form
const fields = event.detail.fields;
console.log('js'+fields.Case_Type__c);

  var latitude;
  var longitude ;
  var decimallat;
  var decimallong;
  var addreslocation;
  
    if(this.lattitude!== undefined){
        
    console.log('lat'+this.lattitude);
    latitude = this.lattitude;
    longitude = this.longitude;
    decimallat = latitude.toString();
    decimallong =longitude.toString();
    addreslocation=this.address;
 } 
   if(decimallat!== undefined){
     fields.latitude_District360__c=decimallat;
     fields.longitude_District360__c=decimallong;
     fields.Address_District360__c=addreslocation;
}
// You need to submit the form after modifications
this.template
    .querySelector('lightning-record-edit-form').submit(fields);
    
}


// Success event to upload file and redirect to detail page
handleSuccess(event) {
    const recordId = event.detail.id;
console.log('data'+this.filesData);
if(this.filesData.length !== 0){
    
if(this.filesData == [] || this.filesData.length == 0) {
            this.showToast('Error', 'error', 'Please select atleat one file'); return;
        }
        this.showSpinner = true;
        uploadFiles({
            recordId :recordId,
            filedata : JSON.stringify(this.filesData)
        })
        .then(result => {
            console.log(result);
            if(result && result == 'success') {
                this.filesData = [];
                this.showToast('Success', 'success', 'Files Uploaded successfully.');
            } else {
                this.showToast('Error', 'error', result);
            }
        }).catch(error => {
            if(error && error.body && error.body.message) {
                this.showToast('Error', 'error', error.body.message);
            }
        }).finally(() => this.showSpinner = false );
}
    const toastEvent = new ShowToastEvent({
        title: 'Success',
        message: 'Case Created Successfully',
        variant: 'success'
    });
    this.dispatchEvent(toastEvent);

    this[NavigationMixin.Navigate]({
        type: 'standard__recordPage',
        attributes: {
            recordId: recordId,
            objectApiName: 'Case', 
            actionName: 'view',
        },
    });
}

showToast(title, variant, message) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: title,
                variant: variant,
                message: message,
            })
        );
    }

}