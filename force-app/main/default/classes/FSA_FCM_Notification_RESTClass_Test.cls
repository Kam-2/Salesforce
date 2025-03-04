/***************************************************************************************
* Class Name			: FSA_FCM_Notification_RESTClass_Test          #Code_Coverage - 90%             
* Created Date			: 19th Sep, 2024	
* Created By			: Buvaneswari P
* Class Description	    : Test class for fcmpush API.	
* Last modified by		: 
***************************************************************************************/

@isTest
public class FSA_FCM_Notification_RESTClass_Test {
    @isTest
    public static void testSendFCMNotification() {
       

        // Create a test Ambassador record
        Ambassador__c ambassador = new Ambassador__c(
            Name = 'Test Ambassador',
            Ambassador_Email__c ='test@example.com',
            Active__c = true,
            Device_Token__c = null, // Initially null
            Device_Id__c = null // Initially null
        );

        insert ambassador;

        // Step 2: Call the method with data
        Test.startTest();
        String fcmToken = 'test_fcm_token';
        String uuid = 'test_uuid';
        String name = 'Test Ambassador';
        String email = 'test@example.com';

        FSA_FCM_Notification_RESTClass.ResponseStatus response = FSA_FCM_Notification_RESTClass.sendFCMNotification(fcmToken, uuid, name, email);
        

        
       Ambassador__c updatedAmbassador = [SELECT Device_Token__c, Device_Id__c FROM Ambassador__c WHERE Id = :ambassador.Id];
        
        response = FSA_FCM_Notification_RESTClass.sendFCMNotification(fcmToken, uuid, name, email);
        
       
        response = FSA_FCM_Notification_RESTClass.sendFCMNotification(fcmToken, uuid, name, 'nonexistent@example.com');

        
        Schema.DescribeSObjectResult describeResult = Schema.getGlobalDescribe().get('Ambassador__c').getDescribe();
        Map<String, Schema.SObjectField> fieldMap = describeResult.fields.getMap();
        
        try {
            
            response = FSA_FCM_Notification_RESTClass.sendFCMNotification(fcmToken, uuid, name, email);
        } catch (Exception e) {
            System.assert(response.status == false, 'Expected status to be false due to exception');
            System.assertEquals('Device token was not updated!', response.message, 'Expected message for DmlException');
        } 
        Test.stopTest();
    }
}