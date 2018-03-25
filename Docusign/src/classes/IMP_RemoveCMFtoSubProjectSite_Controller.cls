/*------------------------------------------------------------
Author: Rey Austral
Company: Cloud Sherpas
Description: Remove cmf record in the cmf number(s) field in the subproject site
Test Class: IMP_RemoveCMFtoSubProjectSite_Test
History
2/6/15    Rey Austral         Created
------------------------------------------------------------*/
public class IMP_RemoveCMFtoSubProjectSite_Controller {
    public List<SelectOption> siteOptions { get; set; }
    public List<CMFWrapper> cmfList { get; set; }
    public String selectedSite { get;  set; }
    public SubProjectSite__c subSite { get; set; }
    public Boolean isValid { get; set; }
    
    public IMP_RemoveCMFtoSubProjectSite_Controller()
    {
        isValid = true;
        String subprojectId = ApexPages.currentPage().getParameters().get('id');
        //populate the Subproject select list        
        List<SubProjectSite__c> listSubproject = [Select Id, Name, Account__c,Account__r.Name From SubProjectSite__c where subproject__c =:  subprojectId];
        //create an option for the select list
        Map<String,String> optionsMap = new Map<String,String>();
        optionsMap.put('', '--None--');
        for (SubProjectSite__c site : listSubproject) {
            optionsMap.put(site.Id, site.Name + ' - ' + site.Account__r.Name);
        }
        siteOptions = IMP_Project_Utility.buildSelectOption(optionsMap, false);
        siteOptions.sort();
        if (siteOptions.size() ==1 ) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, 'There is no existing site for this sub project, Please create a new site first.')); 
            
        }
    }
    
    
    public void populateGrid()
    {
         ApexPages.getMessages().clear();
        //create a list of cmf based on the selected subproject site
        cmfList = new List<CMFWrapper>();
        if (selectedSite != '' && selectedSite != null) { 
            //get the id of the subproject site
            subSite = [Select Id,Name,CMF_Numbers__c,Ship_CMF__c from SubProjectSite__c where Id =: selectedSite ];  
            //setup the list to remove the ship_cmf value in the list of cmf to be remove by the user
            Set<String> setCmf = new Set<String>();
            Set<String> setShipCmf = new Set<String>();
            if (subSite.Ship_CMF__c != null && subSite.Ship_CMF__c != '') 
            {
                setShipCmf.add(subSite.Ship_CMF__c);
            }
            if (subSite.CMF_Numbers__c != null && subSite.CMF_Numbers__c != '')
            {
                setCmf = New Set<String>(subSite.CMF_Numbers__c.Split(','));
            }
            Set<String> setUniqueCMF = new Set<String>();
            setUniqueCMF = IMP_Project_Utility.getUniqueElementsOfSetOne(setCmf,setShipCmf);
            //populate the wrapper class with the list of cmf numbers
            if (setUniqueCMF.size() == 0)
            {
                 ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, 'There are no more CMFs on the site to delete.  Please either select a different site, or exit by clicking the ‘Cancel button’'));
            } else {
                for(String cmfName : setUniqueCMF)
                {
                    CMFWrapper c = new CMFWrapper();
                    c.isSelected = false;
                    c.CMFName = cmfName;
                    cmfList.add(c);
                }
            }
        }
    }
    
    public void Save()
    {        
        Set<String> uniqueCMF = new Set<String>();
        Boolean haveRecordsToRemove = false;
        //check first if the user selected any cmf records
        if (subSite != null && subSite.CMF_Numbers__c != null && subSite.CMF_Numbers__c != '') {
            //get the value again the existing cmf numbers records
            List<String> listCMFNumbers =  IMP_Project_Utility.parseDelimitedString(subSite.CMF_Numbers__c,',',false);                
            //iterate the list
            for (String cmf : listCMFNumbers) {
                //check if the records is going to be remove, if not add in the list
                if (checkCMFToBeRemove(cmf)==false)
                {
                    uniqueCMF.add(cmf);
                } else {
                    //this variable is to check if the user selected any record, the top validation is for the user has not select any subproject site
                    haveRecordsToRemove = true;
                }
            }
        } else {
            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, 'No CMF record(s) selected!')); 
            isValid = false;
        }
        //show an error if the user did not select any cmf records
        if (haveRecordsToRemove == false) { 
            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, 'No CMF record(s) selected!')); 
            isValid = false;
        } else {
            //join the value with comma delimited
            List<String> finalList = new List<String>(uniqueCMF);
            subSite.CMF_Numbers__c = String.join(finalList, ',');
            try 
            { update subSite; }
            catch (Exception ex) 
            {
                ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, ex.getMessage())); 
                isValid = false;
            }
        }
    }
    
    public Boolean checkCMFToBeRemove(String CMFName)
    {
        //this function will validate the cmf record if it is to be removed in the list
        Boolean result = false;
        for(CMFWrapper c : cmfList)
        {
            if (c.isSelected == true && c.CMFName == CMFName) {
                result = true;
            }
        }
        return result;
    }
    
    public class CMFWrapper
    {
        public Boolean isSelected { get; set; }
        public String CMFName { get; set; }
    }
}