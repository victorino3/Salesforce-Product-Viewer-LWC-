/**
 * Fitness class with helpful methods
 * to calculate human fitness
 * */
public class Fitness {


    public static Decimal calculateBMI(Decimal weight, Decimal height) {
        Decimal weightReal = weight < 0 ? 1 : weight;
        Decimal heightReal = height < 0 ? 1 : height;
        Decimal result  = weightReal / (weightReal*heightReal);
        return result.round(System.RoundingMode.CEILING);
    }


    public static Decimal calculatePace(Decimal distance, Decimal minutes) {
        Decimal distanceReal = distance < 0 ? 1 : distance;
        Decimal minutesReal = minutes < 0 ? 1 : minutes;
        Decimal hr = minutesReal/60;
        Decimal pace = distanceReal / hr;
        return pace.round(System.RoundingMode.CEILING);
    }
    
}