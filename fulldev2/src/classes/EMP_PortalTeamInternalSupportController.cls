public class EMP_PortalTeamInternalSupportController 
{
    public Portal_Page__c PortalTeamPage {get; set;}
    public string DisplayPhoto{get;set;}
    public string DisplayName{get;set;}
    public string DisplayTitle{get;set;}
    public string DisplayCompany{get;set;}
    public boolean DisplayImage{get;set;}
    
    public EMP_PortalTeamInternalSupportController()
    { 
        list<Portal_Page__c> lstPortalTeamPage = [
            Select ID, Main_Content__c, Title__c, Image_Title__c, Join_WebEx_meeting__c, join_by_phone__c, Webex_url__c, Image__c, View_Image__c, Chatter_Group__c
            From Portal_Page__c
            Where Name =: 'Internal Support Community'
        ];
        
        if(lstPortalTeamPage != null && !lstPortalTeamPage.isEmpty()) 
        {
            PortalTeamPage = lstPortalTeamPage.get(0);
            system.debug('********* image__c '+PortalTeamPage.Image__c);
        }
        
        if(PortalTeamPage != null)
        {
            CollaborationGroup obj = [
                Select Id, Name, OwnerId, FullPhotoUrl 
                From CollaborationGroup 
                Where id =: PortalTeamPage.Chatter_Group__c
            ];
                                 system.debug('************* obj.FullPhotoUrl'+obj.FullPhotoUrl);
            
            
            User u = [
                Select id, Name, Title, CompanyName, u.SmallPhotoUrl, u.FullPhotoUrl 
                From User u 
                Where u.id=:obj.OwnerId
            ];
            DisplayImage = PortalTeamPage.View_Image__c;
            system.debug('*********'+displayImage + '       ' + PortalTeamPage.Image__c);
            if(PortalTeamPage.Image__c == true)
            {
                DisplayPhoto = u.FullPhotoUrl;
                DisplayName  = u.Name;
                DisplayTitle = u.Title;
                DisplayCompany = u.CompanyName; 
                system.debug('************* displayphot11111'+DisplayPhoto);
                
            }
            else{DisplayPhoto = obj.FullPhotoUrl;
                 system.debug('************* displayphot0'+DisplayPhoto);
            }
            
        }
    }
}