@isTest
public with sharing class NKS_SurveyControllerTest {
    @IsTest
    static void testCreateSurveyInvitaion() {
        Case testCase = new Case();
        Survey testSurvey = new Survey();
        String url;

        Test.startTest();
        try {
            url = NKS_SurveyController.createSurveyInvitation(testSurvey.Id, testCase.Id);
        } catch (Exception ex) {
            System.assertEquals(ex.getMessage(), url, 'Survey URL is not generated.');
        }
        Test.stopTest();
    }

    @IsTest
    static void testCheckSurveyResponse() {
        Case testCase = new Case();

        Test.startTest();
        Boolean completed = NKS_SurveyController.checkSurveyResponse(testCase.Id);
        Test.stopTest();
        System.assertEquals(false, completed, 'Test ResponseStatus');
    }

    @IsTest
    static void testGetBaseUrl() {
        Test.startTest();
        String testUrl = NKS_SurveyController.getBaseUrl();
        Test.stopTest();
        System.assertEquals('testUrl', testUrl, 'Dummy test!');
    }
}