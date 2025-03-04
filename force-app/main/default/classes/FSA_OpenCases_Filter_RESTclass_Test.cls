/***************************************************************************************
* Class Name			: FSA_OpenCases_Filter_RESTclass_Test          #Code_Coverage - 85%             
* Created Date			: 19th Sep, 2024	
* Created By			: Buvaneswari P
* Class Description	    : Test class for Open case Filter API.	
* Last modified by		: 
***************************************************************************************/

@isTest
public class FSA_OpenCases_Filter_RESTclass_Test {
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
        Case cse2 = new Case(Type='Outreach',Ambassador__c=amb1.Id); 
        insert cse2;
        Case cse = new Case(Type='Safe');
        insert cse;

    }
    public static testmethod void getFilterFields_Test(){
        list<Case> getRec =[Select id,Type From Case];
        String JsonMsg=JSON.serialize(getRec[0] );
        system.debug('####getRec[0]--> '+getRec[0]);
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();             
        req.httpMethod = 'GET';
        req.params.put('id', getRec[0].id);
        req.params.put('casetype', 'Clean');
        req.requestBody = Blob.valueof(JsonMsg);      
        RestContext.request = req;
        RestContext.response= res;
        Test.startTest();
        FSA_OpenCases_Filter_RESTclass.getFilterFields();
        Test.stopTest();
    }
    public static testmethod void getFilterFields_Test1(){
        list<Case> getRec =[Select id,Type From Case];
        String JsonMsg=JSON.serialize(getRec[1] );
        system.debug('####getRec[1]--> '+getRec[1]);
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();             
        req.httpMethod = 'GET';
        req.params.put('id', getRec[1].id);
        req.params.put('casetype', 'Outreach');
        req.requestBody = Blob.valueof(JsonMsg);      
        RestContext.request = req;
        RestContext.response= res;
        Test.startTest();
        FSA_OpenCases_Filter_RESTclass.getFilterFields();
        Test.stopTest();
    }

}