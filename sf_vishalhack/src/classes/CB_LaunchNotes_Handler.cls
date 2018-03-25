public class CB_LaunchNotes_Handler 
{
    @AuraEnabled
    public static List<Launch_Notes__c> getAllLaunchNotes(String launchId)
    {
        List<Launch_Notes__c> launchNotes = new List<Launch_Notes__c>();
        //List<Launch_Notes__c> launches = new List<Launch_Notes__c>();
        
        launchNotes = [
            Select ID, Name, Notes_Type__c, Notes__c, Launch_Id__c, 
            Date__c, CreatedById, CreatedBy.Name, CreatedDate 
            From Launch_Notes__c 
            Where Launch_Id__c = :launchId
            ORDER BY Date__c DESC NULLS LAST
            
        ];
        
        //SortUtility sortInstance = new SortUtility(launchNotes, 'Date__c');
        
        //launches = sortInstance.CustomSort(); system.debug(launches);
        return launchNotes;
    }
    
    @AuraEnabled
    public static List<Launch_Notes__c> saveLaunchNotes(Launch_Notes__c newLaunchNotes)
    {
        //system.assertEquals(newLaunchNotes.Date__c, null);
        DateTime currentDateTime = DateTime.now();
        Time currentTime = Time.newInstance(currentDateTime.hour(), currentDateTime.minute(), currentDateTime.second(), 00);
        newLaunchNotes.Date__c = DateTime.newInstance(newLaunchNotes.Date__c.Date() + 1, currentTime);
        
        
        Insert newLaunchNotes;
        
        List<Launch_Notes__c> launches = [
            Select ID, Name, Notes_Type__c, Notes__c, Launch_Id__c, 
            Date__c, CreatedById, CreatedBy.Name, CreatedDate 
            From Launch_Notes__c 
            Where Launch_Id__c = :newLaunchNotes.Launch_Id__c
            ORDER BY Date__c DESC NULLS LAST
                    
        ];
        
        return launches;
    }
    
    //@AuraEnabled
    //public static String getUserName()
    //{
        //return userInfo.getName();
    //}

}