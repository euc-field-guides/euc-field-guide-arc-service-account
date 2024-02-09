trigger UpdatePremises on Account (after insert, after update) {
    // Map to hold record type names and their corresponding ids
    Map<String, Id> recordTypeMap = new Map<String, Id>();
    
    // Query for all Record Types and populate the map
    for(RecordType rt : [SELECT Id, Name FROM RecordType WHERE SObjectType = 'Account']) {
        recordTypeMap.put(rt.Name, rt.Id);
    }
    
    // Check if 'Service Account' record type exists in the map
    if(recordTypeMap.containsKey('Service')) {
        Id serviceAccountRecordTypeId = recordTypeMap.get('Service');
        
        // List to hold Premises records to be updated
        List<vlocity_cmt__Premises__c> premisesToUpdate = new List<vlocity_cmt__Premises__c >();
        
        // Iterate over the Trigger.new list to process new or updated Account records
        for(Account acc : Trigger.new) {
            // Check if the Account record type is 'Service Account'
            if(acc.RecordTypeId == serviceAccountRecordTypeId) {
                // Query for the related Premises records
                List<vlocity_cmt__Premises__c> relatedPremises = [SELECT Id, vlocity_cmt__PropertyOwnerAccountId__c
                                                     FROM vlocity_cmt__Premises__c 
                                                     WHERE Id = :acc.vlocity_cmt__PremisesId__c ];
                
                // Update the related Premises records
                for(vlocity_cmt__Premises__c  prem : relatedPremises) {
                    prem.vlocity_cmt__PropertyOwnerAccountId__c = acc.Id;
                    premisesToUpdate.add(prem);
                }
            }
        }
        
        // Update the Premises records
        if(!premisesToUpdate.isEmpty()) {
            update premisesToUpdate;
        }
    } else {
        System.debug('Record type "Service" not found.');
    }
}