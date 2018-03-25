public virtual class ALL_PageBase_Controller 
{
    private ALL_ComponentBase_Controller myComponentController; 
    
    private Map<String, ALL_ComponentBase_Controller>componentControllerMap; //new
    
    public virtual ALL_ComponentBase_Controller getMyComponentController() 
    {
        return myComponentController;
    }  
    
    //new getter for the hashmap
    public virtual Map<String, ALL_ComponentBase_Controller> getComponentControllerMap()
    { 
        return componentControllerMap;
    }
    //new method for putting value in the hashmap
    //storing multiple component
    public virtual void setComponentControllerMap(String key, ALL_ComponentBase_Controller compController)
    {
        if(componentControllerMap == null)
        {
            componentControllerMap = new Map<String, ALL_ComponentBase_Controller>();
        }
        componentControllerMap.put(key,compController); 
    }
   
    public virtual void setComponentController(ALL_ComponentBase_Controller compController) 
    {
        myComponentController = compController;
    }
    
    public ALL_PageBase_Controller getThis() 
    {
        return this;
    }
    
    public virtual void somethingIsSelected(String parentName,String childName, String parentSelectedId, String childSelectedId)
    {
        
    }
    
    public virtual PageReference childProcessingComplete(Boolean withChanges)
    {
        return null;
    }
    
    //21st May, 2015- Anirudh Singh
    public virtual void rerenderParentChildComponent()
    {
        
    }
}