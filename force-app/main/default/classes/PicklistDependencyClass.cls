global class PicklistDependencyClass {
// String dependToken = 'Case_Type_D360__c';
    global static Map<String, List<String>> getDependentPicklistValues(Schema.sObjectField dependToken) {
        Schema.DescribeFieldResult depend = dependToken.getDescribe();
        Schema.sObjectField controlToken = depend.getController();
        if (controlToken == null) {
            return new Map<String, List<String>>();
        }
        //system.debug('controlToken--Line9 '+controlToken);
        Schema.DescribeFieldResult control = controlToken.getDescribe();
        system.debug(control);
        List<Schema.PicklistEntry> controlEntries;
        if(control.getType() != Schema.DisplayType.Boolean) {
            controlEntries = control.getPicklistValues();
        }
        system.debug(controlEntries);
        List<String> pvalues = new List<String>();
        pvalues.add('None');
        for(Schema.PicklistEntry pv: controlEntries) {
            
			pvalues.add(pv.getValue());
        }
        system.debug(pvalues);
        String base64map = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
        Map<String,List<String>> dependentPicklistValues = new Map<String,List<String>>();
        for (Schema.PicklistEntry entry : depend.getPicklistValues()) {
            //system.debug(entry);
            if (entry.isActive() && String.isNotEmpty(String.valueOf(((Map<String,Object>) JSON.deserializeUntyped(JSON.serialize(entry))).get('validFor')))) {
                List<String> base64chars =
                    String.valueOf(((Map<String,Object>) JSON.deserializeUntyped(JSON.serialize(entry))).get('validFor')).split('');
                //system.debug(base64chars);
                for (Integer index = 0; index < (controlEntries != null ? controlEntries.size() : 2); index++) {
                    Object controlValue =
                        (controlEntries == null
                         ?   (Object) (index == 1)
                         :   (Object) (controlEntries[index].isActive() ? controlEntries[index].getLabel() : null)
                        );
                    //system.debug('Line 38'+controlValue);
                    Integer bitIndex = index / 6;
                    //system.debug(bitIndex);
                    if (bitIndex > base64chars.size() - 1) {
                        break;
                    }
                    //system.debug(bitIndex);
                    Integer bitShift = 5 - Math.mod(index, 6);
                    if  (controlValue == null || (base64map.indexOf( base64chars[ bitIndex ] ) & (1 << bitShift)) == 0)
                        continue;
                    system.debug(controlValue);
                    if (!dependentPicklistValues.containsKey((String) controlValue)) {
                        dependentPicklistValues.put((String) controlValue, new List<String>());
                        system.debug('Dep  @@@@-->'+dependentPicklistValues);
                    }
                    dependentPicklistValues.get((String) controlValue).add(entry.getLabel());
                }
            }
        }
        system.debug('DependentPiclist value@@@@-->'+dependentPicklistValues);
        return dependentPicklistValues;
    }
}