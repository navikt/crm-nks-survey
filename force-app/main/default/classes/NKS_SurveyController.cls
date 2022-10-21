public with sharing class NKS_SurveyController {
    public static String getCommunityURL() {
        Site site = [SELECT Id FROM Site WHERE Name = 'Feedback' LIMIT 1];
        String communityURL = [SELECT SecureURL FROM SiteDetail WHERE DurableId = :site.Id].SecureUrl;
        return communityURL;
    }

    @AuraEnabled
    public static WrapperResult createSurveyInvitation() {
        String communityId;
        String surveyId;
        String result; // result can be surveyInvitationLink or errorMessage
        Integer randNum;
        Integer limitResponses;
        WrapperResult wrapper = new WrapperResult(null, null);

        try {
            /*
            randNum = (Math.random() * 100).intValue();
            if (randNum >= 40) {
                throw new SurveyException('This user did not visit the condition for sending survey.');
            } 
            */
            limitResponses = [SELECT COUNT() FROM SurveyResponse WHERE ResponseStatus = 'Completed'];
            if (limitResponses > 300) {
                throw new SurveyException('Limit for SurveyResponses has exceeded.');
            } else {
                communityId = [SELECT Id FROM Network WHERE Name = 'Feedback'].Id;
                surveyId = [SELECT Id FROM Survey WHERE DeveloperName = 'nks_service_survey'].Id;

                SurveyInvitation surveyInvitation = new SurveyInvitation();
                surveyInvitation.CommunityId = communityId;
                surveyInvitation.OptionsAllowGuestUserResponse = true;
                surveyInvitation.OptionsCollectAnonymousResponse = true;
                surveyInvitation.SurveyId = surveyId;
                surveyInvitation.Name = 'Survey Invitation';
                insert surveyInvitation;

                SurveyInvitation surveyInvitaionRecord = [
                    SELECT Id, UUID
                    FROM SurveyInvitation
                    WHERE Id = :surveyInvitation.Id
                ];
                string uniqueSurveyInvitationId = surveyInvitaionRecord.UUID;
                result =
                    getCommunityURL() +
                    '/survey/runtimeApp.app?invitationId=' +
                    surveyInvitaionRecord.Id +
                    '&surveyName=nks_service_survey&UUID=' +
                    uniqueSurveyInvitationId;

                // System.debug('Survey Invitaion Link: ' + json.serialize(result));
                wrapper = new WrapperResult(false, result);
                return wrapper;
            }
        } catch (exception ex) {
            System.debug('The following exception has occurred while inserting SurveyInvitation: ' + ex.getMessage());
            result = ex.getMessage();
            wrapper = new WrapperResult(true, ex.getMessage());
            return wrapper;
        } finally {
            return wrapper;
        }
    }

    private class WrapperResult {
        @AuraEnabled
        public boolean error { get; set; }
        @AuraEnabled
        public string res { get; set; }

        public WrapperResult(boolean error, string res) {
            this.error = error;
            this.res = res;
        }
    }

    private class SurveyException extends Exception {
    }
}