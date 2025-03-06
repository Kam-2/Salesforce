import { LightningElement, api, wire } from 'lwc';
import {NavigationMixin} from 'lightning/navigation'
import getRelatedFilesByRecordId from '@salesforce/apex/filePreviewAndDownloadController.getRelatedFilesByRecordId'

export default class CasedisplayImage extends NavigationMixin(LightningElement) {

@api recordpage_display;
 @api recordId;
    filesList =[]
        fileLogo;

    @wire(getRelatedFilesByRecordId, {recordId: '$recordId'})
    wiredResult({data, error}){ 
        if(data){ 
            console.log(data)
            this.fileLogo=data;
            this.filesList = Object.keys(data).map(item=>({"label":data[item],
             "value": item,
             "url":`/sfc/servlet.shepherd/document/download/${item}`
            }))
            console.log(this.filesList)
            
        }
        if(error){ 
            console.log(error)
        }
    }
    previewHandler(event){
        console.log(event.target.dataset.id)
        this[NavigationMixin.Navigate]({ 
            type:'standard__namedPage',
            attributes:{ 
                pageName:'filePreview'
            },
            state:{ 
                selectedRecordId: event.target.dataset.id
            }
        })
    }
}