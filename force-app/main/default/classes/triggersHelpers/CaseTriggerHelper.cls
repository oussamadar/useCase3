public with sharing class CaseTriggerHelper {
    private static final Integer CALLOUT_LIMIT_NUMBER = 100;

    public static void checkCaseIsValid(List<Case> cases) {

        Set<Id> accountsIds = new Set<Id>();
        for (Case request : cases) {
            accountsIds.add(request.AccountId);
        }

        Map<Id, Account> accountMap = new Map<Id, Account>(
            [SELECT Id, (SELECT Id FROM Contacts) FROM Account WHERE Id IN :accountsIds ]
        );
    
        for (Case caseObj : cases) {
            
            //check if the case is related to an account
            if(caseObj.AccountId == null) {
                caseObj.addError('You cannot create a request without attaching an account');
                continue;
            }

            Account account = accountMap.get(caseObj.AccountId);
            List<Contact> contacts = account.Contacts;

            //check if the case related account has contacts
            if (contacts.isEmpty()) {
                caseObj.addError('You cannot create a request for accounts without contacts');
                continue;
                
            }

            Integer contactsSize = contacts.size();

            // errors in this block depend on  case origin and contacts size
            switch on caseObj.Origin {
                when 'Web' {
                    if (contactsSize >= 2) {
                        caseObj.addError('Web requests are only allowed to have one attendee');
                        continue;
                    }
                }
                when 'Phone' {
                    if (contactsSize >= 4) {
                        caseObj.addError('Phone requests are only allowed to have three attendees');
                        continue;
                    }
                }
            }
        }
    }
    
  
    public static void callExternalService(List<Case> newCaseList) {
        List<Case> closedCases = new List<Case>();
        for(Case caseObj : newCaseList){
            if(caseObj.Status == 'Closed'){
                closedCases.add(caseObj);
            }
        }
        if (!closedCases.isEmpty()) {
            ExtrernalServiceQueue queue = new ExtrernalServiceQueue(closedCases);
            System.enqueueJob(queue);  
        }
       
    }  
}