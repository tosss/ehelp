global abstract class BulkDML {
    global static void start(List<sobject> s, object obj){
        try{
            List<List<sobject>> sample;
            if(s!=null){
                sample = ListofList(s);
            }
            Datetime currentTime = DateTime.now();
            String sch = TimeToCronConverter(currentTime);
            for(integer i=0;i<sample.size();i++){
                ScheduleClass m = new ScheduleClass(sample.get(i),obj);
                String jobID = system.schedule('Merge Job'+String.valueof(Math.random()), sch, m);
            }
        }
        catch(Exception e)
        {
            System.debug(e.getMessage()+' At '+e.getLineNumber()+' '+e.getStackTraceString());
        }
    }
    static List<List<sobject>> ListofList(List<sobject> s){
        List<List<sobject>> slist = new List<List<sobject>>();
        integer count = s.size()/10000;
        for(integer i=0;i<=count;i++){
            List<sobject> a = new List<sobject>();
            for(integer j=0;(i!=count&&j<10000) ||( i==count && j<Math.mod(s.size(),10000));j++){
                a.add(s.get(i*10000+j));
            }
            slist.add(a);
        }
        return sList;
    }
    static String TimeToCronConverter(DateTime datetimeparam)
    {
        String seconds;
        String minutes;
        String hours;
        String ScheduleDate;
        String month;
        String year;
        dateTimeParam = dateTimeParam.addseconds(5);
        seconds = String.valueof(dateTimeParam.second());
        minutes = String.valueof(dateTimeParam.minute());
        hours = String.valueof(dateTimeParam.hour());
        String fulldate = String.Valueof(datetimeparam.date());
        ScheduleDate = fulldate.substringAfterLast('-').substringBeforeLast(' ');
        month = String.valueof(datetimeParam.month());
        year = String.valueOf(datetimeparam.year())+'-'+String.valueOf(datetimeparam.year());
        String cron = seconds+' '+minutes+' '+hours+' '+ScheduleDate+' '+month+' ? '+year;
        return cron;
    }
    global abstract void execute(List<sobject> s);
}