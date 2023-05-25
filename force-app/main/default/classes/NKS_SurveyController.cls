public with sharing class NKS_SurveyController {
    /**
     * @description Function to generate SF SurveyInvitationLink per Case
     * @author Sara Mohammadi | 14. mars 2023
     * @param Id surveyId
     * @param Id caseId
     * @return String surveyUrl
     */
    @AuraEnabled
    public static String createSurveyInvitation(String developerName, Id caseId) {
        Id communityId;
        Survey survey = new Survey();
        String surveyUrl = '';

        if (!Test.isRunningTest()) {
            communityId = [SELECT Id FROM Network WHERE Name = 'TilbakemeldingAura'].Id;
            survey = [SELECT Id, DeveloperName FROM Survey WHERE DeveloperName = :developerName];
        }

        try {
            // check if user has received SurveyLink for current Case
            List<SurveyInvitation> surveyInvitations = [SELECT Id FROM SurveyInvitation WHERE Case__c = :caseId];
            if (surveyInvitations.size() > 0) {
                throw new SurveyException('A Survey Invitation already exists for this case.');
            }

            SurveyInvitation si = new SurveyInvitation();
            si.CommunityId = communityId;
            si.SurveyId = survey.Id;
            si.Name = 'NKS Survey';
            si.Case__c = caseId;
            si.OptionsAllowGuestUserResponse = true;
            si.OptionsCollectAnonymousResponse = true;
           
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
                developerName +
                '&UUID=' +
                uniqueSInvId;
            System.debug('survey url' + JSON.serialize(surveyUrl));
        } catch (Exception e) {
            System.debug('The following exception has occurred while creating SurveyInvitation: ' + e.getMessage());
            //throw new SurveyException('An error has occurred while creating SurveyInvitation');
        }
        return surveyUrl;
    }

    /**
     * @description Function to create SurveyInvitation
     * @author Sara Mohammadi | 9. Mai 2023
     * @param SurveyInvocableParameters parameters
     * @return String SurveyInvitationLink
     */
    public static String invokeCreateSurveyInvitation(SurveyInvocableParameters parameters) {
        return createSurveyInvitation(parameters.surveyDeveloperName, parameters.caseId);
    }

    /**
     * @description Function to create survey link
     * @author Sara Mohammadi | 9. Mai 2023
     * @param List<SurveyInvocableParameters> parametersList
     * @return List<String> survey link
     */
    @invocableMethod(label='Generate SurveyInvitationLink')
    public static List<String> generateSurveyLink(List<SurveyInvocableParameters> parametersList) {
        List<String> surveyLinks = new List<String>();
        try {
            for (Integer i = 0; i < parametersList.size(); i++) {
                String surveyLink = invokeCreateSurveyInvitation(parametersList[i]);
                surveyLinks.add(surveyLink);
            }
        } catch (Exception e) {
            System.debug('Problem creating SurveyInvitationLink: ' + e.getMessage());
        }
        return surveyLinks;
    }

    /**
     * @description Function to check SurveyResponse
     * @author Sara Mohammadi | 6. April 2023
     * @param Id caseId
     * @return True if status is completed, False otherwise
     */
    @AuraEnabled
    public static Boolean checkSurveyResponse(Id caseId) {
        String status = '';
        if (Test.isRunningTest()) {
            status = 'Started';
        }
        try {
            status = [SELECT Id, ResponseStatus FROM SurveyInvitation WHERE Case__c = :caseId LIMIT 1]?.ResponseStatus;
        } catch (Exception e) {
            System.debug(
                'The following exception has occurred while gettting ResponseStatus for Case ' +
                caseId +
                ': ' +
                e.getMessage()
            );
            // throw new SurveyException('Problem getting ResponseStatus for Case ' + caseId + '.');
        }
        return status == 'Completed';
    }

    /**
     * @description Function to get Base URL
     * @author Sara Mohammadi | 6. April 2023
     * @return String Community Base URL
     */
    public static String getBaseURL() {
        String url = '';
        if (Test.isRunningTest()) {
            url = 'testUrl';
        }
        try {
            Id siteId = [SELECT Id FROM Site WHERE Name = 'TilbakemeldingAura' LIMIT 1]?.Id;
            url = [SELECT SecureURL FROM SiteDetail WHERE DurableId = :siteId].SecureUrl;
        } catch (Exception e) {
            System.debug('The following exception has occurred while gettting Base URL : ' + e.getMessage());
            // throw new SurveyException('Problem getting Base URL.');
        }
        return url;
    }

    private class SurveyException extends Exception {
    }

    /**
     * @description Class to define invocable variables
     * @author Sara Mohammadi | 9. Mai 2023
     */
    public class SurveyInvocableParameters {
        @InvocableVariable(required=true)
        public Id caseId;

        @InvocableVariable(required=true)
        public String surveyDeveloperName;
    }
}
