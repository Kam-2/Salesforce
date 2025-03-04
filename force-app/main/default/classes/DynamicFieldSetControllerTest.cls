@isTest
private class DynamicFieldSetControllerTest {

       @isTest
    public static void testGetObjectFields() {
        // Create a test Case__c custom setting record
        Case__c customSettingRecord = new Case__c(Name = 'Default', Test_one__c = 'Test_one');
        insert customSettingRecord;

        // Create test data for the getObjectFields method
        String objectName = 'Case'; // Replace with your object's API name
        String fieldSetName = 'Test_one'; // Replace with the field set name you want to test

        Test.startTest();

        // Call the getObjectFields method with test data
        List<DynamicFieldSetController.FormField> result = DynamicFieldSetController.getObjectFields(objectName, fieldSetName);

        Test.stopTest();

        // Add assertions to verify the behavior of your code
        //System.assertEquals(1, result.size()); // Adjust this based on your expected result
        DynamicFieldSetController.FormField f = result[0];
        // Add more assertions based on your code's logic
    }
    
    @isTest
    public static void testUploadFiles() {
        // Create a test record for the LinkedEntityId (replace with your object and record)
        case testRecord = new case(Case_Type__c = 'other');
        insert testRecord;

        // Create test data for the ContentVersion and ContentDocumentLink
        List<DynamicFieldSetController.FileDataWP> files = new List<DynamicFieldSetController.FileDataWP>();
        DynamicFieldSetController.FileDataWP file = new DynamicFieldSetController.FileDataWP();
        file.fileName = 'TestFile.txt';
        file.fileContent = 'VGhpcyBpcyBhIHRlc3QgZmlsZSBjb250ZW50Cg=='; // Base64-encoded data (e.g., 'This is a test file content')
        files.add(file);

        // Serialize the files as JSON
        String filedata = JSON.serialize(files);

        Test.startTest();

        // Call the uploadFiles method
        String result = DynamicFieldSetController.uploadFiles(testRecord.Id, filedata);

        Test.stopTest();

        // Assert the results
        System.assertEquals('success', result);

        // Query ContentDocumentLink records and verify as needed
        List<ContentDocumentLink> cdLinks = [SELECT Id FROM ContentDocumentLink WHERE LinkedEntityId = :testRecord.Id];
        System.assertEquals(1, cdLinks.size()); // Ensure that a ContentDocumentLink record was created
    }
}