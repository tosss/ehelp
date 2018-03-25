//2015-11-13- anirudh.singh@cdk.com- Modified the API Version from 15.0 to 34.0.
//2015-11-13- anirudh.singh@cdk.com- This class consisted TestMethods. Now, a new class SalesCoachSetup_Test has been created for test coverage.
public with sharing class SalesCoachSetup
{
    private Boolean showSections=false;
    private Sales_Coach_Stage__c scStage;
    private List<Sales_Coach_Activity__c> scActivities;
    private List<SectionWithItems> swi;
    
    public Map<String, Schema.SObjectField> userValMap;       
    // Variables for content management
    public string stage{get; set;}
    public string toDelete{get; set;}
    
    public Boolean getShowSections()
    {
        return this.showSections;
    }
    
    public Sales_Coach_Stage__c getScStage()
    {
        return this.scStage;
    }
    
    public List<Sales_Coach_Activity__c> getScActivities()
    {
        return this.scActivities;
    }
    
    public List<SectionWithItems> getSwi()
    {
        return this.swi;
    }
    
    //2015-11-13- anirudh.singh@cdk.com- Changed SelectOption[] to List<SelectOption>.
    //This gets the opportunity stages from OppurtunityStage which is set by user.
    public static List<SelectOption> getOpptyStages()
    {
        return SalesCoachUtil.getOpptyStages();
    }
    
    //Retrieve the sales coach sections (and items in those sections).
    public PageReference getSections()
    {
        //2015-11-13- anirudh.singh@cdk.comChanged Sales_Coach_Stage__c[] to List<Sales_Coach_Stage__c>.
        List<Sales_Coach_Stage__c> salesCoachStage;
        
        // Only show the data if all 3 picklists have an option selected
        if(this.stage == '-- Select --')
        {
            this.swi=Null;
            this.showSections=false;
            return Null;
        }
        
        try
        {
            salesCoachStage=[
                SELECT id, 
                name, 
                buyer_stage__c,  
                active__c
                FROM Sales_Coach_Stage__c 
                WHERE active__c=true 
                AND name=: this.stage
            ]; 
        }
        catch(QueryException e)
        {
            ApexPages.addMessages(e);
        }
        
        if(salesCoachStage.size()>0)
        {
            this.scStage=salesCoachStage[0];
        }
        else
        {
            createNewScStage();
        }   
        
        this.showSections=true;
        
        // Get activities for this stage, populate them if necessary
        try
        {
            if(this.scStage != Null)
            {
                this.scActivities=[
                    SELECT id, 
                    name, 
                    activity_details__c, 
                    ordering_number__c
                    FROM Sales_Coach_Activity__c
                    WHERE sales_coach_stage__c=: this.scStage.id
                ];
            }
        }
        catch(QueryException e)
        {
            ApexPages.addMessages(e);
        }
        
        addBlankActivities(3);        
        populateSections();
        
        return Null;
    }
    
    public SalesCoachSetup(){}
    
    public PageReference saveActivities()
    {
        List<Sales_Coach_Activity__c> toAdd=new List<Sales_Coach_Activity__c>();
        
        for(Sales_Coach_Activity__c sca : this.scActivities)
        {
            if(sca.activity_details__c != Null)
            {
                toAdd.add(sca);
            }
        }
        
        upsert toAdd;
        this.saveStage();
        this.saveSections();
        
        getSections();
        return Null;
    }
    
    public PageReference saveStage()
    {
        if(this.swi!=Null && this.swi.size()>0)
        {
            update this.scStage;
        }
        return Null;
    }   
    
    // Section is master-detail with section item, so
    // section needs to be upserted (and IDs saved to section item)
    // before section item can be upserted
    public PageReference saveSections()
    {
        List<Sales_Coach_Section__c> updateScSections;
        List<Sales_Coach_Section_Item__c> updateScSectionItems;
        //2015-11-13- anirudh.singh@cdk.comChanged Sales_Coach_Section__c[] to List<Sales_Coach_Section__c>.
        List<Sales_Coach_Section__c> s;
        
        if(this.swi!=Null && this.swi.size()>0)
        {
            updateScSections=new List<Sales_Coach_Section__c>();
            updateScSectionItems=new List<Sales_Coach_Section_Item__c>();
            s=new List <Sales_Coach_Section__c>();
            
            for(SectionWithItems section: this.swi)
            {
                if(section.scSection.section_name__c!=Null)
                {
                    updateScSections.add(section.scSection);
                    
                    for(ItemProduct item: section.ItemProducts)
                    {
                        if(item.item.item_name__c!=Null)
                        {
                            //if it is a new section title, add the section and get its id
                            //if the section is a duplicate title, the items are not added
                            if(item.item.sales_coach_section__c==Null)
                            {
                                upsert section.scSection;
                                s.clear();
                                s= [
                                    SELECT id 
                                    FROM Sales_Coach_Section__c 
                                    WHERE Section_Name__c=:section.scSection.section_name__c
                                ];
                                
                                if(s.size() ==1)
                                {
                                    item.item.sales_coach_section__c =s[0].id;
                                }
                            }
                            
                            if(item.item.link_to_content__c == Null)
                            {
                                item.item.link_to_content__c='';
                            }                         
                            
                            //ensure that the item can be inserted into database
                            if(item.item.sales_coach_section__c != Null)
                            {
                                updateScSectionItems.add(item.item);
                            }
                        }
                    }
                }
            }
            try
            {
                upsert updateScSections;
                upsert updateScSectionItems;
            }
            catch(DmlException e)
            {
                ApexPages.addMessages(e);
            }
        }
        return Null;
    }
    
    public PageReference deleteActivity()
    {
        Sales_Coach_Activity__c scActivity;
        if(this.toDelete != Null || this.toDelete != '')
        {
            try
            {
                scActivity=[
                    SELECT id
                    FROM Sales_Coach_Activity__c
                    WHERE id=: this.toDelete
                ];
                
                delete scActivity;
                getSections();
            }
            catch(Exception e)
            {
                ApexPages.addMessages(e);
            }
        }
        return Null;        
    }
    
    // master-detail makes it easy to delete a section and all its 
    // child section items
    public PageReference deleteSection() 
    {
        Sales_Coach_Section__c scSection;
        
        if(this.toDelete != '' || this.toDelete != Null)
        {
            try
            {
                scSection=[
                    SELECT id
                    FROM Sales_Coach_Section__c
                    WHERE id=: this.toDelete
                ];
                
                delete scSection;
                getSections();
            }
            catch(Exception e)
            {
                ApexPages.addMessages(e); 
            }
        }
        return Null;
    }
    
    public PageReference deleteSectionItem()
    {
        Sales_Coach_Section_Item__c scSectionItem;
        
        if(this.toDelete != '' || this.toDelete != Null)
        {
            try
            {
                scSectionItem=[
                    SELECT id
                    FROM Sales_Coach_Section_Item__c 
                    WHERE id=: this.toDelete
                ];
                
                delete scSectionItem;
                getSections();
            }
            catch(Exception e)
            {
                ApexPages.addMessages(e);
            }
        }
        return Null;
    }
    
    private void createNewScStage()
    {
        this.scStage=new Sales_Coach_Stage__c(Name=this.stage,
                                                Active__c=true);
        
        insert this.scStage;
    }
    
    private void addBlankActivities(Integer pNumOfBlank)
    {
        if(this.scActivities == Null)
        {
            this.scActivities=new List<Sales_Coach_Activity__c>();
        }
        
        integer i=this.scActivities.size();
        
        if(pNumOfBlank != Null)
        {
            for(Integer x=0; x < pNumOfBlank; x++)
            {
                this.scActivities.add(new Sales_Coach_Activity__c(sales_coach_stage__c=scStage.id,
                                                                  ordering_number__c=i + x + 1 ));
            }
        }
    }
    
    // Load in any existing sections for this stage, and create blank new records; up to 5
    private void populateSections()
    {
        List<Sales_Coach_Section__c> scSections;
        List<Sales_Coach_Section_Item__c> scSectionItems;
        this.swi=new List<SectionWithItems>();      
        
        try
        {
            scSections=[
                SELECT id, 
                sales_coach_stage__c, 
                section_name__c, 
                section_ordering__c, 
                section_width__c,
                (SELECT id, 
                 sales_coach_section__c, 
                 item_name__c, 
                 link_to_content__c, 
                 section_ordering__c
                 FROM Sales_Coach_Section_Items__r 
                 ORDER BY section_ordering__c, item_name__c)
                FROM Sales_Coach_Section__c
                WHERE sales_coach_stage__c=:this.scStage.id 
                ORDER BY section_ordering__c, section_name__c
            ];
        }
        catch(QueryException e)
        {
            ApexPages.addMessages(e);
        }
        
        integer i=scSections.size();
        
        //test if 6, anymore will cause an error
        for(Integer x=0; x < 5 - i; x++ )
        { 
            scSections.add(new Sales_Coach_Section__c(sales_coach_stage__c=scStage.id, 
                                                      section_width__c=20,
                                                      section_ordering__c=i + x + 1 ));
        }
        
        // Load in section items for each section
        scSectionItems=getSectionItems(scSections);
    }
    
    public List<Sales_Coach_Section_Item__c> getSectionItems(list<Sales_Coach_Section__c> SCSList)
    {
        List<Sales_Coach_Section_Item__c> returnList=new List<Sales_Coach_Section_Item__c>();
        
        for(Sales_Coach_Section__c scSection : SCSList )
        {
            returnList=scSection.Sales_Coach_Section_Items__r;
            
            integer itemsize=returnList.size();
            
            for(Integer x=0; x < 3; x++ )
            {
                returnList.add(new Sales_Coach_Section_Item__c(sales_coach_section__c=scSection.id,
                                                               section_ordering__c=itemsize + x + 1 ) );
            }
            
            this.swi.add(new SectionWithItems(scSection,returnList));
        }
        
        return returnList;
    }
    
    public class ItemProduct
    {
        private Sales_Coach_Section_Item__c item;
        public Sales_Coach_Section_Item__c getItem()
        {
            return this.item;
        }
        
        public ItemProduct(Sales_Coach_Section_Item__c pScSectionItem)
        {
            this.item=pScSectionItem;
        }
    }
    
    // subclass for section items to display on the admin page  
    class SectionWithItems
    {
        private Sales_Coach_Section__c scSection;
        private List<ItemProduct> itemProducts;
        
        public Sales_Coach_Section__c getScSection()
        {
            return this.scSection;
        }
        
        public List<ItemProduct> getItemProducts()
        {
            return this.itemProducts;
        }
        
        public SectionWithItems(Sales_Coach_Section__c pSection, List<Sales_Coach_Section_Item__c> pScSectionItems)
        {
            this.scSection=pSection;
            this.itemProducts=new List<ItemProduct>();
            
            for(Sales_Coach_Section_Item__c item : pScSectionItems)
            {
                this.itemProducts.add( new ItemProduct(item));
            }
        }   
    }
}