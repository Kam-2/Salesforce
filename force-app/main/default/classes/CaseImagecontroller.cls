public class CaseImagecontroller {

    @AuraEnabled(Cacheable=true)
    public static List<ContentVersion> getAttachedPhotos(Id caseId) {
        system.debug('caseId'+caseId);
        set<id> contentids = new set<id>();
        for(ContentDocumentLink c:[select ContentDocumentId from ContentDocumentLink where LinkedEntityId=:caseId]){
            contentids.add(c.ContentDocumentId);
        }
        system.debug('contentids'+contentids);
       list<Attachment> a =[SELECT Id, Name, ContentType FROM Attachment WHERE ParentId = :caseId];
        system.debug('a'+a);
                               ContentVersion cv=[select id,ContentDocumentId from ContentVersion where ContentDocumentId in :contentids  and (filetype ='JPG' OR filetype='PNG' ) ];
                                      system.debug('cv'+cv);                   
        return [select id,ContentDocumentId from ContentVersion where ContentDocumentId in :contentids  and (filetype ='JPG' OR filetype='PNG' ) ];
    }
      
}
