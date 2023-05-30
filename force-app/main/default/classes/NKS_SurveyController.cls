public with sharing class NKS_SurveyController {
    /**
     * @description Function to generate SF SurveyInvitationLink per Case
     * @author Sara Mohammadi | 14. mars 2023
     * @param Id surveyId
     * @param Id caseId
     * @return String surveyUrl
     */
    @AuraEnabled
    public static Id createSurveyInvitation(String developerName, Id caseId) {
        Id communityId;
        Survey survey = new Survey();
        SurveyInvitation si = new SurveyInvitation();

        if (!Test.isRunningTest()) {
            communityId = [SELECT Id FROM Network WHERE Name = 'TilbakemeldingAura'].Id;
            survey = [SELECT Id, DeveloperName FROM Survey WHERE DeveloperName = :developerName];
        }

        try {
            // check if user has received SurveyLink for current Case
            List<SurveyInvitation> surveyInvitations = [SELECT Id FROM SurveyInvitation WHERE Case__c = :caseId];
            if (surveyInvitations.size() > 0) {
                System.debug('A Survey Invitation already exists for this case.');
                return null;
               
            }
            si.CommunityId = communityId;
            si.SurveyId = survey.Id;
            si.Name = 'NKS Survey';
            si.Case__c = caseId;
            si.OptionsAllowGuestUserResponse = true;
            si.OptionsCollectAnonymousResponse = true;
           
            if (!Test.isRunningTest()) {
                insert si;
            }
        } catch (Exception e) {
            System.debug('The following exception has occurred while creating SurveyInvitation: ' + e.getMessage());
            //throw new SurveyException('An error has occurred while creating SurveyInvitation');
        } 
        return si.Id;
    }

    /**
     * @description Function to create SurveyInvitation
     * @author Sara Mohammadi | 9. Mai 2023
     * @param SurveyInvocableParameters parameters
     * @return String SurveyInvitationLink
     */
    public static Id invokeCreateSurveyInvitation(SurveyInvocableParameters parameters) {
        return createSurveyInvitation(parameters.surveyDeveloperName, parameters.caseId);
    }

    /**
     * @description Function to create survey link
     * @author Sara Mohammadi | 9. Mai 2023
     * @param List<SurveyInvocableParameters> parametersList
     * @return List<String> survey link
     */
    @invocableMethod(label='Generate SurveyInvitation')
    public static List<Id> generateSurveyInvitation(List<SurveyInvocableParameters> parametersList) {
        List<Id> surveyInvitationIds = new List<Id>();
        try {
            for (Integer i = 0; i < parametersList.size(); i++) {
                Id siId = invokeCreateSurveyInvitation(parametersList[i]);
                surveyInvitationIds.add(siId);
            }
        } catch (Exception e) {
            System.debug('Problem creating SurveyInvitationLink: ' + e.getMessage());
        }
        return surveyInvitationIds;
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
