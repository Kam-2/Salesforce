/**************************************************************************************
* Class Name			: FSA_LoginPage_RestClass
* Created Date			: 4th Jun, 2024	
* Created By			: Senthilnathan R
* Class Description		: Custom API class to support FSA Ambassador login using  mechanisum.	
* Last modified by		: Buvaneswari P
***************************************************************************************/

@RestResource(urlMapping='/login/*')
global with sharing class FSA_LoginPage_RestClass {
    
    /**************************************************************************************
* Method Name			: getAmbassador
* Created Date			: 4th Jun, 2024
* Created By			: Senthilnathan R
* Class Description		: This is a @HttpGet method queries all the Ambassadors and returns a list.
***************************************************************************************/
    @HttpGet
    global static Ambassadors getAmbassador() {
        try{
            RestRequest request = RestContext.request;
            
            Ambassadors objambassadors  = new Ambassadors();
            objambassadors.ambassadorList = new List<ambassador>();
            objambassadors.keyStr = 'Ambassadors';
            
             Map<String, String> apiMetadataMap = new Map<String, String>();
             Map<String, String> queryMetadataMap = new Map<String, String>();
             Map<String, String> urls = new Map<String, String>();
            // Retrieve custom metadata
            
            
            List<District_360_FSA_API__mdt> apiMetadataList = District_360_FSA_API__mdt.getAll().values();
            
            
            for (District_360_FSA_API__mdt obj : apiMetadataList) {
                queryMetadataMap.put(obj.Label, obj.SOQLQuery__c); 
                urls.put(obj.label,obj.url__c);
                apiMetadataMap.put(obj.Label,obj.Api_Name__c);
                
            }
            
            //objambassadors.privacyURL=urls.get('Privacy url');
            // objambassadors.userManual=urls.get('User Manual');
            //objambassadors.googleApiKey =urls.get('GoogleAPI_Key_CasesPA');
            string id=apiMetadataMap.get('Id');
            string name=apiMetadataMap.get('Name');
            string email=apiMetadataMap.get('email');
            string otp=apiMetadataMap.get('Otp');
            string roles=apiMetadataMap.get('Roles');
            
            
            
            
            String baseQuery = queryMetadataMap.get('Ambassador Query');
            String query = baseQuery + ' WHERE Active__c = TRUE ORDER BY Name ASC NULLS LAST';

            
            System.debug(query);
            List<SObject> records = Database.query(query);
            System.debug(records);

        
            for (SObject record : records) {
                Ambassador objAmb = new Ambassador();
                objAmb.id = (String)record.get(id);
                objAmb.name = (String)record.get(name);
                objAmb.email = (String)record.get(email);
                objAmb.password = (String)record.get(otp);
                objAmb.role = (String)record.get(roles);
                if((String)record.get(roles)=='Team Member'){
                    objamb.role = 'TeamMember';    
                } else{
                    objamb.role = (String)record.get(roles);     
                }
                
                objAmbassadors.ambassadorList.add(objAmb);
            }
            
            system.debug('CHECK Response'+objambassadors.ambassadorList );
            return objambassadors;
        } catch(Exception e) {
            System.debug('An exception occurred: ' + e.getMessage());
            return null;
        }
    }
    
    //WRAPPER CLASS FOR AMBASSADOR LIST
     global class ambassador {
        global String Id;
        global String name;
        global String email;
        global String password;
        global String team;
        global String role;
        global String roleDisplayName;
        
        
    }
    global class ambassadors {
        global String keyStr;
        global String privacyURL;
        global String userManual;
        global String googleApiKey;
        global String typeLabel;
        global String subtypeLabel;
        global String subsubtypeLabel;
        global String typeAPi;
        global String subtypeAPi;
        global String subsubtypeAPi;
        global List<ambassador> ambassadorList;
    }
    global class loginResponse {
        global boolean status;
        global String message;
    }
    
    
}