public class ImplementSchedule {
    public static void imp(){
        try{
        ScheduleClass m = new ScheduleClass(new List<sobject>(), new ImplementSchedule());
        Datetime currentTime = DateTime.now();
        for(integer i=0;i<5;i++){
        String sch = TimeToCronConverter(currentTime);
        String jobID = system.schedule('Merge Job'+i, sch, m);
        }
        }
        catch(Exception e)
        {
            System.debug(e.getMessage()+' At '+e.getLineNumber()+' '+e.getStackTraceString());
        }
    }
    static String TimeToCronConverter(DateTime datetimeparam)
    {
        String hour = String.Valueof(datetimeparam.hour());
        String month = String.Valueof(datetimeparam.month());
        String seconds ;        
        String minutes;
        if(datetimeparam.second()+5>=60){
            seconds = String.Valueof(datetimeparam.second()-55);
             minutes = String.Valueof(datetimeparam.minute()+1);
        }
        else{
            seconds = String.Valueof(datetimeparam.second()+5);
             minutes = String.Valueof(datetimeparam.minute());
        }
        String fulldate = String.Valueof(datetimeparam.date());
        String dat = fulldate.substringAfterLast('-').substringBeforeLast(' ');
        String cron = seconds+' '+minutes+' '+hour+' '+dat+' '+month+' ? *';
        return cron;
    }
   
}