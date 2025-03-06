/**************************************************************************************
* Class Name			: FSA_CaseCreation_RestClass
* Created Date			: 04/07/2024
* Created By			: Senthilnathan R
* Class Description	    : Custom API class to create a new case via a POST request.	
* Last modified by		: 
***************************************************************************************/


@RestResource(urlMapping='/createCase')
global with sharing class FSA_CaseCreation_RestClass {

/****************************************************************************************
* Method Name			: createCase
* Created Date			: 04/07/2024
* Created By			: Senthilnathan R
* Method Description   : POST method to insert cases from request and send back the id for success/ error details for failure response.
*****************************************************************************************/
    @HttpPost
    global static FSA_CreateCaseResponseWrapper createCase() {
        
        RestRequest req = RestContext.request;
        String requestBody = req.requestBody.toString();
        String srtStartTime ='';
                system.debug(requestBody);

        //Fetch all fields of Case object and their type. 
        Map<String, String> mapFldAPINameToType = new Map<String, String>();
        String objType='Case';
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Schema.SObjectType leadSchema = schemaMap.get(objType);
        Map<String, Schema.SObjectField> fieldMap = leadSchema.getDescribe().fields.getMap();
        
        for (String fieldName: fieldMap.keySet()) {
            //get data types for each case fields.
            Schema.DisplayType fielddataType = fieldMap.get(fieldName).getDescribe().getType();
            
            if(fielddataType == Schema.DisplayType.DateTime || fielddataType == Schema.DisplayType.Double || fielddataType == Schema.DisplayType.Date 
               || fielddataType == Schema.DisplayType.Boolean || fielddataType == Schema.DisplayType.Time ) {
                //Put Field API Name and type details in map.
               mapFldAPINameToType.put(fieldName,String.valueOf(fielddataType));
                system.debug('fieldName' +fieldName);
                system.debug('String.valueOf(fielddataType)'+String.valueOf(fielddataType));   
             }
        }
        system.debug('****mapFldAPINameToType***'+mapFldAPINameToType);

        
        Map<String, Object> resultsMap = (Map<String, Object>) JSON.deserializeUntyped(requestBody);
        removeAttributes(resultsMap);
        system.debug(resultsMap);
        list<Case> lstCase = new List<Case>();
        
        Case objCase = new Case();
        for (String fieldName : resultsMap.keySet()) {
            if(mapFldAPINameToType.containsKey(fieldName.toLowerCase()) && mapFldAPINameToType.get(fieldName.toLowerCase()) == 'DATETIME'){

                DateTime data = dateFormat(String.valueOf(resultsMap.get(fieldName)));
                objCase.put(fieldName, data);

            }
            
           else if(mapFldAPINameToType.containsKey(fieldName.toLowerCase()) && mapFldAPINameToType.get(fieldName.toLowerCase()) == 'DOUBLE'){

                String data = String.valueOf(resultsMap.get(fieldName));
                Decimal dblValue = decimal.valueOf(data); 
                objCase.put(fieldName, dblValue);
            }
            
            else if(mapFldAPINameToType.containsKey(fieldName.toLowerCase()) && mapFldAPINameToType.get(fieldName.toLowerCase()) == 'DATE'){
				system.debug('****DATE***'+String.valueOf(resultsMap.get(fieldName)));
                String data = String.valueOf(resultsMap.get(fieldName)); 
                system.debug('****DATE*Trimmed**'+data);
                objCase.put(fieldName, Date.valueOf(data));
              
            }
            
            else if(mapFldAPINameToType.containsKey(fieldName.toLowerCase()) && mapFldAPINameToType.get(fieldName.toLowerCase()) == 'TIME'){
                Time data = timeFormat(String.valueOf(resultsMap.get(fieldName)));

                objCase.put(fieldName, data);
              
            }
            
            else if(mapFldAPINameToType.containsKey(fieldName.toLowerCase()) && mapFldAPINameToType.get(fieldName.toLowerCase()) == 'BOOLEAN'){
                system.debug(resultsMap.get(fieldName)+'****IN BOOLEAN***'+fieldName);
                objCase.put(fieldName, Boolean.valueOf(resultsMap.get(fieldName)));
            }
            
            else{
                
                objCase.put(fieldName, resultsMap.get(fieldName));
            }
            
        }
        lstCase.add(objCase);

        FSA_CreateCaseResponseWrapper objResponseWrap = new FSA_CreateCaseResponseWrapper();
        Database.SaveResult[] results = database.insert(lstCase,false);
        
        // Iterate SaveResult array
        for (Database.SaveResult result : results) {
            if (result.isSuccess()) {
                //Successfully inserted
                //Handle insertion
                System.debug('Case Successfully inserted, Case Id is: ' + result.getId());
                
				objResponseWrap.id =  result.getId();
                objResponseWrap.success = true;
				FSA_ImageCreation_RestClass.createImage(result.getId(),requestBody);
               
            }
            else {
                //Error ecountered              
                for(Database.Error error : result.getErrors()) {
                    //Handle error
                    System.debug(error.getStatusCode() + ': ' + error.getMessage() + 
                                 ' Fields that affected the error: ' + error.getFields());
                    
                    objResponseWrap.id =  null;
                    objResponseWrap.success = false;
                    objResponseWrap.errorMsg = error.getMessage();
                }
                
            }
        }
        
        return objResponseWrap;
    }
    
    
/*****************************************************************************************************
* Method Name			: dateTimeFormat
* Created Date			: 04/01/2024
* Created By			: Vigneswaran P
* Class Description		: Method for change date time format from YYYY-MM-DD HH:mm:ss 
*******************************************************************************************************/
    public static Datetime dateFormat(String strDateTime){
        try{

            String srtTime = strDateTime.right(11); // Extract the time portion from the string, including the AM/PM indicator
            List<String> lstTimeValues = srtTime.split(':|\\s+'); // Split the time string using ':' or whitespace
            
            String strHour = lstTimeValues[0]; // Extract hours
            String strMin = lstTimeValues[1]; // Extract minutes
            String strSec = lstTimeValues[2].left(2); // Extract seconds and remove the AM/PM indicator
            
            if (strHour.equals('12') && strDateTime.contains('AM')) {
                strHour = '0'; // Handle 12:XX:XX AM as 00:XX:XX
            } else if (strHour.equals('12') && strDateTime.contains('PM')) {
                strHour = '12'; // Handle 12:XX:XX PM as 12:XX:XX
            } else if (strDateTime.contains('PM')) {
                strHour = String.valueOf(Integer.valueOf(strHour) + 12); // Convert hours from 1-11 PM to 13-23
            }
            
            String srtDate = strDateTime.left(10); // Extract the date portion from the string
            List<String> lstDateValues = srtDate.split('-'); // Split the date string into year, month, and day
            
            String strYear = lstDateValues[0]; // Extract year
            String strMonth = lstDateValues[1]; // Extract month
            String strDate = lstDateValues[2]; // Extract day
            
            // Create a Datetime object from the extracted components
            Datetime myDatetimeValue = Datetime.newInstance(
                Integer.valueOf(strYear),
                Integer.valueOf(strMonth),
                Integer.valueOf(strDate),
                Integer.valueOf(strHour),
                Integer.valueOf(strMin),
                Integer.valueOf(strSec)
            );
            
            System.debug('myDatetimeValue: ' + myDatetimeValue); // Print the created Datetime value
            System.debug('myDatetimeValue Format: ' + myDatetimeValue.format()); // Print the formatted Datetime value
            
            return myDatetimeValue;
            
        } catch(DmlException e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
            return null;
        }
        
    }
    
    public static Time timeFormat(String strTime){
        try{
            
            List<String> timeParts = strTime.split(':');
            String secondsString = timeParts[2];
            List<String> secondsParts = secondsString.split('\\.');
            Time convertedTime = Time.newInstance(Integer.valueOf(timeParts[0]), Integer.valueOf(timeParts[1]), Integer.valueOf(secondsParts[0]), Integer.valueOf(secondsParts[1]));
            System.debug(convertedTime); // Outputs 09:13:13.013Z
            return convertedTime;
            
            
        } catch(DmlException e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
            return null;
        }
        
    }

    global class FSA_CreateCaseResponseWrapper{
        global String id;	
        global boolean success;
        global String errorMsg;
    }
    
    global static void removeAttributes(Map<String,Object> params)  {
        for(String key : params.keySet()) {
            if(  key == 'attributes' || key =='parentId' || key == 'imageData' ) {
                params.remove(key);
            } else {
                if(params.get(key) instanceof Map<String,Object>) {
                    removeAttributes((Map<String,Object>)params.get(key));
                }
                if(params.get(key) instanceof List<Object>) {
                    for(Object listItem : (List<Object>)params.get(key)) {
                        if(listItem instanceof Map<String,Object>)  {
                            removeAttributes((Map<String,Object>)listItem);
                        }
                    }
                }
            }
        }  
    }
}