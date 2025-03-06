/**************************************************************************************
* Class Name			: FSA_LoginDP_Restclass_Test                       Cc -100%.
* Created Date			: 19th Sep, 2023	
* Created By			: Buvaneswari P 
* Class Description		: Test class for LoginDP API.	
* Last modified by		: 
***************************************************************************************/
@isTest
public class FSA_LoginDP_Restclass_Test {
    @TestSetup
    public static void setupData(){
        list<Ambassador__c> amblst = new list<Ambassador__c>();
        Ambassador__c amb = new Ambassador__c(Name='Charlie',Ambassador_Email__c='charlie@gmail.com',OTP__c='cha1',Active__c=True); 
        amblst.add(amb); 
        Ambassador__c amb1 = new Ambassador__c(Name='Charlie1',Ambassador_Email__c='charlie1@gmail.com',OTP__c='ch24',Active__c=True );
        amblst.add(amb1); 
        insert amblst;
        
        list<ContentVersion> cvlst = new list<ContentVersion>();
        ContentVersion newFile = new ContentVersion(PathOnClient='TestFile',Title='TestFile',VersionData=Blob.valueOf('sample content'));
        cvlst.add(newFile);
        insert cvlst;
        
        ContentVersion insertedFile = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id =:cvlst[0].Id];
        list<ContentDocumentLink> cdlst = new list<ContentDocumentLink>();
        ContentDocumentLink linkedFile = new ContentDocumentLink(LinkedEntityId=amblst[0].Id, ContentDocumentId=insertedFile.ContentDocumentId);
        cdlst.add(linkedFile);
        insert cdlst;
        
        
    }
    public static testmethod void DDI_LoginDP_RestClass(){
        list<Ambassador__c> getRec =[Select id,Name,Ambassador_Email__c,OTP__c From Ambassador__c];
        String JsonMsg=JSON.serialize(getRec[0]);
        system.debug('####AmbList-->JsonMsg--> '+JsonMsg);
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();             
        req.httpMethod = 'GET';
        req.requestBody = Blob.valueof(JsonMsg);      
        RestContext.request = req;
        RestContext.request.params.put('id', getRec[0].id);
        RestContext.response= res;
        Test.startTest();
        FSA_LoginDP_RestClass.getAmbImage();
        Test.stopTest();
    }
}