@isTest
private class NKS_SurveyControllerTest {
    private static final Id TEST_COMMUNITY_ID = '0DB000000000001AAA';
    private static final Id TEST_SURVEY_ID = '0K9000000000001AAA';

    private static void resetTestState() {
        NKS_SurveyController.testCommunityId = null;
        NKS_SurveyController.testSurveyId = null;
        NKS_SurveyController.testBaseUrl = null;
        NKS_SurveyController.testSkipInsert = false;
        NKS_SurveyController.testResponseStatus = null;
        NKS_SurveyController.testForceInvitationQueryException = false;
    }

    private static Id createMessagingSession() {
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        Id sessionId;

        System.runAs(thisUser) {
            String uniqueValue = String.valueOf(Datetime.now().getTime());

            MessagingChannel channel = new MessagingChannel(
                MasterLabel = 'TestChannel' + uniqueValue,
                DeveloperName = 'TestChannel' + uniqueValue,
                IsActive = true,
                MessageType = 'Text',
                MessagingPlatformKey = 'PlatformKey' + String.valueOf(Math.abs(Crypto.getRandomInteger()))
            );
            insert channel;

            MessagingEndUser endUser = new MessagingEndUser(
                Name = 'Guest',
                MessageType = 'EmbeddedMessaging',
                MessagingPlatformKey = 'EndUserKey' + String.valueOf(Math.abs(Crypto.getRandomInteger())),
                MessagingChannelId = channel.Id
            );
            insert endUser;

            MessagingSession sessionRecord = new MessagingSession(
                MessagingChannelId = channel.Id,
                MessagingEndUserId = endUser.Id,
                Status = 'New',
                SessionKey = 'sessionKey' + String.valueOf(Math.abs(Crypto.getRandomInteger()))
            );
            insert sessionRecord;
            sessionId = sessionRecord.Id;
        }

        return sessionId;
    }

    @isTest
    static void testCreateSurveyInvitationForCaseThrowsWhenDeveloperNameBlank() {
        resetTestState();

        Case testCase = new Case(Subject = 'Test Subject', Status = 'New');
        insert testCase;

        Test.startTest();
        try {
            NKS_SurveyController.createSurveyInvitationForCase('', testCase.Id);
            Assert.fail('Expected exception was not thrown');
        } catch (Exception e) {
            Assert.areEqual('developerName is required.', e.getMessage());
        }
        Test.stopTest();
    }

    @isTest
    static void testCreateSurveyInvitationForCaseThrowsWhenCaseIdNull() {
        resetTestState();

        Test.startTest();
        try {
            NKS_SurveyController.createSurveyInvitationForCase('test_survey', null);
            Assert.fail('Expected exception was not thrown');
        } catch (Exception e) {
            Assert.areEqual('caseId is required.', e.getMessage());
        }
        Test.stopTest();
    }

    @isTest
    static void testCreateSurveyInvitationForCaseResolveCommunityFailure() {
        resetTestState();

        Case testCase = new Case(Subject = 'Test Subject', Status = 'New');
        insert testCase;

        Test.startTest();
        try {
            NKS_SurveyController.createSurveyInvitationForCase('missing_survey', testCase.Id);
            Assert.fail('Expected exception was not thrown');
        } catch (Exception e) {
            Assert.isTrue(e.getMessage().contains('An error has occurred while creating SurveyInvitation for Case.'));
            Assert.isTrue(e.getMessage().contains('Problem resolving community.'));
        }
        Test.stopTest();
    }

    @isTest
    static void testCreateSurveyInvitationForCaseResolveSurveyFailure() {
        resetTestState();

        Case testCase = new Case(Subject = 'Test Subject', Status = 'New');
        insert testCase;

        NKS_SurveyController.testCommunityId = TEST_COMMUNITY_ID;

        Test.startTest();
        try {
            NKS_SurveyController.createSurveyInvitationForCase('missing_survey', testCase.Id);
            Assert.fail('Expected exception was not thrown');
        } catch (Exception e) {
            Assert.isTrue(e.getMessage().contains('An error has occurred while creating SurveyInvitation for Case.'));
            Assert.isTrue(e.getMessage().contains('Problem resolving survey.'));
        }
        Test.stopTest();
    }

    @isTest
    static void testCreateSurveyInvitationForCaseReturnsNullInTestModeWhenNoExistingInvitation() {
        resetTestState();

        Case testCase = new Case(Subject = 'Test Subject', Status = 'New');
        insert testCase;

        NKS_SurveyController.testCommunityId = TEST_COMMUNITY_ID;
        NKS_SurveyController.testSurveyId = TEST_SURVEY_ID;
        NKS_SurveyController.testSkipInsert = true;

        Test.startTest();
        Id result = NKS_SurveyController.createSurveyInvitationForCase('test_survey', testCase.Id);
        Test.stopTest();

        Assert.areEqual(null, result);
    }

    @isTest
    static void testCreateSurveyInvitationForCaseCatchIsCoveredWhenInvitationQueryFails() {
        resetTestState();

        Case testCase = new Case(Subject = 'Test Subject', Status = 'New');
        insert testCase;

        NKS_SurveyController.testCommunityId = TEST_COMMUNITY_ID;
        NKS_SurveyController.testSurveyId = TEST_SURVEY_ID;
        NKS_SurveyController.testForceInvitationQueryException = true;

        Test.startTest();
        try {
            NKS_SurveyController.createSurveyInvitationForCase('test_survey', testCase.Id);
            Assert.fail('Expected exception was not thrown');
        } catch (Exception e) {
            Assert.isTrue(e.getMessage().contains('An error has occurred while creating SurveyInvitation for Case.'));
        }
        Test.stopTest();
    }

    @isTest
    static void testCreateSurveyInvitationForMessagingSessionThrowsWhenDeveloperNameBlank() {
        resetTestState();

        Id sessionId = createMessagingSession();

        Test.startTest();
        try {
            NKS_SurveyController.createSurveyInvitationForMessagingSession('', sessionId);
            Assert.fail('Expected exception was not thrown');
        } catch (Exception e) {
            Assert.areEqual('developerName is required.', e.getMessage());
        }
        Test.stopTest();
    }

    @isTest
    static void testCreateSurveyInvitationForMessagingSessionThrowsWhenSessionIdNull() {
        resetTestState();

        Test.startTest();
        try {
            NKS_SurveyController.createSurveyInvitationForMessagingSession('test_survey', null);
            Assert.fail('Expected exception was not thrown');
        } catch (Exception e) {
            Assert.areEqual('sessionId is required.', e.getMessage());
        }
        Test.stopTest();
    }

    @isTest
    static void testCreateSurveyInvitationForMessagingSessionResolveCommunityFailure() {
        resetTestState();

        Id sessionId = createMessagingSession();

        Test.startTest();
        try {
            NKS_SurveyController.createSurveyInvitationForMessagingSession('missing_survey', sessionId);
            Assert.fail('Expected exception was not thrown');
        } catch (Exception e) {
            Assert.isTrue(
                e.getMessage().contains('An error has occurred while creating SurveyInvitation for MessagingSession.')
            );
            Assert.isTrue(e.getMessage().contains('Problem resolving community.'));
        }
        Test.stopTest();
    }

    @isTest
    static void testCreateSurveyInvitationForMessagingSessionResolveSurveyFailure() {
        resetTestState();

        Id sessionId = createMessagingSession();

        NKS_SurveyController.testCommunityId = TEST_COMMUNITY_ID;

        Test.startTest();
        try {
            NKS_SurveyController.createSurveyInvitationForMessagingSession('missing_survey', sessionId);
            Assert.fail('Expected exception was not thrown');
        } catch (Exception e) {
            Assert.isTrue(
                e.getMessage().contains('An error has occurred while creating SurveyInvitation for MessagingSession.')
            );
            Assert.isTrue(e.getMessage().contains('Problem resolving survey.'));
        }
        Test.stopTest();
    }

    @isTest
    static void testCreateSurveyInvitationForMessagingSessionReturnsNullInTestMode() {
        resetTestState();

        Id sessionId = createMessagingSession();

        NKS_SurveyController.testCommunityId = TEST_COMMUNITY_ID;
        NKS_SurveyController.testSurveyId = TEST_SURVEY_ID;
        NKS_SurveyController.testSkipInsert = true;

        Test.startTest();
        Id result = NKS_SurveyController.createSurveyInvitationForMessagingSession('test_survey', sessionId);
        Test.stopTest();

        Assert.areEqual(null, result);
    }

    @isTest
    static void testCreateSurveyInvitationForMessagingSessionCatchIsCoveredWhenInvitationQueryFails() {
        resetTestState();

        Id sessionId = createMessagingSession();

        NKS_SurveyController.testCommunityId = TEST_COMMUNITY_ID;
        NKS_SurveyController.testSurveyId = TEST_SURVEY_ID;
        NKS_SurveyController.testForceInvitationQueryException = true;

        Test.startTest();
        try {
            NKS_SurveyController.createSurveyInvitationForMessagingSession('test_survey', sessionId);
            Assert.fail('Expected exception was not thrown');
        } catch (Exception e) {
            Assert.isTrue(
                e.getMessage().contains('An error has occurred while creating SurveyInvitation for MessagingSession.')
            );
        }
        Test.stopTest();
    }

    @isTest
    static void testCheckSurveyResponseReturnsFalseWhenNoInvitation() {
        resetTestState();

        Case testCase = new Case(Subject = 'Test Subject', Status = 'New');
        insert testCase;

        Test.startTest();
        Boolean result = NKS_SurveyController.checkSurveyResponse(testCase.Id);
        Test.stopTest();

        Assert.areEqual(false, result);
    }

    @isTest
    static void testCheckSurveyResponseReturnsFalseWhenResponseIsStarted() {
        resetTestState();

        Case testCase = new Case(Subject = 'Test Subject', Status = 'New');
        insert testCase;

        NKS_SurveyController.testResponseStatus = 'Started';

        Test.startTest();
        Boolean result = NKS_SurveyController.checkSurveyResponse(testCase.Id);
        Test.stopTest();

        Assert.areEqual(false, result);
    }

    @isTest
    static void testCheckSurveyResponseReturnsTrueWhenResponseIsCompleted() {
        resetTestState();

        Case testCase = new Case(Subject = 'Test Subject', Status = 'New');
        insert testCase;

        NKS_SurveyController.testResponseStatus = 'Completed';

        Test.startTest();
        Boolean result = NKS_SurveyController.checkSurveyResponse(testCase.Id);
        Test.stopTest();

        Assert.areEqual(true, result);
    }

    @isTest
    static void testCheckSurveyResponseThrowsWhenCaseIdNull() {
        resetTestState();

        Test.startTest();
        try {
            NKS_SurveyController.checkSurveyResponse(null);
            Assert.fail('Expected exception was not thrown');
        } catch (Exception e) {
            Assert.areEqual('caseId is required.', e.getMessage());
        }
        Test.stopTest();
    }

    @isTest
    static void testCheckSurveyResponseCatchIsCoveredWhenQueryFails() {
        resetTestState();

        Case testCase = new Case(Subject = 'Test Subject', Status = 'New');
        insert testCase;

        NKS_SurveyController.testForceInvitationQueryException = true;

        Test.startTest();
        try {
            NKS_SurveyController.checkSurveyResponse(testCase.Id);
            Assert.fail('Expected exception was not thrown');
        } catch (Exception e) {
            Assert.isTrue(e.getMessage().startsWith('Problem getting ResponseStatus for Case.'));
        }
        Test.stopTest();
    }

    @isTest
    static void testGetBaseURLReturnsOverrideValue() {
        resetTestState();

        NKS_SurveyController.testBaseUrl = 'https://example.test';

        Test.startTest();
        String result = NKS_SurveyController.getBaseURL();
        Test.stopTest();

        Assert.areEqual('https://example.test', result);
    }

    @isTest
    static void testGetBaseURLThrowsSurveyExceptionWhenMissingSite() {
        resetTestState();

        Test.startTest();
        try {
            NKS_SurveyController.getBaseURL();
            Assert.fail('Expected exception was not thrown');
        } catch (Exception e) {
            Assert.areEqual('NKS_SurveyController.SurveyException', e.getTypeName());
            Assert.isTrue(e.getMessage().startsWith('Problem getting Base URL.'));
        }
        Test.stopTest();
    }
}
