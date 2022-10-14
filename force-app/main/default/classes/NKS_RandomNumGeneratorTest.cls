@isTest
public with sharing class NKS_RandomNumGeneratorTest {
    @isTest
    static void testGenerateRandomNumber() {
        Test.startTest();
        List<Integer> randomNums = NKS_RandomNumberGenerator.generateRandomNumber();
        Test.stopTest();
        System.assertEquals(1, randomNums.size());
    }
}
