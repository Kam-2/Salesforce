public with sharing class CasesController {

    @AuraEnabled
    public static List<FormField> getCaseFields(String fieldSetName) {
        List<FormField> fields = new List<FormField>();
        
        if (String.isNotBlank(fieldSetName)) {
            Schema.SObjectType caseType = Case.SObjectType;
            Schema.DescribeSObjectResult caseDescribe = caseType.getDescribe();
            Map<String, Schema.FieldSet> fieldSetMap = caseDescribe.fieldSets.getMap();
            
            if (fieldSetMap.containsKey(fieldSetName)) {
                Schema.FieldSet fieldSet = fieldSetMap.get(fieldSetName);
                List<Schema.FieldSetMember> fieldSetMembers = fieldSet.getFields();
                
                for (Schema.FieldSetMember fsm : fieldSetMembers) {
                    FormField f = new FormField(fsm);
                    fields.add(f);
                }
            }
        }
        
        return fields;
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