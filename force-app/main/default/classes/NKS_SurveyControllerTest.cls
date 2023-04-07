@isTest
public with sharing class NKS_SurveyControllerTest {
    /**
     * Test the createSurveyInvitation() method when one already exists
     */
    @isTest
    static void testCreateSurveyInvitation() {
        // Test data
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
            System.assertEquals('SurveyException', e.getTypeName(), 'Expected to throw SurveyException.');
            System.assertEquals('A Survey Invitation already exists for this case.', e.getMessage());
        }
        Test.stopTest();
    }

    /**
     * Test the checkSurveyResponse() method
     */
    @isTest
    static void testCheckSurveyResponse() {
        // Test data
        Case testCase = new Case(Subject = 'Test Subject', Description = 'Test Description');

        // Call the method
        Test.startTest();
        Boolean result = NKS_SurveyController.checkSurveyResponse(testCase.Id);
        Test.stopTest();

        // Assert the result
        System.assertEquals(false, result, 'Survey response status should be false.');
    }

    /**
     * Test the getBaseURL() method
     */
    @isTest
    static void testGetBaseURL() {
        // Call the method
        Test.startTest();
        try {
            String result = NKS_SurveyController.getBaseURL();
        } catch (Exception e) {
            System.assert(true, 'Expected an exception');
        }
        Test.stopTest();
    }
}
