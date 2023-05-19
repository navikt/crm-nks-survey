/**
 * Trigger on a SurveyInvitation : if the invitation has been responded set option for responding to False
 */
trigger NKS_SurveyInvitationTrigger on SurveyInvitation(before update) {
    for (Id surveyId : Trigger.newMap.keySet()) {
        SurveyInvitation newRecord = Trigger.newMap.get(surveyId);
        SurveyInvitation oldRecord = Trigger.oldMap.get(surveyId);

        if (newRecord.ResponseStatus == 'Completed' && newRecord.ResponseStatus != oldRecord.ResponseStatus) {
            newRecord.OptionsAllowGuestUserResponse = false;
        }
    }
}
