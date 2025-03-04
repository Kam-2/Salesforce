public class MAPPage_CTRL {
    
    public string CaseID = ApexPages.currentPage().getParameters().get('id');
    public string Service_Location{get;set;} 
    public Public_Asset__c This_Asset{get;set;} public string LatValueComp {get; set;} //Get the latval from external common component for DC MAR webservice usage
    public string LongValueComp{get;  set;} //Get the longval from external common component for DC MAR webservice usage
    public list<case> DynamicCaseList = new list<case>();
    public string LatValue;
    public case This_Asset1 {get;set;} 
    public string LongValue;
    public Boolean msg{get;set;} public Boolean Errmsg {get;set;} // For Mapcomponent
  
    public HttpResponse response ;
    
    //For webservice class
  
    
    // Get the multiple nearby addresses from DCMAR 
    
    
    public MApPage_CTRL(){
       This_Asset1 = new case();
        // SOQL all the fields from CASE object.
        
        
        
        
        
    }
    
    //To make sure the address has been passed  lds-button-groups 38.90086371128457
    
    
    
    
   public void AddressPassed(){
       if(ApexPages.currentPage().getParameters().get('addressVal')!=null)
        Service_Location =ApexPages.currentPage().getParameters().get('addressVal');
         if(ApexPages.currentPage().getParameters().get('LatVal')!=null)
        LatValue=ApexPages.currentPage().getParameters().get('LatVal');
         if(ApexPages.currentPage().getParameters().get('LongVal')!=null)
        LongValue=ApexPages.currentPage().getParameters().get('LongVal');
        system.debug('Latvalue to i/p MAR '+ Latvalue);
        system.debug('Lngvalue to i/p MAR '+ LongValue);
          
    }
    
    //To redirect the final page of case submission
    public pagereference Savethe_Record(){
        system.debug('LatVal '+ApexPages.currentPage().getParameters().get('LatVal'));
        system.debug('latval '+LatValueComp);
        system.debug(CaseID);
        // If it is case or Public asset
        if(CaseID.SubString(0,3)!='500'){
            //This_Asset = [select id,latitude_District360__c,longitude_District360__c from Public_asset__c where id=:CaseID limit 1];
           /// This_Asset.latitude_District360__c=LatValue;
           // This_Asset.longitude_District360__c=LongValue;
               //This_Asset.Address_District360__c=Service_Location;
            update This_Asset;
        }else{
            This_Asset1 = [select id,latitude_District360__c,longitude_District360__c from case where id=:CaseID limit 1];
            This_Asset1.latitude_District360__c=LatValue;
            This_Asset1.longitude_District360__c=LongValue;
            This_Asset1.Address_District360__c=Service_Location;
              system.debug(ApexPages.currentPage().getParameters().get('LatVal')); 
            system.debug(LongValueComp);
            update This_Asset1;
        }
       
        
        return null;
        
    }
    // redirect to PA page
    public pagereference Goback(){
         pagereference PA_PAge = new pagereference('/'+CaseID);
        PA_PAge.setRedirect(true); 
        return PA_PAge;
    }
    public pagereference redirecttoRecord(){
        
        pagereference pageref = new pagereference('/'+CaseID);
        
        return pageref;
    }
    public pagereference Previous_SR_Page(){
        pagereference ServiceType_page;
        
        if(CaseID!='')
            ServiceType_page = new pagereference('/apex/NewPublicAssetVF1?id='+CaseID);
        else
            ServiceType_page = new pagereference('/apex/NewPublicAssetVF1');
        // pagereference ServiceType_page = new pagereference('/apex/NewCaseVF?id='+CaseID);
        ServiceType_page .setRedirect(true); 
        return ServiceType_page;
    }
    
    
 
    
}