/*-------------------------------------------------------
 * 2016-07-06 -venkata.shrivol@cdk.com -Created
 * Description - Temporary class created to check the user Permissions on a single page.
 * ----------MODIFICATIONS-------------------------------
 * 2016-07-26  -venkata.shrivol@cdk.com -Class no longer needed RQ-07421
---------------------------------------------------------*/
public class IMP_SubProjectButtons_Extension 
{
    /*public boolean hasAccess {get;set;}
    public IMP_SubProjectButtons_Extension(ApexPages.StandardController stdCon)
    {
        hasAccess = false;
        list<SetupEntityAccess> queryList = [select Id from SetupEntityAccess where
                                            ParentId IN 
                                            (
                                                select PermissionSetId from PermissionSetAssignment 
                                                where AssigneeId = :userInfo.getUserId()
                                            )
                                            and SetupEntityId IN 
                                             (
                                                 select Id from ApexPage where Name = 'ALL_TreeGrid_AngularUIGrid' and NamespacePrefix = null
                                             )
                                            ];
        if(!queryList.isEmpty())
        {
            hasAccess = true;
        }
    }*/
}