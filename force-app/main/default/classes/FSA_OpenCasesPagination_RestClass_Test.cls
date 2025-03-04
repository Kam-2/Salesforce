/***************************************************************************************
* Class Name			: FSA_OpenCasesPagination_RestClass_Test          #Code_Coverage - 93%             
* Created Date			: 19/09/2024
* Created By			: Buvaneswari P 
* Class Description	    : Test class for Open case pagination API.	
* Last modified by		: 
***************************************************************************************/
@isTest
public class FSA_OpenCasesPagination_RestClass_Test {
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
        Case cse = new Case(Type= ''); //Rec-->0 
        insert cse;
        Case cse1 = new Case(Type='Clean'); //Rec-->1
        insert cse1; 
        Case cse4 = new Case(Type='Clean',Ambassador__c=amb.Id); //Rec-->4
        insert cse4;
        
            }
    public static testmethod void getOpenCases_Test0(){
        list<Case> getRec =[select Id,CaseNumber,Type,Status,Priority,Ambassador__c,
                            CreatedDate from Case WHERE IsClosed=FALSE];
        String JsonMsg=JSON.serialize(getRec[0] );
        system.debug('####getRec[0]--> '+getRec[0]);
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();             
        req.httpMethod = 'GET';
        req.params.put('pagenumber','1');
        req.params.put('casesperpage','10');
        req.params.put('sortby','DESC');
        req.params.put('casetype','None');
      //  req.params.put('subtype','None');
		//req.params.put('subsubtype','None');
        req.params.put('ambassadorId','None');
        req.params.put('role','Manager');
        req.requestBody = Blob.valueof(JsonMsg);      
        RestContext.request = req;
        RestContext.response= res;
        Test.startTest();
        FSA_OpenCasesPagination_RestClass.getOpenCases();
        Test.stopTest();
    }
    public static testmethod void getOpenCases_Test1(){
        list<Case> getRec =[select Id,CaseNumber,Type,Status,Priority,Ambassador__c,
                            CreatedDate from Case WHERE IsClosed=FALSE];
        String JsonMsg=JSON.serialize(getRec[1] );
        system.debug('####getRec[1]--> '+getRec[1]);
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();             
        req.httpMethod = 'GET';
        req.params.put('pagenumber','1');
        req.params.put('casesperpage','10');
        req.params.put('sortby','ASC');
        req.params.put('casetype','Clean');
        //req.params.put('subtype','');
		//req.params.put('subsubtype','');
        req.params.put('role','Manager');
        req.params.put('ambassadorId',getRec[1].Ambassador__c);
        req.requestBody = Blob.valueof(JsonMsg);      
        RestContext.request = req;
        RestContext.response= res;
        Test.startTest();
        FSA_OpenCasesPagination_RestClass.getOpenCases();
        Test.stopTest();
    }
    public static testmethod void getOpenCases_Test2(){
        list<Case> getRec =[select Id,CaseNumber,Type,Status,Priority,Ambassador__c,
                            CreatedDate from Case WHERE IsClosed=FALSE];
        String JsonMsg=JSON.serialize(getRec[2] );
        system.debug('####getRec[2]--> '+getRec[2]);
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();             
        req.httpMethod = 'GET';
        req.params.put('pagenumber','1');
        req.params.put('casesperpage','10');
        req.params.put('sortby','ASC');
        req.params.put('casetype','Business Contact');
        req.params.put('subtype','Business Change Form');
        req.params.put('subsubtype','New Business');
        req.params.put('role','Manager');
        req.params.put('ambassadorId',getRec[2].Ambassador__c);
        req.requestBody = Blob.valueof(JsonMsg);      
        RestContext.request = req;
        RestContext.response= res;
        Test.startTest();
        FSA_OpenCasesPagination_RestClass.getOpenCases();
        Test.stopTest();
    }
   /* public static testmethod void getOpenCases_Test3(){
        list<Case> getRec =[select Id,CaseNumber,Type,Request_Reason__c,Request_Sub_Reason__c,Status,Priority,Ambassador__c,
                            CreatedDate from Case ];
        String JsonMsg=JSON.serialize(getRec[5] );
        system.debug('####getRec[5]--> '+getRec[5]);
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();             
        req.httpMethod = 'GET';
        req.params.put('pagenumber','1');
        req.params.put('casesperpage','10');
        req.params.put('sortby','ASC');
        req.params.put('casetype','Security and Safety');
        req.params.put('subtype','Assist with Police Call');
        req.params.put('subsubtype','None');
        req.params.put('role','TeamMember');
        req.params.put('ambassadorId',getRec[5].Ambassador__c);
        req.requestBody = Blob.valueof(JsonMsg);      
        RestContext.request = req;
        RestContext.response= res;
        Test.startTest();
        NOLA_OpenCasesPagination_RestClass.getOpenCases();
        Test.stopTest();
    }
*/
}