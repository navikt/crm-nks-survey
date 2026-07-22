@isTest
private class NKS_CaseSurveyInvitationInvocableTest {
    @isTest
    static void testGenerateSurveyInvitationThrowsWhenInputsNull() {
        Test.startTest();
        try {
            NKS_CaseSurveyInvitationInvocable.generateSurveyInvitation(null);
            Assert.fail('Expected exception was not thrown');
        } catch (Exception e) {
            Assert.areEqual('At least one Case input row is required.', e.getMessage());
        }
        Test.stopTest();
    }

    @isTest
    static void testGenerateSurveyInvitationThrowsWhenInputsEmpty() {
        Test.startTest();
        try {
            NKS_CaseSurveyInvitationInvocable.generateSurveyInvitation(
                new List<NKS_CaseSurveyInvitationInvocable.Input>()
            );
            Assert.fail('Expected exception was not thrown');
        } catch (Exception e) {
            Assert.areEqual('At least one Case input row is required.', e.getMessage());
        }
        Test.stopTest();
    }

    @isTest
    static void testGenerateSurveyInvitationThrowsWhenInputRowNull() {
        List<NKS_CaseSurveyInvitationInvocable.Input> inputs = new List<NKS_CaseSurveyInvitationInvocable.Input>{
            null
        };

        Test.startTest();
        try {
            NKS_CaseSurveyInvitationInvocable.generateSurveyInvitation(inputs);
            Assert.fail('Expected exception was not thrown');
        } catch (Exception e) {
            Assert.areEqual('Case input row cannot be null.', e.getMessage());
        }
        Test.stopTest();
    }

    @isTest
    static void testGenerateSurveyInvitationReturnsSingleResult() {
        Case testCase = new Case(Subject = 'Test Subject', Status = 'New');
        insert testCase;

        NKS_SurveyController.testCommunityId = '0DB000000000001';
        NKS_SurveyController.testSurveyId = '0K9000000000001';

        NKS_CaseSurveyInvitationInvocable.Input inputRow = new NKS_CaseSurveyInvitationInvocable.Input();
        inputRow.caseId = testCase.Id;
        inputRow.surveyDeveloperName = 'test_survey';

        Test.startTest();
        List<Id> results = NKS_CaseSurveyInvitationInvocable.generateSurveyInvitation(
            new List<NKS_CaseSurveyInvitationInvocable.Input>{ inputRow }
        );
        Test.stopTest();

        Assert.areEqual(1, results.size());
        Assert.areEqual(null, results[0]);
    }

    @isTest
    static void testGenerateSurveyInvitationReturnsMultipleResults() {
        Case testCase1 = new Case(Subject = 'Test Subject 1', Status = 'New');
        Case testCase2 = new Case(Subject = 'Test Subject 2', Status = 'New');
        insert new List<Case>{ testCase1, testCase2 };

        NKS_SurveyController.testCommunityId = '0DB000000000001';
        NKS_SurveyController.testSurveyId = '0K9000000000001';

        NKS_CaseSurveyInvitationInvocable.Input inputRow1 = new NKS_CaseSurveyInvitationInvocable.Input();
        inputRow1.caseId = testCase1.Id;
        inputRow1.surveyDeveloperName = 'test_survey';

        NKS_CaseSurveyInvitationInvocable.Input inputRow2 = new NKS_CaseSurveyInvitationInvocable.Input();
        inputRow2.caseId = testCase2.Id;
        inputRow2.surveyDeveloperName = 'test_survey';

        Test.startTest();
        List<Id> results = NKS_CaseSurveyInvitationInvocable.generateSurveyInvitation(
            new List<NKS_CaseSurveyInvitationInvocable.Input>{ inputRow1, inputRow2 }
        );
        Test.stopTest();

        Assert.areEqual(2, results.size());
        Assert.isNull(results[0]);
        Assert.isNull(results[1]);
    }
}
