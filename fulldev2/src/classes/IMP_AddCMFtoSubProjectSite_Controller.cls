/*------------------------------------------------------------
Author: Rey Austral
Company: Cloud Sherpas
Description: add cmf record in the cmf number(s) field in the subproject site
Test Class: IMP_AddCMFtoSubProjectSite_Test
History
02/06/15    Rey Austral         Created
12/16/15    Venkata Shrivol		added a empty check for the existingSite variable.  
------------------------------------------------------------*/
public class IMP_AddCMFtoSubProjectSite_Controller {
    public List<SelectOption> siteOptions { get; set; }
    public List<CMFWrapper> cmfList { get; set; }
    public String selectedSite { get;  set; }    
    public Boolean isValid { get; set; }
    public IMP_AddCMFtoSubProjectSite_Controller()
    {
        isValid = true;
        String subprojectId = ApexPages.currentPage().getParameters().get('id');
        //populate the Subproject select list
        List<SubProjectSite__c> listSubproject = [Select Id, Name, Account__c,Account__r.Name From SubProjectSite__c where subproject__c =:  subprojectId];
        //create an option for the select list
        Map<String,String> optionsMap = new Map<String,String>();
        optionsMap.put('', '--None--');
        for (SubProjectSite__c site : listSubproject) {
            optionsMap.put(site.Id + ',' + site.Account__c, site.Name + ' - ' + site.Account__r.Name);
        }
        siteOptions = IMP_Project_Utility.buildSelectOption(optionsMap, false);
        siteOptions.sort();
        if (siteOptions.size() == 1) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, 'There is no existing site for this sub project, Please create a new site first.')); 
            
        }
    }
    
    public void getCMFInfo()
    {   
        ApexPages.getMessages().clear();
        cmfList = new List<CMFWrapper>();
        if (selectedSite != '' && selectedSite != null) {
            List<String> ids = selectedSite.split(',');
            //get records in the cmf_info__c object, filter by the account of the selected subproject site and has a status of A
            List<CMF_Info__c> listCmf = [Select Id,Name,Ship_CMF__c from CMF_Info__c where Account__c =: ids[1] and Status__c = 'A' ];
            list<SubProjectSite__c> retrieveSiteList = [Select Id,Name,CMF_Numbers__c from SubProjectSite__c where Id =: ids[0] limit 1];
            SubProjectSite__c existingSite = retrieveSiteList.size() > 0 ? retrieveSiteList[0] : new SubprojectSite__c();
            //prepare all the cmf, populate it in a set list
            Set<String> setCMFNumbers = New Set<String>(IMP_Project_Utility.parseDelimitedString(existingSite.CMF_Numbers__c,',',false)); 
            Set<String> setCMF = new Set<String>();  
            for (CMF_Info__c cmf : listCmf)
            {
                setCMF.add(cmf.Ship_CMF__c);
            }
            //remove any duplicate cmf with the current cmf in the subproject site versus the cmf in the cmfInfo object
            Set<String> setUniqueCMF =  IMP_Project_Utility.getUniqueElementsOfSetOne(setCMF,setCMFNumbers);
            
            if (setUniqueCMF.size() == 0) {
                ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, 'You already have added all CMFs associated with this account to the site.  Please either select a different site, or exit by clicking the ‘Cancel button’'));
            }  else
            {
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
        //check first if the user have selected an CMF
        if (selectedSite != '' && selectedSite != null) {
            Boolean haveSelectedCMF = false;
            List<String> ids = selectedSite.split(',');
            //get existing cmf_numbers
            List<SubProjectSite__c> listSubprojectSite = [Select Id,Name,CMF_Numbers__c from SubProjectSite__c where Id =: ids[0] ];
            for (SubProjectSite__c site : listSubprojectSite)
            {
                //this function will remove any duplicate in the list
                Set<String> uniqueCMF = new Set<String>();
                if (site.CMF_Numbers__c != null) {
                    List<String> lstCMFNumbers =  IMP_Project_Utility.parseDelimitedString(site.CMF_Numbers__c,',',false);                
                    for (String cmf : lstCMFNumbers) {
                        uniqueCMF.add(cmf);
                    }
                }
                //add the new selected cmf record
                for(CMFWrapper c: cmfList)
                {
                    if(c.isSelected) { 
                        uniqueCMF.add(c.CMFName);
                        haveSelectedCMF = true;
                    }  
                }
                
                List<String> finalList = new List<String>(uniqueCMF);
                //join all the records
                site.CMF_Numbers__c = String.join(finalList, ',');
            }
            if (haveSelectedCMF) {
                try 
                {
                    //update the list
                    update listSubprojectSite;
                }catch (Exception ex) 
                {
                    ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, ex.getMessage())); 
                    isValid = false;
                }
            } else {
                ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, 'No CMF record selected!')); 
                isValid = false;
            }
        }else 
        {
            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, 'No CMF record selected!')); 
            isValid = false;
        }
    }
    
    public class CMFWrapper
    {
        public Boolean isSelected { get; set; }
        public String CMFName { get; set; }
    }
}