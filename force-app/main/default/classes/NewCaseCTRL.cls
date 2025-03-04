public class NewCaseCTRL {

    /*String Variables */
    public integer Activepath{get;set;}
    public string whoare{get;set;} /* All variables are declared for the input values from VF */
    public string typeval{get;set;}
    public string subtypeval{get;set;}
    public string statusval{get;set;}
    public string descval{get;set;}
 
   public Transient string  ParentCaseId {get;set;}
    public string Selectedaddress{get;set;}
    public string LatValue{get;set;} // getting from Javascript
 
     /* Other Variables & Sobject Variables */
     List<String> contentDocumentIds = new List<String>();
   //public ContentVersion contentVerse = new ContentVersion();
        public string toDelete_contentlink;
    public Map<string,string> ContentDocLinkIDs_ToDelete = new Map<string,string>();

    public  case new_case{get;set;}  // Instance of the Case object to save the record
    public list<case> CaseList_ToInsert = new list<case>();
  
  
 
 /*CONSTRUCTOR - Holding the Initialization of the Sobject Variables */
    public NewCaseCTRL(ApexPages.StandardController controller) {
      new_case=new case();
      Activepath=1;
      system.debug('Latval '+LatValue);

    }
 
 /*For capturing lat,lomg,Address values when the Map position changed   */
 public void AddressPassed(){
          new_case.Address_District360__c =ApexPages.currentPage().getParameters().get('addressVal');
        
        //LatValue=ApexPages.currentPage().getParameters().get('LatVal');
       // LongValue=ApexPages.currentPage().getParameters().get('LongVal');
        new_case.latitude_District360__c=ApexPages.currentPage().getParameters().get('LatVal');
        new_case.longitude_District360__c=ApexPages.currentPage().getParameters().get('LongVal');
        system.debug( new_case.latitude_District360__c);
         //system.debug(  PAsset.Address_District360__c);
    }
   /* Method calls when a section changed */
   public void sectionchanged(){
         system.debug(ApexPages.currentPage().getParameters().get('ClickedActivePath'));
       if(ApexPages.currentPage().getParameters().get('ClickedActivePath')!=null){
           Activepath=integer.valueOf(ApexPages.currentPage().getParameters().get('ClickedActivePath'));
         
       }else
       Activepath+=1;
   }
   /* Method for inserting the case into SF Database */
    public pagereference Save_Case(){
    
    pagereference pageref;
 // Convert the file into ContentDocument
 
 
   
    //new_case.Type=subtypeval;
    //new_case.description=descval;
   //new_case.Address_District360__c=Selectedaddress;
  // new_case.latitude_District360__c=String.valueof(LatValue);
   //new_case.Longitude_District360__c =String.valueof(LongValue);
  // new_case.Who_are_you_District360__c=whoare;
   System.debug('address'+Selectedaddress);
   CaseList_ToInsert.add(new_case);
   //Inserting the case
    try{
    insert CaseList_ToInsert;
   
    
    if(ContentDocLinkIDs_ToDelete.size()>0){   
        for(integer i=0;i<ContentDocLinkIDs_ToDelete.values().size();i++){
    ContentDocumentLink contentlink1=new ContentDocumentLink();
    contentlink1.ContentDocumentId = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id =: ContentDocLinkIDs_ToDelete.values()[i]].ContentDocumentId;
    contentlink1.LinkedEntityId = new_case.id;   // Mapping the content document to this case
    contentlink1.ShareType = 'V';
    insert contentlink1;
        }
    }  
    
  
      pageref = new pagereference('/'+new_case.id);
         pageref .setRedirect(true);

    }Catch(Exception ex){
    system.debug('Exception on Case creation'+ex);
    }
    
    
    //ContentDocument Inserting to this case by using the ContentDocumentLink LinkedEntityId
    

      
    return pageref ;

    } // Save_Case Method ends..
    
    
    public void AddAttachments(){
         
           String Filebody = (String) ApexPages.currentPage().getParameters().get('fileBody');
           ContentVersion contentVerse = new ContentVersion();
            contentVerse.ContentLocation = 'S';
      
       contentVerse.VersionData = EncodingUtil.base64Decode(Filebody);
       contentVerse.Title =  (String) ApexPages.currentPage().getParameters().get('filename');
        contentVerse.PathOnClient =(String) ApexPages.currentPage().getParameters().get('filename');
        //contentVerse.FileType=(String) ApexPages.currentPage().getParameters().get('filetype');
       insert contentVerse;
       contentDocumentIds.add(contentVerse.Id);
     ContentDocLinkIDs_ToDelete.put(ApexPages.currentPage().getParameters().get('FileUploadID'),contentVerse.id);

    }
    
    //Method for redirecting to the created case record detail page
    public pagereference gobackFun(){
        pagereference record_page ;
        system.debug('Activepath '+Activepath);
       if(Activepath==1){
       record_page = new pagereference('/lightning/o/Case/list?filterName=Recent');
        record_page .setRedirect(true); 
         return record_page;
       }
       else{
           Activepath--;
           return null;
       }
       
   
        
    } // gobackFun method ends
      ContentDocumentLink cl_1 = new ContentDocumentLink();
   ContentDocumentLink cl_2 = new ContentDocumentLink();
   ContentDocumentLink cl_3 = new ContentDocumentLink(); // To delete the image
     public void DeleteCD_File(){
        try{
  string the_SpanID =  ApexPages.currentPage().getParameters().get('SpanID') ;
  
   ContentDistribution cd = new ContentDistribution();
   list< ContentDocumentLink> cl_list_todelete = new list< ContentDocumentLink>();
  // List<ID> newSet = ContentDocLinkIDs_ToDelete.get(0);
  //ContentDocumentLink  toDelete = new ContentDocumentLink(); // To delete the distribution link for 311 integration
 // to delete and block the file to save in local SF instance
 system.debug(ContentDocLinkIDs_ToDelete);
  if(the_SpanID!=null)
    ContentDocLinkIDs_ToDelete.remove(the_SpanID);
 
 
  system.debug(ContentDocLinkIDs_ToDelete.values());

  

      
    
    // if(toDelete_contentlink.size()>0)
   // delete cl_list_todelete;
 }catch(exception e){
     system.debug('Exception on deletion '+e);
 }
}

}