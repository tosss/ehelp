public virtual class ALL_ComponentBase_Controller 
{
    public String key
    { 
        get;
        set
        {
            if(value != null)
            {
                Key  = value;
                if(pageController != null)
                    pageController.setComponentControllerMap(Key, this);
            }
        }
    }
    
    public ALL_PageBase_Controller pageController 
    { 
        get; 
        set 
        {                                                  
            if (value != null) 
            {                
                pageController = value;
                pageController.setComponentController(this);
            }
        }
    }
    
    public virtual void somethingIsSelected(String parentName,String childName, String parentSelectedId, String childSelectedId)
    {
        
    }
    
    public virtual PageReference childProcessingComplete(Boolean withChanges)
    {
        return null;
    }
}