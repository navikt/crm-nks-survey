public with sharing class NKS_SurveyController {
    /**
     * @description Function to generate SF SurveyInvitationLink per Case
     * @author Sara Mohammadi | 14. mars 2023
     * @param Id surveyId
     * @param Id caseId
     * @param Boolean reserved
     * @return String surveyUrl
     */
    @AuraEnabled
    public static String createSurveyInvitation(Id surveyId, Id caseId, Boolean isReserved) {
        Id communityId;
        String surveyUrl;
        String surveyName;

        if (!Test.isRunningTest()) {
            communityId = [SELECT Id FROM Network WHERE Name = 'TilbakemeldingAura'].Id;
            Survey survey = [SELECT Id, DeveloperName FROM Survey WHERE Id = :surveyId];
            surveyName = survey.DeveloperName;
        }

        try {
            // check if user is reserved in KRR
            if (isReserved) {
                throw new SurveyException('This user is reserved in KRR.');
            }

            // check if user has recieved SurveyLink for current Case
            List<SurveyInvitation> surveyInvitations = [SELECT id FROM SurveyInvitation WHERE Case__c = :caseId];
            if (surveyInvitations.size() > 0) {
                throw new SurveyException('Survey for this case is already completed.');
            }

            // Send survey to random users
            Integer randNum = (Math.random() * 100).intValue();
            if (randNum <= 40) {
                if (!Test.isRunningTest()) {
                    throw new SurveyException('This user does not visit the condition for sending survey.');
                }
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

            return surveyUrl;
        } catch (exception ex) {
            System.debug('The following exception has occurred while inserting SurveySubject: ' + ex.getMessage());
            surveyUrl = ex.getMessage();
            return surveyUrl;
        } finally {
            return surveyUrl;
        }
    }

    private static String getBaseURL() {
        Site site = [SELECT Id FROM Site WHERE Name = 'TilbakemeldingAura' LIMIT 1];
        String communityUrl = [SELECT SecureURL FROM SiteDetail WHERE DurableId = :site.Id].SecureUrl;
        return communityUrl;
    }

    private class SurveyException extends Exception {
    }
}
