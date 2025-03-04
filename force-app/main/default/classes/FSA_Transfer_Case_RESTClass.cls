/**************************************************************************************
* Class Name			: FSA_Transfer_Case_RESTClass
* Created Date			: 08/07/2024
* Created By			: Senthilnathan R
* Class Description	    : Custom API class to support transfering a case from one ambassador to the other.	
* Last modified by		: 
***************************************************************************************/

@RestResource(urlMapping='/transfercase/*')
global with sharing class FSA_Transfer_Case_RESTClass {
       
    /**************************************************************************************
* Method Name			: getAmbassador
* Created Date			: 08/07/2024
* Created By			: Senthilnathan R
* Class Description		: This is a @HttpGet method queries all the Ambassadors and returns a list.
***************************************************************************************/
    global static String id{ get; set; }
    global static string name{get; set;}
    global static String caseNo{ get; set; }
    global static String fsaCaseType{ get; set; }
    global static string fsaCaseSubType{ get; set; }
    global static string status{get; set;}
    global static string priority{get; set;}
    global static string ambassador{get; set;}
    global static string ambassadorName{get; set;}
    global static string transCase{get; set;}
    global static string additionalInfo{get; set;}
    global static string caseClosureNotes{get; set;}
    global static string endLocation{get; set;}
    global static string address{get;set;}
    global static string latitude{get;set;}
    global static string longitude{get;set;}
    global static string rAmbassador{get;set;}
    global static Map<String, String> queryMetadataMap{get;set;}
    global static Map<String, String> apiMetadataMap{get;set;}
    
    @HttpGet
    global static fields getAmbassador() {
        RestRequest request = RestContext.request;
        String caseId = '';
        caseId = RestContext.request.params.get('id');
        //caseId='500J4000003ElXOIA0';
        system.debug('@@@@CASE Id ='+caseId);
        
        
        
        fields allfields = new fields();
        allfields.fields = new List<field>();
        allfields.openCasesImages = new List<cls_attachment>();
         queryMetadataMap = new Map<String, String>();
        apiMetadataMap = new Map<String, String>();
        List<District_360_FSA_API__mdt> apiMetadataList = District_360_FSA_API__mdt.getAll().values();
            for (District_360_FSA_API__mdt obj : apiMetadataList) {
                queryMetadataMap.put(obj.Label, obj.SOQLQuery__c); 
                apiMetadataMap.put(obj.Label,obj.Api_Name__c);
               }
        // to get custom field Api
               id=apiMetadataMap.get('Id');
               name=apiMetadataMap.get('Name');
               caseNo=apiMetadataMap.get('CaseNumber');
               fsaCaseType=apiMetadataMap.get('FSA Case Type');
               fsaCaseSubType=apiMetadataMap.get('FSA Case Subtype');
               status=apiMetadataMap.get('Status');
               priority=apiMetadataMap.get('Priority');
               ambassador=apiMetadataMap.get('Ambassador');
               transCase=apiMetadataMap.get('Transfer Case');
               additionalInfo=apiMetadataMap.get('Additional Information');
               caseClosureNotes=apiMetadataMap.get('Case Closure Note');
               endLocation=apiMetadataMap.get('End Location');
               address=apiMetadataMap.get('Address');
               latitude=apiMetadataMap.get('Latitude');
               longitude=apiMetadataMap.get('Longitude');
               rAmbassador=apiMetadataMap.get('RelationAmbassador');
               
           string baseQuery=queryMetadataMap.get('Case Query');
           string baseQuery1=queryMetadataMap.get('Case Query1');
           
           system.debug(baseQuery);
           string query= baseQuery +baseQuery1+ ' WHERE IsClosed = FALSE AND Id = \'' + caseId + '\' LIMIT 1';
           system.debug(query);
        
           SObject objCase = Database.query(query);
           system.debug(objCase);
        
        
       
        
        
        /*Case objCase = [select Id,CaseNumber,FSA_Case_Type__c,FSA_Case_Sub_Type__c,Transfer_Case__c,Service_type__c,Address__c,Latitude__c,
                        Longitude__c,Status,Priority,Ambassador__c,Additional_Information__c,Case_Closure_Notes__c,End_Location__c,
                        Ambassador__r.Name,CreatedDate from Case WHERE IsClosed=FALSE AND Id =: caseId LIMIT 1];*/
              
        allfields.Id = objCase.Id;
        allfields.CaseNumber     = (string)objCase.get(caseNo);
        allfields.CaseType     = (string)objCase.get(fsaCaseType);
		allfields.CaseSubType     = (string)objCase.get(fsaCaseSubType);
        //allfields.CaseSubSubType = objCase.Request_Sub_Reason__c;
        allfields.caseStatus = (string)objCase.get(status);
        allfields.priority = (string)objCase.get(priority);
		allfields.Ambassador = (string)objCase.get(ambassador);
        SObject ambassador = objCase.getSObject(rAmbassador);
        String ambassadorName = ambassador != null ? (String)ambassador.get(name) : null;
		allfields.ambName = ambassadorName;
		allfields.CreatedDate = FSA_OpenCasesPagination_RestClass.dateFormat((DateTime)objCase.get('CreatedDate'));
		allfields.transferCase     = (string)objCase.get(transCase);
		allfields.add_Info    = (string)objCase.get(additionalInfo);
		allfields.caseClosure    = (string)objCase.get(caseClosureNotes);
                    allfields.endLocation = (string)objCase.get(endLocation);
		allfields.address =(string)objCase.get(address);
		allfields.latitude = (string)objCase.get(latitude);
		allfields.longitude = (string)objCase.get(longitude);
        //system.debug(Label.Show_End_Location_In_App);
       /* if(objCase.FSA_Case_Sub_Type__c == Label.Show_End_Location_In_App)
        {
           allfields.showEndLocation = true; 
        }
        else
        {
                    allfields.showEndLocation = false;    
        }*/
		
        
        Schema.DescribeFieldResult franklinfieldp = Case.Transfer_Case__c.getDescribe();
        
        
        field ffrankp = new field();
        ffrankp.label = franklinfieldp.getLabel();
        ffrankp.name = franklinfieldp.getName();
        ffrankp.type = 'Picklist';
        if(ffrankp.type == 'Picklist') {
            List<picklistValue> pickp = new List<picklistValue>();
            List<Schema.PicklistEntry> plesp = franklinfieldp.getPicklistValues();
            picklistValue pvalues1p = new picklistValue();
            pvalues1p.name = '';
            pvalues1p.label = 'None';
            pickp.add(pvalues1p);
            List<Ambassador__c> ambassadorlist = new List<Ambassador__c>();
            string ambassadorBaseQuery=queryMetadataMap.get('Ambassador Query');
            
            string ambasQuery=ambassadorBaseQuery + ' ORDER BY Name ASC NULLS FIRST';
            system.debug('line135----'+ambasQuery);
            List<SObject> records = Database.query(ambasQuery);
           // ambassadorlist = [SELECT Id,Name,Ambassador_Email__c FROM Ambassador__c ORDER BY Name ASC NULLS FIRST];
            //ambassadorlist = [SELECT Id,Name,Ambassador_Email__c FROM Ambassador__c ];
            for(SObject pe: records) {
                picklistValue pvalues = new picklistValue();
                pvalues.label =(String)pe.get(name);
                pvalues.name =(String)pe.get(name);
                pickp.add(pvalues);
            }
            ffrankp.picklistValues = pickp;
        }
        allfields.fields.add(ffrankp);
        
        
        List<ContentDocumentLink> contentDocumentLinks = [SELECT ContentDocumentId FROM 
                                                          ContentDocumentLink WHERE LinkedEntityId = :caseId];   //pass caseId
        if (contentDocumentLinks.size() > 0)
        {
            Set<Id> setContentDocumentIds = new Set<Id>();
            
            for (ContentDocumentLink contentDocumentLink : contentDocumentLinks ){
                setContentDocumentIds.add(contentDocumentLink.ContentDocumentId);
            }
            
            List<ContentVersion> lstContentVersions = [SELECT Id,ContentDocumentId,Title,VersionData,isLatest,CreatedDate
                                                       FROM ContentVersion 
                                                       WHERE ContentDocumentId in :setContentDocumentIds 
                                                       AND FileType!='SNOTE' 
                                                       AND IsLatest = true
                                                      ];
            if (lstContentVersions.size() > 0)
            {
                for (ContentVersion contentVersion : lstContentVersions )
                {
                    system.debug(contentVersion.Title);
                    system.debug(contentVersion.VersionData);
                    //contentVersion.Title
                    //EncodingUtil.base64Decode(EncodingUtil.base64Encode(contentVersion .VersionData)).toString();     //this get the attachment body
                    //EncodingUtil.base64Encode(contentVersion.VersionData);
                    cls_attachment attach = new cls_attachment();
                    attach.fileName = contentVersion.Title;
                    attach.fileData = EncodingUtil.base64Encode(contentVersion.VersionData);
                    //attach.createdDate = string.valueOfGmt(contentVersion.CreatedDate);
                    attach.createdDate = imgCreatedDateName(contentVersion.CreatedDate);
                    System.debug('Heap Remaining After Query: ' + (Limits.getLimitHeapSize()-Limits.getHeapSize()));     
                    allfields.openCasesImages.add(attach);
                }
            }
        }
        
        
        return allfields;
    }

    /*****************************************************************************************************
* Method Name			: imgCreatedDateName
* Created Date			: 12th Dec, 2022		
* Created By			: Senthilnathan R
* Class Description		: Method for change date format.
*******************************************************************************************************/
    
      public static String imgCreatedDateName(DateTime imgCreatedDate){
        try{
            Datetime myDatetime = imgCreatedDate;
            String myDatetimeStr = myDatetime.format('d MMM yy');
            system.debug('date*** '+ myDatetimeStr);
            return myDatetimeStr;
        } catch(DmlException e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
            return null;
        }
        
    }
    
    //WRAPPER CLASS FOR SECTIONS AND FIELDS
    global class field {
        global String label;
        global String name;
        global String type;
        //global Boolean required;
        global List<picklistValue> picklistValues;
        //global List<dependency> dependency;
        //global String dependentfields;
    }
    
    
    global class picklistValue {        
        global String label;
        global String name;
        //global Boolean sub_request_enabled;
    }
    
    global class cls_attachment {
        global String fileName;
        global String fileData;
        global String createdDate;
    }
    global class fields {
        global List<field> fields;
        global List<cls_attachment> openCasesImages;
        
         global String Id;
        global String CaseNumber;
        global String CaseType;
        global String CaseSubType;
        global String CaseSubSubType;
        global String priority;
        global String requestorType;
        global String caseStatus;
        global String latitude;
        global String longitude;
        global String ambName;
        global String transferCase;
        global String Ambassador;
        global String CreatedDate;
        global String add_Info;
        global String address;
        global String caseClosure;
        global String typeIcon;
        global String locIcon;
        global String endLocation;
        global boolean showEndLocation;
    }
    
    
 /**************************************************************************************
* Method Name			: updateCase
* Created Date			: 16th Feb, 2023	
* Created By			: Senthilnathan R
* Class Description		: This is a @HttpPatch method updates the case record.
***************************************************************************************/
    
    @HttpPatch
    global static transferResponse validateAmbassador() {
        transferResponse resp = new transferResponse();
        try{
            RestRequest req = RestContext.request;
            String str = req.requestBody.toString();
            system.debug('Str@@ '+str );
            List<ContentVersion> lstConVerToInsert = new List<ContentVersion>();
            List<ContentDocumentLink> lstCntDocLnkToInsert = new List<ContentDocumentLink>();
            
            
            FSA_CloseCaseResponseWrapper objWrapper = new FSA_CloseCaseResponseWrapper();
            objWrapper =  (FSA_CloseCaseResponseWrapper)System.JSON.deserialize(str, FSA_CloseCaseResponseWrapper.class);
            system.debug('****'+objWrapper.imageData.size());
            String parentCaseId = objWrapper.Id;
            String transfercase = objWrapper.transfercase;
            String addinfo = objWrapper.add_info;
            String caseClosure = objWrapper.caseClosure;
            String endLocation = objWrapper.endLocation;
            //String caseDesc = objWrapper.caseDesc;
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
        queryMetadataMap = new Map<String, String>();
        apiMetadataMap = new Map<String, String>();
        List<District_360_FSA_API__mdt> apiMetadataList = [SELECT Label,SOQLQuery__c,Api_Name__c FROM District_360_FSA_API__mdt];
            for (District_360_FSA_API__mdt obj : apiMetadataList) {
                queryMetadataMap.put(obj.Label, obj.SOQLQuery__c); 
                apiMetadataMap.put(obj.Label,obj.Api_Name__c);
               }
            
           
           string baseQuery=queryMetadataMap.get('Case Query');
           string baseQuery1=queryMetadataMap.get('Case Query1');
           system.debug(baseQuery1);
           system.debug(baseQuery);
           string query= baseQuery+baseQuery1+ ' WHERE Id = \'' + parentCaseId + '\' LIMIT 1';
           list<SObject> selectedCases = Database.query(query);
           if (selectedCases.isEmpty()) {
            throw new DmlException('No case found with the provided ID.');
        }
           string transferingCase=apiMetadataMap.get('Transfer Case');
           string ambassador=apiMetadataMap.get('Ambassador');
           string add_Information=apiMetadataMap.get('Additional Information');
           string caseClosuringNote=apiMetadataMap.get('Case Closure Note');
           string endingLocation=apiMetadataMap.get('End Location');
           string id=apiMetadataMap.get('Id');
            
            system.debug('@@selectedCase'+selectedCases);
            SObject selectedCase = selectedCases[0];
            if (transfercase != 'None' && transfercase != '') {
            selectedCase.put(transferingCase, transfercase);
            String ambassadorQuery = queryMetadataMap.get('Ambassador Query') + ' WHERE Name = :transfercase LIMIT 1';
            List<SObject> selectedAmb = Database.query(ambassadorQuery);
            if (!selectedAmb.isEmpty()) {
                selectedCase.put(ambassador, selectedAmb[0].get(id));
            }
        } else {
            selectedCase.put(transferingCase, '');
        }

        selectedCase.put(add_Information, 
                         String.isBlank((String)selectedCase.get(add_Information)) ? addinfo : ' ' + '\n ' + addinfo);
                         
        selectedCase.put(caseClosuringNote, 
                         String.isBlank((String)selectedCase.get(caseClosuringNote)) ? caseClosure : ' ' + '\n ' + caseClosure);
                         
        selectedCase.put(endingLocation, 
                         String.isBlank((String)selectedCase.get(endingLocation)) ? endLocation : ' ' + '\n ' + endLocation);

        update selectedCase;

        resp.status = true;
        resp.message = 'Record Updated Successfully!!!';
        return resp;

    } catch (DmlException e) {
        System.debug('The following exception has occurred: ' + e.getMessage());
        resp.status = false;
        resp.message = e.getMessage();
        return resp;
    }
}
    global class transferResponse {
        global boolean status;
        global String message;
    }
    
}