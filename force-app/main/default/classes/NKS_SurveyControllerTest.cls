@isTest
public with sharing class NKS_SurveyControllerTest {
    @IsTest
    static void testCreateSurveyInvitaionReserved() {
        Case testCase = new Case();
        Survey testSurvey = new Survey();
        String url;

        Test.startTest();
        try {
            url = NKS_SurveyController.createSurveyInvitation(testSurvey.Id, testCase.Id, true);
        } catch (Exception ex) {
            System.assertEquals('SurveyException', ex.getTypeName(), 'Checks exception type');
        }
        Test.stopTest();
        System.assertEquals(
            'This user is reserved in KRR.',
            url,
            'Checks if function throws SurveyException when user is reserved in KRR'
        );
    }

    @IsTest
    static void testCreateSurveyInvitaion() {
        Case testCase = new Case();
        Survey testSurvey = new Survey();
        String url;

        Test.startTest();
        try {
            url = NKS_SurveyController.createSurveyInvitation(testSurvey.Id, testCase.Id, false);
        } catch (Exception ex) {
            System.assertEquals(ex.getMessage(), url, 'Survey URL is not generated.');
        }
        Test.stopTest();
    }

    @IsTest
    static void testGetBaseUrl() {
        Test.startTest();
        String testUrl = NKS_SurveyController.getBaseUrl();
        Test.stopTest();
        System.assertEquals('testUrl', testUrl, 'Dummy test!');
    }
}
