public with sharing class AngularJSDemoController2{ 
    
    public String AccountList { get; set; }
    public String sobjtype{get;set;}
    
           
    //Method to bring the list of Account and Serialize Wrapper Object as JSON
    public  String getlstAccount1() {
        List < sobject > lstacc = Database.query('select Id, Name from '+sobjtype+' limit 100');
        return JSON.serialize(lstacc);
     }
    
}