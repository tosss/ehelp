trigger ALL_BrandRelationship on BrandRelationship__c (after insert, after update, before delete) 
{
    GlobalSettings__c gs = GlobalSettings__c.getInstance();  
    
    if(gs.BrandRelationship_Synch__c)
    {
        ALL_BrandRelationship_Handler.invokeMainMethod();
    }
}