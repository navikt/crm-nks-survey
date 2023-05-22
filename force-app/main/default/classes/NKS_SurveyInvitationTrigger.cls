public with sharing class NKS_SurveyInvitationTrigger extends MyTriggers {
    public override void onBeforeUpdate(Map<Id, SObject> triggerOldMap) {
        for (SurveyInvitation si : (List<SurveyInvitation>) Trigger.new) {
            SurveyInvitation siOld = (SurveyInvitation) triggerOldMap.get(si.Id);
            if (si.ResponseStatus == 'Completed' && si.ResponseStatus != siOld.ResponseStatus) {
                si.OptionsAllowGuestUserResponse = false;
            }
        }
    }
}
