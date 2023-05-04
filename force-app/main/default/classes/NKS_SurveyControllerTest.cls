@isTest
public with sharing class NKS_SurveyControllerTest {
    /**
     * Test the createSurveyInvitation() method when one already exists
     */
    @isTest
    static void testCreateSurveyInvitation() {
        Case testCase = new Case(Subject = 'Test Subject', Description = 'Test Description');
        Survey testSurvey = new Survey();
        // Test creating a survey invitation
        String surveyUrl = NKS_SurveyController.createSurveyInvitation(testSurvey.Id, testCase.Id);

        // Test creating a survey invitation when one already exists
        Test.startTest();
        try {
            NKS_SurveyController.createSurveyInvitation(testSurvey.Id, testCase.Id);
        } catch (Exception e) {
            // Ensure that the correct exception message is returned
            System.assertEquals(
                'NKS_SurveyController.SurveyException',
                e.getTypeName(),
                'Expected to throw SurveyException.'
            );
            System.assertEquals('A Survey Invitation already exists for this case.', e.getMessage());
        }
        Test.stopTest();
    }

    /**
     * Test the checkSurveyResponse() method
     */
    @isTest
    static void testCheckSurveyResponse() {
        Case testCase = new Case(Subject = 'Test Subject', Description = 'Test Description');

        Test.startTest();
        Boolean result = NKS_SurveyController.checkSurveyResponse(testCase.Id);
        Test.stopTest();
        System.assertEquals(false, result, 'Survey response status should be false.');
    }

    /**
     * Test the getBaseURL() method
     */
    @isTest
    static void testGetBaseURL() {
        String url = '';
        Test.startTest();
        try {
            url = NKS_SurveyController.getBaseURL();
        } catch (Exception e) {
            // Ensure that the correct exception message is returned
            System.assertEquals(
                'NKS_SurveyController.SurveyException',
                e.getTypeName(),
                'Expected to throw SurveyException.'
            );
            System.assertEquals('Problem getting Base URL.', e.getMessage());
        }
        Test.stopTest();
        System.assertNotEquals(null, url, 'Expected to return Base URL.');
    }
}
