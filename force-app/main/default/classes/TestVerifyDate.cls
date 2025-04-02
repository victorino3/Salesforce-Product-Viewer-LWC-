@isTest
public class TestVerifyDate {

    @isTest
    public  static void SetEndOfMonthDatePositiveTest(){
       	Date day = Date.today();
		String[] dataArray = String.valueOf(day).split('-');
        Integer currentYear = Integer.valueOf(dataArray.get(0));
        Integer currentMonth = Integer.valueOf(dataArray.get(1));
        Integer totalDate = Date.daysInMonth(currentYear, currentMonth);
        Date date1 = Date.newInstance(currentYear, currentMonth, totalDate);
        Date dateEnd = VerifyDate.SetEndOfMonthDate(date1);
        System.assert(String.valueOf(date1) == String.valueOf(dateEnd),'No Equal Dates');
    
    }
        @isTest
        public  static void DateWithin30DaysPositiveTest(){
            Date day = Date.today();
            String[] dataArray = String.valueOf(day).split('-');
            Integer currentYear = Integer.valueOf(dataArray.get(0));
        	Integer currentMonth = Integer.valueOf(dataArray.get(1));
            Integer currentDay = Integer.valueOf(dataArray.get(2));
            Date currentDayParameter = Date.newInstance(currentYear, currentMonth, currentDay);
            Integer totalDate = Date.daysInMonth(currentYear, currentMonth);
            Date date1 = Date.newInstance(currentYear, currentMonth, totalDate);
            System.assert(true == VerifyDate.DateWithin30Days(currentDayParameter,date1));   
            Date verify = VerifyDate.CheckDates(date1,currentDayParameter);
            System.assert(currentDayParameter != verify);
            Date verifyEnd = VerifyDate.CheckDates(currentDayParameter,date1);
            System.assert(date1 == verifyEnd);
        }

}