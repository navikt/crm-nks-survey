@isTest
public with sharing class NKS_SurveyControllerTest {
    @isTest
    static void testGetCommunityURL() {
        String testurl = '';
        Test.startTest();
        try {
            testurl = NKS_SurveyController.getCommunityURL();
        } catch (Exception ex) {
            System.assertEquals('List has no rows for assignment to SObject', ex.getMessage());
        }
        Test.stopTest();
    }

    @isTest
    static void testCreateSurveyInvitation() {
        NKS_SurveyController.WrapperResult testWrapper;
        Test.startTest();
        try {
            testWrapper = NKS_SurveyController.createSurveyInvitation();
        } catch (Exception ex) {
        }
        Test.stopTest();
    }

    @isTest
    static void testException() {
        NKS_SurveyController.WrapperResult testWrapper;
        Test.startTest();
        NKS_SurveyController.simulateException(new DmlException('ERROR'));
            testWrapper = NKS_SurveyController.createSurveyInvitation();
        Test.stopTest();

        System.assertEquals(true, testWrapper.error);


    }
}
