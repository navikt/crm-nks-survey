public with sharing class NKS_CaseSurveyInvitationInvocable {
    public class Input {
        @InvocableVariable(required=true)
        public Id caseId;

        @InvocableVariable(required=true)
        public String surveyDeveloperName;
    }

    @InvocableMethod(label='Generate SurveyInvitation for Case')
    public static List<Id> generateSurveyInvitation(List<Input> inputs) {
        List<Id> results = new List<Id>();

        if (inputs == null || inputs.isEmpty()) {
            throw new NKS_SurveyController.SurveyException('At least one Case input row is required.');
        }

        for (Input input : inputs) {
            if (input == null) {
                throw new NKS_SurveyController.SurveyException('Case input row cannot be null.');
            }

            results.add(NKS_SurveyController.createSurveyInvitationForCase(input.surveyDeveloperName, input.caseId));
        }

        return results;
    }
}
