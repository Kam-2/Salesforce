trigger CaseTrigger on Case (after insert, after update) {
    //This trigger we used for FCM Push-notification
    if(trigger.isafter){	
        if(trigger.isInsert){
            List<Id> caseInsIdLst=new List<Id>();
            for(Case cse:Trigger.new){
                if(!String.isBlank(cse.Ambassador__c)){
                    caseInsIdLst.add(cse.Id);
                    system.debug('Case ID!!!#### '+caseInsIdLst);
                }
                
            }
            if(caseInsIdLst.size()>0){
                system.debug('Created Case!!!#### '+caseInsIdLst);
                FSA_FcmCalloutClass.SendFCMNotification(caseInsIdLst[0],'insert'); 
            }
        }
        if(trigger.isUpdate){
            List<Id> caseUpIdLst=new List<Id>();
            for(Case cs:Trigger.new){
                //checking if the Ambassador value has changed during update
                system.debug(cs.Ambassador__c);
                system.debug(Trigger.oldMap.get(cs.id).Ambassador__c);
                system.debug(!String.isBlank(cs.Ambassador__c));

                if(cs.Ambassador__c!= Trigger.oldMap.get(cs.id).Ambassador__c && !String.isBlank(cs.Ambassador__c)){
                    caseUpIdLst.add(cs.Id);
                    system.debug('UPDATED CASE id#### '+caseUpIdLst);
                }
            }
            if(caseUpIdLst.size()>0){
                system.debug('UPDATED CASE id '+caseUpIdLst);
                FSA_FcmCalloutClass.SendFCMNotification(caseUpIdLst[0],'update');
            }
        }
    }
}