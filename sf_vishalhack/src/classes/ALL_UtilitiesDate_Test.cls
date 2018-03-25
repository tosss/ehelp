@isTest
public class ALL_UtilitiesDate_Test 
{
    public static testmethod void BusinessDaysCounter()
    {
        Holiday h = new Holiday();
        h.IsAllDay = true;
        h.Description = 'CDK Holiday';
        h.ActivityDate = Date.newInstance(2014, 12, 25);
        h.Name = 'Christmas Day';
        
        insert h;
        
        Integer daysToAdd1 = ALL_UtilitiesDate.BusinessDaysCounter(Date.newInstance(2014, 12, 24), 4, 'CDK Holiday');
        System.assertEquals(7, daysToAdd1);
        
        Integer daysToAdd2 = ALL_UtilitiesDate.BusinessDaysCounter(Date.newInstance(2014, 12, 24), -4, 'CDK Holiday');
        System.assertEquals(-6, daysToAdd2);
    }
    
    public static testMethod void CalculateWeekDay()
    {
        Date actualDate = ALL_UtilitiesDate.CalculateWeekDay(Date.newInstance(2015, 8, 14), -2, 'Friday');
        system.assertEquals(Date.newInstance(2015, 7, 31), actualDate);
    }
}