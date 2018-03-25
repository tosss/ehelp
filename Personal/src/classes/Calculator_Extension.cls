public class Calculator_Extension {

    private final Calculator__c cal;

    public Calculator_Extension(ApexPages.StandardController controller) {
        this.cal = (Calculator__c)controller.getrecord();
    }
    public void Add(){
        cal.Result__c = cal.First_Number__c+cal.Second_Number__c;
        upsert cal;
    }
    public void Sub(){
        cal.Result__c = cal.First_Number__c-cal.Second_Number__c;
        upsert cal;
    }
    public void Mul(){
        cal.Result__c = cal.First_Number__c*cal.Second_Number__c;
        upsert cal;
    }
    public void Div(){
        cal.Result__c = cal.First_Number__c/cal.Second_Number__c;
        upsert cal;
    }
}