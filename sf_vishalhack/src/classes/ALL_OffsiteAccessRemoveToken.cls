global class ALL_OffsiteAccessRemoveToken
{    
    //Author: Anirudh Singh
    //Created Date: 16th January, 2015
    
    public PageReference removeToken()
    {
        List<TwoFactorInfo> twoFactors=[SELECT UserId, Type FROM TwoFactorInfo where userID=:UserInfo.getUserId()];
        delete(twoFactors);
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,'You have successfully removed the token. If you want to re-register please go to Home Page and click on "Offsite Access Registration" link.'));
        return Null;
    }
}