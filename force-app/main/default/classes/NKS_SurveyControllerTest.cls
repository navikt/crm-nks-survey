@isTest
public with sharing class NKS_SurveyControllerTest {
    @isTest
    static void testGetCommunityURL() {
        Boolean throwsException = false;
        String testurl = '';
        Test.startTest();
        try {
            testurl = NKS_SurveyController.getCommunityURL();
        } catch (Exception ex) {
            throwsException = true;
            System.assertEquals('List has no rows for assignment to SObject', ex.getMessage());
        }
        Test.stopTest();

        System.assertEquals('', testurl);
        System.assertEquals(true, throwsException);
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

        System.assertEquals(testWrapper.res, 'List has no rows for assignment to SObject');
        System.assertEquals(true, testWrapper.error);
    }
}
