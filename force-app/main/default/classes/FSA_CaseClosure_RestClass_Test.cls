/***************************************************************************************
* Class Name			: FSA_CaseClosure_RestClass_Test          #Code_Coverage - 92%             
* Created Date			: 19th Sep, 2024	
* Created By			: Buvaneswari P
* Class Description	    : Test class for Case closure API.	
* Last modified by		: 
***************************************************************************************/

@isTest
public class FSA_CaseClosure_RestClass_Test {
       
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
        
        
        Case cse1 = new Case(Type='Clean',Ambassador__c=amb.Id); 
        insert cse1;
        Case cse2 = new Case(Type='Clean',Ambassador__c=amb1.Id); 
        insert cse2;
        Case cse = new Case(Type='');
        insert cse;
        
        //Content Version for caseRec 01
        ContentVersion newFile = new ContentVersion(PathOnClient='TestFile',Title='TestFile',VersionData=Blob.valueOf('sample content'));
        insert newFile;
        ContentVersion insertedFile = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id =:newFile.Id];
        ContentDocumentLink linkedFile = new ContentDocumentLink(LinkedEntityId=cse1.Id, ContentDocumentId=insertedFile.ContentDocumentId);
        insert linkedFile;
         //Content Version for caseRec 02
        ContentVersion newFile2 = new ContentVersion(PathOnClient='TestFile',Title='TestFile',VersionData=Blob.valueOf('sample content'));
        insert newFile2;
        ContentVersion insertedFile2 = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id =:newFile2.Id];
        ContentDocumentLink linkedFile2 = new ContentDocumentLink(LinkedEntityId=cse2.Id, ContentDocumentId=insertedFile2.ContentDocumentId);
        insert linkedFile2;
            }
    public static testmethod void getImages_Test(){
        
        list<Case> getRec1 =[select Id,CaseNumber,Type,Status,Priority,Additional_Information__c,Address_District360__c,
                            Latitude__c,Longitude__c,CreatedDate from Case WHERE IsClosed=FALSE];
        List<Ambassador__c> lstAmbsdr = [select Name,Ambassador_Email__c,OTP__c,Roles__c from Ambassador__c];
        
       
        // Set mock callout
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse());
        
        String baseUrl = URL.getOrgDomainURL().toExternalForm();
        String caseId = String.valueOf(getRec1[1].id);
        String strJson = '{"parentId":"'+caseId+'","transfercase":"","add_info":"","caseClosure":"","endLocation":"","imageData":[{"fileName":"image_picker560955961694798436","image":"/9j/4AAQSkZJRgABAQEBLAEsAAD/4QBSRXhpZgAASUkq"}]}';
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = baseUrl + '/services/apexrest/nolaclosecase';
        req.httpMethod = 'POST';
        req.params.put('id',getRec1[1].id);
        req.requestBody = Blob.valueof(strJson);      
        RestContext.request = req;
        RestContext.response= res;
        Test.startTest();
        FSA_CaseClosure_RestClass.caseClosure();
        Test.stopTest();
    }
    
    
    public static testmethod void getTransfer_Test(){
        
        list<Case> getRec1 =[select Id,CaseNumber,Type,Status,Priority,Additional_Information__c,Address_District360__c,
                            Latitude__c,Longitude__c,CreatedDate from Case WHERE IsClosed=FALSE];
        List<Ambassador__c> lstAmbsdr = [select Name,Ambassador_Email__c,OTP__c,Roles__c from Ambassador__c];
        
       
        // Set mock callout
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse());
        
        String baseUrl = URL.getOrgDomainURL().toExternalForm();
        String caseId = String.valueOf(getRec1[1].id);
        String strJson = '{"parentId":"'+caseId+'","transfercase":"Charlie","add_info":"","caseClosure":"","endLocation":"","imageData":[]}';
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = baseUrl + '/services/apexrest/nolaclosecase';
        req.httpMethod = 'POST';
        req.params.put('id',getRec1[1].id);
        req.requestBody = Blob.valueof(strJson);      
        RestContext.request = req;
        RestContext.response= res;
        Test.startTest();
        FSA_CaseClosure_RestClass.caseClosure();
        Test.stopTest();
    } 
}