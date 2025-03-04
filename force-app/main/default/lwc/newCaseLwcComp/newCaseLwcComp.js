import { LightningElement, wire, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import getFieldSetFieldsByFieldSetName from '@salesforce/apex/DynamicFieldSetControllerForCase.getFieldSetFieldsByFieldSetName';
import getObjectFields from '@salesforce/apex/DynamicFieldSetControllerForCase.getObjectFields';
import uploadFiles from '@salesforce/apex/DynamicFieldSetControllerForCase.uploadFiles';
// import getCustomSettingValues from '@salesforce/apex/DynamicFieldSetControllerForCase.getCustomSettingValues';
// import getAllTypeFieldset from '@salesforce/apex/DynamicFieldSetControllerForCase.getAllTypeFieldset';
// import getDynamicFieldMap from '@salesforce/apex/DynamicFieldSetControllerForCase.getDynamicFieldMap';
// import getSubDynamicFieldMap from '@salesforce/apex/DynamicFieldSetControllerForCase.getSubDynamicFieldMap';
import casestyle from '@salesforce/resourceUrl/Casecss';
const MAX_FILE_SIZE = 2097152;
import Vfpageurl from '@salesforce/label/c.VFURL';

export default class NewCaseLwcComp extends NavigationMixin(LightningElement) {
    
    // vfRoot = "https://downtownpartnershipofbaltimore--cube84--c.sandbox.vf.force.com";
    @api recordId;
    @track formFields = [];
    @track setformFields = [];
    @track setfullformFields = [];
    @api pickvaue;

    @track fieldApiName;
    @track fieldValue;
    @track dynamicField;

    @track caseinfo = true;
    @track locationinfo = false;
    @api messageFromVF;

    @track hideaddinfo = false;
    @track savedFieldValues = {};
    lattitude;
    longitude;
    address;
    @track filesData = [];
    css = casestyle;
    @track resultMap = {};
    @track metadataDependencies = {};
    @track submetadataDependencies = {};
    
    @track previousvalue = '';
    @track previousapi = '';
    @track prevobj = {};

    @track subtypeValue = '';
    @track presentKeys = '';
    @track eletoRemove = [];
    @track val = [];
    @api toggleChng=false;

    label = {
        Vfpageurl,
    };
    customsettingname='CaseCustomSetting';


    @wire(getObjectFields, { objectName: 'Case', fieldSet_Name:'New Case Information'}) //New_Case_Information
    wiredFields({ error, data }) {
        if (data) {
            this.formFields = data;
            console.log('d'+JSON.stringify(data));
        } else if (error) {
            console.error('Error fetching fields:', error);
        }
    }


    connectedCallback() {
        this.toggleChng=true;
        window.addEventListener("message", (message) => {
            console.log(message.origin);
            //handle the message
            if (message.data.name === "EmbedVflwc") {

                this.messageFromVF = message.data.payload;
                console.log(this.messageFromVF);

                console.log("Message from payload: " + JSON.stringify(this.messageFromVF.lattitude));

            }
            this.lattitude = this.messageFromVF.latitude;
            this.longitude = this.messageFromVF.longitude;
            this.address = this.messageFromVF.autocompleteValue;

            console.log("Latitude:", latitude);
            console.log("Longitude:", longitude);
            console.log("Autocomplete Value:", autocompleteValue);
        });
    }



    handleTypeChange(event) {
        
        let apiName = event.target.fieldName;
        var Picklist_Value = event.target.value;
        this.pickvaue = Picklist_Value;
        var pp = 'Case';
        console.log('OUTPUT Picklist_Value: ', Picklist_Value);
        if(apiName == 'FSA_Case_Sub_Type__c'){
        // alert('value' + this.pickvaue);
        console.log('this.pickvaue: ', this.pickvaue);
        console.log('this.pickvaue: ', this.pickvaue != '');
        if((this.pickvaue != null) || (this.pickvaue != '')){

        getFieldSetFieldsByFieldSetName({ objectApiName: 'Case', fieldsetName: this.pickvaue }).then(result => {
        console.log('OUTPUT result: ', result);

            if (result != null) {
                let tempData = [];
                result.FieldsetFields.forEach(field => {
                    let tempField = Object.assign({}, field);
                    tempField['isVisible'] = field.isVisible;
                    tempField['category'] = '';
                    //tempField['total'] = '';
                    tempData.push(tempField);
                })
                this.setfullformFields = tempData;
                console.log('OUTPUT setformFields : ', JSON.stringify(this.setfullformFields));
                this.template.querySelector('[data-id="additionalinfo"]').classList.remove('slds-hide');
            }
            else {
                this.setfullformFields = [];
            }

            var fieldsetfields = this.setfullformFields;
            // Clear values after a short delay
            setTimeout(() => {
                this.setfullformFields.forEach(field => {
                    field.value = '';
                });
            }, 100);


        })
        .then(() => {
            // Clear values after setting the form fields
            this.setfullformFields.forEach(field => {
                field.value = '';
            });
        })

            .catch((error) => {
                console.log("Error updating date => " + error.body.message);
            });

        }
        else {
                this.template.querySelector('[data-id="additionalinfo"]').classList.add('slds-hide');
                this.setfullformFields = [];
        }
    }
    else if(apiName == 'FSA_Case_Type__c'){
                this.template.querySelector('[data-id="additionalinfo"]').classList.add('slds-hide');
                this.setfullformFields = [];
        }
        

    }

    handleInfoChange(event) {

    }


    validateRequiredFields() {
        // Check for required fields
        for (const field of this.setfullformFields) {
            if (field.required && field.isVisible && (field.value === null || field.value === '')) {
                return false; // Validation failed
            }
        }
        return true; // Validation passed
    }

    casessinfo() {

        event.preventDefault();
        this.template.querySelector('[data-path="caseinfo"]').classList.add('slds-is-active');
        this.template.querySelector('[data-path="locinfo"]').classList.remove('slds-is-active');
        this.template.querySelector('[data-id="caseinfo"]').classList.remove('slds-hide');
        this.template.querySelector('[data-id="locinfo"]').classList.add('slds-hide');
        this.template.querySelector('[data-path="locinfo"]').classList.add('slds-is-incomplete');
    }

    locate() {

        event.preventDefault();
        this.handleClickNext();
    }

    handleClickNext() {
        // Validation check
        const isValidationPassed = this.validateRequiredFields();

        if (isValidationPassed) {
            this.template.querySelector('[data-id="caseinfo"]').classList.add('slds-hide');
            this.template.querySelector('[data-id="locinfo"]').classList.remove('slds-hide');
            this.template.querySelector('[data-path="caseinfo"]').classList.remove('slds-is-active');
            this.template.querySelector('[data-path="caseinfo"]').classList.remove('slds-is-current');
            this.template.querySelector('[data-path="caseinfo"]').classList.add('slds-is-incomplete');
            this.template.querySelector('[data-path="locinfo"]').classList.add('slds-is-active');
            //this.template.querySelector('[data-path="locinfo"]').classList.add('slds-is-current');
            this.template.querySelector('[data-path="locinfo"]').classList.remove('slds-is-incomplete');

        } else {
            // Show an alert for validation failure
            alert('Please fill in all required fields.');
        }

    }

    handleClickBack() {

        this.template.querySelector('[data-id="caseinfo"]').classList.remove('slds-hide');
        this.template.querySelector('[data-id="locinfo"]').classList.add('slds-hide');
        this.template.querySelector('[data-path="caseinfo"]').classList.add('slds-is-active');
        this.template.querySelector('[data-path="locinfo"]').classList.remove('slds-is-active');
        this.template.querySelector('[data-path="locinfo"]').classList.add('slds-is-incomplete');
    }

    toggleSection(event) {
     
         if(this.toggleChng==true)
         {
             console.log('this.toggleChng If'+this.toggleChng);
            this.toggleChng=false;
         }
         else
         {
             console.log('this.toggleChng else'+this.toggleChng);
             this.toggleChng=true;
         }
    }
    
    toggleSection1(event) {
        console.log(' event.currentTarget.dataset.buttonid'+ event.currentTarget.dataset.buttonid);
        let buttonid = event.currentTarget.dataset.buttonid;
        console.log('buttonid'+buttonid);
        let currentsection = this.template.querySelector('[data-id="' + buttonid + '"]');
        console.log('currentsection'+currentsection);
        if (currentsection.className.search('slds-is-open') == -1) {
            console.log('currentsection'+currentsection);
            currentsection.className = 'slds-section slds-is-open';
            this.template.querySelector('[data-id="publicinfo"]').classList.remove('slds-hide');
        } else {
            console.log('currentsection'+currentsection);
            currentsection.className = 'slds-section slds-is-close';
            this.template.querySelector('[data-id="publicinfo"]').classList.add('slds-hide');
        }
    }

    handleFileUploaded(event) {

        if (event.target.files.length > 0) {
            for (var i = 0; i < event.target.files.length; i++) {
                if (event.target.files[i].size > MAX_FILE_SIZE) {
                    this.showToast('Error!', 'error', 'File size exceeded the upload size limit.');
                    return;
                }
                let file = event.target.files[i];
                let reader = new FileReader();
                reader.onload = e => {
                    var fileContents = reader.result.split(',')[1]
                    this.filesData.push({ 'fileName': file.name, 'fileContent': fileContents });
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


    handlebacktolist() {

        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'Case', 
                actionName: 'list',
            },
        });
        setTimeout(() => {
    console.log('refresh');
    window.location.reload();
}, 1000);
    }

    removeReceiptImage(event) {

        var index = event.currentTarget.dataset.id;
        this.filesData.splice(index, 1);
    }

    onSubmitHandler(event) {
        event.preventDefault();
        const inputFields = this.template.querySelectorAll('lightning-input-field');

        inputFields.forEach(field => {
            const fieldName = field.fieldName;
            const value = field.value;

            // Now you can save these values to a data property or an array for later use
            // For example, you can save them to an object:
            this.savedFieldValues[fieldName] = value;
        });
        // Get data from submitted form
        const fields = event.detail.fields;
        // Here you can execute any logic before submit
        // and set or modify existing fields
        var latitude;
        var longitude;
        var decimallat;
        var decimallong;
        var addreslocation;

        if (this.lattitude !== undefined) {
            latitude = this.lattitude;
            longitude = this.longitude;
            decimallat = latitude.toString();
            decimallong = longitude.toString();
            addreslocation = this.address;
        }
        if (decimallat !== undefined) {
            fields.Latitude_District360__c = decimallat;
            fields.Longitude_District360__c = decimallong;
            fields.Address_District360__c = addreslocation;
        }
        // You need to submit the form after modifications
        this.template
            .querySelector('lightning-record-edit-form').submit(fields);

    }


    handleSuccess(event) {

        const recordId = event.detail.id;

        if (this.filesData.length !== 0) {
            if (this.filesData == [] || this.filesData.length == 0) {
                this.showToast('Error', 'error', 'Please select atleat one file'); return;
            }
            this.showSpinner = true;
            uploadFiles({
                recordId: recordId,
                filedata: JSON.stringify(this.filesData)
            })
                .then(result => {
                    console.log(result);
                    if (result && result == 'success') {
                        this.filesData = [];
                        this.showToast('Success', 'success', 'Files Uploaded successfully.');
                    } else {
                        this.showToast('Error', 'error', result);
                    }
                }).catch(error => {
                    if (error && error.body && error.body.message) {
                        this.showToast('Error', 'error', error.body.message);
                    }
                }).finally(() => this.showSpinner = false);
        }
        const toastEvent = new ShowToastEvent({
            title: 'Success',
            message: 'Case Created Successfully',
            variant: 'success'
        });
        this.dispatchEvent(toastEvent);
                console.log('Navigating to record:', recordId);

        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: recordId,
                objectApiName: 'Case', 
                actionName: 'view',
            },
        });
        setTimeout(() => {
    console.log('refresh');
    window.location.reload();
}, 1000);
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