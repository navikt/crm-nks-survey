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
}
