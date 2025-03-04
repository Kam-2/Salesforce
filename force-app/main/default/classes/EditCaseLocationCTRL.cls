public class EditCaseLocationCTRL {
    
    public Case EditCase{get;set;}
    public Public_Asset__c EditAsset{get;set;}
    
    public string This_CaseID =ApexPages.currentPage().getParameters().get('id');
    public EditCaseLocationCTRL (ApexPages.StandardController controller){
        // attachedPhotos = new list<Attachment>();
        EditCase = new Case(); EditAsset = new Public_Asset__c();
        //  EditAsset=[select id,name,Type__c,Description__c,latitude__c,longitude__c, TERMINAL_NUMBER__c, INSTALLED__c, LOCKED__c, NUMBER_OF_BIKES__c, NUMBER_OF_EMPTY_DOCKS__c, Damages__c, Temporary_Install__c, Photo__c, Image_URL__c, Needs_Repair__c  from Public_Asset__c where id=:This_AssetID];
       system.debug(This_CaseID);
        try{
        if(This_CaseID.substring(0,3)=='500'){
        EditCase = [select id,latitude_District360__c,longitude_District360__c,Address_District360__c, Type from Case where id=:This_CaseID];  
          system.debug(This_CaseID);}
        else{
       // EditAsset = [select id,latitude_District360__c,longitude_District360__c,Address_District360__c from Public_Asset__c where id=:this_caseID];
          system.debug(This_CaseID);}    
        }
        catch(exception e){system.debug(e+ ''+e.getlinenumber());}
        
    }
    
    
}