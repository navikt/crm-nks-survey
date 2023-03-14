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
            System.assertEquals('SurveyException', ex.getTypeName());
        }
        Test.stopTest();
        System.assertEquals('This user is reserved in KRR.', url);
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
            System.assertEquals(ex.getMessage(), url);
        }
        Test.stopTest();
    }
}
