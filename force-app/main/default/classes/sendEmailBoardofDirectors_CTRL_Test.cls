@isTest
public class sendEmailBoardofDirectors_CTRL_Test {
    @isTest
    public static void testmethods() {
        list<Board_District360__c> meetlist = new list<Board_District360__c>();
        //for(integer i=0;i<2;i++) {
            Board_District360__c meet = new Board_District360__c(name='Test');
            meetlist.add(meet);
        //}
        insert meetlist;
        System.assertEquals(1, meetlist.size());

        account acc=new account(name='test');   
        insert acc;
        System.assertEquals('test', acc.Name);

        list<contact> conlist = new list<contact>();
        //for(integer j=0;j<2;j++) {
            contact con = new contact(firstname='John',lastname='Test',email='test@gmail.com',phone='9989668003',AccountId=acc.id,
                                      MobilePhone='897657977',OtherPhone ='9988776655');
            conlist.add(con);
        //}
        insert conlist;
        System.assertEquals(1, conlist.size());

        List<Board_Members_District360__c> Attendees = new List<Board_Members_District360__c>();
        Board_Members_District360__c bod = new Board_Members_District360__c(Board_District360__c=meetlist[0].id,Contact_District360__c=conlist[0].id);
        insert bod; 
        System.assertEquals(1, [SELECT COUNT() FROM Board_Members_District360__c]);

        String jsonStr = '<Base64 String>';
        
        list<Attachment> alist = new list<Attachment>();
        //for(integer k=0;k<2;k++) {
            Attachment a  = new Attachment( name='Test', Body = Blob.valueOf(jsonStr),parentId=meetlist[0].Id);
            alist.add(a);
        //}
        insert alist;
        System.assertEquals(1, [SELECT COUNT() FROM Attachment WHERE ParentId =: meetlist[0].Id]);

        // sendEmailAttendees helper = new sendEmailAttendees();
        String meetId = meetlist[0].Id;
        ID fileId = alist[0].ID;
        List<String> filelist = new List<String>();
        filelist.add(alist[0].ID);
        string base64Data = 'Base64 String';
        base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');
        List<String> toAddress = new List<String>();
        String ad = 'Test@gmail.com';
        toAddress.add(ad);
        List<String> ccAddress = new List<String>();
        String adr = 'Test@gmail.com';
        ccAddress.add(adr);
        //String ccAddress = 'Test@gmail.com';
        List<String> BccAddress = new List<String>();
        String bcc = 'Test@gmail.com';
        BccAddress.add(bcc);
        String mSubject = 'Test';
        String mbody = 'Test';
        Id parentId = meetlist[0].Id;
        String fname =  alist[0].Name;
        String[] fileName = new List<String>();
        fileName.add(fname);
        //String fname =  'aName';
        String contentType = alist[0].ContentType; 
        
        Test.startTest();
        sendEmailBoardofDirectors_CTRL.appendToFile(fileId, base64Data);
        sendEmailBoardofDirectors_CTRL.sendMailMethodMIRoles(meetId);
        sendEmailBoardofDirectors_CTRL.sendMailMethod(toAddress, ccAddress, bccAddress, mSubject, mbody, meetId, filelist);
        mbody = '{!Contact.FirstName},{!Account.Name},{!User.FirstName}';
        sendEmailBoardofDirectors_CTRL.sendMailMethod(toAddress, ccAddress, bccAddress, mSubject, mbody, meetId, filelist);
        mbody = '{!Contact.FirstName},{!Account.Name}';
        sendEmailBoardofDirectors_CTRL.sendMailMethod(toAddress, ccAddress, bccAddress, mSubject, mbody, meetId, filelist);
        mbody = '{!Contact.FirstName},{!Account.Name},{!User.FirstName}';
        sendEmailBoardofDirectors_CTRL.sendMailMethod(toAddress, ccAddress, bccAddress, mSubject, mbody, meetId, filelist);
        mbody = '{!Contact.FirstName},{!User.FirstName}';
        sendEmailBoardofDirectors_CTRL.sendMailMethod(toAddress, ccAddress, bccAddress, mSubject, mbody, meetId, filelist);
        mbody = '{!User.FirstName}';
        sendEmailBoardofDirectors_CTRL.sendMailMethod(toAddress, ccAddress, bccAddress, mSubject, mbody, meetId, filelist);
        mbody = '{!Contact.FirstName}';
        sendEmailBoardofDirectors_CTRL.sendMailMethod(toAddress, ccAddress, bccAddress, mSubject, mbody, meetId, filelist);
        sendEmailBoardofDirectors_CTRL.saveTheFile(parentId, fileName, base64Data, contentType);
        sendEmailBoardofDirectors_CTRL.saveChunk(parentId, fileName, base64Data, contentType, fileId);
        sendEmailBoardofDirectors_CTRL.saveChunk(parentId, fileName, base64Data, contentType, '');
        //sendEmailCommittee_CTRL.getTemplateDetails(emt.id);
        sendEmailBoardofDirectors_CTRL.getTemplates();
        sendEmailBoardofDirectors_CTRL.getListViews('test');
        sendEmailBoardofDirectors_CTRL.getListViewsBcc('test');
        Test.stopTest();
    }
}