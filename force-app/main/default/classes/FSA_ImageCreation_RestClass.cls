/**************************************************************************************
* Class Name			: FSA_ImageCreation_RestClass
* Created Date			: 09/07/2024
* Created By			: Senthilnathan R
* Class Description	    : Custom API class for uploading images while create a case.	
* Last modified by		: 
***************************************************************************************/
@RestResource(urlMapping='/images/*')
global with sharing class FSA_ImageCreation_RestClass {
    
     @HttpPost
    global static createResponse createImage(String ccId, String reqBody) {
        createResponse objResponse = new createResponse();
        RestRequest request = RestContext.request;
        String str = request.requestBody.toString();
        String caseId = '';
        //caseId = RestContext.request.params.get('id');
        caseId = ccId;
        system.debug('@@@@-->Created CASE Id ='+caseId);
        
        //For Image data 
        List<ContentVersion> lstConVerToInsert = new List<ContentVersion>();
        List<ContentDocumentLink> lstCntDocLnkToInsert = new List<ContentDocumentLink>();
            
            
        FSA_CloseCaseResponseWrapper objWrapper = new FSA_CloseCaseResponseWrapper();
        objWrapper =  (FSA_CloseCaseResponseWrapper)System.JSON.deserialize(str, FSA_CloseCaseResponseWrapper.class);
        system.debug('****'+objWrapper.imageData.size());
        //String parentCaseId = objWrapper.Id;
        String parentCaseId = caseId;
        /*String transfercase = objWrapper.transfercase;
		String addinfo = objWrapper.add_info;
		String caseClosure = objWrapper.caseClosure; */
        //If Case has new images uploaded while closure.
        if(objWrapper.imageData.size() > 0){
            system.debug('**Create Salesforce Files in Images API**');
            for(FSA_CloseCaseResponseWrapper.cls_imageData objImg : objWrapper.imageData){
                
                ContentVersion cv = new ContentVersion();
                cv.ContentLocation = 'S';
                cv.ContentDocumentId = NULL;
                cv.VersionData =EncodingUtil.base64Decode(objImg.image);
                cv.Title = objImg.fileName;
                cv.PathOnClient = objImg.filename+'.JPG';
                lstConVerToInsert.add(cv);
            }
            if(!lstConVerToInsert.isEmpty())
                insert lstConVerToInsert;
            
            for(ContentVersion conVer : [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id IN :lstConVerToInsert]){
                
                ContentDocumentLink cdl = new ContentDocumentLink();
                cdl.ContentDocumentId = conVer.ContentDocumentId ;
                cdl.LinkedEntityId = parentCaseId ;
                cdl.ShareType = 'V';
                lstCntDocLnkToInsert.add(cdl);
            } 
            if(!lstCntDocLnkToInsert.isEmpty()){
            Database.SaveResult[] sr = Database.insert(lstCntDocLnkToInsert, false);
            // Iterate SaveResult array
        for (Database.SaveResult srRslt : sr) {
            if (srRslt.isSuccess()) {
                //Successfully Updated
                //Handle Updation
                System.debug('Case images Successfully Created, Case Id is: ' + srRslt.getId());
                
				objResponse.status =  true;
                objResponse.message = 'Case images created Successfully!!!';

            }
            else {
                //Error ecountered              
                for(Database.Error error : srRslt.getErrors()) {
                    //Handle error
                    System.debug(error.getStatusCode() + ': ' + error.getMessage() + 
                                 ' Fields that affected the error: ' + error.getFields());
                    
                    objResponse.status =  false;
                    objResponse.message = error.getMessage();
                    
                }
                
            }
        }
         }
       
        }
         return objResponse;
    }
    
    global class createResponse {
        global boolean status;
        global String message;
    }
    
}