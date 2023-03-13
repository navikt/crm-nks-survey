@isTest
public with sharing class NKS_SurveyControllerTest {
    @TestSetup
    static void makeData() {
        Account testAccount = new Account(FirstName = 'Test', LastName = 'Test');
        insert testAccount;
        Id accountId = [SELECT Id FROM Account WHERE LastName = 'Test' LIMIT 1]?.Id;
        Case c = new Case(AccountId = accountId, Status = 'New', Origin = 'Web');
        insert c;
    }

    @isTest
    static void testCreateSurveyInvitaionReserved() {
        Id caseId = [SELECT Id FROM Case LIMIT 1]?.Id;
        String url;

        Test.startTest();
        try {
            url = NKS_SurveyController.createSurveyInvitation(caseId, true);
        } catch (Exception ex) {
            System.assertEquals('SurveyException', ex.getTypeName());
        }
        Test.stopTest();

        System.assertEquals('This user is reserved in KRR.', url);
    }

    @isTest
    static void testCreateSurveyInvitaion() {
        Id caseId = [SELECT Id FROM Case LIMIT 1]?.Id;
        String url;

        Test.startTest();
        try {
            url = NKS_SurveyController.createSurveyInvitation(caseId, false);
        } catch (Exception ex) {
            System.assertEquals(ex.getMessage(), url);
        }
        Test.stopTest();
    }

    @isTest
    static void testCreateSurveyInvitaionForRandomUser() {
        Id caseId = [SELECT Id FROM Case LIMIT 1]?.Id;
        String url;

        Test.startTest();
        try {
            url = NKS_SurveyController.createSurveyInvitation(caseId, false);
        } catch (Exception ex) {
            System.assertEquals(ex.getMessage(), url);
        }
        Test.stopTest();
    }

    /*
    @isTest
    static void testGetCommunityUrl() {
        Test.startTest();
        String url = NKS_SurveyController.getBaseURL();
        Test.stopTest();

        System.assertNotEquals(null, url);
    } */

    @isTest
    static void testGenerateRandNum() {
        Test.startTest();
        Integer testNum = NKS_SurveyController.generateRandNum();
        Test.stopTest();

        System.assertNotEquals(null, testNum);
    }
}
