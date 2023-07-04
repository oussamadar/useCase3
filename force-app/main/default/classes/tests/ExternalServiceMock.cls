@isTest
public with sharing class ExternalServiceMock implements HttpCalloutMock {
    private Integer statusCode;

    public ExternalServiceMock(Integer statusCode) {
        this.statusCode = statusCode;
    }

    public HTTPResponse respond(HTTPRequest request) {
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setStatusCode(statusCode);
        return response; 
    }
}