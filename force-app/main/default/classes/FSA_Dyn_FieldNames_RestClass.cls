/****************************************************************************************
* Class Name			: FSA_Dyn_FieldNames_RestClass
* Created Date			: 19/09/2024
* Created By			: Buvaneswari P
* Class Description		: For showing Dynamic field names in New case screen in FSA App.
*****************************************************************************************/
@RestResource(urlMapping='/getDynamicFieldsList/*')
global class FSA_Dyn_FieldNames_RestClass {
    
    
    @HttpGet  
    global static Sections getCaseFields() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        RestContext.response.addHeader('Content-Type', 'application/json');
        
        String caseType = '';
        caseType = req.params.get('caseType');
        system.debug('caseType###-->'+caseType);
        
        String ambassadorId = '';
        ambassadorId = req.params.get('ambassadorId');
        system.debug('ambassadorId###-->'+ambassadorId);
        
        sections secs = new sections();
        secs.dynamicFields = new List<dynamicField>();
        
        if(caseType!=null){
            
            String fieldNames = '';
            
            list<String> apiName = fieldNames.split(',');
            system.debug('apiName### '+apiName);
            for(String name : apiName){
               dynamicField objDyn = new dynamicField();
               objDyn.name =  name;
               secs.dynamicFields.add(objDyn); 
            }
        }
       
        
        
        return secs;
    }
    
    global class dynamicField{
		 global String name;
    }
     global class sections {
        global List<dynamicField> dynamicFields;
        
    }
}