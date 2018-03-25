/*------------------------------------------------------------
Author: Kimiko Roberto
Company: Cloud Sherpas
Description: Controller for IMP_DisplayMission that gets Mission Name parameter and formats it to JSON
             the passed JSON content will be used by the NIS org and displays a Mission record
             if there is a matching record.
Test Class:
History
09/25/14    Kimiko Roberto      Created

------------------------------------------------------------*/
public class IMP_DisplayMission_Controller{
    //set parameters that will be used by the NIS Mission
    public String generateJsonParam1{get;set;}
    public String param1 = '';        
    public String param2 {get;set;}
    public IMP_DisplayMission_Controller(){
        param2 = ApexPages.currentPage().getParameters().get('organizationId');
        generateJSONContent();
    }
    //Create JSON Content to be passed via the Canvas App to retrieve a view into the NIS Mission view page
    //First, we consume param1 from the currentpage.
    //Next, we instatiate the JSONGenerator object, and add the param1 key/value pair to it
    //The JSON is passed & utilized by the NIS org, making it possible to view the Mission stored in NIS environment in our own environment
    public void generateJSONContent(){
        
        param1 = ApexPages.currentPage().getParameters().get('param1');
        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject();
        gen.writeStringField('param1',param1);
        gen.writeEndObject();
        
        generateJsonParam1 = gen.getAsString();
        
        
    }
    
}