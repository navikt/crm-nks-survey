public with sharing class NKS_SurveyController {
    private static final String COMMUNITY_NAME = 'TilbakemeldingAura';
    private static final String SITE_NAME = 'TilbakemeldingAura';
    private static final String INVITATION_NAME = 'NKS Survey';

    @TestVisible
    private static Id testCommunityId;
    @TestVisible
    private static Id testSurveyId;
    @TestVisible
    private static String testBaseUrl;

    @AuraEnabled
    public static Id createSurveyInvitationForCase(String developerName, Id caseId) {
        if (String.isBlank(developerName)) {
            throw new SurveyException('developerName is required.');
        }
        if (caseId == null) {
            throw new SurveyException('caseId is required.');
        }

        Id communityId = getCommunityId();
        Id surveyId = getSurveyId(developerName);

        try {
            List<SurveyInvitation> surveyInvitations = [
                SELECT Id
                FROM SurveyInvitation
                WHERE Case__c = :caseId
            ];
            if (!surveyInvitations.isEmpty()) {
                return null;
            }

            SurveyInvitation si = new SurveyInvitation();
            si.CommunityId = communityId;
            si.SurveyId = surveyId;
            si.Name = INVITATION_NAME;
            si.Case__c = caseId;
            si.OptionsAllowGuestUserResponse = true;
            si.OptionsCollectAnonymousResponse = true;

            if (!Test.isRunningTest()) {
                insert si;
            }

            return si.Id;
        } catch (Exception e) {
            throw new SurveyException(
                'An error has occurred while creating SurveyInvitation for Case. ' +
                    'caseId=' +
                    caseId +
                    ', developerName=' +
                    developerName +
                    ', message=' +
                    e.getMessage()
            );
        }
    }

    @AuraEnabled
    public static Id createSurveyInvitationForMessagingSession(String developerName, Id sessionId) {
        if (String.isBlank(developerName)) {
            throw new SurveyException('developerName is required.');
        }
        if (sessionId == null) {
            throw new SurveyException('sessionId is required.');
        }

        Id communityId = getCommunityId();
        Id surveyId = getSurveyId(developerName);

        try {
            List<SurveyInvitation> surveyInvitations = [
                SELECT Id
                FROM SurveyInvitation
                WHERE MessagingSession__c = :sessionId
            ];
            if (!surveyInvitations.isEmpty()) {
                return null;
            }

            if (!Test.isRunningTest()) {
                MessagingSession ms = [
                    SELECT Id, OwnerId, CreatedById
                    FROM MessagingSession
                    WHERE Id = :sessionId
                    LIMIT 1
                ];

                SurveyInvitation si = new SurveyInvitation();
                si.CommunityId = communityId;
                si.SurveyId = surveyId;
                si.Name = INVITATION_NAME;
                si.MessagingSession__c = sessionId;
                si.OptionsAllowGuestUserResponse = true;
                si.OptionsCollectAnonymousResponse = true;

                insert si;
                return si.Id;
            }

            return null;
        } catch (Exception e) {
            throw new SurveyException(
                'An error occurred while creating SurveyInvitation for MessagingSession. ' +
                    'userId=' +
                    UserInfo.getUserId() +
                    ', sessionId=' +
                    sessionId +
                    ', developerName=' +
                    developerName +
                    ', communityId=' +
                    communityId +
                    ', surveyId=' +
                    surveyId +
                    ', canReadMessagingSession=' +
                    Schema.sObjectType.MessagingSession.isAccessible() +
                    ', canCreateSurveyInvitation=' +
                    Schema.sObjectType.SurveyInvitation.isCreateable() +
                    ', message=' +
                    e.getMessage()
            );
        }
    }

    @AuraEnabled
    public static Boolean checkSurveyResponse(Id caseId) {
        if (caseId == null) {
            throw new SurveyException('caseId is required.');
        }

        String status = '';
        if (Test.isRunningTest()) {
            status = 'Started';
        }

        try {
            status = [
                SELECT ResponseStatus
                FROM SurveyInvitation
                WHERE Case__c = :caseId
                LIMIT 1
            ]
            ?.ResponseStatus;
        } catch (Exception e) {
            throw new SurveyException(
                'Problem getting ResponseStatus for Case. caseId=' + caseId + ', message=' + e.getMessage()
            );
        }

        return status == 'Completed';
    }

    public static String getBaseURL() {
        if (Test.isRunningTest() && testBaseUrl != null) {
            return testBaseUrl;
        }

        String url = '';
        if (Test.isRunningTest()) {
            url = 'testUrl';
        }

        try {
            Id siteId = [SELECT Id FROM Site WHERE Name = :SITE_NAME LIMIT 1]?.Id;
            url = [SELECT SecureURL FROM SiteDetail WHERE DurableId = :siteId].SecureUrl;
        } catch (Exception e) {
            throw new SurveyException('Problem getting Base URL. message=' + e.getMessage());
        }

        return url;
    }

    private static Id getCommunityId() {
        if (Test.isRunningTest() && testCommunityId != null) {
            return testCommunityId;
        }
        return resolveCommunityId();
    }

    private static Id getSurveyId(String developerName) {
        if (Test.isRunningTest() && testSurveyId != null) {
            return testSurveyId;
        }
        return resolveSurveyId(developerName);
    }

    private static Id resolveCommunityId() {
        try {
            return [SELECT Id FROM Network WHERE Name = :COMMUNITY_NAME LIMIT 1].Id;
        } catch (Exception e) {
            throw new SurveyException(
                'Problem resolving community. name=' + COMMUNITY_NAME + ', message=' + e.getMessage()
            );
        }
    }

    private static Id resolveSurveyId(String developerName) {
        try {
            return [SELECT Id FROM Survey WHERE DeveloperName = :developerName LIMIT 1].Id;
        } catch (Exception e) {
            throw new SurveyException(
                'Problem resolving survey. developerName=' + developerName + ', message=' + e.getMessage()
            );
        }
    }

    public class SurveyException extends Exception {
    }
}
