@isTest
public with sharing class CaseTriggerTest {
    @TestSetup
    static void makeData(){
        List<Account> accounts = new List<Account>();

        for (Integer i = 0; i < 4; i++) {
            Account a = (Account) TestDataFactory.createSObject('Account', new Map<String, Object> {
                'Name' => 'Test' + i
            });
            accounts.add(a);
        }
        TestDataFactory.createSObjectList('Contact', new Map<String, Object> {
            'Email' => 'contact@gmail.com',
            'AccountId' => accounts.get(0).Id
        }, 4);

        TestDataFactory.createSObjectList('Contact', new Map<String, Object> {
            'Email' => 'test@gmail.com',
            'AccountId' => accounts.get(1).Id
        }, 3);

        TestDataFactory.createSObjectList('Contact', new Map<String, Object> {
            'Email' => 'test3@gmail.com',
            'AccountId' => accounts.get(3).Id
        }, 1);

        TestDataFactory.createSObjectList('Case', new Map<String, Object> {
            'Status' => 'New',
            'AccountId' => accounts.get(1).Id
        }, 3);
    }

    @isTest
    public static void refuseCaseCreationWhenAnAccountIsNotAttachedToACase(){
        // Given

        Case request = new Case(Origin = 'Phone',Subject = 'Event Booking', Description = 'Book Spots');
        
        // When 

        Test.startTest();

        Database.SaveResult result = Database.insert(request, false);

        Test.stopTest();

        // Then

        System.assert(!result.isSuccess(), 'Unexpected result');
        System.assert(result.getErrors().size() > 0, 'Unexpected result');
        System.assertEquals('You cannot create a request without attaching an account',
        result.getErrors()[0].getMessage(), 'Unexpected Result');
    }   

    @isTest
    public static void refuseCaseCreationWhenNoContactIsAttachedToAnAccount(){
        // Given
  
        Account accountWithoutContact = [SELECT ID FROM Account WHERE Name = 'Test2' LIMIT 1];
        

        Case request = new Case(Origin = 'Phone',Subject = 'Event Booking', Description = 'Book Spots', AccountId = accountWithoutContact.ID);
        
        // When 

        Test.startTest();

        Database.SaveResult result = Database.insert(request, false);

        Test.stopTest();

        // Then

        System.assert(!result.isSuccess(), 'Unexpected result');
        System.assert(result.getErrors().size() > 0, 'Unexpected result');
        System.assertEquals('You cannot create a request for accounts without contacts',
        result.getErrors()[0].getMessage(), 'Unexpected result');
    }  

    @isTest
    public static void bookEventFromPhoneSuccess(){
        // Given
        
        Account accountWith3Contacts = [SELECT Id, (Select Id FROM Contacts) FROM Account WHERE Name = 'Test1' LIMIT 1];
        Case request = new Case(Origin = 'Phone',Subject = 'Event Booking', AccountId = accountWith3Contacts.ID);
        
        // When 

        Test.startTest();

        Database.SaveResult result = Database.insert(request, false);
        Test.stopTest();

        // Then

        System.assert(result.isSuccess(),'Unexpected result');
       



    }  
    @isTest
    public static void bookEventFromPhoneError(){
        //Given
        Account accountWith4Contacts = [SELECT Id, (Select Id FROM Contacts) FROM Account WHERE Name = 'Test0' LIMIT 1];
        Case request = new Case(Origin = 'Phone',Subject = 'Event Booking', AccountId = accountWith4Contacts.ID);
        
        // When 

        Test.startTest();

        Database.SaveResult result = Database.insert(request, false);
        Test.stopTest();

        // Then
        System.assert(!result.isSuccess(),'Unexpected result');
        System.assert(result.getErrors().size() > 0, 'Unexpected result');
        System.assertEquals('Phone requests are only allowed to have three attendees',
        result.getErrors()[0].getMessage(), 'Unexpected result');
    }

    @isTest
    public static void bookEventFromWebSuccess(){
        // Given
        
        Account accountWithOneContact = [SELECT Id, (Select Id FROM Contacts) FROM Account WHERE Name = 'Test3' LIMIT 1];
        Case request = new Case(Origin = 'Web',Subject = 'Event Booking', AccountId = accountWithOneContact.ID);
        
        // When 

        Test.startTest();

        Database.SaveResult result = Database.insert(request, false);
        Test.stopTest();

        // Then
        System.assert(result.isSuccess(),'Unexpected result');
        
       
    } 

    @isTest
    public static void bookEventFromWebError(){
        //Given
        Account accountWith4Contacts = [SELECT Id, (Select Id FROM Contacts) FROM Account WHERE Name = 'Test1' LIMIT 1];
        Case request = new Case(Origin = 'Web',Subject = 'Event Booking', AccountId = accountWith4Contacts.ID);
        
        // When 

        Test.startTest();

        Database.SaveResult result = Database.insert(request, false);
        Test.stopTest();

        // Then
        System.assert(!result.isSuccess(),'Unexpected result');
        System.assert(result.getErrors().size() > 0, 'Unexpected result');
        System.assertEquals('Web requests are only allowed to have one attendee',
        result.getErrors()[0].getMessage(), 'Unexpected result');

      
    }
    
    @isTest
    public static void shouldEnqueueJob() {
        // GIVEN
        Test.setMock(HttpCalloutMock.class, new ExternalServiceMock(201));

        Integer numberOfQueuebaleJobs = [SELECT count(Id) FROM AsyncApexJob where JobType = 'Queueable'].size() ;       
        Case request = [SELECT Id, Status FROM Case LIMIT 1];
        request.Status = 'Closed';

        //WHEN
        Test.startTest();
        Database.SaveResult result = Database.update(request, false);
        Test.stopTest();

        //THEN
        System.assertEquals(numberOfQueuebaleJobs, 1, 'Unexpected Result');
    }

}