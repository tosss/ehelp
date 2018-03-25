/*------------------------------------------------------------
    Author: Kimiko Roberto
    Company: Cloud Sherpas
    Description: Supports the IMP_WorkbookAcrossProjects page to drive workbook copy processes 
                 from the current project to a target selected project and site.
    History
    11/11/14    Kimiko Roberto      Created
    11/20/14    Samuel Oberes       Applied usage of IMP_Project_Utility.buildSelectOption
    
 ------------------------------------------------------------*/


public class IMP_WorkBookAcrossProjects_Controller{
    
    public Site_Workbook__c selectedProject{get;set;}
    public Discovery_Workbook_Category__c siteClone{get;set;}
    public Id projectId;
    
    public IMP_WorkBookAcrossProjects_Controller(){
        selectedProject = new Site_Workbook__c();
        siteClone = new Discovery_Workbook_Category__c();
        projectId = ApexPages.currentPage().getParameters().get('id');
    }
    
    /*------------------------------------------------------------
    Author: Kimiko Roberto
    Company: Cloud Sherpas
    Description: Gets all the existing subproject sites in a Project.
    Inputs: None
    Returns: List<SelectOption>
    History
    11/13/14      Kimiko Roberto      Created
    ------------------------------------------------------------*/
    
    public List<SelectOption> getSites() {
        return IMP_Project_Utility.getSites(selectedProject.Project__c);
    }
    
    /*------------------------------------------------------------
    Author: Kimiko Roberto
    Company: Cloud Sherpas
    Description: Gets all the existing workbooks in a Project.
    Inputs: None
    Returns: List<SelectOption>
    History
    11/13/14      Kimiko Roberto      Created
    ------------------------------------------------------------*/
    public List<SelectOption> getSources() {
        return IMP_Project_Utility.getSources(projectId);
    }
    
    /*------------------------------------------------------------
    Author: Rey Austral
    Company: Cloud Sherpas
    Description: Method of calling the clone class
    Inputs: None
    Returns: void
    History
    11/13/14      Kimiko Roberto      Created
    ------------------------------------------------------------*/
    public void cloneWkbook() {
        if (siteClone.Site_Workbook__c!= null) 
        {
            if (selectedProject.Site__c != null) 
            {        
                Project__c prjName = [SELECT Id, Name FROM Project__c WHERE Id =: selectedProject.Project__c];        
                IMP_CloneWorkbook_Helper cloneWorkbook = new IMP_CloneWorkbook_Helper();
                //execute the clone function , the clone function will return an error message if the site already contain a workbook
                string ErrMessage= cloneWorkbook.cloneWorkBook(selectedProject.Project__c,selectedProject.Site__c,siteClone.Site_Workbook__c);
                
                if(ErrMessage!='')
                {
                    //Get the name of the site to be able to use in the error message
                    Account acct = IMP_Project_Utility.retrieveAccount(selectedProject.site__c);
                    //Account acct = [SELECT id, Name from Account where ( id =:site.Site__c) ];
                    if(acct.Name != null){
                        
                        ApexPages.Message errMsg = new ApexPages.Message(ApexPages.Severity.Error, 'Workbook for Site ' + acct.Name +' already exists in Project ' + prjName.Name);
                        ApexPages.addMessage(errMsg);
                    }
                }
                else
                {
                    //Get the name of the site which will be used for the success message
                    Account acct = IMP_Project_Utility.retrieveAccount(selectedProject.site__c);
                    //Account acct = [SELECT id, Name from Account where ( id =:site.Site__c) ];
                    //ApexPages.getMessages().clear();
                    if(acct.Name != null){
                        ApexPages.Message errMsg = new ApexPages.Message(ApexPages.Severity.Info, 'Workbook for Site ' + acct.Name +' has been created to Project ' + prjName.Name);
                        ApexPages.addMessage(errMsg);
                    }
                    
                }
              
            }else
            {
                ApexPages.Message errMsg = new ApexPages.Message(ApexPages.Severity.Error, 'No Target Site record found. Please select a Target Site');
                ApexPages.addMessage(errMsg);
                
            }
        }
        else 
        {                   
            ApexPages.Message errMsg = new ApexPages.Message(ApexPages.Severity.Error, 'No Source Site record found. Please select a Source Site');
            ApexPages.addMessage(errMsg);
            
        }
    }

}