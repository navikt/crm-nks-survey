@isTest
public with sharing class NKS_SurveyControllerTest {
    @TestSetup
    static void makeData() {
        Case testCase = new Case(Subject = 'Test Subject', Description = 'Test Description');
        insert testCase;
    }

    /**
     * Test the generateSurveyInvitation() method when one already exists
     */
    @isTest
    static void testGenerateSurveyInvitation() {
        Id caseId = [SELECT Id FROM Case LIMIT 1]?.Id;
        NKS_SurveyController.SurveyInvocableParameters parameters = new NKS_SurveyController.SurveyInvocableParameters();
        parameters.surveyDeveloperName = 'test_survey';
        parameters.caseId = caseId;
        List<NKS_SurveyController.SurveyInvocableParameters> parametersList = new List<NKS_SurveyController.SurveyInvocableParameters>();
        parametersList.add(parameters);
        List<Id> surveyIds = new List<Id>();

        // Test creating a survey invitation
        Test.startTest();
        try {
            surveyIds = NKS_SurveyController.generateSurveyInvitation(parametersList);
        } catch (Exception e) {
            // Ensure that the correct exception message is returned
            System.assertEquals(
                'NKS_SurveyController.SurveyException',
                e.getTypeName(),
                'Expected to throw SurveyException.'
            );
            System.assertEquals('An error has occurred while creating SurveyInvitation', e.getMessage());
        }
        Test.stopTest();
        System.assertNotEquals(0, surveyIds.size(), 'Survey URL should not be null.');
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
