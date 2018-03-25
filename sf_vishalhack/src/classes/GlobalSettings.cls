//2015-11-26- anirudh.singh@cdk.com- Modified the API Version from 18.0 to 34.0.
public class GlobalSettings 
{
    private static GlobalSettings instance;
    
    private final GlobalSettings__c gs;
    public String BIZ_HOURS_ID { get {return (gs==null||gs.DefaultBusinessHoursId__c==null)?'':gs.DefaultBusinessHoursId__c;}}
    public String CASE_TEAM_ROLE_ID { get {return (gs==null||gs.DefaultCaseTeamMemberId__c==null)?'':gs.DefaultCaseTeamMemberId__c;}}
    public String[] ERROR_EMAIL { get {return (gs==null||gs.ErrorEmail__c==null)?new String[]{/*'psaini@cobaltgroup.com','sbysani@osius.com',*/'matt_keefe@adp.com'}:gs.ErrorEmail__c.split(',');}}
    public String MMREPORT_URL { get {return (gs==null||gs.MMReportURL__c==null)?'https://cs1.salesforce.com/00OS0000000dNql':gs.MMReportURL__c;}}
    public String CONVERSION_USERID { get {return (gs==null||gs.Conversion_User_ID__c==null)?'':gs.Conversion_User_ID__c;}}
    public String AEs_To_Delete_RM { get {return (gs==null||gs.AEs_To_Delete_RM__c==null)?'':gs.AEs_To_Delete_RM__c;}}
    
    //MonthlyMaintenance Record Types
    public final String AA_Monthly_MAINTENANCE = 'AA - Monthly Maintenance';
    public final String AA_SEO_Monthly_Maintenance ='SEO - Monthly Maintenance';
    public final String AA_OMS_Monthly_Maintenance='OMS Monthly Maintenance';
    public final String AA_DAS_Monthly_Maintenance='DAS - Monthly Maintenance';
    public final String AA_EMS_Monthly_Maintenance='EMS - Campaign Tracking';
    public final String SITE_CHECK_STATUS='Not Started';
    public final String STATUS='Not Started';
    public final String RECOMMENDATION_STATUS='Proposed';
    public final String PROCARE_HEALTH='Unknown';
    
    public final String DATETIME_FORMAT='MM/dd/yyyy K:mm:ss:SS a, z';
    
    public static boolean BypassCaseTriggersTrigger = false;
    public static boolean BypassMMRechargeCloneRecordTrigger = false;
    
    private GlobalSettings()
    {
        gs = GlobalSettings__c.getInstance();
    }
    
    public static GlobalSettings getInstance(String name) 
    {
        if (instance == null)
        {
            instance = new GlobalSettings();
        }
        
        return instance;
    }
    
    public static String convertListToString(List<String> lData)
    {
        String r='(';
        Integer ss=lData.size();
        Integer counter=0;
        
        for(String ls: lData)
        {
            counter++;
            if(counter==ss)
            {
                r+='\'' + ls + '\')';
            }
            else
            {
                r+='\'' + ls + '\',';
            }    
        }
        
        return r;
    }
}