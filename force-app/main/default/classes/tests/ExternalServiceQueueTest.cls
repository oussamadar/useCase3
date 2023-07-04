@isTest
public with sharing class ExternalServiceQueueTest {
    @TestSetup
    static void makeData(){
        Account accountObj = (Account) TestDataFactory.createSObject('Account');

        TestDataFactory.createSObject('Contact', new Map<String,Object> {
            'Email' => 'Test@gmail.com',
            'AccountId' => accountObj.Id
        });

        TestDataFactory.createSObjectList('Case', new Map<String, Object> {
            'Status' => 'New',
            'AccountId' => accountObj.Id
        }, 3);
    }

    @isTest
    static void shouldEnqueueJob() {
        //GIVEN
        Test.setMock(HttpCalloutMock.class, new ExternalServiceMock(201));
        List<Case> listCases = [SELECT Id,Status FROM Case];
        ExtrernalServiceQueue job = new ExtrernalServiceQueue(listCases);
       
        //WHEN
        Test.startTest();
        Id jobid = System.enqueueJob(job);
        Test.stopTest();

        //THEN
        System.assert(jobid != null);
    }
}