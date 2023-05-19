@IsTest(SeeAllData=true)
public with sharing class NKS_SurveyInvitationTriggerTest {
    @isTest
    static void testOptionsAllowGuestUserResponse() {
        Survey s = [SELECT Id FROM Survey WHERE DeveloperName = 'nks_test_survey'];

        SurveyInvitation si = [
            SELECT Id, SurveyId, ResponseStatus, OptionsAllowGuestUserResponse
            FROM SurveyInvitation
            LIMIT 1
        ];
        SurveyInvitation updatedSI = new SurveyInvitation(Id = si.Id, OptionsAllowGuestUserResponse = false);
        Test.startTest();
        update updatedSI;
        Test.stopTest();

        SurveyInvitation siResult = [SELECT OptionsAllowGuestUserResponse FROM SurveyInvitation WHERE Id = :si.Id];
        System.assertEquals(false, siResult.OptionsAllowGuestUserResponse);
    }
}
