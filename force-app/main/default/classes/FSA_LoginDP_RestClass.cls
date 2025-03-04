/**************************************************************************************
* Class Name			: FSA_LoginDP_RestClass
* Created Date			: 5th Jun, 2024	
* Created By			: Senthilnathan R
* Class Description		: Custom API class to pass Ambassador DP	
* Last modified by		: 
***************************************************************************************/

@RestResource(urlMapping='/ambassador/*')
global with sharing class FSA_LoginDP_RestClass {
    
    /**************************************************************************************
* Method Name			: getAmbImage
* Created Date			: 5th Jun, 2024	
* Created By			: Senthilnathan R
* Class Description		: This is a @HttpGet method fetch the Ambassador attachment.
***************************************************************************************/
    
    @HttpGet
    global static ambDP getAmbImage() {
        RestRequest request = RestContext.request;
        String ambId = '';
        ambId = RestContext.request.params.get('id');
        system.debug('@@@@ambId--> '+ambId);    
        ambDP proPic = new ambDP();
        proPic.ambassadorImage = '';
        
        List<ContentDocumentLink> contentDocumentLinks = [SELECT ContentDocumentId FROM 
                                                          ContentDocumentLink WHERE LinkedEntityId = :ambId];   //pass caseId
        if (contentDocumentLinks.size() > 0)
        {
            Set<Id> setContentDocumentIds = new Set<Id>();
            
            for (ContentDocumentLink contentDocumentLink : contentDocumentLinks ){
                setContentDocumentIds.add(contentDocumentLink.ContentDocumentId);
            }
            
            List<ContentVersion> lstContentVersions = [SELECT Id,ContentDocumentId,Title,VersionData,isLatest,CreatedDate
                                                       FROM ContentVersion 
                                                       WHERE ContentDocumentId in :setContentDocumentIds 
                                                       AND FileType!='SNOTE' 
                                                       AND IsLatest = true
                                                      ];
            if (lstContentVersions.size() > 0)
            {
                for (ContentVersion contentVersion : lstContentVersions )
                {
                    system.debug(contentVersion.Title);
                    system.debug(contentVersion.VersionData);
                    
                    proPic.ambassadorImage = EncodingUtil.base64Encode(contentVersion.VersionData);
                    
                }
            }
        }
        
        return proPic;
        
    }
    
     global class ambDP {
        global String ambassadorImage;
    }
}