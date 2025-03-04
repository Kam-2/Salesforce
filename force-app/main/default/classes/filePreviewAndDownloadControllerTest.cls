@isTest
public class filePreviewAndDownloadControllerTest {

       @isTest
    public static void testGetRelatedFilesByRecordId() {
        // Create a test record
        Case testRecord = new Case(Case_Type__c = 'Other');
        insert testRecord;

      // Create test ContentVersion record associated with the test record
        ContentVersion testContentVersion = new ContentVersion(
            ContentLocation = 'S', // Salesforce
            VersionData = Blob.valueOf('Test file content'), // Replace with your file content
            Title = 'Test File',
            PathOnClient = 'TestFile.txt'
        );
        insert testContentVersion;

        // Create a ContentDocumentLink record to link the ContentDocument with the test record
        ContentDocumentLink testContentDocumentLink = new ContentDocumentLink(
            LinkedEntityId = testRecord.Id,
            ContentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :testContentVersion.Id][0].ContentDocumentId,
            Visibility = 'AllUsers',
            ShareType = 'V'
        );
        insert testContentDocumentLink;

        Test.startTest();

        // Call the getRelatedFilesByRecordId method with the test record's Id
        Map<ID, String> result = filePreviewAndDownloadController.getRelatedFilesByRecordId(testRecord.Id);

        Test.stopTest();

        // Add assertions to verify the behavior of your code
        System.assertEquals(1, result.size());
        //System.assertEquals('Test File', result.get(testContentVersion.ContentDocumentId));
        // Add more assertions based on your code's logic
    }
    
}