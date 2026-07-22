public with sharing class NKS_MessagingSurveyInvitationInvocable {
    public class Input {
        @InvocableVariable(required=true)
        public String sessionId;

        @InvocableVariable(required=true)
        public String surveyDeveloperName;
    }

    @InvocableMethod(label='Generate SurveyInvitation for Messaging Session')
    public static List<Id> generateSurveyInvitation(List<Input> inputs) {
        List<Id> results = new List<Id>();

        if (inputs == null || inputs.isEmpty()) {
            throw new NKS_SurveyController.SurveyException('At least one MessagingSession input row is required.');
        }

        for (Input input : inputs) {
            if (input == null) {
                throw new NKS_SurveyController.SurveyException('MessagingSession input row cannot be null.');
            }

            results.add(
                NKS_SurveyController.createSurveyInvitationForMessagingSession(
                    input.surveyDeveloperName,
                    input.sessionId
                )
            );
        }

        return results;
    }
}
