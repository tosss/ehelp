//2016-10-14- anirudh.singh@cdk.com- Created this dynamic component for rendering components dynamically.
public class ALL_RenderComponents_Controller
{
    private Boolean initialized=false;
    public String tabNameSelected{get; set;}
    public Opportunity_Location__c oppLocationRecord{get; set;}
    
    public ApexPages.Component getOutputTextPanel()
    {
        if(!initialized && tabNameSelected!=Null && oppLocationRecord!=Null)
        {
            initialized=true;
            return fetchComponentsList(tabNameSelected, oppLocationRecord);
        }
        return new Component.Apex.OutputText();
    }
    
    private static ApexPages.Component fetchComponentsList(String tabNameSelected, Opportunity_Location__c oppLocationRecord)
    {
        List<ApexPages.Component> componentsList=new List<ApexPages.Component>();
        
        List<ALL_DiscoveryTab__mdt> discoveryTabRecordsList;
        if(tabNameSelected=='Print Version')
        {
            //Fetching all the Tab records.
            discoveryTabRecordsList=new List<ALL_DiscoveryTab__mdt>([
                SELECT Id, MasterLabel, Related_to_Question_Answer__c, Order__c 
                FROM ALL_DiscoveryTab__mdt 
                ORDER BY Order__c ASC
            ]);
        }
        
        String tabContentRecordsQuery='SELECT Id, Component_Name__c, Component_Order__c, Display_Header__c, Discovery_Tab_Name__r.MasterLabel, Label_to_Display__c ' 
            +'FROM ALL_DiscoveryTabContent__mdt ';
        if(tabNameSelected!='Print Version')
        {
            tabContentRecordsQuery+='WHERE Discovery_Tab_Name__r.MasterLabel=:tabNameSelected ';
        }
        tabContentRecordsQuery+=' ORDER BY Component_Order__c';
        
        //Fetching all the Tab Contents.
        List<ALL_DiscoveryTabContent__mdt> tabContentRecordsList=database.query(tabContentRecordsQuery);
        
        //Fetching all the Category and Sub-Category Records.
        List<ALL_DiscoveryCategory__mdt> categoriesList=new List<ALL_DiscoveryCategory__mdt>([
            SELECT Id, MasterLabel, Discovery_Tab_Content__c, Order_Field_API_Name__c, 
            (
                SELECT MasterLabel, Discovery_Category__c, Order__c, Order_Field_API_Name__c 
                FROM ALL_DiscoverySubCategories__r
                ORDER BY Order__c
            )
            FROM ALL_DiscoveryCategory__mdt
            WHERE Discovery_Tab_Content__c IN :tabContentRecordsList
        ]);
        
        //Fetching all the SObject Detail Records.
        List<ALL_SObject__mdt> sObjectList=new List<ALL_SObject__mdt>([
            SELECT Id, MasterLabel, Discovery_Tab_Content__c, SObject_Name__c, SObject_Record_Type__c, 
            Field_Set_API_Name__c, Where_Clause_Field_API_Name__c, Building_Dependent__c 
            FROM ALL_SObject__mdt 
            WHERE Discovery_Tab_Content__c IN :tabContentRecordsList
        ]);
        
        Component.Apex.OutputText outputTextPanel=new Component.Apex.OutputText();
        
        
        if(tabNameSelected=='Print Version')
        {
            componentsList=fetchComponentsListForPDF(discoveryTabRecordsList, tabContentRecordsList, 
                                                     categoriesList, sObjectList, oppLocationRecord);
        }
        else
        {
            componentsList=fetchComponentsListForNonPDF(tabContentRecordsList, categoriesList, 
                                                        sObjectList, oppLocationRecord);
        }
        
        if(componentsList.size()>0)
        {
            outputTextPanel.childComponents.addAll(componentsList);
        }
        
        return outputTextPanel;
    }
    
    private static List<ApexPages.Component> fetchComponentsListForPDF(List<ALL_DiscoveryTab__mdt> discoveryTabRecordsList,
                                                                       List<ALL_DiscoveryTabContent__mdt> tabContentRecordsList, 
                                                                       List<ALL_DiscoveryCategory__mdt> categoriesList, 
                                                                       List<ALL_SObject__mdt> sObjectList, 
                                                                       Opportunity_Location__c oppLocationRecord)
    {
        List<ApexPages.Component> componentsList=new List<ApexPages.Component>();
        
        Component.c.ALL_DiscoveryBuildingImages buildingImagesComponent=new Component.c.ALL_DiscoveryBuildingImages();
        buildingImagesComponent.opportunityLocationSiteId=oppLocationRecord.Id;
        buildingImagesComponent.tabName='Building Map';
        buildingImagesComponent.scenario='pdf';
        buildingImagesComponent.displayHeader=true;
        componentsList.add(buildingImagesComponent);
        
        for(ALL_DiscoveryTab__mdt tabRecord: discoveryTabRecordsList)
        {
            for(ALL_DiscoveryTabContent__mdt tabContentRecord: tabContentRecordsList)
            {
                if(tabRecord.Id==tabContentRecord.Discovery_Tab_Name__c)
                {
                    if(tabContentRecord.Component_Name__c=='ALL_QuestionAnswer')
                    {
                        componentsList.addAll(fetchQuestionAnswerPDFComponents(tabContentRecord, categoriesList, oppLocationRecord));
                    }
                    else if(tabContentRecord.Component_Name__c=='ALL_ObjectDetails')
                    {
                        componentsList.add(fetchObjectDetailsPDFComponent(tabContentRecord, sObjectList, oppLocationRecord));
                    }
                    else if(tabContentRecord.Component_Name__c=='ALL_DiscoveryProduct')
                    {
                        Component.c.ALL_DiscoveryProductForPDF productComponentForPDF=new Component.c.ALL_DiscoveryProductForPDF();
                        productComponentForPDF.headerName=tabRecord.MasterLabel;
                        componentsList.add(productComponentForPDF);
                    }
                    else if(tabContentRecord.Component_Name__c=='ALL_DiscoverySolution')
                    {
                        Component.c.ALL_DiscoverySolutionForPDF solutionComponentForPDF=new Component.c.ALL_DiscoverySolutionForPDF();
                        solutionComponentForPDF.headerName=tabRecord.MasterLabel;
                        componentsList.add(solutionComponentForPDF);
                    }
                    else if(tabContentRecord.Component_Name__c=='ALL_ProductQuestions')
                    {
                        Component.c.ALL_ProductQuestionsForPDF productQuesForPDFComponent=new Component.c.ALL_ProductQuestionsForPDF();
                        productQuesForPDFComponent.opportunityLocationSiteId=oppLocationRecord.Id;
                        productQuesForPDFComponent.siteWorkbookId=oppLocationRecord.Discovery_Site_Workbooks__r[0].Id;
                        productQuesForPDFComponent.scenario='pdf';
                        componentsList.add(productQuesForPDFComponent);
                    }
                    else if(tabContentRecord.Component_Name__c=='ALL_DiscoveryBuildingImages' 
                            && tabContentRecord.Discovery_Tab_Name__r.MasterLabel!='Building Map')
                    {
                        Component.c.ALL_DiscoveryBuildingImages imgComponent=new Component.c.ALL_DiscoveryBuildingImages();
                        imgComponent.opportunityLocationSiteId=oppLocationRecord.Id;
                        imgComponent.labelToDisplay=(tabContentRecord.Label_to_Display__c!=Null) ? tabContentRecord.Label_to_Display__c : '';
                        imgComponent.tabName=tabContentRecord.Discovery_Tab_Name__r.MasterLabel;
                        imgComponent.displayHeader=tabContentRecord.Display_Header__c;
                        imgComponent.scenario='pdf';
                        componentsList.add(imgComponent);
                    }
                }
            }
        }
        
        return componentsList;
    }
    
    private static List<ApexPages.Component> fetchComponentsListForNonPDF(List<ALL_DiscoveryTabContent__mdt> tabContentRecordsList, 
                                                                          List<ALL_DiscoveryCategory__mdt> categoriesList, 
                                                                          List<ALL_SObject__mdt> sObjectList, 
                                                                          Opportunity_Location__c oppLocationRecord)
    {
        List<ApexPages.Component> componentsList=new List<ApexPages.Component>();
        
        for(ALL_DiscoveryTabContent__mdt tabContentRecord: tabContentRecordsList)
        {
            if(tabContentRecord.Component_Name__c=='ALL_QuestionAnswer')
            {
                componentsList.addAll(fetchQuestionAnswerComponents(tabContentRecord, categoriesList, oppLocationRecord));
            }
            else if(tabContentRecord.Component_Name__c=='ALL_ObjectDetails')
            {
                componentsList.add(fetchObjectDetailsComponent(tabContentRecord, sObjectList, oppLocationRecord));
            }
            else if(tabContentRecord.Component_Name__c=='ALL_DiscoveryBuildingImages')
            {
                Component.c.ALL_DiscoveryBuildingImages buildingImagesComponent=new Component.c.ALL_DiscoveryBuildingImages();
                buildingImagesComponent.opportunityLocationSiteId=oppLocationRecord.Id;
                buildingImagesComponent.tabName=tabContentRecord.Discovery_Tab_Name__r.MasterLabel;
                buildingImagesComponent.labelToDisplay=(tabContentRecord.Label_to_Display__c!=Null) ? tabContentRecord.Label_to_Display__c : '';
                buildingImagesComponent.displayHeader=tabContentRecord.Display_Header__c;
                componentsList.add(buildingImagesComponent);
            }
            else if(tabContentRecord.Component_Name__c=='ALL_DiscoverySolution')
            {
                Component.c.ALL_DiscoverySolution solutionsComponent=new Component.c.ALL_DiscoverySolution();
                componentsList.add(solutionsComponent);
            }
            else if(tabContentRecord.Component_Name__c=='ALL_DiscoveryProduct')
            {
                Component.c.ALL_DiscoveryProduct productsComponent=new Component.c.ALL_DiscoveryProduct();
                componentsList.add(productsComponent);
            }
            else if(tabContentRecord.Component_Name__c=='ALL_ProductQuestions')
            {
                Component.c.ALL_ProductQuestions productsComponent=new Component.c.ALL_ProductQuestions();
                productsComponent.opportunityLocationSiteId=oppLocationRecord.Id;
                productsComponent.siteWorkbookId=oppLocationRecord.Discovery_Site_Workbooks__r[0].Id;
                
                componentsList.add(productsComponent);
            }
        }
        return componentsList;
    }
    
    private static List<ApexPages.Component> fetchQuestionAnswerComponents(ALL_DiscoveryTabContent__mdt tabContentRecord, List<ALL_DiscoveryCategory__mdt> categoriesList, 
                                                                           Opportunity_Location__c oppLocationRecord)
    {
        List<ApexPages.Component> componentsList=new List<ApexPages.Component>();
        
        for(ALL_DiscoveryCategory__mdt categoryRecord: categoriesList)
        {
            //If the Category Record is for the current tab Content Record.
            if(tabContentRecord.Id==categoryRecord.Discovery_Tab_Content__c)
            {
                //If there are Sub-Category records present for the Category Record.
                if(categoryRecord.ALL_DiscoverySubCategories__r!=Null && categoryRecord.ALL_DiscoverySubCategories__r.size()>0)
                {
                    for(ALL_DiscoverySubCategory__mdt subCategoryRecord: categoryRecord.ALL_DiscoverySubCategories__r)
                    {
                        Component.c.ALL_QuestionAnswer questionAnswerComponent=new Component.c.ALL_QuestionAnswer(
                            categoryName=categoryRecord.MasterLabel, 
                            subCategoryName=subCategoryRecord.MasterLabel, 
                            displayHeader=tabContentRecord.Display_Header__c, 
                            discoverySiteWorkbookId=oppLocationRecord.Discovery_Site_Workbooks__r[0].Id, 
                            orderByField=subCategoryRecord.Order_Field_API_Name__c
                        );
                        componentsList.add(questionAnswerComponent);
                    }
                }
                else
                {
                    Component.c.ALL_QuestionAnswer questionAnswerComponent=new Component.c.ALL_QuestionAnswer(
                        categoryName=categoryRecord.MasterLabel, 
                        displayHeader=tabContentRecord.Display_Header__c, 
                        discoverySiteWorkbookId=oppLocationRecord.Discovery_Site_Workbooks__r[0].Id, 
                        orderByField=categoryRecord.Order_Field_API_Name__c
                    );
                    componentsList.add(questionAnswerComponent);
                }
                break;
            }
        }
        
        return componentsList;
    }
    
    private static List<ApexPages.Component> fetchQuestionAnswerPDFComponents(ALL_DiscoveryTabContent__mdt tabContentRecord, 
                                                                              List<ALL_DiscoveryCategory__mdt> categoriesList, 
                                                                              Opportunity_Location__c oppLocationRecord)
    {
        List<ApexPages.Component> componentsList=new List<ApexPages.Component>();
        
        for(ALL_DiscoveryCategory__mdt categoryRecord: categoriesList)
        {
            //If the Category Record is for the current tab Content Record.
            if(tabContentRecord.Id==categoryRecord.Discovery_Tab_Content__c)
            {
                //If there are Sub-Category records present for the Category Record.
                if(categoryRecord.ALL_DiscoverySubCategories__r!=Null && categoryRecord.ALL_DiscoverySubCategories__r.size()>0)
                {
                    for(ALL_DiscoverySubCategory__mdt subCategoryRecord: categoryRecord.ALL_DiscoverySubCategories__r)
                    {
                        Component.c.ALL_QuestionAnswerForPDF questionAnswerComponent=new Component.c.ALL_QuestionAnswerForPDF(
                            categoryName=categoryRecord.MasterLabel, 
                            subCategoryName=subCategoryRecord.MasterLabel, 
                            displayHeader=tabContentRecord.Display_Header__c, 
                            orderByField=subCategoryRecord.Order_Field_API_Name__c, 
                            discoverySiteWorkbookId=oppLocationRecord.Discovery_Site_Workbooks__r[0].Id, 
                            scenario='pdf'
                        );
                        componentsList.add(questionAnswerComponent);
                    }
                }
                else
                {
                    Component.c.ALL_QuestionAnswerForPDF questionAnswerComponent=new Component.c.ALL_QuestionAnswerForPDF(
                        categoryName=categoryRecord.MasterLabel, 
                        displayHeader=true, 
                        orderByField=categoryRecord.Order_Field_API_Name__c, 
                        discoverySiteWorkbookId=oppLocationRecord.Discovery_Site_Workbooks__r[0].Id, 
                        scenario='pdf'
                    );
                    componentsList.add(questionAnswerComponent);
                }
                break;
            }
        }
        
        return componentsList;
    }
    
    private static ApexPages.Component fetchObjectDetailsComponent(ALL_DiscoveryTabContent__mdt tabContentRecord, List<ALL_SObject__mdt> sObjectList, 
                                                                   Opportunity_Location__c oppLocationRecord)
    {
        Component.c.ALL_ObjectDetails objectDetailsComponent=new Component.c.ALL_ObjectDetails();
        for(ALL_SObject__mdt sObjectRecord: sObjectList)
        {
            if(tabContentRecord.Id==sObjectRecord.Discovery_Tab_Content__c)
            {
                objectDetailsComponent.displayHeader=tabContentRecord.Display_Header__c;
                objectDetailsComponent.opportunityLocationSiteId=oppLocationRecord.Id;
                objectDetailsComponent.sObjectMetadata=sObjectRecord;
                break;
            }
        }
        
        return objectDetailsComponent;
    }
    
    private static ApexPages.Component fetchObjectDetailsPDFComponent(ALL_DiscoveryTabContent__mdt tabContentRecord, List<ALL_SObject__mdt> sObjectList, 
                                                                      Opportunity_Location__c oppLocationRecord)
    {
        Component.c.ALL_ObjectDetailsForPDF objectDetailsForPDFComponent=new Component.c.ALL_ObjectDetailsForPDF();
        for(ALL_SObject__mdt sObjectRecord: sObjectList)
        {
            if(tabContentRecord.Id==sObjectRecord.Discovery_Tab_Content__c)
            {
                objectDetailsForPDFComponent.displayHeader=true;
                objectDetailsForPDFComponent.sObjectMetadata=sObjectRecord;
                objectDetailsForPDFComponent.scenario='pdf';
                objectDetailsForPDFComponent.opportunityLocationSiteId=oppLocationRecord.Id;
                break;
            }
        }
        
        return objectDetailsForPDFComponent;
    }
}