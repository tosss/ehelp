//2016-10-19- anirudh.singh@cdk.com- Created this for Questions Tab for Products.
public class ALL_ProductQuestions_Controller 
{
    private Boolean initialized=false;
    private Map<String, Map<String, List<Id>>> deptWorkflowNameProdNameAndQuesIdsMap;
    private List<String> deptWorkflowNamesList;
    
    public String selectedDeptWorkflow{get; set;}
    public Id oppLocationSiteIdForRecs{get; set;}
    public Id siteWorkbookIdForQuestionsTab{get; set;}
    public String questionsScenario{get; set;}
    
    public ApexPages.Component getQuestionAnswerComponent()
    {
        if(siteWorkbookIdForQuestionsTab!=Null && deptWorkflowNameProdNameAndQuesIdsMap!=Null 
           && deptWorkflowNameProdNameAndQuesIdsMap.size()>0)
        {
            return fetchQuestionAnswerComponent(selectedDeptWorkflow, siteWorkbookIdForQuestionsTab, 
                                                deptWorkflowNameProdNameAndQuesIdsMap, questionsScenario);
        }
        return new Component.Apex.OutputText();
    }
    
    public List<String> displaySideBarTabsList
    {
        get
        {
            if(!initialized && siteWorkbookIdForQuestionsTab!=Null)
            {
                deptWorkflowNameProdNameAndQuesIdsMap=new Map<String, Map<String, List<Id>>>();
                deptWorkflowNameProdNameAndQuesIdsMap.putAll(fetchProdsMap(oppLocationSiteIdForRecs));
                
                deptWorkflowNamesList=new List<String>();
                deptWorkflowNamesList.addAll(deptWorkflowNameProdNameAndQuesIdsMap.keySet());
                
                if(ApexPages.currentPage().getParameters().get('deptWorkflowName')==Null)
                {
                    if(deptWorkflowNamesList.size()>0)
                    {
                        selectedDeptWorkflow=deptWorkflowNamesList[0];
                    }
                }
                else
                {
                    selectedDeptWorkflow=ApexPages.currentPage().getParameters().get('deptWorkflowName');
                }
                initialized=true;
            }
            return deptWorkflowNamesList;
        }
        set;
    }
    
    private static Map<String, Map<String, List<Id>>> fetchProdsMap(Id oppLocationSiteIdForRecs)
    {
        Map<Id, Discovery_Product_Definition__c> prodDefinitionsMap=new Map<Id, Discovery_Product_Definition__c>();
        
        for(Product_at_Site__c prodRecord: [
            SELECT Id, Discovery_Product_Definition__c, Discovery_Product_Definition__r.Active__c, Discovery_Product_Definition__r.Name, 
            Discovery_Product_Definition__r.Department__c, Discovery_Product_Definition__r.Workflow__c, 
            Discovery_Product_Definition__r.Order__c 
            FROM Product_at_Site__c 
            WHERE Opportunity_Location__c=:oppLocationSiteIdForRecs 
            AND Discovery_Product_Definition__r.Active__c=true
            AND Include_Questions__c=true
            ORDER BY Discovery_Product_Definition__r.Order__c
        ])
        {
            if(prodRecord.Discovery_Product_Definition__r.Department__c!=Null 
               && prodRecord.Discovery_Product_Definition__r.Workflow__c!=Null)
            {
                prodDefinitionsMap.put(prodRecord.Discovery_Product_Definition__c, prodRecord.Discovery_Product_Definition__r);
            }
        }
        
        //Fetching a list of Discovery Product Questions using the Product Definition Ids.
        List<Discovery_Product_Question__c> prodQuestsList=new List<Discovery_Product_Question__c>([
            SELECT Id, Discovery_Question__c, Discovery_Product_Definition__c, Order__c
            FROM Discovery_Product_Question__c
            WHERE Discovery_Product_Definition__c IN :prodDefinitionsMap.keySet() 
            ORDER BY Order__c
        ]);
        
        //Creating a Map of Product Definition Id and Discovery Question Ids.
        Map<Id, List<Id>> prodDefIdAndQuestionIdsMap=new Map<Id, List<Id>>();
        if(prodQuestsList!=Null && prodQuestsList.size()>0)
        {
            for(Discovery_Product_Question__c prodQuestRec: prodQuestsList)
            {
                if(!prodDefIdAndQuestionIdsMap.containsKey(prodQuestRec.Discovery_Product_Definition__c))
                {
                    prodDefIdAndQuestionIdsMap.put(prodQuestRec.Discovery_Product_Definition__c, new List<Id>{prodQuestRec.Discovery_Question__c});
                }
                else
                {
                    prodDefIdAndQuestionIdsMap.get(prodQuestRec.Discovery_Product_Definition__c).add(prodQuestRec.Discovery_Question__c);
                }
            }
        }
        
        Map<String, Map<String, List<Id>>> deptWorkflowNameProdNameAndQuesIdsMap=new Map<String, Map<String, List<Id>>>();
        if(prodDefinitionsMap!=Null && prodDefinitionsMap.size()>0 
           && prodDefIdAndQuestionIdsMap!=Null && prodDefIdAndQuestionIdsMap.size()>0)
        {
            for(Id prodDefinitionId: prodDefinitionsMap.keySet())
            {
                for(Id prodDefId: prodDefIdAndQuestionIdsMap.keySet())
                {
                    if(prodDefinitionId==prodDefId)
                    {
                        String deptWorkflowName=prodDefinitionsMap.get(prodDefinitionId).Department__c+'- '+prodDefinitionsMap.get(prodDefinitionId).Workflow__c;
                        if(!deptWorkflowNameProdNameAndQuesIdsMap.containsKey(deptWorkflowName))
                        {
                            Map<String, List<Id>> prodNameAndQuesIdsMap=new Map<String, List<Id>>();
                            prodNameAndQuesIdsMap.put(prodDefinitionsMap.get(prodDefinitionId).Name, prodDefIdAndQuestionIdsMap.get(prodDefinitionId));
                            deptWorkflowNameProdNameAndQuesIdsMap.put(deptWorkflowName, prodNameAndQuesIdsMap);
                        }
                        else
                        {
                            Map<String, List<Id>> prodNameAndQuesIdsMap=deptWorkflowNameProdNameAndQuesIdsMap.get(deptWorkflowName);
                            prodNameAndQuesIdsMap.put(prodDefinitionsMap.get(prodDefinitionId).Name, prodDefIdAndQuestionIdsMap.get(prodDefinitionId));
                        }
                    }
                }
            }
        }
        
        return deptWorkflowNameProdNameAndQuesIdsMap;
    }
    
    private static ApexPages.Component fetchQuestionAnswerComponent(String selectedDeptWorkflow, Id siteWorkbookIdForQuestionsTab, 
                                                                    Map<String, Map<String, List<Id>>> deptWorkflowNameProdNameAndQuesIdsMap, 
                                                                    String questionsScenario)
    {
        List<ApexPages.Component> componentsList=new List<ApexPages.Component>();
        for(String deptWorkflowName: deptWorkflowNameProdNameAndQuesIdsMap.keySet())
        {
            if(questionsScenario=='pdf')
            {
                for(String prodName: deptWorkflowNameProdNameAndQuesIdsMap.get(deptWorkflowName).keySet())
                {
                    Component.c.ALL_QuestionAnswerForPDF questionAnswerForPDFComponent=new Component.c.ALL_QuestionAnswerForPDF(
                        productName=deptWorkflowName+' - '+prodName, 
                        displayHeader=true, 
                        questionIds=deptWorkflowNameProdNameAndQuesIdsMap.get(deptWorkflowName).get(prodName), 
                        discoverySiteWorkbookId=siteWorkbookIdForQuestionsTab, 
                        scenario='pdf'
                    );
                    componentsList.add(questionAnswerForPDFComponent);
                }
            }
            else if(questionsScenario!='pdf' && selectedDeptWorkflow==deptWorkflowName)
            {
                for(String prodName: deptWorkflowNameProdNameAndQuesIdsMap.get(deptWorkflowName).keySet())
                {
                    Component.c.ALL_QuestionAnswer questionAnswerComponent=new Component.c.ALL_QuestionAnswer(
                        productName=prodName, 
                        displayHeader=true, 
                        discoverySiteWorkbookId=siteWorkbookIdForQuestionsTab, 
                        questionIds=deptWorkflowNameProdNameAndQuesIdsMap.get(deptWorkflowName).get(prodName)
                    );
                    componentsList.add(questionAnswerComponent);
                }
                break;
            }
        }
        
        Component.Apex.OutputText outputTextPanel=new Component.Apex.OutputText();
        if(componentsList.size()>0)
        {
            outputTextPanel.childComponents.addAll(componentsList);
        }
        
        return outputTextPanel;
    }
}