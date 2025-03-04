@isTest
public class EditCaseLocationCTRLTest {

     @isTest
    static void testEditCaseController() {
        // Create a test Case
        Case testCase = new Case(
            Subject = 'Test Case'
            // Add other required fields
        );
        insert testCase;

        // Set the page parameters to simulate being on the page
        ApexPages.currentPage().getParameters().put('id', testCase.Id);

        // Create a new instance of the controller
        ApexPages.StandardController controller = new ApexPages.StandardController(testCase);
        EditCaseLocationCTRL controllerExtension = new EditCaseLocationCTRL(controller);

        // Ensure that the EditCase property is populated
        System.assertEquals(testCase.Id, controllerExtension.EditCase.Id);

        // Test other aspects of your controller logic as needed
    }
}