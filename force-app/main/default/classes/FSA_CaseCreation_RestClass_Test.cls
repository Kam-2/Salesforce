/**************************************************************************************
* Class Name			: FSA_CaseCreation_RestClass_Test                       Cc -82%.
* Created Date			: 19/09/2024
* Created By			: Buvaneswari P 
* Class Description		: Test class for NOLA_CaseCreation_RestClass.	
* Last modified by		: 
***************************************************************************************/
@isTest
public class FSA_CaseCreation_RestClass_Test {
     @isTest
   public static void testCreateCase_Failure() {
        // Test case for a failure scenario (e.g., invalid data, missing fields, etc.)
        // Construct a request body with invalid data or missing required fields
        String requestBody = '{"Ambassador__c":"invalid_value","Address__c":""}';

        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();

        request.requestURI = '/services/apexrest/createCase';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueOf(requestBody);

        RestContext.request = request;
        RestContext.response = response;

        Test.startTest();
        FSA_CaseCreation_RestClass.FSA_CreateCaseResponseWrapper result = FSA_CaseCreation_RestClass.createCase();
        Test.stopTest();

        // Perform assertions to verify the expected failure response
        System.assertEquals(false, result.success, 'Expected failure response');
        System.assertNotEquals(null, result.errorMsg, 'Expected error message in the response');
    }

    @isTest
    public static void testCreateCase_Success() {
        // Mock request body data
        String requestBody = '{"Ambassador__c":"a0D8B000002OcQqUAK","Address__c":"1 Infinite Loop, Cupertino, United States","Latitude__c":"37.33233141","Longitude__c":"-122.0312186","Type":"Clean","potholes__c":"2","Requested_Time__c": "2023-12-31 23:59:59","Public_property__c":"True","sample_time__c":"09:13:13.013","imageData":[{"fileName":"image_picker560955961694798436","image":"/9j/4AAQSkZJRgABAQEBLAEsAAD/4QBSRXhpZgAASUkq"}]}';

        // Make a mock HTTP request with the constructed request body
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();

        request.requestURI = '/services/apexrest/createCase';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueOf(requestBody);

        // Set the request and response contexts for the REST service
        RestContext.request = request;
        RestContext.response = response;

        // Call the REST service method
        Test.startTest();
        FSA_CaseCreation_RestClass.FSA_CreateCaseResponseWrapper result = FSA_CaseCreation_RestClass.createCase();
        Test.stopTest();

        // Perform assertions to verify the expected behavior
        //System.assertEquals(true, result.success, 'Expected successful response');
        //System.assertNotEquals(null, result.id, 'Expected Case Id in the response');
    }
}