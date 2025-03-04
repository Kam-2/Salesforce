/***************************************************************************************
* Class Name			: Case_Dynamic_Page_CTRL_Test          #Code_Coverage - 81%             
* Created Date			: 25 SEP, 2024	
* Created By			: Buvaneswari P
* Class Description	    : Test class for Dynamic page.	
* Last modified by		: 
***************************************************************************************/

@isTest
public class Case_Dynamic_Page_CTRL_Test {
    
    @TestSetup
    public static void setupData(){
        
        Ambassador__c amb = new Ambassador__c(Name='Charlie',Ambassador_Email__c='charlie@gmail.com');
        insert amb; 
        //Rec-->0
        Case cse = new Case(FSA_Case_Type__c= 'Clean',Status='open',Origin='Ambassador'); 
        insert cse;
        
    }
    
   
    public static testmethod void getFieldSet(){
        list<Case> getRec =[select Id,FSA_Case_Type__c,FSA_Case_Sub_Type__c,Ambassador__c from Case ];
        Test.startTest();
        Case_Dynamic_Page_CTRL.getFieldSet('case');
        Case_Dynamic_Page_CTRL.getFieldSetMember('case',getRec[0].id);
        Case_Dynamic_Page_CTRL.getInfoFields('Case-Case Layout',getRec[0].id);
        Test.stopTest();
    }
    
    
    
    
}