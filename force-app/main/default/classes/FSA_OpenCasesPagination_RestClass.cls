/**************************************************************************************
* Class Name			: FSA_OpenCasesPagination_RestClass
* Created Date			: 08/07/2024	
* Created By			: Senthilnathan R
* Class Description	    : Custom API class for Open Cases Pagination for FSA App.	
* Last modified by		: Buvaneswari P
***************************************************************************************/
@RestResource(urlMapping='/opencasespagi/*')
global with sharing class FSA_OpenCasesPagination_RestClass {
   
    /**************************************************************************************
* Method Name			: getOpenCases
* Created Date			: 08/07/2024	
* Created By			: Senthilnathan R
* Class Description		: This is a @HttpGet method queries the open cases based on parameters passed in call.
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
    global static string transferCase{get; set;}
    global static string additionalInfo{get; set;}
    global static string caseClosureNotes{get; set;}
    global static string endLocation{get; set;}
    global static string address{get;set;}
    global static string latitude{get;set;}
    global static string longitude{get;set;}
    global static string rAmbassador{get;set;}
    
    @HttpGet
    global static OpenCases getOpenCases() {
        
        RestRequest request = RestContext.request;
        
        Integer pageNumber = Integer.valueOf(RestContext.request.params.get('pagenumber'));
        Integer casesPerPage = Integer.valueOf(RestContext.request.params.get('casesperpage'));
        String  sortBy = RestContext.request.params.get('sortby');
        String  caseType =RestContext.request.params.get('casetype');
        //String  subType =RestContext.request.params.get('subtype');
        //String  serviceReq =RestContext.request.params.get('servicereq');
        String  ambassadorId =RestContext.request.params.get('ambassadorId');
        String  role =RestContext.request.params.get('role');
        
        system.debug('ambassadorId--> '+ambassadorId);
        system.debug('casetype--> '+casetype);
        system.debug('sortby--> '+sortby);
        system.debug('casesperpage--> '+casesperpage);
        system.debug('pagenumber--> '+pagenumber);
        
        Integer page = pageNumber;
        Integer offset = (page - 1) * casesPerPage;
        
        OpenCases objOpenCases = new OpenCases();
        objOpenCases.openCasesList = new List<Caserec>(); 
        Map<String, String> queryMetadataMap = new Map<String, String>();
        Map<String, String> apiMetadataMap = new Map<String, String>();
        List<District_360_FSA_API__mdt> apiMetadataList = District_360_FSA_API__mdt.getAll().values();
            for (District_360_FSA_API__mdt obj : apiMetadataList) {
                queryMetadataMap.put(obj.Label, obj.SOQLQuery__c); 
                apiMetadataMap.put(obj.Label,obj.Api_Name__c);
               }
           string baseQuery=queryMetadataMap.get('Case Query');
           system.debug(baseQuery);
           string baseQuery1=queryMetadataMap.get('Case Query1');
           string subquery= baseQuery+baseQuery1+  ' WHERE isClosed = FALSE';
           system.debug(subquery);
        
        //String subquery = 'select Id,CaseNumber,FSA_Case_Type__c,FSA_Case_Sub_Type__c,End_Location__c,Transfer_Case__c,Address__c,Additional_Information__c,Case_Closure_Notes__c,Status,Priority,Ambassador__c,Ambassador__r.Name,IsClosed,CreatedDate from Case WHERE IsClosed=FALSE';
        
        if(!String.isBlank(caseType) && caseType!='None')
           { 
               subquery= subquery+' AND FSA_Case_Type__c  ='+ '\'' + caseType + '\'';
           }
       
        //if(!String.isBlank(ambassadorId) && ambassadorId!='None' && !String.isBlank(role)  && role=='TeamMember')
            if(!String.isBlank(ambassadorId) && ambassadorId!='None' && !String.isBlank(role) )
            {
                subquery= subquery+' AND Ambassador__c ='+ '\'' + ambassadorId + '\'';
        
            }
                
        if(!String.isBlank(sortBy) && sortBy!='None'){
            subquery = subquery+' ORDER BY CreatedDate '+sortBy;
        }
        else{
            subquery = subquery+' ORDER BY CreatedDate DESC';    
        }
        String queryForCount = subquery+';';
        String queryForCases = subquery+' LIMIT '+casesPerPage+' OFFSET '+offset;
        
        system.debug('****subquery******'+subquery);
        system.debug('****queryForCount******'+queryForCount);
        system.debug('****queryForCases******'+queryForCases);
        list<SObject> lstAllCases = Database.query(subquery);
        List<SObject> lstPagedCases = Database.query(queryForCases);
        
       // List<Case> lstAllCases = Database.query(subquery);
        //List<Case> lstPagedCases = Database.query(queryForCases);
        objOpenCases.Totalcount = lstAllCases.size();
        // to get custom field Api
               id=apiMetadataMap.get('Id');
               caseNo=apiMetadataMap.get('CaseNumber');
               fsaCaseType=apiMetadataMap.get('FSA Case Type');
               fsaCaseSubType=apiMetadataMap.get('FSA Case Subtype');
               status=apiMetadataMap.get('Status');
               priority=apiMetadataMap.get('Priority');
               ambassador=apiMetadataMap.get('Ambassador');
               transferCase=apiMetadataMap.get('Transfer Case');
               additionalInfo=apiMetadataMap.get('Additional Information');
               caseClosureNotes=apiMetadataMap.get('Case Closure Note');
               endLocation=apiMetadataMap.get('End Location');
               address=apiMetadataMap.get('Address');
               rAmbassador=apiMetadataMap.get('RelationAmbassador');
               name=apiMetadataMap.get('Name');
               
        
        for (SObject objCase : lstPagedCases) {
            
            Caserec objcaserec =  new Caserec();
            objcaserec.id = (string)objCase.get(Id);
            objcaserec.caseNumber=(string)objCase.get(caseNo);
            objcaserec.caseType     = (string)objCase.get(fsaCaseType);
            objcaserec.caseSubType     =(string) objCase.get(fsaCaseSubType);
            //objcaserec.CaseSubSubType     = objCase.Request_Sub_Reason__c;
            objcaserec.caseStatus     = (string)objCase.get(status);
            objcaserec.ambassador = (string)objCase.get(ambassador);
            SObject ambassador = objCase.getSObject(rAmbassador);
            String ambassadorName = ambassador != null ? (String)ambassador.get(name) : null;
		    objcaserec.ambName = ambassadorName;
            objcaserec.createdDate = dateFormat((DateTime)objCase.get('CreatedDate'));
            objcaserec.transferCase = (string)objCase.get(transferCase);
            objcaserec.add_Info    = (string)objCase.get(additionalInfo);
            objcaserec.caseClosure    =(string)objCase.get(caseClosureNotes);
            objcaserec.address = (string)objCase.get(address);
            objcaserec.endLocation =(string)objCase.get(endLocation);
            
            objOpenCases.openCasesList.add(objcaserec); 
        }
        return objOpenCases;  
    }
    
    
    /*****************************************************************************************************
* Method Name			: dateFormat
* Created Date			: 	
* Created By			: Senthilnathan R
* Class Description		: Method for change date format.
*******************************************************************************************************/
    public static String dateFormat(DateTime createdDateFormat){
        try{
            system.debug('createdDateFormat*** '+ createdDateFormat);
            String myDatetimeStr = createdDateFormat.format('yyyy-MM-dd HH:mm:ss');
            system.debug('myDatetimeStr*** '+ myDatetimeStr);
            return myDatetimeStr;
            
        } catch(DmlException e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
            return null;
        }
        
    }
    
    
     global class OpenCases {
        global Integer Totalcount;
        global List<caserec> openCasesList;
        
    }
    
    global class caserec {
        global String Id;
        global String CaseNumber;
        global String CaseType;
        global String CaseSubType;
        global String CaseSubSubType;
        global String ServiceReqType;
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
}