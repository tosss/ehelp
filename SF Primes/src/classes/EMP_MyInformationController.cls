/*RQ-04089 -line 7 : added fields to query *** Vijay Manimaran *** 2/25/2015 */
public class EMP_MyInformationController {
    public List<User> infoSource { get; set; }
    public list<contact> myInfoContact {get; set; }
    public EMP_MyInformationController() {
        infoSource = [
            Select 
            Id,Name ,
                (Select
                 FirstName,LastName,Title,Vendor_ID__c,Email,HR_Title__c,HR_Manager__r.Name,HR_Location__c,HR_Business_Unit__c 
                 from contacts__r) 
            from User 
            where Id = : UserInfo.getUserId()];
        myInfoContact =  new list<contact>();
        
        for (User u: infoSource) {
            if(u.contacts__r == null)continue;
            for (Contact cont : u.contacts__r) {
                myInfoContact.add(cont);
            }
        }
        
    }
}