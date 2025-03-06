public class Case_Dynamic_Page_CTRL {
    
    @AuraEnabled
    public static List<String> getFieldSet(String sObjectName){
        Schema.SObjectType sObj = Schema.getGlobalDescribe().get(sObjectName);
        List<String> fieldSetList = new List<String>();
        FOR(Schema.FieldSet FS : sObj.getDescribe().fieldSets.getMap().values()){
            fieldSetList.add(fs.getName() +'####'+fs.getLabel());
        }
        return fieldSetList;
    }
    
    @AuraEnabled //@future
    public static string getFieldSetMember(String objectName, String ThisCaseId){
        string CaseTypeValue='';
        string SubTypeValue='';
        Map<string,List<string>> FieldSetNamesMap = new Map<string,List<string>>();
        system.debug('@@thiscaseid'+ThisCaseId);
        CaseTypeValue =[select id,FSA_Case_Type__c from case where id=:ThisCaseId].FSA_Case_Type__c;
        SubTypeValue =[select id,FSA_Case_Sub_Type__c from case where id=:ThisCaseId].FSA_Case_Sub_Type__c;
        system.debug('@@casetype-->'+CaseTypeValue+'@@SubTypeValue-->'+SubTypeValue);
      
        if(SubTypeValue!='General Ambassador services'){
            Schema.SObjectType sObj = Schema.getGlobalDescribe().get(objectName);
            System.debug('CaseTypeValue'+SubTypeValue);
            string Text_To_check = '';
            string ActualFieldSet_Name = '';
            List<string> FieldSetNamesList = new list<string>();
            
          
                if(SubTypeValue!=null && SubTypeValue!=''){
                    ActualFieldSet_Name=SubTypeValue;
            }
             
            if(ActualFieldSet_Name!=null && ActualFieldSet_Name!='') {
                Text_To_check = ActualFieldSet_Name.replace(' - ', '_');
                Text_To_check = Text_To_check.replace('/', '_');
                Text_To_check = Text_To_check.replace('(', '');
                Text_To_check = Text_To_check.replace(')', '');
                Text_To_check = Text_To_check.replace(' ', '_');
            }
           
            Schema.DescribeSObjectResult d =  Case.sObjectType.getDescribe();
            Map<String, Schema.FieldSet> FsMap = d.fieldSets.getMap();
            
            for(String fs:FsMap.keySet()){
                // system.debug(fs +' '+CaseTypeValue);
                if(fs== Text_To_check && Text_To_check!=null && Text_To_check!='' ) {
                    // Text_To_check=fs;
                    system.debug('#####Text to check--> '+Text_To_check);
                    
                    FieldSetNamesList.add(fs);
                    
                }
            }
            
            
            List<string> fieldAPINames = new List<string>();
            system.debug(FieldSetNamesList);
            for(String s :FieldSetNamesList){
                // system.debug(s);
                //fieldAPINames.clear();
                //system.debug(Schema.SObjectType.Case.fieldSets.getMap().get(s));
                Schema.FieldSet  fs1 =  Schema.SObjectType.Case.fieldSets.getMap().get(s);
                
                for(Schema.FieldSetMember FSM :fs1.getFields()){
                    //system.debug(fs1.getLabel()+' '+FSM.fieldPath);
                    fieldAPINames.add(FSM.fieldPath);
                }
                system.debug(fs1.getfields()+' '+fieldAPINames);
                //FieldSetNamesMap.put(fs1.getLabel(),fieldAPINames);
                FieldSetNamesMap.put(fs1.getDescription(),fieldAPINames);
                system.debug('FieldSetNamesMap>>>>'+FieldSetNamesMap);
                fieldAPINames =  new list<string>();
            }
        } 
        /*else {
            Schema.SObjectType sObj = Schema.getGlobalDescribe().get(objectName);
            System.debug('CaseTypeValue>>>'+CaseTypeValue);
            System.debug('SubTypeValue>>>'+SubTypeValue);
            string Text_To_check;
            List<string> FieldSetNamesList = new list<string>();
            
            string ActualFieldSet_Name=SubTypeValue;
            if(ActualFieldSet_Name!=null && ActualFieldSet_Name!='')
                Text_To_check = ActualFieldSet_Name.replace(' ', '_');
            Schema.DescribeSObjectResult d =  Case.sObjectType.getDescribe();
            Map<String, Schema.FieldSet> FsMap = d.fieldSets.getMap();
            
            for(String fs:FsMap.keySet()){
                // system.debug(fs +' '+CaseTypeValue);
                if(fs.containsignorecase(Text_To_check)) {
                    // Text_To_check=fs;
                    FieldSetNamesList.add(fs);
                    
                }
            }
            
            List<string> fieldAPINames = new List<string>();
            system.debug(FieldSetNamesList);
            for(String s :FieldSetNamesList){
                // system.debug(s);
                //fieldAPINames.clear();
                //system.debug(Schema.SObjectType.Case.fieldSets.getMap().get(s));
                Schema.FieldSet  fs1 =  Schema.SObjectType.Case.fieldSets.getMap().get(s);
                
                for(Schema.FieldSetMember FSM :fs1.getFields()){
                    //system.debug(fs1.getLabel()+' '+FSM.fieldPath);
                    fieldAPINames.add(FSM.fieldPath);
                }
                system.debug(fs1.getLabel()+' '+fieldAPINames);
                FieldSetNamesMap.put(fs1.getLabel(),fieldAPINames);
                system.debug('FieldSetNamesMap>>>>'+FieldSetNamesMap);
                fieldAPINames =  new list<string>();
            }
        }*/
        // system.debug(FieldSetNamesMap.values());
        
        /*  if(Text_To_check!=null && Text_To_check!=''  ){
        fs1  = Schema.SObjectType.Case.fieldSets.getMap().get(Text_To_check);
        }
        else
        return null;*/
        // return JSON.serialize(fs1.getFields());
        system.debug(FieldSetNamesMap);
        return JSON.serialize(FieldSetNamesMap);
        
    }
    
    @AuraEnabled
    public static List<string> getInfoFields (string PageLayoutName, String ThisCaseId1){
        string CaseTypeValue='';
        CaseTypeValue =[select id,FSA_Case_Sub_Type__c from case where id=:ThisCaseId1].FSA_Case_Sub_Type__c;
        List<LayoutSection> lstSections = new List<LayoutSection>();
        List<string> FieldAPINames = new List<string>();
        List<String> componentNameList = new List<String>{'Case-App Layout'};
            // Retrieve page layout details 
            List<Metadata.Metadata> components = Metadata.Operations.retrieve(Metadata.MetadataType.Layout, componentNameList);
        Metadata.Layout contLayout = (Metadata.Layout) components.get(0);
        try{
            // We are going to find the fields names and will keep them according to columns so 
            // we can show them as per page layout 
            for( Metadata.LayoutSection ls : contLayout.layoutSections ) {
                // FieldAPINames.add(ls.label);
                LayoutSection section = new LayoutSection( ls.label, ls.layoutColumns.size() );
                
                List<LayoutColumn> lstColumns = new List<LayoutColumn>();
                Integer maxFieldsInColumn = 0;
                for( Metadata.LayoutColumn lc : ls.layoutColumns ) {
                    
                    LayoutColumn column = new LayoutColumn();
                    // check if there are fields available in that column
                    if( lc.layoutItems != null ) { 
                        // Get the max number of fields in a column to preserve the alignment 
                        if( maxFieldsInColumn < lc.layoutItems.size() ) {
                            maxFieldsInColumn = lc.layoutItems.size();
                        }
                        for( Metadata.LayoutItem li : lc.layoutItems ) {
                            
                            // Pass the LayoutItem object in the LayoutField consturctor	    
                            column.lstFields.add( new LayoutField( li ) );
                        }
                    }
                    // No need to add a column in the section if there is no field available 
                    if( column.lstFields.size() > 0 ) {
                        lstColumns.add( column );
                    }
                }
                
                // Now, we need to arrange the fields in section so we can use them in the iteration 
                // on the component so we will have to arrange them in the order 
                if( maxFieldsInColumn > 0 ) {
                    for( Integer i = 0; i < maxFieldsInColumn; i++ ) {
                        for( Integer j = 0; j < lstColumns.size(); j++ ){
                            if( lstColumns[j].lstFields.size() > i ) {
                                if(section.label=='Case Information' || section.label=='Location Details')
                                    FieldAPINames.add(lstColumns[j].lstFields[i].fieldName);
                                
                                
                            }    
                            
                        }    
                    }    
                }
                
            }
            return FieldAPINames;
        }catch(Exception e){
            system.debug('Error in retriving fields '+e.getMessage()+' '+e.getLineNumber());
            throw new AuraHandledException(e.getMessage() +' '+e.getLineNumber());  
        }
    }
    
    public class LayoutField {
        @AuraEnabled public String fieldName;
        @AuraEnabled public Boolean isRequired;
        @AuraEnabled public object fieldValue;
        @AuraEnabled public Boolean isReadOnly;
        
        
        public LayoutField() {}
        
        public LayoutField( Metadata.LayoutItem li ) {
            
            this.fieldName = li.field;
            if( li.behavior == Metadata.UiBehavior.Required ) {
                this.isRequired = true;
            }
            else if( li.behavior == Metadata.UiBehavior.ReadOnly ) {
                this.isReadOnly = true;
            }    
        }
        
    }
    public class LayoutSection {   
        @AuraEnabled public String label;
        @AuraEnabled public List<LayoutField> lstFields;
        @AuraEnabled public Integer totalColumns;
        public LayoutSection( String label, Integer totalColumns ) {
            this.label = label;
            this.totalColumns = totalColumns;
            this.lstFields = new List<LayoutField>();
        }
    }
    
    private class LayoutColumn {
        private List<LayoutField> lstFields;    
        public LayoutColumn() {
            this.lstFields = new List<LayoutField>();
        }
    }
    
}