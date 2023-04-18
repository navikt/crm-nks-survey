public with sharing class NKS_SurveyController {
    /**
     * @description Function to generate SF SurveyInvitationLink per Case
     * @author Sara Mohammadi | 14. mars 2023
     * @param Id surveyId
     * @param Id caseId
     * @return String surveyUrl
     */
    @AuraEnabled
    public static String createSurveyInvitation(Id surveyId, Id caseId) {
        Id communityId;
        String surveyUrl = '';
        Survey Survey = new Survey();

        if (!Test.isRunningTest()) {
            communityId = [SELECT Id FROM Network WHERE Name = 'TilbakemeldingAura'].Id;
            survey = [SELECT Id, DeveloperName FROM Survey WHERE Id = :surveyId];
        }

        try {
            // check if user has received SurveyLink for current Case
            List<SurveyInvitation> surveyInvitations = [SELECT Id FROM SurveyInvitation WHERE Name = :caseId];
            if (surveyInvitations.size() > 0) {
                throw new SurveyException('A Survey Invitation already exists for this case.');
            }

            SurveyInvitation si = new SurveyInvitation();
            si.CommunityId = communityId;
            si.Name = caseId;
            si.OptionsAllowGuestUserResponse = true;
            si.OptionsCollectAnonymousResponse = true;
            si.SurveyId = surveyId;
            if (!Test.isRunningTest()) {
                insert si;
            }

            SurveyInvitation sInv = new surveyInvitation();
            if (!Test.isRunningTest()) {
                sInv = [SELECT Id, UUID FROM SurveyInvitation WHERE Id = :si.Id];
            }
            String uniqueSInvId = sInv.UUID;
            surveyUrl =
                getBaseURL() +
                'survey/runtimeApp.app?invitationId=' +
                sInv.Id +
                '&surveyName=' +
                survey.DeveloperName +
                '&UUID=' +
                uniqueSInvId;
            System.debug('survey url' + JSON.serialize(surveyUrl));
        } catch (Exception e) {
            System.debug('The following exception has occurred while creating SurveyInvitation: ' + e.getMessage());
        }
        return surveyUrl;
    }

    /**
     * @description Function to check SurveyResponse
     * @author Sara Mohammadi | 6. April 2023
     * @param Id caseId
     * @return True if status is completed, False otherwise
     */
    @AuraEnabled
    public static Boolean checkSurveyResponse(Id caseId) {
        String status = [SELECT Id, ResponseStatus FROM SurveyInvitation WHERE Name = :caseId LIMIT 1]?.ResponseStatus;
        return status == 'Completed';
    }

    /**
     * @description Function to get Base URL
     * @author Sara Mohammadi | 6. April 2023
     * @return String Community Base URL
     */
    public static String getBaseURL() {
        Site site = [SELECT Id FROM Site WHERE Name = 'TilbakemeldingAura' LIMIT 1];
        return [SELECT SecureURL FROM SiteDetail WHERE DurableId = :site.Id].SecureUrl;
    }

    private class SurveyException extends Exception {
    }
}
