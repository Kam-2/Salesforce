/**************************************************************************************
* Class Name			: DependentPicklistValues                        CodeCoverage = 93%
* Created Date			: 01-11-2023
* Created By			: Vigneswaran
* Class Description	    : Utility class for getting dependent picklist values 
by passing only the dependent picklist field api will return as map
***************************************************************************************/
public class DependentPicklistValues {
    public static Map<Object,List<String>> getDependentPicklistValues(Schema.sObjectField dependToken)
    {
        //dependent field details as metadata
        Schema.DescribeFieldResult depend = dependToken.getDescribe();
        
        //getting controlling field of the dependent field
        Schema.sObjectField controlToken = depend.getController();
        // system.debug('controlToken '+controlToken);
        
        if ( controlToken == null ) 
        {
            return null;
        }
        
        //controlling field details as metadata
        Schema.DescribeFieldResult control = controlToken.getDescribe();
        
        //checking controlling field type as boolean or not
        List<Schema.PicklistEntry> controlEntries =
            (   control.getType() == Schema.DisplayType.Boolean
             ?   null
             :   control.getPicklistValues()
            );
        Map<Object,List<String>> dependentPicklistValues = valuesFun(depend, controlEntries);
        system.debug(dependentPicklistValues);
        
        return dependentPicklistValues;
    }
    public static Map<Object, List<String>> valuesFun(Schema.DescribeFieldResult depend, List<Schema.PicklistEntry> controlEntries) 
    {
        String base64map = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
        Map<Object, List<String>> dependentPicklistValues = new Map<Object, List<String>>();
        
        for (Schema.PicklistEntry entry : depend.getPicklistValues()) {
            if (entry.isActive()) {
                Map<Object, List<String>> result = processPicklistEntry(entry, controlEntries);
                mergeResult(dependentPicklistValues, result);
            }
        }
        
        return dependentPicklistValues;
    }
    public static Map<Object, List<String>> processPicklistEntry(Schema.PicklistEntry entry, List<Schema.PicklistEntry> controlEntries)
    {
        Map<Object, List<String>> result = new Map<Object, List<String>>();
        
        String validFor = (String) ((Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(entry))).get('validFor');
        List<String> base64chars = String.valueOf(validFor).split('');
        String base64map = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
        for (Integer index = 0; index < (controlEntries != null ? controlEntries.size() : 2); index++)
        {
            Object controlValue = (controlEntries == null)
                ? (Object)(index == 1)
                : (Object)(controlEntries[index].isActive() ? controlEntries[index].getLabel() : null);
                    
                    Integer bitIndex = index / 6;
            Integer bitShift = 5 - Math.mod(index, 6);
            
            if (controlValue == null || (base64map.indexOf(base64chars[bitIndex]) & (1 << bitShift)) == 0)
            {
                continue;
            }
            
            if (!result.containsKey(controlValue)) {
                result.put(controlValue, new List<String>());
            }
            result.get(controlValue).add(entry.getLabel());
        }
        
        return result;
    }
    public static void mergeResult(Map<Object, List<String>> dependentPicklistValues, Map<Object, List<String>> result) 
    {
        for (Object controlValue : result.keySet()) {
            if (!dependentPicklistValues.containsKey(controlValue)) {
                dependentPicklistValues.put(controlValue, new List<String>());
            }
            dependentPicklistValues.get(controlValue).addAll(result.get(controlValue));
        }
    }

}