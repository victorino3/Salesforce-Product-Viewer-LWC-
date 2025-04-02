public class Company {
	list <CostumersInfo> people = new list <CostumersInfo>();
    public void addCostumers(String name,Integer age, Long desireSalary){
        CostumersInfo peoples = new CostumersInfo(name,age,desireSalary);
        people.add(peoples);
    }
    public void getCostumers(){
        for(CostumersInfo p : people ){
            System.debug('Peoples: '+p);
        }
    }
    private class CostumersInfo{
        String name;
        Integer age;
        Long desireSalary;
        CostumersInfo(String name,Integer age, Long desireSalary){
            this.name = name;
            this.age = age;
            this.desireSalary = desireSalary;
        }
    }
}