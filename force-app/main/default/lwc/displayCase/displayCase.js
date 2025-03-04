import { LightningElement, api, track, wire } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader'; //17-07-2024
import { CurrentPageReference } from 'lightning/navigation';
// import editcasegetFieldSetFieldsByFieldSetName from '@salesforce/apex/DynamicFieldSetControllerForCase.editcasegetFieldSetFieldsByFieldSetName';
import getObjectFields from '@salesforce/apex/DynamicFieldSetControllerForCase.getObjectFields';
//import getCustomSettingValues from '@salesforce/apex/DynamicFieldSetControllerForCase.getCustomSettingValues';
import getAllTypeFieldset from '@salesforce/apex/DynamicFieldSetControllerForCase.getAllTypeFieldset';
import getType from '@salesforce/apex/DynamicFieldSetControllerForCase.getType';
import getFieldSetFieldsByFieldSetName from '@salesforce/apex/DynamicFieldSetControllerForCase.getFieldSetFieldsByFieldSetName';

import casestyle from '@salesforce/resourceUrl/Casecss';
import casestyle1 from '@salesforce/resourceUrl/custom_style' //17-07-2024
export default class CaseDynamicPage extends LightningElement {
    // 17-07-2024
    renderedCallback() {

        // Loading external CSS File
        Promise.all([
            loadStyle(this, casestyle1)
        ]).then(() => { })
            .catch(error => {
                console.log(error);
            });

    }
    // 17-07-2024
    @api recordId;
    @track showSpinner = false;
    @track Sections = [];
    @track CaseInfoFields = [];
    @track SystemInfoFields = ['CreatedDate', 'LastModifiedDate'];

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
    //css=casestyle1;
    @track resultMap = {};
    @track metadataDependencies = {};
    @track submetadataDependencies = {};
    
@track previousvalue = '';
@track previousapi = '';
@track prevobj = {};
@track pv='';

@track subtypeValue = '';
@track presentKeys = '';
@track eletoRemove = [];
@track val = [];
@track dRecId='';
    
 @wire(getObjectFields, { objectName: 'Case', fieldSet_Name: 'Standard_Fields' })
wiredFields({ error, data }) {
    if (data) {
        this.formFields = data;
        console.log('d' + JSON.stringify(data));
        console.log('this.recordId.' + this.recordId);
        // editcasegetFieldSetFieldsByFieldSetName({ objectApiName: 'Case', recordid: this.recordId }).then(result => {
        //     console.log('66 result' + JSON.stringify(result));
        //     if (result != null) {
        //         console.log('72 result' + JSON.stringify(result));
        //         let tempData = [];
               
        //         result.FieldsetFields.forEach(field => {
        //             console.log('79 field' + JSON.stringify(field));
        //             let tempField = Object.assign({}, field);
        //             console.log('81 tempField' + tempField);
        //             console.log('82 tempField' + JSON.stringify(tempField));
        //             tempField['isVisible'] = field.isVisible;
        //             tempField['category'] = '';
                   
        //             // Hide fields based on the Clean_Task_Completed__c value
                    
        //             tempData.push(tempField);
        //         });

        //         this.setfullformFields = tempData;
        //         console.log('OUTPUT setformFields: ', JSON.stringify(this.setformFields));
        //         this.template.querySelector('[data-id="additionalinfo"]').classList.remove('slds-hide');
        //     } else {
        //         this.setfullformFields = [];
        //     }

        //     var fieldsetfields = this.setfullformFields;
        // });
    } else if (error) {
        console.error('Error fetching fields:', error);
    }
}


   /* @wire(getCustomSettingValues)
    wiredCustomSetting({ data, error }) {
        if (data) {
            this.fieldApiName = data.Field_Name__c;
            this.fieldValue = data.Field_Value__c;
            this.dynamicField = data.Dynamic_Fieldset__c
        } else if (error) {
            console.error(error);
        }

    } */

    @wire(CurrentPageReference)
    currentPageReference;

    connectedCallback() {
        
        // getAllTypeFieldset().then(result => {
            
        // // Iterate over each picklist value and its corresponding fields
        // for (let picklistValue in result) {
        //     if (result.hasOwnProperty(picklistValue)) {
        //         let fields = result[picklistValue];
        //         this.resultMap[picklistValue] = fields.map(field => {
        //             let tempField = Object.assign({}, field);
        //             tempField['isVisible'] = field.isVisible;
        //             tempField['category'] = '';
        //             // Uncomment if needed
        //             // tempField['total'] = '';
        //             return tempField;
        //         });
        //     }
        // }

        // console.log('this.resultMap',JSON.stringify(this.resultMap) );
        // })

        getType({ objectApiName: 'Case', recordid: this.recordId}).then(result => {
                console.log('162 result'+result);
                 this.pv=result;
                console.log('162 this.pv'+this.pv);
               
            }).then(() => {
            
        
            getFieldSetFieldsByFieldSetName({ objectApiName: 'Case', fieldsetName: this.pv }).then(result => {
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

            
        })
        })
        
       window.addEventListener("message", (message) => {
            console.log(message.origin);
            if (message.origin !== this.vfRoot) {
                //Not the expected origin
                return;
            }

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

    expandSection(event) {
        const SectionName = event.target.name;
        const sectionDiv = this.template.querySelector(`#${SectionName}`);
        if (sectionDiv) {
            sectionDiv.style.display = sectionDiv.style.display === 'none' ? 'block' : 'none';
        }
    }

    sectionOne() {
        const element = this.template.querySelector('[data-id="articleOne"]');
        if (element) {
            element.classList.toggle('slds-show');
            element.classList.toggle('slds-hide');
        }
    }

    handleSuccess(event) {
        this.dispatchEvent(new CustomEvent('navigate', {
            detail: { recordId: this.recordId }
        }));
    }
    handleTypeChange(event) {
            
            let  apiName = event.target.fieldName;
            var Picklist_Value = event.target.value;
            this.pickvaue = Picklist_Value;
            var pp = 'Case';
            console.log('OUTPUT Picklist_Value: ', Picklist_Value);
        if(apiName == 'FSA_Case_Sub_Type__c'){
    // to delete field values after changing 
            if(Picklist_Value != null){
                if (this.resultMap.hasOwnProperty(Picklist_Value)) {
        console.log('this.resultMap',JSON.stringify(this.resultMap) );

                    this.setfullformFields = this.resultMap[Picklist_Value];
                this.template.querySelector('[data-id="additionalinfo"]').classList.remove('slds-hide');
                    //added new line of code on 26-06-2024 by shubham k
                    this.pv=Picklist_Value;
                    //ended new line of code on 26-06-2024 by shubham k
                try {
                    Promise.resolve().then(() => {
                        this.setfullformFields.forEach(field => {
                            field.value = '';
                        });
                    });
                } catch (error) {
                    console.error("Error updating data => " + error);
                }
                }
                else {
                    this.template.querySelector('[data-id="additionalinfo"]').classList.add('slds-hide');
                    this.setfullformFields = [];
                }
            }
                else {
                    this.template.querySelector('[data-id="additionalinfo"]').classList.add('slds-hide');
                    this.setfullformFields = [];
                }
            
    
         
      
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


   
}