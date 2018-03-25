public class DSCB_CloneAnythingPermissions 
{
    public map<Id, Profile> ProfileMap;
    public list<Profile> Profiles {get;set;}
    
    public map<String, Clone_Records_Settings__c> CloneSettings {get;set;}
    public map<String, Clone_Profile_Access__c> ProfileAccessSettings {get;set;}
    
    public DSCB_CloneAnythingPermissions()
    {
        ProfileMap = new map<Id, Profile>([Select Id, Name From Profile Order By Name]); 
        CloneSettings = Clone_Records_Settings__c.getAll();
        ProfileAccessSettings = Clone_Profile_Access__c.getAll().clone();
        
        if(ProfileMap != null && !ProfileMap.isEmpty())
        {
            Profiles = ProfileMap.values(); Profiles.sort();
            
            for(Id ProfileId : ProfileMap.keySet())
            {
                Profile CurrentProfile = ProfileMap.get(ProfileId);
                
                if(!ProfileAccessSettings.keySet().contains(ProfileId))
                {
                    ProfileAccessSettings.put(ProfileId, new Clone_Profile_Access__c(
                        Name=ProfileId,
                        Profile_Id__c=ProfileId, 
                        Profile_Name__c=CurrentProfile.Name
                    ));
                }
            }
        }
    }
    
    public void SavePermissions()
    {
        upsert ProfileAccessSettings.values();
    }
}