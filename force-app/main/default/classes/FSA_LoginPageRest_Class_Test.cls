/**************************************************************************************
* Class Name			: FSA_LoginPage_RestClass_Test                       Cc -91%.
* Created Date			: 19th Sep, 2024	
* Created By			: Buvaneswari P
* Class Description		: Test class for Custom API	using Login page.	
* Last modified by		: 
***************************************************************************************/
@isTest
public class FSA_LoginPageRest_Class_Test {
    @TestSetup 
    public static void setupData(){
        Ambassador__c amb = new Ambassador__c(Name='Charlie',Ambassador_Email__c='charlie@gmail.com',OTP__c='cha1',Active__c=True); 
        insert amb; 
        Ambassador__c amb1 = new Ambassador__c(Name='Charlie1',Ambassador_Email__c='charlie1@gmail.com',OTP__c='ch24',Active__c=True );
        insert amb1;
        Ambassador__c amb2 = new Ambassador__c(Name='Charlie2',Ambassador_Email__c='charlie2@gmail.com',OTP__c='cha5',Active__c=True );
        insert amb2;
        Ambassador__c amb3 = new Ambassador__c(Name='',Ambassador_Email__c='',OTP__c='',Active__c=True );
        insert amb3;
    }
    public static testmethod void getAmbassador_Test(){
        list<Ambassador__c> getRec =[Select id,Name,Ambassador_Email__c,OTP__c,Roles__c From Ambassador__c];
        System.assertEquals(getRec.size() , 4);
        String JsonMsg=JSON.serialize(getRec[0]);
        system.debug('####AmbList-->JsonMsg--> '+JsonMsg);
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();             
        req.httpMethod = 'GET';
        req.requestBody = Blob.valueof(JsonMsg);      
        RestContext.request = req;
        RestContext.response= res;
        Test.startTest();
        FSA_LoginPage_RestClass.getAmbassador();
        Test.stopTest();
    }
     public static testmethod void error_Test(){
        list<Ambassador__c> getRec =[Select id,Name,Ambassador_Email__c,OTP__c,Roles__c From Ambassador__c];
        System.assertEquals(getRec.size() , 4);
        String JsonMsg=JSON.serialize(getRec[3]);
        system.debug('####AmbList-->JsonMsg--> '+JsonMsg);
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();             
        req.httpMethod = 'GET';
        req.requestBody = Blob.valueof(JsonMsg);      
        RestContext.request = req;
        RestContext.response= res;
        Test.startTest();
        FSA_LoginPage_RestClass.getAmbassador();
        Test.stopTest();
    }
}