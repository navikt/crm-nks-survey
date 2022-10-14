public with sharing class NKS_RandomNumberGenerator {
    @invocableMethod(label='Generate Random Number')
    public static List<Integer> generateRandomNumber() {
        List<Integer> randomNums = new List<Integer>();
        Integer probability = (Math.random() * 100).intValue();
        randomNums.add(probability);
        return randomNums;
    }
}