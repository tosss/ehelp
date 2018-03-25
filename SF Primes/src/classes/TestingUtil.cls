//2015-11-13- anirudh.singh@cdk.com- To upgrade the API Version FROM 16.0 to 34.0.
public with sharing class TestingUtil
{
    //2015-11-13- anirudh.singh@cdk.com- Commented the below variables opId, scsId, scsecId, scsecItemId, actId.
    //public String opId;
    //public String scsId;
    //public String scsecId;
    //public String scsecItemId;
    //public String actId;
    
    //2015-11-13- anirudh.singh@cdk.com- Commented the constructor as it is not needed.
    //public TestingUtil()
    //{
    //opId = makeTestableOp();
    //scsId = makeSalesCoachStage();
    //scsecId = makeSalesCoachSections();
    //scsecItemId = makeSecItem();
    //actId = makeActivities();
    //ApexPages.currentPage().getParameters().put('id', this.opId);
    //}
    
    //2015-11-13- anirudh.singh@cdk.com- Made the method static. Added the static keyword. Changed access modifier from private to public.
    //2015-11-13- anirudh.singh@cdk.com- The method now returns Opportunity record. Doesn't insert it. Earlier returned Opportunity Id.
    public static Opportunity makeTestableOp()
    {
        Opportunity op = new Opportunity();
        op.Name='testOpName';
        op.CloseDate = Date.today();
        op.StageName='testStage';
        op.ADP_Opportunity_Owner__c = UserInfo.getUserId();
        //insert op;
        return op;
    }
    
    //2015-11-13- anirudh.singh@cdk.com- Made the method static. Added the static keyword. Changed access modifier from private to public.
    //2015-11-13- anirudh.singh@cdk.com- The method now returns Sales_Coach_Stage__c record. Doesn't insert it. Earlier returned Sales_Coach_Stage__c Id.
    public static Sales_Coach_Stage__c makeSalesCoachStage()
    {
        Sales_Coach_Stage__c scs = new Sales_Coach_Stage__c();
        scs.Name='testStage';
        scs.Buyer_Stage__c='testBuyStage';
        scs.Active__c=true;
        return scs;
    }
    
    //2015-11-13- anirudh.singh@cdk.com- Made the method static. Added the static keyword. The method now accepts Id parameter Sales_Coach_Stage__c recordId. Changed access modifier from private to public.
    //2015-11-13- anirudh.singh@cdk.com- The method now returns Sales_Coach_Section__c record. Doesn't insert it. Earlier returned Sales_Coach_Section__c Id.
    public static Sales_Coach_Section__c makeSalesCoachSections(Id salesCoachStageRecId)
    {
        Sales_Coach_Section__c scsec =  new Sales_Coach_Section__c();
        scsec.Section_Ordering__c =1.0;
        scsec.Section_Name__c='testSection';
        scsec.Sales_Coach_Stage__c=salesCoachStageRecId;
        scsec.Section_Width__c=33.0;
        return scsec;
    }
    
    //2015-11-13- anirudh.singh@cdk.com- Made the method static. Added the static keyword. The method now accepts Id parameter Sales_Coach_Section__c recordId. Changed access modifier from private to public.
    //2015-11-13- anirudh.singh@cdk.com- The method now returns Sales_Coach_Section_Item__c record. Doesn't insert it. Earlier returned Sales_Coach_Section_Item__c Id.
    public static Sales_Coach_Section_Item__c makeSecItem(Id salesCoachSectionRecId)
    {
        Sales_Coach_Section_Item__c secItem = new Sales_Coach_Section_Item__c();
        secItem.Section_Ordering__c=1.0;
        secItem.Sales_Coach_Section__c=salesCoachSectionRecId;
        secItem.Link_to_Content__c='http://www.google.com';
        secItem.Item_Name__c='testItem';
        secItem.Display__c=true;
        secItem.Products__c='';
        return secItem;
    }
    
    //2015-11-13- anirudh.singh@cdk.com- Made the method static. Added the static keyword. The method now accepts Id parameter Sales_Coach_Stage__c recordId. Changed access modifier from private to public.
    //2015-11-13- anirudh.singh@cdk.com- The method now returns Sales_Coach_Activity__c record. Doesn't insert it. Earlier returned Sales_Coach_Activity__c Id.
    public static Sales_Coach_Activity__c makeActivities(Id salesCoachStageRecId)
    {
        Sales_Coach_Activity__c sca = new Sales_Coach_Activity__c();
        sca.Sales_Coach_Stage__c=salesCoachStageRecId;
        sca.Ordering_Number__c=1.0;
        sca.Activity_Details__c='testActivity';
        return sca;
    }
}