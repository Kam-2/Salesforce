@isTest
public class DynamicFieldSetControllerForCaseTest {
@testSetup
    static void setup() {
        
        
        Case testCase = new Case(
            FSA_Case_Type__c = 'Clean',
            FSA_Case_Sub_Type__c = 'Pressure Washing Needed'
            
            
        );
        insert testCase;
        Case testCase1 = new Case(
            FSA_Case_Type__c = 'Safe'
            //FSA_Case_Sub_Type__c='Landscaping Needs Attention'
	    );
        insert testCase1;
        Case testCase2 = new Case(
            FSA_Case_Type__c = 'Safe'          
            
        );
        insert testCase2;
        String result = DynamicFieldSetControllerForCase.getType('Case', testCase.Id);

        // Verify the result
        System.assertEquals('Pressure Washing Needed', result);
    }
    
    @isTest
    static void testGetObjectFields() {
        Test.startTest();
        List<DynamicFieldSetControllerForCase.FormField> result = DynamicFieldSetControllerForCase.getObjectFields('Case', 'Al_Cl');
        //System.assertNotEquals(0, result.size(), 'FieldSet fields should be returned');
        Test.stopTest();
    }

    @isTest
    static void testUploadFiles() {
        Case testCase = new Case(
            FSA_Case_Type__c = 'Clean',
            FSA_Case_Sub_Type__c = 'Pressure Washing Needed'
            
            
        );
        insert testCase;
        Test.startTest();
        String fileData = '[{"fileName":"TestFile.txt","fileContent":"VGhpcyBpcyBhIHRlc3QgZmlsZQ=="}]';
        String result = DynamicFieldSetControllerForCase.uploadFiles(testcase.Id, fileData);
        System.assertEquals('success', result, 'Files should be uploaded successfully');
        Test.stopTest();
    }
    
     @isTest
    public static void testGetFieldSetFieldsByFieldSetName() {
        // Create a test PicklistFieldsetMapping__c record
       
        
        // Mock FieldSet setup
        Test.startTest();
        
        // Create a test object with a field set
        Schema.FieldSet fieldSet = Schema.SObjectType.Case.fieldSets.FSA_Case_SubType;
        // Assuming the field set and fields exist in the Account object. Adjust accordingly.

        // Call the method to be tested
        Map<String, Object> result = DynamicFieldSetControllerForCase.getFieldSetFieldsByFieldSetName('Case', 'FSA_Case_SubType');

        // Verify the result
        System.assert(result != null, 'Result should not be null');
        System.assert(result.containsKey('FieldsetFields'), 'Result should contain key "FieldsetFields"');
        
        
        Test.stopTest();
    }
    
    
    @isTest
    public static void testGetAllTypeFieldset() {
        // Create test PicklistFieldsetMapping__c records
        
       /* List<PicklistFieldsetMapping__c> picklistFieldsetMappings = new List<PicklistFieldsetMapping__c>();
        
        // Mock picklist mappings for testing
        picklistFieldsetMappings.add(new PicklistFieldsetMapping__c(
            Name = 'Cleaning Services',
            Fieldset_Name__c = 'Desktop_Cleaning_Services'
        ));
picklistFieldsetMappings.add(new PicklistFieldsetMapping__c(
            Name = 'Park Steward Daily Report',
            Fieldset_Name__c = 'Desktop_Park_Steward_Daily_Report'
        ));
picklistFieldsetMappings.add(new PicklistFieldsetMapping__c(
            Name = 'Hospitality and Safety Services',
            Fieldset_Name__c = 'Desktop_Hospitality_and_Safety_Services'
        ));
picklistFieldsetMappings.add(new PicklistFieldsetMapping__c(
            Name = 'Outreach Services',
            Fieldset_Name__c = 'Outreach_Services'
        ));        
        
        insert picklistFieldsetMappings;*/
         Schema.DescribeFieldResult fieldResult = Case.FSA_Case_Type__c.getDescribe();
         
        List<Schema.PicklistEntry> picklistValuesList = fieldResult.getPicklistValues();
         Test.startTest();
        Map<String, Object> result = DynamicFieldSetControllerForCase.getAllTypeFieldset();
        Test.stopTest();

     
    }
    
    




}