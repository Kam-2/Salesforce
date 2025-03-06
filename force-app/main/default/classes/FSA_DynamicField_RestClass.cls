/****************************************************************************************
* Class Name			: FSA_DynamicField_RestClass
* Created Date			: 10/06/2024
* Created By			: Senthilnathan R
* Class Description		: For showing Dynamic field in New case screen in FSA App.
*****************************************************************************************/

@RestResource(urlMapping='/getVisibleFields/*')
global class FSA_DynamicField_RestClass {
    
/****************************************************************************************
* Method Name			: getCaseFields
* Created Date			: 10/06/2024
* Created By			: Senthilnathan R
* Class Description		: GET - Method for fetching Visible & In-Visible fields
*****************************************************************************************/    
    
    @HttpGet  
    global static Sections getCaseFields() {
        
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        RestContext.response.addHeader('Content-Type', 'application/json');
        
        String fieldName = '';
        fieldName = req.params.get('fieldName');
        system.debug('fieldName###-->'+fieldName);
        
        String fieldValue = '';
        fieldValue = req.params.get('fieldValue');
        system.debug('fieldValue###-->'+fieldValue);
        
        sections secs = new sections();
        secs.visibleFields = new List<visibleField>();
        secs.inVisibleFields = new List<inVisibleField>();
        
         if(!String.isBlank(fieldName) && !String.isBlank(fieldValue)){
            
           
             
         }
         return secs;
    }
    
    
//WRAPPER CLASS FOR SECTIONS AND FIELDS    
    global class visibleField {
        global String label;
        global String name;
        global String type;
        global Boolean required;
        global List<picklistValue> picklistValues;
        global List<dependency> dependency;
        global String dependentfields;
        //global List<dependentfields> dependentfields;
        global Boolean isToolTipRequired;
        global String toolTipMessage;
        global String getRecordKey;
    }
    
    global class inVisibleField {
        global String label;
        global String name;
        global String type;
        global Boolean required;
        global List<picklistValue> picklistValues;
        global List<dependency> dependency;
        global String dependentfields;
        //global List<dependentfields> dependentfields;
        global Boolean isToolTipRequired;
        global String toolTipMessage;
        global String getRecordKey;
    }
    /*global class dependentfields {
global String dependentfield;
}*/
    global class dependency {
        global String controllingValue;
        //global List<String> dependentValues;
        global List<dependentValue> dependentValue;
    }
    global class dependentValue {
        global String label;
        global String name;
    }
    
    global class picklistValue {        
        global String label;
        global String name;
        //global String icon;
    }
   
       
    global class sections {
        global List<visibleField> visibleFields;
        global List<inVisibleField> inVisibleFields;
    }
}