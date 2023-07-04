public  class ExternalSystemService {

    private String webServiceURL;
    private List<Case> cases;

    public ExternalSystemService(List<Case> cases){
        this.webServiceURL = 'https://th-apex-http-callout.herokuapp.com/animals';
        this.cases = cases;
    }
    
    public void registerAttendees(){
        List<Id> toBeNotifiedContacts = new List<Id>();
        Set<Id> accountsIds = new Set<Id>();
        for(Case caseObj : this.cases){
            // get only closed cases
            if(caseObj.Status == 'Closed'){
                accountsIds.add(caseObj.AccountId);
            } 
        }
        List<Contact> contacts = [SELECT Id, Name, Email FROM Contact WHERE AccountId IN :accountsIds];

        for (Contact contactObj : contacts) {
            HttpResponse response = postCallout(contactObj);
            if (response.getStatusCode() != 201) {
                System.debug('The status code returned was not expected: ' +
                response.getStatusCode() + ' ' + response.getStatus());
            } else {
                toBeNotifiedContacts.add(contactObj.Id);
            }
        }

        if (!toBeNotifiedContacts.isEmpty()) {
            notifyAttendeeByEmail(toBeNotifiedContacts);
        }
        
    }   
        
    public void notifyAttendeeByEmail(List<Id> contactsIds) {
        Id emailTemplateId = [SELECT id, Name FROM EmailTemplate WHERE Name = 'Support: Case Response'].Id;
    
        Messaging.MassEmailMessage mail = new Messaging.MassEmailMessage();
        mail.setTemplateID(emailTemplateId);
        mail.setTargetObjectIds(contactsIds);
        mail.setSenderDisplayName('Event Manager');
        Messaging.sendEmail(new Messaging.MassEmailMessage[] { mail }); 
    }
 

    private  HttpResponse postCallout(Contact c) {
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(this.webServiceURL);
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json;charset=UTF-8');
        request.setBody('{"name":"mighty moose"}');
        
        return http.send(request);  
    }

   
}
