/*------------------------------------------------------------
Author:      Samuel Oberes
Company:     Cloud Sherpas
Description: Controller extension of ALL_DataTableComponent that handles records updating and following
Test Class:  ALL_DataTableComponent_Extension_Test
History
03/21/15     Samuel Oberes       Created
------------------------------------------------------------*/
global class ALL_DataTableComponent_Extension 
{

    private final ALL_DataTableComponent_Controller dataTableMainController;

    public Project_Task__c massUpdateTask { get; set; }
    public Boolean allowInlineEdit { get; set; }

    // generates a random number that can eventually act as a unique identifier for each instance of the component
    public Integer randomNumber 
    {
        get 
        {
            if (randomNumber == null) 
            {
                randomNumber = Math.round(Math.random() * 1000);
            }
            return randomNumber;
        }
        set;
    }

    public ALL_DataTableComponent_Extension(ALL_DataTableComponent_Controller ctrlParam) 
    {
        dataTableMainController = ctrlParam;
    }

    // ==============================================================================

    public Boolean isEdit { get; set; }
    public void edit() 
    {
        ApexPages.getMessages().clear();
        isEdit = true;
    }

    public void cancelEdit() 
    {
        ApexPages.getMessages().clear();
        isEdit = false;
    }

    public PageReference refreshPage() 
    {
        return null;
    }

    public PageReference saveAndClose() 
    {
        System.debug('\n\n*****[save]*****\n\n');
        
        ApexPages.getMessages().clear();
        try 
        {
            dataTableMainController.setCon.save();
            isEdit = false;
            
            for (ApexPages.Message apm : ApexPages.getMessages()) 
            {
                if (apm.getSeverity() == ApexPages.Severity.ERROR) 
                {
                    isEdit = true;
                    break;
                }
            }
        } 
        catch (Exception e)
        {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.severity.ERROR, 'Error while saving:\n ' + e.getMessage());
            ApexPages.addMessage(myMsg);
            System.debug('DBG: Save failed due to exception:\n' + e.getMessage());
            isEdit = true;
        }

        return null;
    }

    @RemoteAction
    global static String unFollowItem(String itemId) 
    {
        try 
        {
            EntitySubscription es = [SELECT Id FROM EntitySubscription WHERE ParentId = :itemId AND SubscriberId = :UserInfo.getUserId() LIMIT 1000];
            delete es;
            return itemId;
        } 
        catch(System.Exception ex)
        {
            system.debug(ex);
            return 'error';
        }

        return 'error';
    } 

    @RemoteAction
    global static String followItem(String itemId) 
    {
        try 
        {
            EntitySubscription es = new EntitySubscription(parentId = itemId, SubscriberId = UserInfo.getUserId());
            insert es;
            return itemId;
        } 
        catch(System.Exception ex)
        {
            system.debug(ex);
            return 'error';
        }

        return 'error';
    }  
}