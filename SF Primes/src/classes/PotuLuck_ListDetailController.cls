public class PotuLuck_ListDetailController 
{
    @AuraEnabled
    public static List<sobject> getPotuLuckDishes()
    {
        return [
            SELECT Id, Potluck_Attendee__r.Name__r.Name, PotLuck_Dish__r.Dish_Name__c, Quantity__c, Brought_By__c, Dish_Detailed_Name__c
            FROM Potluck_Dish_Selection__C 
            Order by CreatedDate desc
        ];
    }
    
    @AuraEnabled
    public static List<sobject> getALLDishes()
    {
        return [
            SELECT Id, Dish_Name__c,Is_Veg__c, Potluck_Dish_Category__r.Name, Quantity__c, Remaining_Quantity__c 
            FROM Potluck_Dish__C 
            Order by Dish_Name__c desc
        ];
    }
    
    @AuraEnabled
    public static List<sobject> getCurrentAttendeePotuLuckDishes()
    {
        return [
            SELECT Id, Potluck_Attendee__r.Name__r.Name, PotLuck_Dish__r.Dish_Name__c, Quantity__c, Brought_By__c, Dish_Detailed_Name__c 
            FROM Potluck_Dish_Selection__C 
            WHERE Potluck_Attendee__r.Name__c =: UserInfo.getUserId() 
            Order by CreatedDate desc
        ];
    }
    
    @AuraEnabled
    public static sobject getCurrentAttendee()
    {
        List<Potluck_Attendee__c> attendee = [
            SELECT Id, Name__r.Name, Vegeterian__c, Vehicle__c
            FROM Potluck_Attendee__c 
            WHERE Name__c =: UserInfo.getUserId() 
        ];
        if(attendee.size() != 0)
            return attendee[0];
        return null;
    }
    
    @AuraEnabled
    public static User getCurrentUser()
    {
        return [
            SELECT Id, Name, FirstName,LastName, Email, Profile.Name 
            FROM User 
            WHERE Id =: UserInfo.getUserId()
        ];   
    }
    
    @AuraEnabled
    public static sobject saveCurrentAttendee(Sobject attendee)
    {
        insert attendee;
        attendee = [
            SELECT Id, Name__r.Name, Vegeterian__c, Vehicle__c
            FROM Potluck_Attendee__c 
            WHERE Name__c =: UserInfo.getUserId() 
        ];
        return attendee;
    }
    
    
    @AuraEnabled
    public static Decimal getRemainingQuantity(Id pId,Integer reqQuantity)
    {
        Decimal remaining = [
            SELECT Remaining_Quantity__c
            FROM PotLuck_Dish__c 
            WHERE Id =: pId
        ].Remaining_Quantity__c;
        return remaining - reqQuantity;
    }
    
    @AuraEnabled
    public static sobject saveDishSelectionController(Sobject attendee)
    {
        Id attendeeId = (Id)attendee.get('Potluck_Attendee__c');
        attendee.put('Potluck_Attendee__c',[Select id from Potluck_Attendee__c where Name__c =: attendeeId].Id);
        insert attendee;
        attendee = [
            SELECT Id, PotLuck_Dish__c, Potluck_Attendee__c, Quantity__c
            FROM Potluck_Dish_Selection__c 
            WHERE Id =: attendee.Id
        ];
        return attendee;
    }
    
    @AuraEnabled
    public static List<sobject> getSearchList(String ObjectName, String NameField, String searchString)
    {
        return DataBase.query('Select Id,'+NameField+' from '+ObjectName+' where '+NameField+' like \'%'+searchString+'%\'  and Remaining_Quantity__c > 0');
    }
}