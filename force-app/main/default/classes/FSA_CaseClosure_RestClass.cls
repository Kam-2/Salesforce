/****************************************************************************************
* Class Name			: FSA_CaseClosure_RestClass
* Created Date			: 19/09/2024
* Created By			: Buvaneswari P
* Class Description		: For Case closure in FSA App.
*****************************************************************************************/

@RestResource(urlMapping='/closecase/*')
global with sharing class FSA_CaseClosure_RestClass {
    
    @HttpPost
    global static CloseCaseResponse caseClosure() {
        CloseCaseResponse objcloseCaseResponse = new CloseCaseResponse();
        try{
            RestRequest req = RestContext.request;
            String str = req.requestBody.toString();
            system.debug(str);
            
            List<ContentVersion> lstConVerToInsert = new List<ContentVersion>();
            List<ContentDocumentLink> lstCntDocLnkToInsert = new List<ContentDocumentLink>();
            
            
            FSA_CloseCaseResponseWrapper objWrapper = new FSA_CloseCaseResponseWrapper();
            objWrapper =  (FSA_CloseCaseResponseWrapper)System.JSON.deserialize(str, FSA_CloseCaseResponseWrapper.class);
            system.debug('****'+objWrapper.imageData.size());
            String parentCaseId = objWrapper.parentId;
            system.debug(parentCaseId);
            
            //If Case has new images uploaded while closure.
            if(objWrapper.imageData.size() > 0){
                system.debug('**Create Salesforce Files**');
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
                if(!lstCntDocLnkToInsert.isEmpty())
                    insert lstCntDocLnkToInsert;
            }
            
            //Update Status and Add_Info on case.
                Map<String, String> queryMetadataMap = new Map<String, String>();
                Map<String, String> apiMetadataMap = new Map<String, String>();
                List<District_360_FSA_API__mdt> apiMetadataList = District_360_FSA_API__mdt.getAll().values();
                for (District_360_FSA_API__mdt obj : apiMetadataList) {
                           queryMetadataMap.put(obj.Label, obj.SOQLQuery__c); 
                           apiMetadataMap.put(obj.Label,obj.Api_Name__c);
                       }
                string transferingCase=apiMetadataMap.get('Transfer Case');
                string id=apiMetadataMap.get('Id');
                string ambassador=apiMetadataMap.get('Ambassador');
                string baseQuery=queryMetadataMap.get('Case Query');
                system.debug(baseQuery);
                string baseQuery1=queryMetadataMap.get('Case Query1');
                system.debug(baseQuery1);
                string query= baseQuery+baseQuery1+  ' WHERE Id =  \''+objWrapper.parentId + '\'';
                system.debug(query);
                list<SObject> lstCase = Database.query(query);
                system.debug(lstCase);
               
                if(!lstCase.isEmpty()) {
                system.debug('lstCase'+lstCase);
                
                if(objWrapper.transfercase!='None' && objWrapper.transfercase!='') {
                string transCase=(string)lstCase[0].get(transferingCase);
                transCase = objWrapper.transfercase;
                lstCase[0].put(transferingCase,transCase);
                string ambassadorBaseQuery=queryMetadataMap.get('Ambassador Query');
                string ambassadorQuery=ambassadorBaseQuery+' WHERE Name = \'' + objWrapper.transfercase  + '\' LIMIT 1';
                system.debug(ambassadorQuery);
                list<SObject> selectedAmb=Database.query(ambassadorQuery);
                string ambas=(string)lstCase[0].get(ambassador);
                ambas = (string)selectedAmb[0].get(id);
                lstCase[0].put(ambassador, ambas);  
            }
                else
                lstCase[0].put(transferingCase, '');  
                Case objCase =(case)lstCase[0];
                objCase.status = 'Closed';
                objCase.End_Location__c = String.isBlank(objCase.End_Location__c)==true ? objWrapper.endLocation : ' ' + '\n '+objWrapper.endLocation;
                objCase.Additional_Information__c = String.isBlank(objCase.Additional_Information__c)==true ? objWrapper.add_info : ' ' + '\n '+objWrapper.add_info;
                objCase.Case_Closure_Notes__c = String.isBlank(objCase.Case_Closure_Notes__c)==true ? objWrapper.caseClosure : ' ' + '\n '+objWrapper.caseClosure;
                
                update objCase;
                objcloseCaseResponse.status = true;
                objcloseCaseResponse.message = 'Case '+objCase.CaseNumber+' has been resolved/closed.';
                system.debug('objCase'+objCase);
                    
            }
            return objcloseCaseResponse; 
            
        } catch(DmlException e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
            objcloseCaseResponse.status = False;
            objcloseCaseResponse.message = 'Oops, Something went wrong, Please try again later.';
            return objcloseCaseResponse;
        }
        
    }
     
    global class closeCaseResponse {
        global boolean status;
        global String message;
    }
    
    global class imageData {
        global String fileName;
        global String image;
    }
    
}