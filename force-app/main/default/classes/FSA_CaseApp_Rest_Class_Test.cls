/**************************************************************************************
* Class Name			: FSA_CaseApp_Rest_Class_Test                       Cc -89%.
* Created Date			: 19/09/2024
* Created By			: Buvaneswari P 
* Class Description		: Test class for FSA_CaseApp_Rest_Class.	
* Last modified by		: 
***************************************************************************************/
@isTest
public class FSA_CaseApp_Rest_Class_Test {

    public static testmethod void getCaseDetails_Test(){
       
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();             
        req.httpMethod = 'GET';
        req.params.put('casetype', '');
        req.params.put('casesubtype', '');
        req.params.put('casesubsubtype', '');
        RestContext.request = req;
        RestContext.response= res;
        Test.startTest();
        FSA_CaseApp_Rest_Class.getCaseDetails();
        Test.stopTest();
    }
    
   
    public static testmethod void getCaseDetails_Test3(){
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();             
        req.httpMethod = 'GET';
        req.params.put('casetype', 'Clean');
        req.params.put('casesubtype', 'Pressure washing needed');
        req.params.put('casesubsubtype', '');
        RestContext.request = req;
        RestContext.response= res;
        Test.startTest();
        FSA_CaseApp_Rest_Class.getCaseDetails();
        Test.stopTest();
    }
    public static testmethod void getCaseDetails_Test4(){
       
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();             
        req.httpMethod = 'GET';
        req.params.put('casetype', 'Clean');
        req.params.put('casesubtype', '');
        req.params.put('casesubsubtype', '');
        RestContext.request = req;
        RestContext.response= res;
        Test.startTest();
        FSA_CaseApp_Rest_Class.getCaseDetails();
        Test.stopTest();
    }

}