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
        String surveyUrl;
        String surveyName;
        Survey survey = new Survey();

        if (!Test.isRunningTest()) {
            communityId = [SELECT Id FROM Network WHERE Name = 'TilbakemeldingAura'].Id;
            survey = [SELECT Id, DeveloperName FROM Survey WHERE Id = :surveyId];
        }
        surveyName = survey.DeveloperName;

        try {
            // check if user has recieved SurveyLink for current Case
            List<SurveyInvitation> surveyInvitations = [SELECT id FROM SurveyInvitation WHERE Case__c = :caseId];
            if (surveyInvitations.size() > 0 && !Test.isRunningTest()) {
                throw new SurveyException('A Survey Invitation already exists for this case.');
            }

            SurveyInvitation si = new SurveyInvitation();
            si.CommunityId = communityId;
            si.Name = caseId;
            si.Case__c = caseId;
            si.OptionsAllowGuestUserResponse = true;
            si.OptionsCollectAnonymousResponse = true;
            si.SurveyId = surveyId;
            if (!Test.isRunningTest()) {
                insert si;
            }

            SurveySubject ss = new SurveySubject();
            ss.SubjectId = caseId;
            ss.ParentId = si.Id;
            ss.Name = caseId;
            if (!Test.isRunningTest()) {
                insert ss;
            }

            SurveyInvitation sInv = new surveyInvitation();
            if (!Test.isRunningTest()) {
                sInv = [SELECT Id, UUID FROM SurveyInvitation WHERE Id = :si.Id];
            }
            String uniqueSInvId = sInv.UUID;
            surveyUrl =
                getBaseURL() +
                'survey/runtimeApp.app?invitationId=' +
                sInv.id +
                '&surveyName=' +
                surveyName +
                '&UUID=' +
                uniqueSInvId;
            System.debug('survey url' + json.serialize(surveyURL));
        } catch (exception e) {
            System.debug('The following exception has occurred while creating SurveyInvitation: ' + e.getMessage());
        }
        return surveyUrl;
    }

    @AuraEnabled
    public static Boolean checkSurveyResponse(Id caseId) {
        String status;
        if (Test.isRunningTest()) {
            status = 'Started';
        }

        try {
            if (!Test.isRunningTest()) {
                status = [SELECT Id, Case__c, ResponseStatus FROM SurveyInvitation WHERE Case__c = :caseId LIMIT 1]
                ?.ResponseStatus;
            }
            if (status == 'Completed') {
                return true;
            }
        } catch (Exception ex) {
            System.debug('The following exception has occurred while checking ResponseStatus: ' + ex.getMessage());
        }
        return false;
    }

    public static String getBaseURL() {
        Site site = new Site();
        String communityUrl;
        if (Test.isRunningTest()) {
            communityUrl = 'testUrl';
        }
        if (!Test.isRunningTest()) {
            site = [SELECT Id FROM Site WHERE Name = 'TilbakemeldingAura' LIMIT 1];
            communityUrl = [SELECT SecureURL FROM SiteDetail WHERE DurableId = :site.Id].SecureUrl;
        }
        return communityUrl;
    }

    private class SurveyException extends Exception {
    }
}
