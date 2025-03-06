public with sharing class FSA_FcmCalloutClass {
    @future(callout=true)
    public static void sendFCMNotification(String caseId, String dml){
        try{
            if(!String.isBlank(caseId)){
                Map<String, String> queryMetadataMap = new Map<String, String>();
                Map<String, String> apiMetadataMap = new Map<String, String>();
                List<District_360_FSA_API__mdt> apiMetadataList = District_360_FSA_API__mdt.getAll().values();
                for (District_360_FSA_API__mdt obj : apiMetadataList) {
                           queryMetadataMap.put(obj.Label, obj.SOQLQuery__c); 
                           apiMetadataMap.put(obj.Label,obj.Api_Name__c);
                       }
                string id=apiMetadataMap.get('Id');
                string ambassador=apiMetadataMap.get('Ambassador');
                string devicToken=apiMetadataMap.get('DeviceToken');
                string caseNo=apiMetadataMap.get('CaseNumber');
                 string baseQuery=queryMetadataMap.get('Case Query');
                string baseQuery1=queryMetadataMap.get('Case Query1');
                   system.debug(baseQuery);
                string query= baseQuery+baseQuery1+ ' WHERE Id = \'' + caseId + '\' LIMIT 1';
                system.debug(query);
                list<SObject> updatedCase = Database.query(query);
                system.debug(updatedCase);
                
                if(!updatedCase.isEmpty()){
                    string ambassadorBaseQuery=queryMetadataMap.get('Ambassador Query');
                    string ambassadorQuery=ambassadorBaseQuery+' WHERE Id = \'' +(string)updatedCase[0].get(ambassador)  + '\' LIMIT 1';
                    list<SObject> updatedAmb=Database.query(ambassadorQuery);
                    system.debug('updatedAmb##'+updatedAmb[0]);
                    string deviceToken = (string)updatedAmb[0].get(devicToken); //your device token
                    string msg ='';
                    string title ='';
                    string deepLink ='';
                    if(!String.isBlank(dml) && dml=='insert'){
                        msg ='New Case '+ updatedCase[0].get(caseNo) +' has been created!';
                        title ='New Case Created!!!';
                        deepLink = 'nola-deeplink://main/caseDetail/'+updatedCase[0].get(id);
                        System.debug('check insert MSG ####  '+ msg +' title--> '+ title);
                    } else{
                        msg ='New Case '+ updatedCase[0].get(caseNo) +' has been assigned to you';
                        title ='New Case assigned!!!';
                        deepLink = 'nola-deeplink://main/caseDetail/'+updatedCase[0].get(id);
                        System.debug('check update MSG ####  '+ msg +' title--> '+ title);                    
                    }
                    system.debug('FCM TOKEN##### '+deviceToken);
                    //system.debug('UUID ##### '+uuid);
                    Http http = new Http(); 
                    HttpRequest request = new HttpRequest();
                    request.setEndpoint('https://fcm.googleapis.com/fcm/send');
                    request.setMethod('POST');
                    request.setHeader('Content-Type', 'application/json;charset=UTF-8');
                    //request.setHeader('Authorization', 'Key=AAAA8yJs0yw:APA91bFIvV4PFB21KTpglFygZzshJFeMr-neroKAYDzIRRfG9xPLIqukTSw0iltFAJRQXqg73LlbzX1fuk7f9_ADwSG7YwITDueq263isGuVRv2Pjaife2nAK-EeB-SOqx8Bqg-0jntU'); //legacy server key
                    request.setHeader('Authorization', 'Key=AAAA6pH_rZA:APA91bHskT6WgFQCoXFdrKSp96O3qYUWCAjcJqpocDqphzrTs9ENNReQoesqp1d-DCf2_xuRufThTrNDo9f3FBf9TRII_pTkDNNvsSG-Brw5PwER4epRFzry9l-dB_bcMNmj4iGLALM7');
                    
                    // Set the body as a JSON object
                    //request.setBody('{"message":{"token":"'+deviceToken+'", "notification":{"body":"'+msg+'", "title":"'+title+'"} } }');
                    system.debug('MSG----> '+msg +'TITLE---> '+title);
                    //request.setBody('{"to":"'+deviceToken+'", "notification":{"body":"'+msg+'", "title":"'+title+'"}, "deep_link":"'+deepLink+'" }');
                    request.setBody('{"to":"'+deviceToken+'", "notification":{"body":"'+msg+'", "title":"'+title+'"}, "data":{"title":"'+msg+'", "message":"'+title+'", "deep_link":"'+deepLink+'"}}');
                    System.debug('REQUEST BODY#### '+ request.getBody());
                    HttpResponse response = http.send(request);
                    
                    // Parse the JSON response
                    if (response.getStatusCode() != 200) {
                        System.debug('The status code returned was not expected: ' +
                                     response.getStatusCode() + ' ' + response.getStatus());
                        //return string.valueOf(response.getStatus());
                    } else {
                        System.debug('RESPONSE - OK ##### '+response.getBody() + ', Status Code - '+ response.getStatusCode());
                        //return string.valueOf(response.getStatus());
                        //return string.valueOf(response.getBody());
                    }
                }
            }
        } catch(Exception e){
            		System.debug('An exception occurred in FcmCalloutClass####: ' + e.getMessage());
        }
    }
}