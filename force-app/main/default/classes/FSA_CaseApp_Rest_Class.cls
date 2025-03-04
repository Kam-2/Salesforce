/****************************************************************************************
* Class Name			: FSA_CaseApp_Rest_Class
* Created Date			: 
* Created By			: Vigneswaran P
* Class Description		: 
*****************************************************************************************/

@RestResource(urlMapping='/caseappapi/*')
global class FSA_CaseApp_Rest_Class {
    
    /****************************************************************************************
* Method Name			: getCaseDetails
* Created Date			: 
* Created By			: Vigneswaran P
* Class Description		: To get casetype,subtype and subsubtype images and to create dynamic page.
*****************************************************************************************/
    global static List<String> formulaList{ get; set; }
    global static List<String> checkboxList{ get; set; }
    global static Map<String,District_360_FSA__mdt > metadataMap{ get; set; }
    global static string orgBaseUrl{ get; set; }
    global static string commonBG{get; set;}
    global static string objectApi{get; set;}
    global static string typeApi{get; set;}
    global static string typeFieldset{get; set;}
    global static string subtypeApi{get; set;}
    global static string subtypeFieldset{get; set;}
    global static string subsubtypeApi{get; set;}
    global static string subsubtypeFieldset{get; set;}
    
    @HttpGet  
    global static Sections getCaseDetails() {
        
        
        Map<String,string > apiMetadataMap = new Map<String,string>();
        Map<String,string > fieldsetMetadataMap = new Map<String,string>();
        List<District_360_FSA_API__mdt> apiMetadataList = District_360_FSA_API__mdt.getall().values();
        for(District_360_FSA_API__mdt obj : apiMetadataList)
        {
            apiMetadataMap.put(obj.Label, obj.Api_Name__c); //Map has name, Api_Name__c
            fieldsetMetadataMap.put(obj.Label, obj.FieldsetName__c ); //Map has name, FieldsetName__c 
        }
        objectApi = apiMetadataMap.get('Object');
        typeApi = apiMetadataMap.get('Type');
        subtypeApi = apiMetadataMap.get('Sub type');
        subsubtypeApi = apiMetadataMap.get('Sub Subtype');
        
        typeFieldset = fieldsetMetadataMap.get('Type');
        subtypeFieldset = fieldsetMetadataMap.get('Sub type');
        subsubtypeFieldset = fieldsetMetadataMap.get('Sub Subtype');
        
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        RestContext.response.addHeader('Content-Type', 'application/json');
        
        String caseType = '';
        caseType = req.params.get('casetype'); //metadata 
        
        String caseSubtype = '';
        caseSubtype = req.params.get('casesubtype'); //metadata
        
        String caseSubSubtype = '';
        caseSubSubtype = req.params.get('casesubsubtype'); //metadata
        
        system.debug('CaseType@@@@@22--> '+caseType);
        system.debug('caseSubtype###22-->'+caseSubtype);
        system.debug('caseSubSubtype###22-->'+caseSubSubtype); 
        
        //List<District_360_FSA__mdt> metadataList = District_360_FSA__mdt.getall().values();
        List<District_360_FSA__mdt> metadataList =[SELECT Active__c, Full_Name__c,BG_color_code__c, Checkbox_fields_in_UI__c, Formula_Fields__c, Icon_url__c, Org_Base_Url__c, Subtype_dependency__c, Type_dependency__c FROM District_360_FSA__mdt  where Active__c = true];
        metadataMap = new Map<String,District_360_FSA__mdt>();
        
        for(District_360_FSA__mdt obj : metadataList)
        {
            metadataMap.put(obj.Full_Name__c, obj); //Map has subtype full name, obj
        }
        District_360_FSA__mdt metadaCom = metadataMap.get('Common fields'); 
        orgBaseUrl = metadaCom.Org_Base_Url__c;
        
        string typeDep = metadaCom.Type_dependency__c;
        List<String> typDepList = typeDep.split(',');
        
        string subtypeDep = metadaCom.Subtype_dependency__c ;
        List<String> subDepList = subtypeDep.split(',');
        
        string formulaFields = metadaCom.Formula_Fields__c ;
        formulaList = formulaFields.split(',');
        
        commonBG = metadaCom.BG_color_code__c;
        
        string checkboxFields = metadaCom.Checkbox_fields_in_UI__c;
        checkboxList = checkboxFields.split(',');
        
        List<string> types = new List<string>();
        //Schema.DescribeFieldResult fieldResulttype = case.Type.getDescribe(); // case and type from metadata 
        Schema.DescribeSObjectResult  sObjectDes = Schema.getGlobalDescribe().get(objectApi).getDescribe();        
        Schema.DescribeFieldResult fieldResulttype = sObjectDes.fields.getMap().get(typeApi).getDescribe();
        
        List<Schema.PicklistEntry> picklistValuesListtype = fieldResulttype.getPicklistValues();
        
        for( Schema.PicklistEntry f : picklistValuesListtype)
        {
            types.add(f.getLabel());
        }
        
        List<string> subTypes = new List<string>();
        //Schema.DescribeFieldResult fieldResult = case.Case_Subtype__c.getDescribe();
        Schema.DescribeFieldResult fieldResult = sObjectDes.fields.getMap().get(subtypeApi).getDescribe();
        List<Schema.PicklistEntry> picklistValuesList = fieldResult.getPicklistValues();
        
        for( Schema.PicklistEntry f : picklistValuesList)
        {
            subTypes.add(f.getLabel());
        }
        
        List<string> subSubTypes = new List<string>();
        if((subsubtypeApi != null) && (subsubtypeApi !='Test'))
        {

        //Schema.DescribeFieldResult fieldResult2 = case.Sub_SubType__c.getDescribe();
        Schema.DescribeFieldResult fieldResult2 = sObjectDes.fields.getMap().get(subsubtypeApi).getDescribe();
        List<Schema.PicklistEntry> picklistValuesList2 = fieldResult2.getPicklistValues();
        
        for( Schema.PicklistEntry f : picklistValuesList2)
        {
            subSubTypes.add(f.getLabel());
        }
        }
        sections secs = new sections();
        secs.sections = new List<section>();
        
        //if selected subtype is there in subDepList(which is the subtypes list of having sub-subtypes)
        if((caseSubSubtype =='' || caseSubSubtype == null) && !subDepList.contains(caseSubtype)){
            caseSubSubtype ='N/A';
        }
        //if selected subtype is there in typDepList(which is the types list of having no subtypes)
        if((caseSubtype =='' || caseSubtype == null )&& typDepList.contains(caseType)){
            caseSubtype='N/A';
        }
        
        //If no type is selected, will return all types and its icon,BGscolorcode
        if((caseType == null || caseType == '' || caseType == 'None') &&
           (caseSubtype == null || caseSubtype == '' || caseSubtype == 'None')){
               secs = getcasetypenull();
           } 
        
        //If any type is selected and subtype is null, will return all types and its subtypes with its icon,BGscolorcode
        if( (Casetype !=null && caseSubtype== null || Casetype != '' && 
             caseSubtype ==''   || Casetype != 'None' && caseSubtype =='None') && types.contains(Casetype))
        {
            secs = getcasesubtypenull();
        }

        
        if(Casetype != '' && types.contains(Casetype) && !subDepList.contains(caseSubtype) &&
           !string.isBlank(caseSubtype) && casesubsubtype=='N/A')
        {
            secs = getcasesubtype(caseSubType);
        }
                /* These method will be used for getting sub-subtype fields


        if(Casetype != ''  && caseSubtype != ''  && (caseSubSubtype == '' || caseSubSubtype == null)&&
           subDepList.contains(caseSubtype) && subTypes.contains(caseSubtype) && types.contains(Casetype)) 
        {
            secs = getcaseSubSubtypenull();
        }

        if(Casetype != '' && caseSubtype != '' && types.contains(Casetype) && subSubTypes.contains(caseSubSubtype)) 
        {
           secs = getcasesubsubtype(caseSubSubtype);
        }
        */
        return secs;
    }
    
    //WRAPPER CLASS FOR SECTIONS AND FIELDS
    global class Field {
        global String label;
        global String name;
        global String type;
        global String firstLabel;
        global String midLabel;
        global String lastLabel;
        global Boolean required;
        global List<picklistValue> picklistValues;
        global List<dependency> dependency;
        global String dependentfields;
        //global List<dependentfields> dependentfields;
        global Boolean isToolTipRequired;
        global String toolTipMessage;
        global String getRecordKey;
        global String selectedValue;
        global String selectedDisplayValue;
    }
    /*global class dependentfields {
global String dependentfield;
}*/
    global class Dependency {
        global String controllingValue;
        //global List<String> dependentValues;
        global List<dependentValue> dependentValue;
    }
    global class DependentValue {
        global String label;
        global String name;
        global String icon;
        global String bgColorCode;
        
    }
    
    global class PicklistValue {        
        global String label;
        global String name;
        global String icon;
        global String bgColorCode;
        global String type;
    }
    global class Section {
        global String label;
        global String name;
        global List<field> fields;
    }
    global class Sections {
        global List<section> sections;
    }
   global static string getTextTocheck(string actualFieldSetName) {
       string textToCheck='';
        if(actualFieldSetName!=null && actualFieldSetName!='' ) {
            textToCheck = actualFieldSetName.replace(' - ', '_');
            textToCheck = textToCheck.replace('/', '_');
            textToCheck = textToCheck.replace(' (', '_');
            textToCheck = textToCheck.replace(')', '');
            textToCheck = textToCheck.replace(', ', '_');
            textToCheck = textToCheck.replace('.', '');
            textToCheck = textToCheck.replace('-', '_');
            textToCheck = textToCheck.replace(' ', '_');
            textToCheck = textToCheck.replace('|', '');
        }
        return textToCheck;
    }
   /* 
    global static Sections getcaseSubSubtypenull(){
        system.debug('Entered caseSubSubtype null with values in custom metadata where subtype is having sub-subtypes');//inside if formula same as above
        sections secs = new sections();
        secs.sections = new List<section>();
        
        //Schema.DescribeSObjectResult commoncase = Case.sObjectType.getDescribe(); // case from custom metadata 
        Schema.SObjectType sObjectType = Schema.getGlobalDescribe().get(objectApi);        
        Schema.DescribeSObjectResult commoncase = sObjectType.getDescribe();
        
        Map<String, Schema.FieldSet> fsMapCommon = commoncase.fieldSets.getMap();
        List<String> fslistcommon = new List<String>();
        String fsvaluescommon='';
        for(String fs:fsMapCommon.keySet()) {
            
            if(fs.containsIgnoreCase(subsubtypeFieldset)) { // from custom metadata 
                fsvaluescommon = fs;
                fslistcommon.add(fsvaluescommon);
            }
        }
        Schema.FieldSet fs1common;
        
        for(String fsstring:fslistcommon) {
            Schema.DescribeSObjectResult  sObjectDes = Schema.getGlobalDescribe().get(objectApi).getDescribe();        
            fs1common = sObjectDes.fieldSets.getMap().get(fsstring); //case to be fetched from metadata
            //fs1common = Schema.SObjectType.Case.fieldSets.getMap().get(fsstring); // case from custom metadata 
            section sec = new section();
            sec.name = fs1common.name;
            sec.label = fs1common.description;
            sec.fields = new List<field>();
            for(Schema.FieldSetMember fsm:fs1common.getfields()) {
                schema.DescribeFieldResult fr = fsm.getSObjectField().getdescribe();
                //Schema.DescribeFieldResult typefield = Case.Sub_SubType__c.getDescribe(); // Case and Sub_SubType__c from custom metadata 
                Schema.DescribeFieldResult typefield = sObjectDes.fields.getMap().get(subsubtypeApi).getDescribe();
                List<Schema.PicklistEntry> typevalues = typefield.getPicklistValues();
                List<String> typevalueslist = new List<String>();
                for(Schema.PicklistEntry typevalue: typevalues) {
                    String tv = String.valueof(typevalue.getValue());
                }
                String helptext = '';
                helptext = fr.getSObjectField().getDescribe().getInlineHelpText();
                
                if(!formulaList.contains(fr.getName())) {
                    getcasesubtypenullSection(fr,helptext,sec);  
                }
                
            }
            secs.sections.add(sec);
        }
        return secs;
    }

     global static sections getcasesubsubtype(string caseSubSubtype){
        sections secs = new sections();
        secs.sections = new List<section>();
        system.debug('Entered caseSubSubtype values in custom label');
        
        string textToCheck = getTextTocheck(caseSubSubtype);
        //Schema.DescribeSObjectResult d = Case.sObjectType.getDescribe(); //from metadata
        Schema.SObjectType sObjectType = Schema.getGlobalDescribe().get(objectApi);        
        Schema.DescribeSObjectResult d = sObjectType.getDescribe();
        
        Map<String, Schema.FieldSet> fsMap = d.fieldSets.getMap();
        List<String> fslist = new List<String>();
        String fsvalues='';
        for(String fs:fsMap.keySet()) {
            Schema.FieldSet fsObj = fsMap.get(fs);
            String fieldSetLabel = fsObj.getLabel();
            if(fs.containsIgnoreCase(textToCheck)) {
                fsvalues = fs;
                fslist.add(fsvalues);
            }
            else if(fieldSetLabel == caseSubSubtype)
            {
                fsvalues = fs;
                fslist.add(fsvalues);
            }
        } 
        if (fslist.isEmpty()) {
            fslist.add('Common_fields');
        }
        
        Schema.FieldSet fs1;
        
        for(String fsstring : fslist) {
            Schema.DescribeSObjectResult  sObjectDes = Schema.getGlobalDescribe().get(objectApi).getDescribe();        
            fs1 = sObjectDes.fieldSets.getMap().get(fsstring); //case  from metadata
            //fs1 = Schema.SObjectType.Case.fieldSets.getMap().get(fsstring); //from metadata
            section sec = new section();
            if(fs1.name == 'Common_fields')
            {
                sec.name = caseSubSubtype; 
            }
            else 
            {
                sec.name = fs1.name;    
            }
            
            sec.label = fs1.description;
            sec.fields = new List<field>();
            for(Schema.FieldSetMember fsm : fs1.getfields()) {
                schema.DescribeFieldResult fr = fsm.getSObjectField().getdescribe();
                String helptext = '';
                helptext = fr.getSObjectField().getDescribe().getInlineHelpText();
                if(!formulaList.contains(fr.getName())){
                   getcaseSection(fr,helptext,sec);
                }
            }
            secs.sections.add(sec);
        }
        return secs;
    } */
    global static sections getcasesubtype(string caseSubType){
        sections secs = new sections();
        secs.sections = new List<section>();
        system.debug('Entered caseSubSubtype null with values in custom metadata where subtype is not having sub-subtypes');
        string textToCheck = getTextTocheck(caseSubType);
        system.debug('TEXT to check@@@@  '+textToCheck);
        //Schema.DescribeSObjectResult d = Case.sObjectType.getDescribe(); //case from metadata
        Schema.SObjectType sObjectType = Schema.getGlobalDescribe().get(objectApi);        
        Schema.DescribeSObjectResult d = sObjectType.getDescribe();
        
        Map<String, Schema.FieldSet> fsMap = d.fieldSets.getMap();
        List<String> fslist = new List<String>();
        String fsvalues='';
        
        for(String fs:fsMap.keySet()) {
            if(fs.containsIgnoreCase(textToCheck)) {
                fsvalues = fs;
                fslist.add(fsvalues);
            }
        }
        Schema.FieldSet fs1;
        
        for(String fsstring : fslist) {
            Schema.DescribeSObjectResult  sObjectDes = Schema.getGlobalDescribe().get(objectApi).getDescribe();        
            fs1 = sObjectDes.fieldSets.getMap().get(fsstring); //case  from metadata
           // fs1 = Schema.SObjectType.Case.fieldSets.getMap().get(fsstring); 
            section sec = new section();
            sec.name = fs1.name;
            sec.label = fs1.description;
            sec.fields = new List<field>();
            for(Schema.FieldSetMember fsm : fs1.getfields()) {
                schema.DescribeFieldResult fr = fsm.getSObjectField().getdescribe();
                String helptext = '';
                helptext = fr.getSObjectField().getDescribe().getInlineHelpText();
                if(!formulaList.contains(fr.getName())){
                    getcaseSection(fr,helptext,sec);
                }
            }
            secs.sections.add(sec);
        }
        return secs;
    }
    global static Section getcaseSection(schema.DescribeFieldResult fr, string helptext, Section sec){
        field f = new field();
        f.label = fr.getLabel();
        f.name = fr.getName();
        Schema.DisplayType fieldType = fr.type;
        f.type = fieldType.name();
        if(helptext != '' && helptext != null) {
            f.isToolTipRequired = TRUE;
        }
        else {
            f.isToolTipRequired = FALSE;
        }
        f.toolTipMessage = helptext;
        if(f.type != 'TEXTAREA') {
            if(checkboxList.contains(f.name)) {
                f.type = 'RADIO';
                List<picklistValue> pick = new List<picklistValue>();
                List<Schema.PicklistEntry> ples = fr.getPicklistValues();
                
                for(Schema.PicklistEntry pe: ples) {
                    picklistValue pvalues = new picklistValue();
                    pvalues.label = pe.getLabel();
                    pvalues.name = pe.getValue();
                    pick.add(pvalues);
                }
                f.picklistValues = pick;
            }
        }
        if(f.type == 'Picklist' || f.type == 'MULTIPICKLIST') {
            List<picklistValue> pick = new List<picklistValue>();
            List<Schema.PicklistEntry> ples = fr.getPicklistValues();
            picklistValue pvalues1 = new picklistValue();
            if(f.type != 'MULTIPICKLIST') {
                pvalues1.label = 'None';
                pvalues1.name = '';
                pick.add(pvalues1);
            }
            for(Schema.PicklistEntry pe: ples) {
                picklistValue pvalues = new picklistValue();
                pvalues.label = pe.getLabel();
                pvalues.name = pe.getValue();
                pick.add(pvalues);
            }
            f.picklistValues = pick;
        }
        sec.fields.add(f);
        return sec;                
    }
    
    
    
    global static Sections getcasesubtypenull() {
        system.debug('Entered caseSubtype null');
        
        sections secs = new sections();
        secs.sections = new List<section>();
        
        //Schema.DescribeSObjectResult commoncase = Case.sObjectType.getDescribe(); // from metadata 
        Schema.SObjectType sObjectType = Schema.getGlobalDescribe().get(objectApi);        
        Schema.DescribeSObjectResult commoncase = sObjectType.getDescribe();
        
        Map<String, Schema.FieldSet> fsMapCommon = commoncase.fieldSets.getMap();
        List<String> fslistcommon = new List<String>();
        String fsvaluescommon='';
        for(String fs:fsMapCommon.keySet()) {
            if(fs.containsIgnoreCase(subtypeFieldset)) { // from metadata 
                fsvaluescommon = fs;
                fslistcommon.add(fsvaluescommon);
            }
        }
        Schema.FieldSet fs1common;
        
        for(String fsstring:fslistcommon) {
            Schema.DescribeSObjectResult  sObjectDes = Schema.getGlobalDescribe().get(objectApi).getDescribe();        
            fs1common = sObjectDes.fieldSets.getMap().get(fsstring); //case to be fetched from metadata
            //fs1common = Schema.SObjectType.Case.fieldSets.getMap().get(fsstring); // from metadata 
            section sec = new section();
            sec.name = fs1common.name;
            sec.label = fs1common.description;
            sec.fields = new List<field>();
            for(Schema.FieldSetMember fsm:fs1common.getfields()) {
                schema.DescribeFieldResult fr = fsm.getSObjectField().getdescribe();
                //Schema.DescribeFieldResult typefield = Case.Case_Subtype__c.getDescribe(); // case and subtype from metadata  
                Schema.DescribeFieldResult typefield = sObjectDes.fields.getMap().get(subtypeApi).getDescribe();
                List<Schema.PicklistEntry> typevalues = typefield.getPicklistValues();
                List<String> typevalueslist = new List<String>();
                for(Schema.PicklistEntry typevalue: typevalues) {
                    String tv = String.valueof(typevalue.getValue());
                }
                String helptext = '';
                helptext = fr.getSObjectField().getDescribe().getInlineHelpText();
                
                if(!formulaList.contains(fr.getName())) {
                    getcasesubtypenullSection(fr,helptext,sec);
                }
            }
            secs.sections.add(sec);
        }
        return secs;
    }
    global static Section getcasesubtypenullSection(schema.DescribeFieldResult fr, string helptext, Section sec){
        field f = new field();
        f.label = fr.getLabel();
        f.name = fr.getName();
        Schema.DisplayType fieldType = fr.type;
        f.type = fieldType.name();
        if(f.name == subtypeApi) { //from metadata
            f.required = TRUE;
        }
        else 
        {
            f.required = FALSE;
        }
        f.type = fr.getType().name();
        if(helptext != '' && helptext != null) {
            f.isToolTipRequired = TRUE;
        }
        else {
            f.isToolTipRequired = FALSE;
        }
        f.toolTipMessage = helptext;
        
        Schema.sObjectField dependentField = fr.getSObjectField();
        Map<String,List<String>> dependentPicklistValuesMap = PicklistDependencyClass.getDependentPicklistValues(dependentField);
        
        if(dependentPicklistValuesMap.size() != 0) {
            List<dependency> dependlist = new List<dependency>();
            for(String dep : dependentPicklistValuesMap.keyset()) {
                List<dependentValue> depvallist = new List<dependentValue>();
                List<String> depvalstrlist = new List<String>();
                dependency depend = new dependency();
                depend.controllingValue = dep;
                
                depvalstrlist = dependentPicklistValuesMap.get(dep);
                for(String d : dependentPicklistValuesMap.get(dep)) {
                    dependentValue depvalue = new dependentValue();
                    depvalue.name = d;
                    depvalue.label = d;
                    string strLable = d;
                    if(metadataMap.containsKey(strLable)){
                        District_360_FSA__mdt typIcon = metadataMap.get(strLable);
                        depvalue.icon= orgBaseUrl+typIcon.Icon_url__c;
                        if(!String.isBlank(typIcon.BG_color_code__c)){
                            depvalue.bgColorCode =typIcon.BG_color_code__c;  
                        }
                        else{
                            depvalue.bgColorCode =commonBG;  
                        }
                    }
                    depvallist.add(depvalue);
                }
                
                dependlist.add(depend);
                depend.dependentValue = depvallist;
            }
            f.dependency = dependlist;
        }
        sec.fields.add(f);
        
        return sec;                
    }
    
    global static Sections getcasetypenull() {
        system.debug('Entered casetype null');       
        
        sections secs = new sections();
        secs.sections = new List<section>();
        
        //Schema.DescribeSObjectResult commoncase = Case.sObjectType.getDescribe();//case to be fetched from metadata
        Schema.SObjectType sObjectType = Schema.getGlobalDescribe().get(objectApi);        
        Schema.DescribeSObjectResult commoncase = sObjectType.getDescribe();
        Map<String, Schema.FieldSet> fsMapCommon = commoncase.fieldSets.getMap();
        List<String> fslistcommon = new List<String>();
        String fsvaluescommon='';
        for(String fs:fsMapCommon.keySet()) {
            if(fs.containsIgnoreCase(typeFieldset)) { //Case Type to be fetched from metadata
                fsvaluescommon = fs;
                fslistcommon.add(fsvaluescommon);
            }
        }
        Schema.FieldSet fs1common;
        
        for(String fsstring:fslistcommon) {
            //fs1common = Schema.SObjectType.Case.fieldSets.getMap().get(fsstring); //case to be fetched from metadata
            Schema.DescribeSObjectResult  sObjectDes = Schema.getGlobalDescribe().get(objectApi).getDescribe();        
            fs1common = sObjectDes.fieldSets.getMap().get(fsstring); //case to be fetched from metadata
            section sec = new section();
            sec.name = fs1common.name;
            sec.label = fs1common.description;
            sec.fields = new List<field>();
            for(Schema.FieldSetMember fsm:fs1common.getfields()) {
                schema.DescribeFieldResult fr = fsm.getSObjectField().getdescribe();
                // Schema.DescribeFieldResult typefield = Case.Type.getDescribe();//case and type to be fetched from metadata
                Schema.DescribeFieldResult typefield = sObjectDes.fields.getMap().get(typeApi).getDescribe();
                List<Schema.PicklistEntry> typevalues = typefield.getPicklistValues();
                List<String> typevalueslist = new List<String>();
                for(Schema.PicklistEntry typevalue: typevalues) {
                    String tv = String.valueof(typevalue.getValue());
                    
                }
                String helptext = '';
                helptext = fr.getSObjectField().getDescribe().getInlineHelpText();
                
                if(!formulaList.contains(fr.getName())) {
                    getcasetypenullSection(fr,helptext,sec);
                }
            }
            secs.sections.add(sec);
        }
        return secs;
    }
    global static Section getcasetypenullSection(schema.DescribeFieldResult fr, string helptext, Section sec){
        field f = new field();
        f.label = fr.getLabel();
        f.name = fr.getName();
        Schema.DisplayType fieldType = fr.type;
        f.type = fieldType.name();
        if(f.name == typeApi|| f.name == subtypeApi) { //type and subtype to be fetched from metadata
            f.required = TRUE;
        }
        else 
        {
            f.required = FALSE;
        } 
        
        f.type = fr.getType().name();
        if(helptext != '' && helptext != null) {
            f.isToolTipRequired = TRUE;
        }
        else {
            f.isToolTipRequired = FALSE;
        }
        f.toolTipMessage = helptext;
        if(f.type == 'Picklist' || f.type == 'MULTIPICKLIST') {
            List<picklistValue> pick = new List<picklistValue>();
            List<Schema.PicklistEntry> ples = fr.getPicklistValues();
            picklistValue pvalues1 = new picklistValue();
            for(Schema.PicklistEntry pe: ples) {
                picklistValue pvalues = new picklistValue();
                pvalues.label = pe.getLabel();
                pvalues.name = pe.getValue();
                string strLable = pe.getLabel();
                if(metadataMap.get(strLable)!=null){
                    District_360_FSA__mdt typIcon = metadataMap.get(strLable);
                    pvalues.icon= orgBaseUrl+typIcon.Icon_url__c;
                    if(!String.isBlank(typIcon.BG_color_code__c)){
                        pvalues.bgColorCode =typIcon.BG_color_code__c;  
                        
                    }
                } 
                pick.add(pvalues);
            }
            f.picklistValues = pick;
        }
        
        String dependentfields = '';
        
        if(f.name == typeApi) { // from metadata 
            
            f.dependentfields = subtypeApi; // from metadata 
        }
        
        if(f.name == subtypeApi) { // from metadata 
            
            f.dependentfields = subsubtypeApi; // from metadata 
        }
        
        sec.fields.add(f);
        return sec;                
    }
}