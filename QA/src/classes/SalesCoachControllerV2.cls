//2015-11-13- anirudh.singh@cdk.com- Modified the API Version from 15.0 to 34.0.
//2015-11-13- anirudh.singh@cdk.com- This class consisted TestMethods. Now, a new class SalesCoachControllerV2_Test has been created for test coverage.
public with sharing class SalesCoachControllerV2
{
    public Opportunity oppty{get; set;}
    private List<String> salesCoachProducts;
    private String opportunityStage;
    private Sales_Coach_Stage__c salesCoachStage;
    private List<SuperSection> superSections;
    private List<Sales_Coach_Activity__c> salesCoachActivities;
    public Boolean renderCheck{get; set;}
    
    public String getOpportunityStage()
    {
        return this.opportunityStage;
    }
    
    public Sales_Coach_Stage__c getSalesCoachStage()
    {
        return this.salesCoachStage;
    }
    
    public List<SuperSection> getSuperSections()
    {
        return this.superSections;
    }
    
    public List<Sales_Coach_Activity__c> getSalesCoachActivities()
    {
        return this.salesCoachActivities;
    }
    
    public void setOpportunityStage(String pStage)
    {
        this.opportunityStage=pStage;
    }
    
    //2015-11-13- anirudh.singh@cdk.com- Changed SelectOption[] to List<SelectOption>.
    public List<SelectOption> getOpptyStages()
    {
        List<SelectOption> op=SalesCoachUtil.getOpptyStages();
        
        if(op.size()>0)
        {
            op.remove(0);
        }
        return op;
    }
    
    public SalesCoachControllerV2()
    {
        String ID=ApexPages.currentPage().getParameters().get('id');
        
        try
        { 
            this.oppty=[
                SELECT Id, 
                StageName, 
                forecastcategory
                FROM Opportunity 
                WHERE Id= :ID
            ];
            this.opportunityStage=this.oppty.StageName;
            startProcess();
        }
        catch(QueryException e)
        {
            ApexPages.addMessages(e);
        }
    }
    
    public void startProcess()
    {
        populateSalesCoachStage();        
        
        if(this.salesCoachStage!=Null)
        {
            populateSuperSections();
            populateActivities();
            if(this.salesCoachActivities.size()>0 && this.superSections.size()>0)
            {
                this.renderCheck=true;
            }
            else
            {
                this.renderCheck=false;
            }
        }
    }
    
    private void populateSalesCoachStage()
    {
        try
        {
            this.salesCoachStage=[
                SELECT 
                Name, 
                Id, 
                Buyer_Stage__c, 
                Active__c 
                FROM Sales_Coach_Stage__c
                WHERE Name=: this.opportunityStage Limit 1
            ];
        }
        catch(QueryException e)
        {
            this.salesCoachStage=Null;
        }
    }
    
    private void populateSuperSections()
    {
        this.superSections=new List<SuperSection>();
        
        try
        {
            List<Sales_Coach_Section__c> sList=[
                SELECT Section_Ordering__c, 
                Section_Name__c, 
                Sales_Coach_Stage__c, 
                Name, 
                Id,
                Sales_Coach_Section__c.Sales_Coach_Stage__r.Name, 
                Section_Width__c,
                (SELECT Section_Ordering__c, 
                 Sales_Coach_Section__c, 
                 Name, 
                 Link_to_Content__c, 
                 Item_Name__c, 
                 Id, 
                 Display__c, 
                 Products__c 
                 FROM Sales_Coach_Section_Items__r
                 order by Section_Ordering__c)  
                FROM Sales_Coach_Section__c
                WHERE Sales_Coach_Stage__c=:this.salesCoachStage.Id
                ORDER BY Section_Ordering__c
            ];
            
            for(Sales_Coach_Section__c section : sList)
            {
                if(section.Sales_Coach_section_Items__r.isEmpty())
                {
                    this.superSections.add(new SuperSection(section, Null));
                }
                else
                {
                    this.superSections.add(new SuperSection(section, section.Sales_Coach_section_Items__r));
                }
            }
        }
        catch(Exception e)
        {
            ApexPages.addMessages(e);
        }
    }
    
    private void populateActivities()
    {
        try
        {
            this.salesCoachActivities=[
                SELECT Sales_Coach_Stage__c, 
                Ordering_Number__c, 
                Name, 
                Id, 
                Activity_Details__c 
                FROM Sales_Coach_Activity__c
                WHERE Sales_Coach_Stage__c=: this.salesCoachStage.Id
                ORDER BY Ordering_Number__c
            ];
        }
        catch(Exception e)
        {
            ApexPages.addMessages(e);
        }
    }
    
    public PageReference updateStageData()
    {
        startProcess();
        return Null;
    }
    
    class SuperSection
    {
        private Sales_Coach_Section__c salesCoachSection;
        private List<Sales_Coach_Section_Item__c> salesCoachSectionItems;
        
        public Sales_Coach_Section__c getSalesCoachSection(){return salesCoachSection;}
        public List<Sales_Coach_Section_Item__c> getSalesCoachSectionItems(){return salesCoachSectionItems;}
        
        public SuperSection(Sales_Coach_Section__c pSec, List<Sales_Coach_Section_Item__c> pItems)
        {
            salesCoachSection=pSec;
            salesCoachSectionItems=pItems;
        }
    }
}