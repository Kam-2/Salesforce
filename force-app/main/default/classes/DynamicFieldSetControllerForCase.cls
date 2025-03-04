/**************************************************************************************
* Class Name            : DynamicFieldSetControllerForCase
* Created Date          : 
* Created By            : 
* Class Description     : Display Fields based on fieldsets from case object and to save records with files.
***************************************************************************************/

public  class DynamicFieldSetControllerForCase {
    
    @AuraEnabled(cacheable = true)
    	public static string getType(String objectApiName, String recordid)
        {
            System.debug('Called GetType');
            System.debug('Called GetType'+recordid);
            Case caserecord = [SELECT Id, FSA_Case_Type__c,FSA_Case_Sub_Type__c from Case where Id=:recordid];
            return caserecord.FSA_Case_Sub_Type__c;
        }

    @AuraEnabled(cacheable = true )
    public static List<FormField> getObjectFields(String objectName, String fieldSet_Name) {
        List<FormField> fields = new List<FormField>();
        System.debug('test');
                 string fieldSetName = getTextTocheck(fieldSet_Name);

        if (String.isNotBlank(objectName) && String.isNotBlank(fieldSetName)) {
            system.debug('1');
            Schema.SObjectType objectType = Schema.getGlobalDescribe().get(objectName);
            Schema.DescribeSObjectResult objectDescribe = objectType.getDescribe();
            Map<String, Schema.FieldSet> fieldSetMap = objectDescribe.fieldSets.getMap();
                        system.debug('1'+fieldSetName);
                        system.debug('1'+fieldSetMap);

            if (fieldSetMap.containsKey(fieldSetName)) {
                Schema.FieldSet fieldSet = fieldSetMap.get(fieldSetName);
                List<Schema.FieldSetMember> fieldSetMembers = fieldSet.getFields();
                
                for (Schema.FieldSetMember fsm : fieldSetMembers) {
                    FormField f = new FormField(fsm);
                    fields.add(f);
                    system.debug('fileds'+fields);
                }
            }
        }
        
        return fields;
    }
    
    public static string getTextTocheck(string actualFieldSetName) {
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
    
    @AuraEnabled
    public static String uploadFiles(String recordId, String filedata) {
        system.debug('recordId'+recordId);
        try {
            if(String.isNotBlank(FileData)) {
                List<FileDataWP> files = (List<FileDataWP>) JSON.deserialize(filedata, List<FileDataWP>.class);
                System.debug(files);
                
                List<ContentVersion> cvList = new List<ContentVersion>();
                for(FileDataWP file : files) {
                    ContentVersion conVer = new ContentVersion();
                    conVer.ContentLocation = 'S'; // S = Salesforce, E = External Files
                    conVer.VersionData = EncodingUtil.base64Decode(file.fileContent);
                    conVer.Title = file.fileName;
                    conVer.PathOnClient = file.fileName;
                    cvList.add(conVer);
                }
                Insert cvList;
                
                List<ContentDocumentLink> cdList = new List<ContentDocumentLink>();
                for(ContentVersion cv : [SELECT ContentDocumentId FROM ContentVersion WHERE Id =: cvList]) {
                    ContentDocumentLink conDocLink = New ContentDocumentLink();
                    conDocLink.LinkedEntityId = recordId;
                    conDocLink.ContentDocumentId = cv.ContentDocumentId;
                    conDocLink.Visibility = 'AllUsers';
                    conDocLink.shareType = 'V'; // V = Viewer, C = Collaborator, I = Inferred
                    cdList.add(conDocLink);
                }
                Insert cdList;        
            } else {
                return 'record Id is Blank';
            }
            return 'success';
        } catch (Exception ex) {
            System.debug(ex.getMessage() + ' -> ' + ex.getStackTraceString());
            throw new AuraHandledException(ex.getMessage());
        }
    }
    
    public class FileDataWP {
        public String fileName;
        public String fileContent;
    }
    
    public class FormField {
        @AuraEnabled
        public Boolean isRequired { get; set; }
        @AuraEnabled
        public String apiName { get; set; }
        @AuraEnabled
        public String label { get; set; }
        @AuraEnabled
        public Boolean required { get; set; }
        @AuraEnabled
        public String type { get; set; }
        @AuraEnabled
        public String value { get; set; }
        
        public FormField(Schema.FieldSetMember f) {
            this.isRequired = f.DBRequired;
            this.apiName = f.fieldPath;
            this.label = f.label;
            this.required = f.required;
            this.type = String.valueOf(f.getType());
        }
    }

        @AuraEnabled(cacheable = true)
    public static Map<String,Object> getFieldSetFieldsByFieldSetName(String objectApiName,String fieldsetName) {

        Map<String,Object> mapObjects = new Map<String,Object>();
                  fieldSetName = getTextTocheck(fieldSetName);

        system.debug('fieldsetName>>> '+fieldsetName);
        List<Schema.FieldSetMember> fieldSetMembers = new List<Schema.FieldSetMember>();
         fieldSetMembers =  ((SObject)Type.forName(objectApiName).newInstance()).getSObjectType().getDescribe().FieldSets.getMap().get(fieldsetName).getFields();
        system.debug('fmem'+fieldSetMembers);
        
        List<FieldSetField> fields = new List<FieldSetField>();
        for (Schema.FieldSetMember fieldSetMember : fieldSetMembers) {
            Schema.SObjectField field = fieldSetMember.getSObjectField();
            if(!field.getDescribe().isCalculated()) {
                system.debug(!field.getDescribe().isCalculated());
            FieldSetField fieldSetField = new FieldSetField(fieldSetMember, fieldsetName,fieldsetName !=null);
            fields.add(fieldSetField);
            } //to add common section condition
        }
        mapObjects.put('FieldsetFields',fields);
        system.debug(mapObjects);
            system.debug(mapObjects.keyset());
            
       // mapObjects.put('DefaultFields',getDefaultFieldSets());
        //if(picklistValue == 'Person Interest - Trip and Fall')
          //  return null;
        //else
            return mapObjects;
            
        
    }


@AuraEnabled(cacheable = true)
    public static Map<String,Object> getAllTypeFieldset() {
        Map<String,Object> mapFieldsets = new Map<String,String>();
        Map<String,Object> mapFieldsetsfull = new Map<String,Object>();
        
                        Map<String,List<String>> dependentPicklistValuesMap = PicklistDependencyClass.getDependentPicklistValues(case.FSA_Case_Sub_Type__c);
        system.debug(dependentPicklistValuesMap);
   List<String> allValues = new List<String>();

        for (List<String> categoryValues : dependentPicklistValuesMap.values()) {
            allValues.addAll(categoryValues);
        }
        system.debug(allValues);
        List<string> picklistValues = new List<string>();
        Schema.DescribeFieldResult fieldResult = case.FSA_Case_Sub_Type__c.getDescribe();
        List<Schema.PicklistEntry> picklistValuesList = fieldResult.getPicklistValues();
        System.debug('fieldResult'+fieldResult);
        System.debug('picklistValuesList'+picklistValuesList);

        for( Schema.PicklistEntry f : picklistValuesList)
        {
            picklistValues.add(f.getLabel());
            
        }
        System.debug('picklistValues'+picklistValues);
        string ActualFieldSetName = '';
        for( string actualPicklistName : picklistValues)
        {	System.debug('actualPicklistName'+actualPicklistName);
        
         if(allValues.contains(actualPicklistName)){
             ActualFieldSetName = getTextTocheck(actualPicklistName);
             system.debug('ActualFieldSetName'+ActualFieldSetName);
             mapFieldsets = getAllTypeFieldsetMethod('case',actualPicklistName,ActualFieldSetName);
             mapFieldsetsfull.put(actualPicklistName,mapFieldsets.get(actualPicklistName));
             system.debug('mapFieldsetsfull'+mapFieldsetsfull);
         }
         
        }
        
        return mapFieldsetsfull;
    }

     @AuraEnabled(cacheable = true)
    public static Map<String,Object> getAllTypeFieldsetMethod(String objectApiName,String actualPicklistName,String fieldsetName) {
        


        Map<String,Object> mapObjects = new Map<String,Object>();
        system.debug(fieldsetName);
        system.debug(objectApiName);

        if(fieldsetName!=''){
             system.debug(fieldsetName);
            List<Schema.FieldSetMember> fieldSetMembers = new List<Schema.FieldSetMember>();
            fieldSetMembers =  ((SObject)Type.forName(objectApiName).newInstance()).getSObjectType().getDescribe().FieldSets.getMap().get(fieldsetName).getFields();
            system.debug('fmem'+fieldSetMembers);
            
            List<FieldSetField> fields = new List<FieldSetField>();
            for (Schema.FieldSetMember fieldSetMember : fieldSetMembers) {
                Schema.SObjectField field = fieldSetMember.getSObjectField();
                if(!field.getDescribe().isCalculated()) {
                    system.debug(!field.getDescribe().isCalculated());
                    FieldSetField fieldSetField = new FieldSetField(fieldSetMember, fieldsetName, fieldsetName!=null);
                    fields.add(fieldSetField);
                }
            }
            if(fieldsetName != 'Person Interest - Trip and Fall')
                mapObjects.put(actualPicklistName,fields);
            // mapObjects.put('DefaultFields',getDefaultFieldSets());
            //if(picklistValue == 'Person Interest - Trip and Fall')
            //  return null;
            //else
            return mapObjects;
            
        }
        else{
            return null;
        }
    }

    public class FieldSetField {
        @AuraEnabled public Boolean dbRequired;
        @AuraEnabled public String apiName;
        @AuraEnabled public String label;
        @AuraEnabled public String value;
        @AuraEnabled public Boolean required;
        @AuraEnabled public String type;
        @AuraEnabled public String section;
        @AuraEnabled public String auraId;
        @AuraEnabled public Boolean isVisible;
         @AuraEnabled
        public Boolean isCalculated;
        
        public FieldSetField(String apiName, Boolean isCalculated) {
            this.apiName = apiName;
            this.isCalculated = isCalculated;
            this.isVisible=true;
           
        }
         public FieldSetField(Schema.FieldSetMember fieldSetMember, String section, Boolean required) {
            this.dbRequired = fieldSetMember.dbRequired;
            this.apiName = fieldSetMember.fieldPath;
            
            //system.debug('FIELDSET Field Api name-->'+fieldSetMember.fieldPath);
            //system.debug('FIELDSET Label-->'+ section);
            this.label = fieldSetMember.label;
            //this.required = required;
            
            this.type = String.valueOf(fieldSetMember.getType());
            this.section = section;
            this.isVisible = true;
            
            
            
        }
    }
    
}