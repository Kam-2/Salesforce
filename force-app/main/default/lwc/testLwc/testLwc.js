import { LightningElement, api ,wire} from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { CurrentPageReference } from 'lightning/navigation';

export default class TestLwc extends NavigationMixin(LightningElement) {

@api recordId;
iframeLoaded = false;
message="";

lattitude;
     longitude;
     address;
      @api messageFromVF;
vfRoot = "https://cube84148-dev-ed--c.develop.vf.force.com";


handlebacktolist(){
alert('tes');
    this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'Case', // Replace with the API name of the object
                actionName: 'list',
            },
        });
}
handleIframeLoad(){
    try {
                this.iframeLoaded = true;

       var iframeElement = this.template.querySelector("iframe");
        console.log('iframeElement'+iframeElement);
        alert('test');
        if (iframeElement) {
           const rec=this.recordId;
            const vfWindow = iframeElement.contentWindow;
            if (vfWindow) {
                vfWindow.postMessage(rec, this.vfRoot);
            } else {
                console.error("iframe contentWindow is null.");
            }
        } else {
            console.error("iframe element not found.");
        }
    } catch (error) {
        console.error("An error occurred:", error);
    }
}

 connectedCallback() {
     alert('com');
    window.addEventListener("message", (message) => {
        alert('receving');
            console.log(message.origin);
            if (message.origin !== this.vfRoot) {
                //Not the expected origin
                return;
            }

            //handle the message
            if (message.data.name === "EmbedVflwc") {
                //alert('test');
                this.messageFromVF = message.data.payload;
                console.log(this.messageFromVF);
                //alert(this.messageFromVF);
                console.log("Message from payload: " + JSON.stringify(this.messageFromVF.lattitude));

            }
            this.lattitude = this.messageFromVF.latitude;
this.longitude= this.messageFromVF.longitude;
this.address= this.messageFromVF.autocompleteValue;

console.log("Latitude:", latitude);
console.log("Longitude:", longitude);
console.log("Autocomplete Value:", autocompleteValue);
        });
       
   //code
}

       
onSubmitHandler(event) {

        //alert('six');
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
    //alert(fields);
    console.log('js'+fields.Case_Type__c);
    // Here you can execute any logic before submit
    // and set or modify existing fields
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
    //=this.inputFieldValue;
    //fields.Case_Type__c='Incident';
    //fields.Status='Working';
    //fields.Priority='Medium';
   // alert(decimallat);

    if(decimallat!== undefined){
    fields.latitude_District360__c=decimallat;
    
    
    fields.longitude_District360__c=decimallong;
    
    
    fields.Address_District360__c=addreslocation;
    }
    

   
    // You need to submit the form after modifications
    this.template
        .querySelector('lightning-record-edit-form').submit(fields);
       
}
handleSuccess(event) {
               const recordId = event.detail.id;

       const toastEvent = new ShowToastEvent({
            title: 'Success',
            message: 'Case Created successfully',
            variant: 'success'
        });
        this.dispatchEvent(toastEvent);

        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: recordId,
                objectApiName: 'Case', // Replace with your object's API name
                actionName: 'view',
            },
        });
    }
}