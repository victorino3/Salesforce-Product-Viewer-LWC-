@istest
public class FitnessTest {

    @istest
    public static void calculateBMI_Positive_Test() {
        Decimal result  = Fitness.calculateBMI(45.5,23.1);
        System.assertEquals(1, result);
        Decimal resultPace  = Fitness.calculatePace(45.5,23.1);
        System.assertEquals(119, resultPace);
    }
    
    @istest
    public static void calculateBMI_Negative_Test() {
        Decimal result  = Fitness.calculateBMI(-45.5,-23.1);
        System.assert(0 != result,'Invalid inputs');
        Decimal resultPace  = Fitness.calculatePace(-45.5,-23.1);
        System.assert(0 != resultPace,'Invalid inputs');
    }
}