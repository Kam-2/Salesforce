/***************************************************************************************
* Class Name			: FSA_Transfer_Case_RESTClass_Test          #Code_Coverage -94 %             
* Created Date			: 19/09/2024
* Created By			: Buvaneswari P
* Class Description	    : Test class for Transfer case.	
* Last modified by		: 
***************************************************************************************/

@isTest
public class FSA_Transfer_Case_RESTClass_Test {
    
    private class MockHttpResponse implements HttpCalloutMock {
        
        public HttpResponse respond(HttpRequest request) {
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody('{"success": true}');
            response.setStatusCode(200);
            return response;
        }
    }
    
    @TestSetup
    public static void setupData(){
        Ambassador__c amb = new Ambassador__c(Name='Charlie',Ambassador_Email__c='charlie@gmail.com',OTP__c='cha1',Active__c=True); 
        insert amb; 
        Ambassador__c amb1 = new Ambassador__c(Name='Charlie1',Ambassador_Email__c='charlie1@gmail.com',OTP__c='ch24',Active__c=True );
        insert amb1;
        Ambassador__c amb2 = new Ambassador__c(Name='Charlie2',Ambassador_Email__c='charlie2@gmail.com',OTP__c='cha5',Active__c=True );
        insert amb2;
        
         Case cse1 = new Case(FSA_Case_Type__c='Clean',Ambassador__c=amb.Id); //Rec-->4
        insert cse1;
        //create Content version
        ContentVersion newCV = new ContentVersion(PathOnClient='Test Content',Title='Test Content',VersionData=Blob.valueOf('Sample Content data'));
        insert newCV;
        //create Content DocumentId
        Id conDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:newCV.Id].ContentDocumentId;
        system.debug('conDocId#####--->'+conDocId);
        //create Content DocumentLink
        ContentDocumentLink newCDocuLink = new ContentDocumentLink(LinkedEntityId=cse1.Id, ContentDocumentId=conDocId,shareType='V');
        insert newCDocuLink;
        
        Case cse2 = new Case(FSA_Case_Type__c='Clean'); //Rec-->2
        insert cse2;
        //create Content version
        ContentVersion newCV1 = new ContentVersion(PathOnClient='Test Content',Title='Test Content',VersionData=Blob.valueOf('Sample Content data'));
        insert newCV1;
        //create Content DocumentId
        Id conDocId1 = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:newCV1.Id].ContentDocumentId;
        system.debug('conDocId1#####--->'+conDocId1);
        //create Content DocumentLink
        ContentDocumentLink newCDocuLink1 = new ContentDocumentLink(LinkedEntityId=cse2.Id, ContentDocumentId=conDocId1,shareType='V');
        insert newCDocuLink1;
        
    }
  
    public static testmethod void getImages_Test1(){
        list<Case> getRec1 =[select Id,CaseNumber,Type,Status,Priority,Additional_Information__c,Address_District360__c,
                            Latitude__c,Longitude__c,CreatedDate from Case WHERE IsClosed=FALSE];
        String JsonMsg=JSON.serialize(getRec1[0] );
        system.debug('####getRec1[0]--> '+getRec1[0]);
        // Set mock callout
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse());
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();             
        req.httpMethod = 'GET';
        req.params.put('id',getRec1[0].Id);
        req.requestBody = Blob.valueof(JsonMsg);      
        RestContext.request = req;
        RestContext.response= res;
        Test.startTest();
        FSA_Transfer_Case_RESTClass.getAmbassador();
        Test.stopTest();
    }
      /*public static testmethod void getImages_Test(){
        list<Case> getRec1 =[select Id,CaseNumber,Type,Status,Priority,Additional_Information__c,Address_District360__c,
                            Latitude__c,Longitude__c,CreatedDate from Case WHERE IsClosed=FALSE];
        List<Ambassador__c> lstAmbsdr = [Select id,Name,OTP__c From Ambassador__c];
        system.debug('####getRec[1]--> '+getRec1[1]);
        FSA_CloseCaseResponseWrapper objJson = new FSA_CloseCaseResponseWrapper();
        objJson.transfercase = lstAmbsdr[0].Name;
        objJson.parentId = getRec1[1].id;
        objJson.Id = getRec1[1].id;
        objJson.add_info=getRec1[1].Additional_Information__c;
        objJson.caseClosure = 'test';
        
        objJson.imageData = new List<FSA_CloseCaseResponseWrapper.cls_imageData>();
        
        FSA_CloseCaseResponseWrapper.cls_imageData objImgdata = new FSA_CloseCaseResponseWrapper.cls_imageData();
		objImgdata.fileName = 'TestFile';
        objImgdata.image = 'fjjifhajifhaijfhajfhijashfjashfjasfhasjfhajfhaojfhaojfhaoj';
        
        objJson.imageData.add(objImgdata);
        String JsonMsg=JSON.serialize(objJson );
        
        system.debug('JsonMsg@@@@-->'+JsonMsg);
        
         // Set mock callout
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse()); 
          
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();             
        req.httpMethod = 'PATCH';
        req.requestBody = Blob.valueof(JsonMsg);      
        RestContext.request = req;
        RestContext.response= res;
        Test.startTest();
        FSA_Transfer_Case_RESTClass.validateAmbassador();
        Test.stopTest();
    }*/
    public static testmethod void getImages_Test(){
        list<Case> getRec1 =[select Id,CaseNumber,Type,Status,Priority,Additional_Information__c,Address_District360__c,
                            Latitude__c,Longitude__c,CreatedDate from Case WHERE IsClosed=FALSE];
        List<Ambassador__c> lstAmbsdr = [Select id,Name,OTP__c From Ambassador__c];
        system.debug('####getRec[1]--> '+getRec1[1]);
        FSA_CloseCaseResponseWrapper objJson = new FSA_CloseCaseResponseWrapper();
        objJson.transfercase = lstAmbsdr[0].Name;
        objJson.parentId = getRec1[1].id;
        objJson.Id = getRec1[1].id;
        objJson.add_info=getRec1[1].Additional_Information__c;
        objJson.caseClosure = 'test';
        
        objJson.imageData = new List<FSA_CloseCaseResponseWrapper.cls_imageData>();
        
        FSA_CloseCaseResponseWrapper.cls_imageData objImgdata = new FSA_CloseCaseResponseWrapper.cls_imageData();
		objImgdata.fileName = 'TestFile';
        objImgdata.image = 'fjjifhajifhaijfhajfhijashfjashfjasfhasjfhajfhaojfhaojfhaoj';
        
        objJson.imageData.add(objImgdata);
        String JsonMsg=JSON.serialize(objJson );
        
        system.debug('JsonMsg@@@@-->'+JsonMsg);
        
         // Set mock callout
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse()); 
          
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();             
        req.httpMethod = 'PATCH';
        req.requestBody = Blob.valueof(JsonMsg);      
        RestContext.request = req;
        RestContext.response= res;
        Test.startTest();
        FSA_Transfer_Case_RESTClass.validateAmbassador();
        Test.stopTest();
    }
}