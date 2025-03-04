@RestResource(urlMapping='/fcmpush/*')
global with sharing class FSA_FCM_Notification_RESTClass {

    @HttpPost
    global static ResponseStatus sendFCMNotification(String fcmToken, String uuid, String name, String email) {
        system.debug('FCM TOKEN#####--> ' + fcmToken);
        system.debug('UUID #####---> ' + uuid);
        system.debug('Amb Name #####---> ' + name);
        system.debug('Amb Email #####---> ' + email);
        ResponseStatus resp = new ResponseStatus();
        
        try {
            // Retrieve API metadata
            Map<String, String> apiMetadataMap = new Map<String, String>();
            Map<String, String> queryMetadataMap = new Map<String, String>();
            List<District_360_FSA_API__mdt> apiMetadataList = District_360_FSA_API__mdt.getAll().values();
            
            for (District_360_FSA_API__mdt obj : apiMetadataList) {
                apiMetadataMap.put(obj.Label, obj.Api_Name__c);
                queryMetadataMap.put(obj.Label, obj.SOQLQuery__c);
            }
            
            // Construct and execute the query
            String baseQuery = queryMetadataMap.get('Ambassador Query');
            String query = baseQuery + ' WHERE Active__c = TRUE AND Ambassador_Email__c = :email ORDER BY Name ASC NULLS LAST';
            System.debug(query);
            string deviceToken=apiMetadataMap.get('DeviceToken');
            string deviceId=apiMetadataMap.get('deviceId');
            
            // Use SObject for dynamic querying
            List<SObject> selectedAmbsdr = Database.query(query);
            System.debug(selectedAmbsdr);
            
            // Process the result
            if (!selectedAmbsdr.isEmpty()) {
               // if (Schema.sObjectType.Ambassador__c.fields.Device_Token__c.isAccessible() & Schema.sObjectType.Ambassador__c.fields.Device_Id__c.isAccessible()) {
                SObject amb = selectedAmbsdr[0];
                
                
                
                // Check if update is necessary
                String currentToken = (String) amb.get(deviceToken);
                if (String.isBlank(currentToken) || currentToken != fcmToken) {
                    amb.put(deviceToken, fcmToken);
                    amb.put(deviceId, uuid);
                    update amb;
                
                
                    System.debug('Updated Record: ' + amb);
                     
                    resp.status = true;
                    resp.message = 'Device token & DeviceId updated successfully!!!';
                
                } else {
                    resp.status = true;
                    resp.message = 'Device token & DeviceId is already up-to-date!';
                    System.debug('Response Msg####---> ' + resp.message);
                }
            } else {
                resp.status = false;
                resp.message = 'No matching Ambassador record found!';
                System.debug('Response Msg####---> ' + resp.message);
            }
        
            
        } catch (DmlException e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
            resp.status = false;
            resp.message = 'Device token was not updated!';
        }
        
        return resp;
    }

    
    global class ResponseStatus {
        global boolean status;
        global String message;
    }
}