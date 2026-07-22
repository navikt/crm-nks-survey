@isTest
private class NKS_MessagingSurveyInvitationInvocTest {
    private static Id createMessagingSession() {
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        Id sessionId;

        System.runAs(thisUser) {
            MessagingChannel channel = new MessagingChannel(
                MasterLabel = 'MsgChannel' + String.valueOf(Datetime.now().getTime()),
                DeveloperName = 'MsgChannel' + String.valueOf(Datetime.now().getTime()),
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
    static void testGenerateSurveyInvitationThrowsWhenInputsNull() {
        Test.startTest();
        try {
            NKS_MessagingSurveyInvitationInvocable.generateSurveyInvitation(null);
            Assert.fail('Expected exception was not thrown');
        } catch (Exception e) {
            Assert.areEqual('At least one MessagingSession input row is required.', e.getMessage());
        }
        Test.stopTest();
    }

    @isTest
    static void testGenerateSurveyInvitationThrowsWhenInputsEmpty() {
        Test.startTest();
        try {
            NKS_MessagingSurveyInvitationInvocable.generateSurveyInvitation(
                new List<NKS_MessagingSurveyInvitationInvocable.Input>()
            );
            Assert.fail('Expected exception was not thrown');
        } catch (Exception e) {
            Assert.areEqual('At least one MessagingSession input row is required.', e.getMessage());
        }
        Test.stopTest();
    }

    @isTest
    static void testGenerateSurveyInvitationThrowsWhenInputRowNull() {
        List<NKS_MessagingSurveyInvitationInvocable.Input> inputs = new List<NKS_MessagingSurveyInvitationInvocable.Input>{
            null
        };

        Test.startTest();
        try {
            NKS_MessagingSurveyInvitationInvocable.generateSurveyInvitation(inputs);
            Assert.fail('Expected exception was not thrown');
        } catch (Exception e) {
            Assert.areEqual('MessagingSession input row cannot be null.', e.getMessage());
        }
        Test.stopTest();
    }

    @isTest
    static void testGenerateSurveyInvitationReturnsSingleResult() {
        Id sessionId = createMessagingSession();

        NKS_SurveyController.testCommunityId = '0DB000000000001';
        NKS_SurveyController.testSurveyId = '0K9000000000001';

        NKS_MessagingSurveyInvitationInvocable.Input inputRow = new NKS_MessagingSurveyInvitationInvocable.Input();
        inputRow.sessionId = (String) sessionId;
        inputRow.surveyDeveloperName = 'test_survey';

        Test.startTest();
        List<Id> results = NKS_MessagingSurveyInvitationInvocable.generateSurveyInvitation(
            new List<NKS_MessagingSurveyInvitationInvocable.Input>{ inputRow }
        );
        Test.stopTest();

        Assert.areEqual(1, results.size());
        Assert.isNull(results[0]);
    }

    @isTest
    static void testGenerateSurveyInvitationReturnsMultipleResults() {
        Id sessionId1 = createMessagingSession();
        Id sessionId2 = createMessagingSession();

        NKS_SurveyController.testCommunityId = '0DB000000000001';
        NKS_SurveyController.testSurveyId = '0K9000000000001';

        NKS_MessagingSurveyInvitationInvocable.Input inputRow1 = new NKS_MessagingSurveyInvitationInvocable.Input();
        inputRow1.sessionId = (String) sessionId1;
        inputRow1.surveyDeveloperName = 'test_survey';

        NKS_MessagingSurveyInvitationInvocable.Input inputRow2 = new NKS_MessagingSurveyInvitationInvocable.Input();
        inputRow2.sessionId = (String) sessionId2;
        inputRow2.surveyDeveloperName = 'test_survey';

        Test.startTest();
        List<Id> results = NKS_MessagingSurveyInvitationInvocable.generateSurveyInvitation(
            new List<NKS_MessagingSurveyInvitationInvocable.Input>{ inputRow1, inputRow2 }
        );
        Test.stopTest();

        Assert.areEqual(2, results.size());
        Assert.isNull(results[0]);
        Assert.isNull(results[1]);
    }
}
