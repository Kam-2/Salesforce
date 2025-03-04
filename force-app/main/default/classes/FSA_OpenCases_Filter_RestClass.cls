/****************************************************************************************
* Class Name			: FSA_OpenCases_Filter_RestClass
* Created Date			: 10/06/2024
* Created By			: Senthilnathan R
* Class Description		: For filtering open cases by ambassador, created date and case type.
*****************************************************************************************/
@RestResource(urlMapping='/filterapi/*')
global class FSA_OpenCases_Filter_RestClass {
    
/****************************************************************************************
* Method Name			: getFilterFields
* Created Date			: 10/06/2024
* Created By			: Senthilnathan R
* Class Description		: This is a @HttpGet method returns filter fields to display.
*****************************************************************************************/
    global static string objectApi{get; set;}
    
    
    @HttpGet
    global static section getFilterFields() {
        
        
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        RestContext.response.addHeader('Content-Type', 'application/json');
        
        section sec = new section();
        sec.name = 'Open Case filter';
        sec.label = 'Open Case filter';
        sec.fields = new List<field>();
        sec.ambassadorList = new List<ambassador>();
        Map<String,string > apiMetadataMap = new Map<String,string>();
        Map<String,string > queryMetadataMap = new Map<String,string>();
       List<District_360_FSA_API__mdt> apiMetadataList = District_360_FSA_API__mdt.getall().values();
        for(District_360_FSA_API__mdt obj : apiMetadataList)
        {
            apiMetadataMap.put(obj.Label, obj.Api_Name__c);
            queryMetadataMap.put(obj.Label,obj.SOQLQuery__c);
            
            
        }
        objectApi=apiMetadataMap.get('Object');
        Schema.SObjectType sObjectType = Schema.getGlobalDescribe().get(objectApi);
        Schema.DescribeSObjectResult commoncase = sObjectType.getDescribe();
        Map<String, Schema.FieldSet> FsMapcommon = commoncase.fieldSets.getMap();
        List<String> fslistcommon = new List<String>();
        String fsvaluescommon='';
        for(String fs:FsMapcommon.keySet()) {
            if(fs.containsIgnoreCase('Open_Case_Filter')) {
                fsvaluescommon = fs;
                fslistcommon.add(fsvaluescommon);
            }
        }
        system.debug(fslistcommon);
        Schema.FieldSet fs1common;
        
        for(String fsstring:fslistcommon) {
            fs1common = FsMapcommon.get(fsstring);
            //fsm = Schema.SObjectType.Case.fieldSets.fields().getMap().get(fsstring);
            section sec1 = new section();
            sec1.name = fs1common.name;
            sec1.label = fs1common.description;
            sec1.fields = new List<field>();
            field f1 = new field();
            f1.label = 'Sort by';
            f1.name = 'Sort by';
            f1.type = 'PICKLIST';
            List<String> pickvalstr = new List<String>{'None','Oldest','Newest'};
                List<picklistValue> pick1 = new List<picklistValue>();
            for(String pv : pickvalstr) {
                picklistValue pvalues12 = new picklistValue();
                pvalues12.label = pv;
                pvalues12.name = pv;
                pick1.add(pvalues12);
            }
            f1.picklistValues = pick1;
            sec.fields.add(f1);
            
            field f2 = new field();
            f2.label = 'Ambassador';
            f2.name = 'ambassadorName_Filter';
            f2.type = 'PICKLIST';
          List<String> pickvalstr1 = new List<String>{'None'};
                List<picklistValue> pick2 = new List<picklistValue>();
            for(String pv : pickvalstr1) {
                picklistValue pvalues12 = new picklistValue();
                pvalues12.label = pv;
                pvalues12.name = pv;
                pick2.add(pvalues12);
            }
            
            string baseQuery=queryMetadataMap.get('Ambassador Query');
            String query = baseQuery + ' WHERE Active__c = TRUE ORDER BY Name ASC NULLS LAST';

            
            System.debug(query);
            List<SObject> records = Database.query(query);
            System.debug(records);
            string Name=apiMetadataMap.get('Name');
            string id=apiMetadataMap.get('Id');
            string fsaCaseType=apiMetadataMap.get('FSA Case Type');
            
            //for(Ambassador__c objAmbsdr : [SELECT Id,Name,Ambassador_Email__c,OTP__c,Roles__c FROM Ambassador__c WHERE Active__c=True ORDER BY Name ASC NULLS LAST])
                for(SObject objAmbsdr : records){
				picklistValue pvalues12 = new picklistValue();
                pvalues12.label = (string)objAmbsdr.get(Name);
                pvalues12.name = (string)objAmbsdr.get(id);
                pick2.add(pvalues12);
                
            }            

            f2.picklistValues = pick2;
            sec.fields.add(f2);
            
            
            for(Schema.FieldSetMember fsm:fs1common.getfields()) {
                schema.DescribeFieldResult fr = fsm.getSObjectField().getdescribe();
                Schema.DescribeFieldResult typefield = commoncase.fields.getMap().get(fsaCaseType).getDescribe();
                List<Schema.PicklistEntry> typevalues = typefield.getPicklistValues();
                List<String> typevalueslist = new List<String>();
                for(Schema.PicklistEntry typevalue: typevalues) {
                    String tv = String.valueof(typevalue.getValue());
                    
                }
                system.debug(fr.getName());
                field f = new field();
                f.label = fr.getLabel();
                f.name = fr.getName();
                if(f.name == 'Service_Request_Type__c') {
                    f.required = FALSE;
                    f.type = fr.getType().name();
                    if(f.type == 'Picklist') {
                        List<picklistValue> pick = new List<picklistValue>();
                        List<Schema.PicklistEntry> ples = fr.getPicklistValues();
                        picklistValue pvalues1 = new picklistValue();
                        pvalues1.label = 'None';
                        pvalues1.name = 'None';
                        pick.add(pvalues1);
                        for(Schema.PicklistEntry pe: ples) {
                            picklistValue pvalues = new picklistValue();
                            pvalues.label = pe.getLabel();
                            pvalues.name = pe.getValue();
                            pick.add(pvalues);
                        }
                        f.picklistValues = pick;
                    }
                }
                else{
                    f.required = FALSE;
                    f.type = fr.getType().name();
                    if(f.type == 'Picklist') {
                        List<picklistValue> pick = new List<picklistValue>();
                        List<Schema.PicklistEntry> ples = fr.getPicklistValues();
                        picklistValue pvalues1 = new picklistValue();
                        pvalues1.label = 'None';
                        pvalues1.name = 'None';
                        pick.add(pvalues1);
                        
                        f.picklistValues = pick;
                    }
                } 
                
                String dependentfields = '';
                string caseType=apiMetadataMap.get('FSA Case Type');
                                string caseSubType=apiMetadataMap.get('FSA Case Subtype');
                //String dependentfieldstr='';
                if(f.name == caseType) {
                    f.dependentfields = caseSubType;
                }
               /* if(f.name == 'Request_Reason__c') {
                    f.dependentfields = 'Request_Sub_Reason__c ';
                }*/
                
                sec.fields.add(f);  
                
            }
        }

        return sec;
        
    }
    
    //WRAPPER CLASS FOR SECTIONS AND FIELDS
    global class field {
        global String label;
        global String name;
        global String type;
        global Boolean required;
        global List<picklistValue> picklistValues;
        global List<dependency> dependency;
        global String dependentfields;
    }
    
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
        global Boolean sub_request_enabled;
    }
    global class section {
        global String label;
        global String name;
        global List<field> fields;
        global List<ambassador> ambassadorList;
    }
    
    global class ambassador {
        global String Id;
        global String name;
        global String email;
    }
    
    
}