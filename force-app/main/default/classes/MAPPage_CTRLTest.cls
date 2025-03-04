@isTest
public class MAPPage_CTRLTest {

    @isTest
    static void testMAPPageController() {
        // Create a test Case or Public Asset record
        Case testCase = new Case(
            Subject = 'Test Case'
            // Add other required fields
        );
        insert testCase;

        // Set the page parameters to simulate being on the page
        ApexPages.currentPage().getParameters().put('id', testCase.Id);
        ApexPages.currentPage().getParameters().put('addressVal', 'Test Address');
        ApexPages.currentPage().getParameters().put('LatVal', '38.90086371128457');
        ApexPages.currentPage().getParameters().put('LongVal', '-77.0375437057764');

        // Create a new instance of the controller
        ApexPages.StandardController controller = new ApexPages.StandardController(testCase);
        MAPPage_CTRL controllerExtension = new MAPPage_CTRL();
        controllerExtension = new MAPPage_CTRL();

        // Test the AddressPassed method
        Test.startTest();
        controllerExtension.AddressPassed();
        Test.stopTest();

        // Ensure that the Service_Location, LatValue, and LongValue properties are populated
        System.assertEquals('Test Address', controllerExtension.Service_Location);
        System.assertEquals('38.90086371128457', controllerExtension.LatValue);
        System.assertEquals('-77.0375437057764', controllerExtension.LongValue);

        // Test the Savethe_Record method
        Test.startTest();
        controllerExtension.Savethe_Record();
        Test.stopTest();

        // Test other aspects of your controller logic as needed
    }
}