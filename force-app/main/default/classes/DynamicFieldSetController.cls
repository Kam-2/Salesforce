/**************************************************************************************
* Class Name            : DynamicFieldSetController
* Created Date          : 
* Created By            : Kamal
* Class Description     : Display Fields based on fieldsets from case object and to save records with files.
***************************************************************************************/

public  class DynamicFieldSetController {
    
    @AuraEnabled(cacheable = true )
    public static List<FormField> getObjectFields(String objectName, String fieldSetName) {
        List<FormField> fields = new List<FormField>();
        System.debug('test'+fieldSetName);
        
        // Specify the name of your List Custom Setting and the desired record name
        String customSettingName = 'Case__c';
        String recordName = 'Default'; 
        
        // Query the List Custom Setting to retrieve the specific record
        Case__c customSettingRecord = [SELECT Test_one__c FROM Case__c WHERE Name = :recordName LIMIT 1];
        String customFieldValues ;
        if (customSettingRecord != null) {
            
            customFieldValues = customSettingRecord.Test_one__c;
            
            // Use the fieldValue as needed
            System.debug('Field Value: ' + customSettingRecord);
        } else {
            // Handle the case where the custom setting record doesn't exist
            System.debug('Custom setting record not found.');
        }
              
        if (String.isNotBlank(objectName) && String.isNotBlank(customFieldValues)) {
            Schema.SObjectType objectType = Schema.getGlobalDescribe().get(objectName);
            Schema.DescribeSObjectResult objectDescribe = objectType.getDescribe();
            Map<String, Schema.FieldSet> fieldSetMap = objectDescribe.fieldSets.getMap();
            
            if (fieldSetMap.containsKey(customFieldValues)) {
                Schema.FieldSet fieldSet = fieldSetMap.get(customFieldValues);
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
        
        public FormField(Schema.FieldSetMember f) {
            this.isRequired = f.DBRequired;
            this.apiName = f.fieldPath;
            this.label = f.label;
            this.required = f.required;
            this.type = String.valueOf(f.getType());
        }
    }
}