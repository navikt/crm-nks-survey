@isTest
private class NKS_SurveyControllerTest {
    private static Id createMessagingSession() {
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        Id sessionId;

        System.runAs(thisUser) {
            MessagingChannel channel = new MessagingChannel(
                MasterLabel = 'TestChannel' + String.valueOf(Datetime.now().getTime()),
                DeveloperName = 'TestChannel' + String.valueOf(Datetime.now().getTime()),
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
        Case testCase = new Case(Subject = 'Test Subject', Status = 'New');
        insert testCase;

        NKS_SurveyController.testCommunityId = null;
        NKS_SurveyController.testSurveyId = null;
        NKS_SurveyController.testBaseUrl = null;

        Test.startTest();
        try {
            NKS_SurveyController.createSurveyInvitationForCase('missing_survey', testCase.Id);
            Assert.fail('Expected exception was not thrown');
        } catch (Exception e) {
            Assert.isTrue(e.getMessage().startsWith('Problem resolving community.'));
        }
        Test.stopTest();
    }

    @isTest
    static void testCreateSurveyInvitationForCaseResolveSurveyFailure() {
        Case testCase = new Case(Subject = 'Test Subject', Status = 'New');
        insert testCase;

        NKS_SurveyController.testCommunityId = '0DB000000000001';
        NKS_SurveyController.testSurveyId = null;

        Test.startTest();
        try {
            NKS_SurveyController.createSurveyInvitationForCase('missing_survey', testCase.Id);
            Assert.fail('Expected exception was not thrown');
        } catch (Exception e) {
            Assert.isTrue(e.getMessage().startsWith('Problem resolving survey.'));
        }
        Test.stopTest();
    }

    @isTest
    static void testCreateSurveyInvitationForCaseReturnsNullInTestModeWhenNoExistingInvitation() {
        Case testCase = new Case(Subject = 'Test Subject', Status = 'New');
        insert testCase;

        NKS_SurveyController.testCommunityId = '0DB000000000001';
        NKS_SurveyController.testSurveyId = '0K9000000000001';

        Test.startTest();
        Id result = NKS_SurveyController.createSurveyInvitationForCase('test_survey', testCase.Id);
        Test.stopTest();

        System.assertEquals(null, result);
    }

    @isTest
    static void testCreateSurveyInvitationForMessagingSessionThrowsWhenDeveloperNameBlank() {
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
        Id sessionId = createMessagingSession();

        NKS_SurveyController.testCommunityId = null;
        NKS_SurveyController.testSurveyId = null;

        Test.startTest();
        try {
            NKS_SurveyController.createSurveyInvitationForMessagingSession('missing_survey', sessionId);
            Assert.fail('Expected exception was not thrown');
        } catch (Exception e) {
            Assert.isTrue(e.getMessage().startsWith('Problem resolving community.'));
        }
        Test.stopTest();
    }

    @isTest
    static void testCreateSurveyInvitationForMessagingSessionResolveSurveyFailure() {
        Id sessionId = createMessagingSession();

        NKS_SurveyController.testCommunityId = '0DB000000000001';
        NKS_SurveyController.testSurveyId = null;

        Test.startTest();
        try {
            NKS_SurveyController.createSurveyInvitationForMessagingSession('missing_survey', sessionId);
            Assert.fail('Expected exception was not thrown');
        } catch (Exception e) {
            Assert.isTrue(e.getMessage().startsWith('Problem resolving survey.'));
        }
        Test.stopTest();
    }

    @isTest
    static void testCreateSurveyInvitationForMessagingSessionReturnsNullInTestMode() {
        Id sessionId = createMessagingSession();

        NKS_SurveyController.testCommunityId = '0DB000000000001';
        NKS_SurveyController.testSurveyId = '0K9000000000001';

        Test.startTest();
        Id result = NKS_SurveyController.createSurveyInvitationForMessagingSession('test_survey', sessionId);
        Test.stopTest();

        Assert.areEqual(null, result);
    }

    @isTest
    static void testCheckSurveyResponseReturnsFalseWhenNoInvitation() {
        Case testCase = new Case(Subject = 'Test Subject', Status = 'New');
        insert testCase;

        Test.startTest();
        Boolean result = NKS_SurveyController.checkSurveyResponse(testCase.Id);
        Test.stopTest();

        Assert.areEqual(false, result);
    }

    @isTest
    static void testCheckSurveyResponseThrowsWhenCaseIdNull() {
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
    static void testGetBaseURLReturnsOverrideValue() {
        NKS_SurveyController.testBaseUrl = 'https://example.test';

        Test.startTest();
        String result = NKS_SurveyController.getBaseURL();
        Test.stopTest();

        Assert.areEqual('https://example.test', result);
    }

    @isTest
    static void testGetBaseURLThrowsSurveyExceptionWhenMissingSite() {
        NKS_SurveyController.testBaseUrl = null;

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
