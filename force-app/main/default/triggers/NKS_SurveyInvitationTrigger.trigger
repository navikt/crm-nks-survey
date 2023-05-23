trigger NKS_SurveyInvitationTrigger on SurveyInvitation(
    before insert,
    before update,
    before delete,
    after insert,
    after update,
    after delete,
    after undelete
) {
    MyTriggers.run();
}
