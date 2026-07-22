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
    @TestVisible
    private static Boolean testSkipInsert = false;
    @TestVisible
    private static String testResponseStatus;
    @TestVisible
    private static Boolean testForceInvitationQueryException = false;

    @AuraEnabled
    public static Id createSurveyInvitationForCase(String developerName, Id caseId) {
        if (String.isBlank(developerName)) {
            throw new SurveyException('developerName is required.');
        }
        if (caseId == null) {
            throw new SurveyException('caseId is required.');
        }

        try {
            Id communityId = getCommunityId();
            Id surveyId = getSurveyId(developerName);

            List<SurveyInvitation> surveyInvitations = getSurveyInvitationsByCase(caseId);
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

            if (!shouldSkipInsert()) {
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

        try {
            Id communityId = getCommunityId();
            Id surveyId = getSurveyId(developerName);

            List<SurveyInvitation> surveyInvitations = getSurveyInvitationsByMessagingSession(sessionId);
            if (!surveyInvitations.isEmpty()) {
                return null;
            }

            SurveyInvitation si = new SurveyInvitation();
            si.CommunityId = communityId;
            si.SurveyId = surveyId;
            si.Name = INVITATION_NAME;
            si.MessagingSession__c = sessionId;
            si.OptionsAllowGuestUserResponse = true;
            si.OptionsCollectAnonymousResponse = true;

            if (!shouldSkipInsert()) {
                insert si;
            }
            return si.Id;
        } catch (Exception e) {
            throw new SurveyException(
                'An error has occurred while creating SurveyInvitation for MessagingSession. ' +
                    'sessionId=' +
                    sessionId +
                    ', developerName=' +
                    developerName +
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

        try {
            String responseStatus = getResponseStatus(caseId);
            return responseStatus == 'Completed';
        } catch (Exception e) {
            throw new SurveyException(
                'Problem getting ResponseStatus for Case. caseId=' + caseId + ', message=' + e.getMessage()
            );
        }
    }

    public static String getBaseURL() {
        if (Test.isRunningTest() && testBaseUrl != null) {
            return testBaseUrl;
        }

        try {
            Id siteId = [SELECT Id FROM Site WHERE Name = :SITE_NAME LIMIT 1].Id;
            return [SELECT SecureURL FROM SiteDetail WHERE DurableId = :siteId LIMIT 1].SecureUrl;
        } catch (Exception e) {
            throw new SurveyException('Problem getting Base URL. message=' + e.getMessage());
        }
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

    private static List<SurveyInvitation> getSurveyInvitationsByCase(Id caseId) {
        if (Test.isRunningTest() && testForceInvitationQueryException) {
            Integer forceError = 1 / 0;
        }

        return [
            SELECT Id
            FROM SurveyInvitation
            WHERE Case__c = :caseId
        ];
    }

    private static List<SurveyInvitation> getSurveyInvitationsByMessagingSession(Id sessionId) {
        if (Test.isRunningTest() && testForceInvitationQueryException) {
            Integer forceError = 1 / 0;
        }

        return [
            SELECT Id
            FROM SurveyInvitation
            WHERE MessagingSession__c = :sessionId
        ];
    }

    private static String getResponseStatus(Id caseId) {
        if (Test.isRunningTest() && testResponseStatus != null) {
            return testResponseStatus;
        }

        if (Test.isRunningTest() && testForceInvitationQueryException) {
            Integer forceError = 1 / 0;
        }

        List<SurveyInvitation> invitations = [
            SELECT ResponseStatus
            FROM SurveyInvitation
            WHERE Case__c = :caseId
            LIMIT 1
        ];

        if (invitations.isEmpty()) {
            return null;
        }

        return invitations[0].ResponseStatus;
    }

    private static Boolean shouldSkipInsert() {
        return Test.isRunningTest() && testSkipInsert;
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
