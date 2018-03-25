/****************************************************************************************************************
*  2016-08-31 ragashalini.koka@cdk.com - RQ-07678 Created this class 
*  Description : This class is used to terminate the User when the terminate link is clicked on User details page
*  Test Class : ALL_TerminateUser_Test
*  History
*  2016-10-25 ragashalini.koka@cdk.com - Added '_' to ADID__c field
*  2017-02-15 ragashalini.koka@cdk.com - unchecked the Allow Contract Creation for RQ-08669
* ****************************************************************************************************************/
//2017-03-23- anirudh.singh@cdk.com- Formatted, Optimized and added invokeTerminateUserWebService method in this class for RQ-08829 Termination Process.
public class ALL_TerminateUser_Controller
{
    public Boolean hasPermissions{get; set;}
    public String statusMessage{get; set;}
    public static Boolean isLockError{get; set;}
    public static String reason{get; set;}
    
    private String userId{get; set;}
    private GlobalSettings__c globalValue;
    private String userEmailId{get; set;}
    
    public ALL_TerminateUser_Controller(ApexPages.StandardController userController)
    {
        hasPermissions=false;
        isLockError=false;
        userId=userController.getId();
        String currentUserId=UserInfo.getUserId();
        globalValue=GlobalSettings__c.getOrgDefaults();
        String adminProfiles=globalValue.Admin_Profiles__c;
        Set<String> adminProfileSet=adminProfiles!=Null ? new Set<String>(adminProfiles.split(',')) : Null;
        
        User userRecord=[SELECT Id, IsActive, LastName, Non_Interactive_User__c, Profile.Name, Title, Email FROM User WHERE Id=:userId];
        userEmailId=userRecord.Email;
        
        if(!userRecord.isActive || userRecord.LastName.containsIgnoreCase('retired'))
        {
            statusMessage='This user has been terminated.';
        }
        else if(userRecord.Non_Interactive_User__c 
                || (adminProfileSet!=Null && adminProfileSet.contains(userRecord.Profile.Name)))
        {
            statusMessage='This user cannot be terminated.';
        }
        else if(currentUserId.substring(0,15)!=userId.substring(0,15))
        {
            hasPermissions=true;
        }
        else
        {
            statusMessage='You cannot terminate your own record.';
        }
    }
    
    public PageReference terminateUserVF()
    {
        try
        {
            Boolean messageStatus=terminateUser(userId, globalValue);
            
            if(messageStatus)
            {
                statusMessage='<b>ARNA :</b> User Terminated Successfully.';
                hasPermissions=false;
            }
            else
            {
                statusMessage='<b>ARNA :</b> User cannot be terminated.';
            }
        }
        catch(Exception ex)
        {
            system.debug('Exception : ' +ex.getMessage()+' at '+ex.getLineNumber());
            statusMessage='Sorry, you do not have enough privileges to terminate the user.';
        }
        
        return Null;
    }
    
    private static Boolean terminateUser(Id userId, GlobalSettings__c globalValue)
    {
        Boolean userTerminated=false;
        isLockError=false;
        
        List<User> userList=new List<User>([
            SELECT Id, Name, FirstName, LastName, Manager.Name, Username, 
            Email, FederationIdentifier, Forecasting_Channel__c, Title, ADID__c 
            FROM User 
            WHERE Id=:userId
            LIMIT 1
        ]);
        
        if(userList.size()>0)
        {
            User userRec=userList[0];
            
            Set<String> titleSet;
            if(globalValue.User_Titles__c!=Null)
            {
                titleSet=new Set<String>(globalValue.User_Titles__c.split(','));
            }
            
            userRec.Username='_'+userRec.Username;
            userRec.Email='_'+userRec.Email;
            userRec.FederationIdentifier='_'+userRec.FederationIdentifier;
            userRec.Termination_Date__c=system.today();
            userRec.Short_Notes__c='Termination Notice : '+userRec.Name+ '\nTerm Date : '+system.now();
            if(userRec.Manager.Name!=Null && userRec.Manager.Name!='')
            {
                userRec.Short_Notes__c+='\nManager : '+userRec.Manager.Name;
            }
            
            //2017-02-15  ragashalini.koka@cdk.com - Added for RQ-08669
            userRec.BigMachines__Allow_Quote_Creation__c=false;
            if(userRec.ADID__c!=Null)
            {
                userRec.ADID__c='_'+userRec.ADID__c.left(14);
            }
            
            if(userRec.Forecasting_Channel__c!=Null || (titleSet!=Null && titleSet.contains(userRec.Title)))
            {
                userRec.LastName+=' - retired';
                system.resetPassword(userRec.Id, false);
            }
            else
            {
                userRec.IsActive=false;
            }
            
            Database.DMLOptions dmlOptions=new Database.DMLOptions();
            dmlOptions.EmailHeader.triggerUserEmail=false; 
            dmlOptions.OptAllOrNone=false;
            
            Database.SaveResult userUpdateRes=Database.update(userRec, dmlOptions);
            
            if(userUpdateRes.isSuccess())
            {
                removeUserLicenses(userUpdateRes.getId());
                userTerminated=true;
            }
            else
            {
                for(Database.Error err: userUpdateRes.getErrors())
                {
                    reason='<b>Reason : </b>'+err.getMessage();
                    if(err.getMessage().containsIgnoreCase('unable to obtain exclusive access'))
                    {
                        isLockError=true;
                        break;
                    }
                }
            }
        }
        
        return userTerminated;
    }
    
    private static void removeUserLicenses(Id userId)
    {
        List<UserPackageLicense> packageLicenseList=new List<UserPackageLicense>([SELECT Id FROM UserPackageLicense WHERE UserId=:userId]);
        
        if(packageLicenseList.size()>0)
        {
            delete packageLicenseList;
        }
    }
    
    //2017-03-23- anirudh.singh@cdk.com- Created this method for RQ-08829 Termination Process.
    public void invokeTerminateUserWebService()
    {
        try
        {
            //String username='anirudh.singh2@cdk.com.playground';
            //String password='test@r999Eb3ix1U6NIBXxUyhBP91qgq8Q';
            ALL_Terminate_User_Endpoints__c dmiEndpointRec=ALL_Terminate_User_Endpoints__c.getValues('DMI Endpoint');
            
            String username=dmiEndpointRec.Username__c;
            String password=dmiEndpointRec.Password__c;
            
            DMI_PartnerSoapSforceCom_Service.Soap sp=new DMI_PartnerSoapSforceCom_Service.Soap();
            DMI_PartnerSoapSforceCom_Service.LoginResult loginResult=sp.login(username, password);
            
            DMI_TerminateUser_Service.SessionHeader_element sessionHeader=new DMI_TerminateUser_Service.SessionHeader_element();
            sessionHeader.sessionId=loginResult.sessionId;
            system.debug('loginResult---->'+loginResult);
            
            DMI_TerminateUser_Service.ALL_TerminateUser_Controller termUserService=new DMI_TerminateUser_Service.ALL_TerminateUser_Controller();
            termUserService.endpoint_x=dmiEndpointRec.Service_Endpoint_URL__c;
            termUserService.timeout_x=20000;
            termUserService.SessionHeader=sessionHeader;
            
            //Response variable.
            String response=termUserService.terminateUser(userEmailId);
            system.debug('response---->'+response);
            statusMessage+='<br/>'+response;
            system.debug('statusMessage---->'+statusMessage);
        }
        catch(Exception ex)
        {
            system.debug('Exception : '+ex.getMessage()+' at '+ex.getLineNumber());
        }
    }
}