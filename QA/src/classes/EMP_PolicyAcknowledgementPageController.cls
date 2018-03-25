public class EMP_PolicyAcknowledgementPageController {
    public String policy { get; set; }
    public ID selectedPolicy { get; set; }
    
    public Set<Id> cDoc = new Set<Id>();
    public Id usrID = userInfo.getUserId();
    public Map <Id, EMP_Policy__c> policyMap {get;set;}
    public List<EMP_Policy__c> policyList {get;set;}
    public List<EMP_Policy__c> policyAcknowList {get;set;}
    public List<EMP_Policy__c> policyNonAcknowList{get;set;}
    public Id policyID {get;set;}
    public Boolean showLink{get;set;}
    public Boolean showtable{get;set;}
    public Contact userContact {get;set;}

    
    public EMP_PolicyAcknowledgementPageController(){
        policyMap = new Map <Id, EMP_Policy__c>();
        policyAcknowList = new  List<EMP_Policy__c>();
        policyNonAcknowList = new List<EMP_Policy__c>();
        
        Contact userActiveContact = activeUserContact();
        try
        {
             if(userActiveContact != null) {
            policyList =[
                SELECT Acknowledgement_Status__c,
                Content_Version_ID__c,
                Date_of_Acknowledgement__c,
                Policy_Addition_Date__c,
                Name,
                VersionNumber__c
                FROM EMP_Policy__c
                WHERE Employee_Contact__c =: userActiveContact.Id
                ORDER BY Policy_Addition_Date__c DESC];
        }
           
        for(EMP_Policy__c Policy : PolicyList){
            if(Policy.Acknowledgement_Status__c == true){
                policyAcknowList.add(Policy);
                showtable= true;
            }else{
                policyNonAcknowList.add(Policy);
            }
        }
            
        }
        catch(exception e){
        }
       
    }
   
    public Contact activeUserContact() {
        Contact userContact = new Contact();
        try {
        	userContact = [
                SELECT id
                FROM Contact
                WHERE User__c =: usrID
                AND Status__c = 'Active'
                LIMIT 1
            ];
        }
        catch(Exception e) {
            return null;
        }
        return userContact;
    }
    
   public pageReference ContentLoad(){ 
        showlink = true;
        pageReference Pageref = new Pagereference('/Employees/sfc/servlet.shepherd/version/download/'+policyID);
        showlink=false;
        return PageRef;
        
    }
    public void acknowledge(){
        //this method will set the selected record as acknowledge
        List<EMP_Policy__c> updatePolicy = new List<EMP_Policy__c>();
        List<ContentVersion> cvList = new List<ContentVersion>();
        
        Contact userActiveContact = activeUserContact();
        if(userActiveContact != null) {
            for(EMP_Policy__c policy : [
                SELECT Acknowledgement_Status__c,
                Content_Version_ID__c,
                Date_of_Acknowledgement__c,
                Policy_Addition_Date__c,
                Name,
                VersionNumber__c
                FROM EMP_Policy__c
                WHERE Employee_Contact__c =: userActiveContact.Id
                AND Id =: policyID])
            { 
                if(policy.Acknowledgement_Status__c == false){
                    policy.Acknowledgement_Status__c = true;
                    policy.Date_of_Acknowledgement__c = dateTime.now();
                    updatePolicy.add(policy);
                }
            }
        }
        
        if(!updatePolicy.isEmpty() || updatePolicy.size()>0){       
            update updatePolicy;       
        } 
        
        if(userActiveContact != null) {
            policyList =[
                SELECT Acknowledgement_Status__c,
                Content_Version_ID__c,
                Date_of_Acknowledgement__c,
                Policy_Addition_Date__c,
                Name,
                VersionNumber__c
                FROM EMP_Policy__c
                WHERE Employee_Contact__c =: userActiveContact.Id 
                ORDER BY Policy_Addition_Date__c DESC];
        }
    }
}