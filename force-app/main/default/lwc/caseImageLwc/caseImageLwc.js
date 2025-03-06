import { LightningElement, api ,wire} from 'lwc';
import getAttachedPhotos from '@salesforce/apex/CaseImagecontroller.getAttachedPhotos';

export default class CaseImageLwc extends LightningElement {


@api recordId;

@wire(getAttachedPhotos, { caseId: '$recordId' })

attachedPhotos;

getAttachmentUrl(contentDocumentId) {
    console.log('contentDocumentId'+contentDocumentId);
        return `/sfc/servlet.shepherd/version/download/${contentDocumentId}`;
    }
    getFormattedPhotos() {
        console.log('this.attachedPhotos'+this.attachedPhotos.data);
        if (this.attachedPhotos.data) {
            return this.attachedPhotos.data.map(photo => ({
                id: photo.Id,
                url: this.getAttachmentUrl(photo.ContentDocumentId)
            }));
        }
        return [];
    }
     /*getAttachmentUrls() {
        return this.attachments.data.map(attachment => {
            return this.getAttachmentUrl(attachment.Id);
        });
    }*/
}