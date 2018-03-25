global class ScheduleClass  implements Schedulable {
    global List<sobject> sobjectInsert;
    global String className;
    global ScheduleClass(List<sobject> s,object obj)
    {
        sobjectInsert = s;
        className = String.valueOf(obj).substringBefore(':');
    }
    global void execute(SchedulableContext SC) {
        Type typeOfInvokingClass = Type.forName(className);
        BulkDML objectOfInvokingClass = (BulkDML)typeOfInvokingClass.newInstance();
        objectOfInvokingClass.execute(sobjectInsert);
    }
}