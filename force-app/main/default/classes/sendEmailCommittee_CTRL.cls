public with sharing class sendEmailCommittee_CTRL {
    /**Send an email to the Major Initiative Roles --> Members will be autopopulated (related list of the meeting)
    * And also collecting the cc address from the end-user and will be inputted to the SingleEmailMessage
    * Then sendEmail method will be called
    **/
    Public static List<string> AttachmentIDs = new list<string>();
    @AuraEnabled 
    public static void sendMailMethod(List<String> toAddress,List<String> ccAddress,List<String> bccAddress,String mSubject,String mbody,String MI_ID,List<string> AttachID){
        List<Messaging.SingleEmailMessage> mails =  new List<Messaging.SingleEmailMessage>(); 
        system.debug('AttachID ' + AttachID);
        try{
            System.debug('bccAddress'+bccAddress);
            if(Task.SObjectType.getDescribe().isAccessible()  && Task.SObjectType.getDescribe().isCreateable() && Schema.sObjectType.Task.fields.Status.isCreateable() &&
            Schema.sObjectType.Task.fields.Subject.isCreateable() &&  Schema.sObjectType.Task.fields.Description.isCreateable() &&
            Schema.sObjectType.Task.fields.WhoId.isCreateable() ){
            List<Attachment> att = [select Name, Body, BodyLength from Attachment where ParentId = :MI_ID and Id IN :AttachID WITH SECURITY_ENFORCED limit 5];
            system.debug('att ' + att);
            Set<String> Conset = new Set<String>();
        	List<String> sendTo = new List<String>();
            List<Task> lstinserttask = new List<Task>();
                
            List<Contact> ConList = [Select Id, FirstName, LastName, Name, Email, Account.Name from Contact where Email =: toAddress WITH SECURITY_ENFORCED];
            List<Contact> CCConList = [Select Id, FirstName, LastName, Name, Email, Account.Name from Contact where Email =: ccAddress WITH SECURITY_ENFORCED];
            List<Contact> BCConList = [Select Id, FirstName, LastName, Name, Email, Account.Name from Contact where Email =: bccAddress WITH SECURITY_ENFORCED];
            System.debug('BCConList'+BCConList);
            User ThisUser = [Select Id, Name from User where Id =:system.userInfo.getUserId() WITH SECURITY_ENFORCED limit 1];
            List<String> sendBccAddress = new List<String>();
            for(Contact con : BCConList){
                if(con.Email!=null){
                sendBccAddress.add(con.Email);
                }
            }
            List<String> sendccAddress = new List<String>();
            for(Contact con : CCConList){
                if(con.Email!=null){
                sendccAddress.add(con.Email);
                }
            }
            for(Contact con : ConList) {
                List<String> sendtoAddress = new List<String>();
                sendtoAddress.add(con.Email);
                system.debug('con.Account.Name ' + con.Account.Name);
                // Step 1: Create a new Email
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                
                // Step 2: Set list of people who should get the email
                mail.setToAddresses(sendtoAddress);
                mail.setCcAddresses(sendccAddress);
                mail.setBccAddresses(sendBccAddress);
                
                // Step 3: Set who the email is sent from
                // mail.setReplyTo('noreply@gmail.com'); // change it with your mail address.
                //mail.setSenderDisplayName('salesforce User'); 
                
                // Step 4. Set email contents - you can use variables!
                mail.setSubject(mSubject);
                
                String mbody1='';
                if(con.FirstName!=null && mbody.contains('{!Contact.FirstName}') && mbody.contains('{!Account.Name}')  && mbody.contains('{!User.FirstName}')){
                    mbody1 = mbody.replace('{!Contact.FirstName}',con.FirstName);
                    mbody1 = mbody1.replace('{!Account.Name}',con.Account.Name);
                	mbody1 = mbody1.replace('{!User.FirstName}', ThisUser.Name);
                }
                else if(con.FirstName!=null && mbody.contains('{!Contact.FirstName}') && mbody.contains('{!Account.Name}')){
                    mbody1 = mbody.replace('{!Contact.FirstName}',con.FirstName);
                    mbody1 = mbody1.replace('{!Account.Name}',con.Account.Name);
                }
                else if(con.FirstName!=null && mbody.contains('{!Contact.FirstName}') && mbody.contains('{!User.FirstName}')){
                    mbody1 = mbody.replace('{!Contact.FirstName}',con.FirstName);
                	mbody1 = mbody1.replace('{!User.FirstName}', ThisUser.Name);
                }
                else if(con.FirstName!=null && mbody.contains('{!Contact.FirstName}')){
                    mbody1 = mbody.replace('{!Contact.FirstName}',con.FirstName);
                }
                else if(con.FirstName!=null && mbody.contains('{!User.FirstName}')){
                    mbody1 = mbody.replace('{!User.FirstName}', ThisUser.Name);
                }
                else {
                    mbody1 = mbody;
                } 
                
                mail.setHtmlBody(mbody1);
                
                List<Messaging.Emailfileattachment> fileAttachments = new List<Messaging.Emailfileattachment>();
                system.debug(att);
                for (Attachment a : att)
                {
                    Messaging.Emailfileattachment efa = new Messaging.Emailfileattachment();
                    efa.setFileName(a.Name);
                    efa.setBody(a.Body);
                    fileAttachments.add(efa);
                }
                mail.setFileAttachments(fileAttachments); 
                
                //Add Email to the respective record in Activity
                mail.setWhatId(MI_ID);
                
                // Step 5. Add your email to the master list
                mails.add(mail);
                
                // Step 6: Send all emails in the master list
                //Messaging.sendEmail(mails);
                
                //Create Activity in Contact level
                Task atask = new Task();
                atask.WhoId = con.Id;
                atask.Subject = mSubject;
                atask.Description = mbody1;
                atask.Status = 'Completed';
                lstinserttask.add(atask);
                
            }
            insert lstinserttask;
        }
            Messaging.SendEmailResult[] results = Messaging.sendEmail(mails);
            for(Messaging.SendEmailResult result : results) {
                if(result.success) {
                    System.debug('The email was sent successfully.');
                } 
                else {
                    System.debug('The email failed to send: ' + result.errors[0].message);
                }
            }
            
        } catch(Exception e) {
            System.debug('Exception in the SendEmail '+e.getLineNumber()+e.getStackTraceString()+e.getMessage());
        }
    }
    
    /**Send an email to the Major Intiative Role - It's field in the Major Initiative object
    * And also collecting the cc address from the end-user and will be inputted to the SingleEmailMessage
    * Then sendEmail method will be called
    **/
    /** Get the MI Roles of the Major Initiative and returned **/
    @AuraEnabled
     public static List<String> sendMailMethodCommitteeMembers(String CommitteeID){
        List<String> DupsendTo = new List<String>();
        Set<String> nondupSet = new Set<String>();
        List<String> sendTo = new List<String>();
        List<Committee_Membership_District360__c> CMlist = new List<Committee_Membership_District360__c>();
        
       /* d360v2__Commitee__mdt metadataRecord;
        if (Schema.sObjectType.d360v2__Commitee__mdt.isAccessible()) {
            metadataRecord = [SELECT d360v2__Commitee_Members_Status__c FROM d360v2__Commitee__mdt ];
        }  
    
        String availableFields = metadataRecord.d360v2__Commitee_Members_Status__c;
        //the 'availableFields' variable contains the value of the 'Fields_Selected__c' field.
        String fieldList;
        
        // Split the comma-separated text into a list of strings
        fieldList = availableFields;
        // fieldList contains the list of strings

if(fieldList == 'active'){
        CMlist = [select id, name, CommitteeMember_District360__c,CommitteeMember_District360__r.Email, Committee_District360__c, Active_District360__c 
                  from Committee_Membership_District360__c where Committee_Membership_District360__c.Active_District360__c= true and Committee_District360__c = :CommitteeID WITH SECURITY_ENFORCED];
}
else if(fieldList == 'Inactive'){
    CMlist = [select id, name, CommitteeMember_District360__c,CommitteeMember_District360__r.Email, Committee_District360__c, Active_District360__c 
    from Committee_Membership_District360__c where Committee_Membership_District360__c.Active_District360__c= false and Committee_District360__c = :CommitteeID WITH SECURITY_ENFORCED];

}
else if(fieldList == 'both'){

    CMlist = [select id, name, CommitteeMember_District360__c,CommitteeMember_District360__r.Email, Committee_District360__c, Active_District360__c 
    from Committee_Membership_District360__c where Committee_District360__c = :CommitteeID WITH SECURITY_ENFORCED];
 
}
*/
         
        CMlist = [select id, name, CommitteeMember_District360__c,CommitteeMember_District360__r.Email, Committee_District360__c, Active_District360__c 
    from Committee_Membership_District360__c where Committee_District360__c = :CommitteeID WITH SECURITY_ENFORCED];
         
        for(Committee_Membership_District360__c ba : CMlist){
            if(ba.CommitteeMember_District360__r.Email!=null){
                DupsendTo.add(ba.CommitteeMember_District360__r.Email);
            }
        }
        nondupSet.addAll(DupsendTo);
        sendTo.addAll(nondupSet);
         if(!sendTo.isEmpty()){
        return sendTo;
         }
         else {return null;
         }
    }
    
    // check if fileId id ''(Always blank in first chunk), then call the saveTheFile method,
    //  which is save the check data and return the attachemnt Id after insert, 
    //  next time (in else) we are call the appentTOFile() method
    //   for update the attachment with reamins chunks  
    @AuraEnabled
    public static Id saveChunk(string parentId, String[] fileName, String base64Data, String contentType, String fileId) {
        if (fileId == '') {
            fileId = saveTheFile(parentId, fileName, base64Data, contentType);
        } else {
            appendToFile(fileId, base64Data);
        }
        return Id.valueOf(fileId);
    }
    
    /** Save the uploaded file to the attachment **/
    @AuraEnabled
    public static Id saveTheFile(Id parentId, String[] fileName, String base64Data, String contentType) {
        base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');
                list<Attachment> oAttachmentlst = new list<Attachment>();

        
        if(Attachment.SObjectType.getDescribe().isAccessible() && Attachment.SObjectType.getDescribe().isCreateable() && Schema.sObjectType.Attachment.fields.parentId.isCreateable() &&
        Schema.sObjectType.Attachment.fields.Body.isCreateable() && Schema.sObjectType.Attachment.fields.Name.isCreateable() &&
        Schema.sObjectType.Attachment.fields.ContentType.isCreateable()){

       Attachment oAttachment = new Attachment();
        oAttachment.parentId = parentId;
        oAttachment.Body = EncodingUtil.base64Decode(base64Data);
        for(String s : fileName){
            oAttachment.Name = s;
        }
        oAttachment.ContentType = contentType;
        //    try {
        oAttachmentlst.add(oAttachment);
        insert oAttachmentlst;
        AttachmentIDs.add(oAttachment.id);
        //  } catch(Exception e) { System.debug('Error on Attachment '+e.getMessage()+e.getLineNumber()); }        
        system.debug('attachid'+oAttachment.id);
    }
        return oAttachmentlst[0].Id;
       
    }
    
    /*  Appending the file body   */
    @AuraEnabled
    public static void appendToFile(Id fileId, String base64Data) {
        base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');
        if(Attachment.SObjectType.getDescribe().isAccessible() && Attachment.SObjectType.getDescribe().isUpdateable() && Schema.sObjectType.Attachment.fields.Body.isUpdateable()){

        Attachment a = [SELECT Id, Body FROM Attachment WHERE Id =: fileId];
        String existingBody = EncodingUtil.base64Encode(a.Body);
        a.Body = EncodingUtil.base64Decode(existingBody + base64Data);
        try{
            update a;
        }catch(Exception e){ system.debug('Exception in the appendfile method '+e.getStackTraceString()); }
        }
    }
    
    @AuraEnabled 
    public static EmailTemplate getTemplateDetails(string templteId){
        EmailTemplate emailTemp = new EmailTemplate();
        if (Schema.sObjectType.EmailTemplate.isAccessible()){
        list<EmailTemplate> emailTempLst = new list<EmailTemplate>();
        emailTempLst = [SELECT Id,Name,Subject,TemplateType,FolderName,body FROM EmailTemplate WHERE ID=: templteId];
        emailTemp = emailTempLst.size()>0 ? emailTempLst[0] : emailTemp;
    }
        return emailTemp;
       
        
    }
    
    @AuraEnabled
    public static list<EmailTemplate> getTemplates(){
        //RelatedEntityType='Account' AND 
        list<EmailTemplate> emailTemp = new list<EmailTemplate>();
        emailTemp = [SELECT Id,Name,Subject,TemplateType,FolderName,body FROM EmailTemplate WHERE TemplateType IN ('text','html') and IsActive=TRUE];
        if(!emailTemp.isEmpty()){
        return emailTemp;
        }
        else {return null;
        }
    }
    
    @AuraEnabled
    public static list<contact> getListViews(string search_string) {
        string search_value = '%' + search_string + '%';
        list<contact> conemails = new list<contact>();
        //list<string> newconemail = new list<string>();
        conemails = [SELECT Id, Name,Email FROM contact where Name LIKE: search_value WITH SECURITY_ENFORCED];
       if(!conemails.isEmpty()){
        return conemails;
    }
        else {return null;
        }
    }
     @AuraEnabled
    public static list<contact> getListViewsBcc(string search_stringBcc) {
        string search_value = '%' + search_stringBcc + '%';
        list<contact> conemails = new list<contact>();
        conemails = [SELECT Id, Name,Email FROM contact where Name LIKE: search_value WITH SECURITY_ENFORCED];
       if(!conemails.isEmpty()){
        return conemails;
       }
        else {
            return null;
        }
    }
}