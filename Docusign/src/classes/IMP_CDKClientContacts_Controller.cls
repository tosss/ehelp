/*------------------------------------------------------------
    Author:      Kimiko Roberto
    Company:     Cloud Sherpas
    Description: Controller for IMP_CDKClientContacts that creates a virtual table that contains all the subproject CDK and Client contacts
                    up to its child records from Milestone up to Tasks.
    Inputs:      
    Returns:     
    History
    03/05/2015     Kimiko Roberto    Created
    ------------------------------------------------------------*/
    public class IMP_CDKClientContacts_Controller
    {
        public Map<Id, List<IMP_Project_Utility.CDKClientContactsWrapper>> cdkContactsMap{get;set;}
        public Map<Id, List<IMP_Project_Utility.CDKClientContactsWrapper>> clientContactsMap{get;set;}
        public Id subProjectId;
        public Id subProjectIdKey {get;set;}

        
        public IMP_CDKClientContacts_Controller()
        {   
            //get the subproject Id included in the page's parameter
            subProjectId = ApexPages.currentPage().getParameters().get('id');
            
            Set<Id> subProjectIdSet = new Set<Id>();
            
            if(subProjectId != null)
            {
                subProjectIdSet.add(subProjectId);
            }
            
            if(subProjectIdSet != null && !subProjectIdSet.isEmpty())
            {
                //get the list of all CDK users from the subproject up to all of its child records from Milestone up to Tasks
                cdkContactsMap = IMP_Project_Utility.combineCDKContactsOrClientsBySubProject(subProjectIdSet, true);

                //get the list of all client Contacts from the subproject up to all of its child records from Milestone up to Tasks
                clientContactsMap = IMP_Project_Utility.combineCDKContactsOrClientsBySubProject(subProjectIdSet, false);

                if(cdkContactsMap != null && !cdkContactsMap.isEmpty())
                {
                    for(Id key : cdkContactsMap.keySet())
                    {
                        subProjectIdKey = key;
                    }
                        
                }
            }
            
        }

    }