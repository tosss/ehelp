//2017-01-16  ragashalini.koka@cdk.com - RQ-08462 - Created this class
//2017-04-12  lalitha.adduru@cdk.com - added a method to fetch the ID of BlackFlagImage  - RQ-08902
public class SLS_Top5List_Controller {
    
    private final static String OBJECT_NAME = 'Top_5__c';
    //List is used instead of Set to maintain the order
    public static List<String> viewIdList{get;set;}
    public static String nextPage {get;set;}
    public static String message{get;set;}
    public static Boolean hasPermission{get;set;}
    public static Boolean isPresent{get;set;}
    public static String nextPageName{get;set;}

    
    public SLS_Top5List_Controller() {
        try {
            
            String url = ApexPages.currentPage().getUrl();
            if(!url.contains('?')) {
                url += '?';
            }
            Apexpages.currentPage().getHeaders().put('X-UA-Compatible', 'IE=edge');
            String pageName = url.substringBetween('apex/', '?');
            String pageType;
            isPresent = false;
            hasPermission = false;
            viewIdList = new List<String>();
            
            if(pageName != null) {
                if(pageName.contains('Primary')) {
                    pageType = 'Primary';
                    nextPage = 'apex/SLS_Top5ListPage_Secondary?core.apexpages.request.devconsole=1';
                    nextPageName = 'View Secondary';
                }
                else if(pageName.contains('Secondary')) {
                    pageType = 'Secondary';
                    nextPage = 'apex/SLS_Top5ListPage_Primary?core.apexpages.request.devconsole=1';
                    nextPageName = 'View Primary';
                }
                
                getListViews(pageType);
                System.debug('viewIdList : ' + viewIdList);
                if(viewIdList.size() > 0) {
                    isPresent = true;
                }
                if(!hasPermission) {
                    message = 'You do not have access to this page. Please contact Sales Operations if you feel you should have access.';
                }
                else if(!isPresent) {
                    message = 'No List Views found. Please contact Sales Operations for additional information.';
                }
            }
        }
        catch(Exception exp) {
            System.debug('exp :' + exp.getLineNumber() + exp.getMessage());
        }
    }
    
    private void getListViews(String pageType) {
        String userType = getUserType(); 
        System.debug('user type : ' + userType );
        
        if(userType != null) {
            Top_5_Listview_Mappings__mdt top5ListMapping = [
                SELECT List_Views__c FROM Top_5_Listview_Mappings__mdt 
                WHERE User_Type__c = :userType AND Mapping_Type__c = :pageType
                LIMIT 1];
            
            if(top5ListMapping.List_Views__c != null && top5ListMapping.List_Views__c.length() > 0) {
                //removes extra spaces
                String listViews = top5ListMapping.List_Views__c.replaceAll(' ','');
               
                // List is used instead of Set to maintain the order
                List<String> viewNameList = new List<String>(listViews.split(','));
               
                List<ListView> viewList = [SELECT Id, DeveloperName FROM ListView WHERE SObjectType = :OBJECT_NAME AND DeveloperName IN :viewNameList];
                Map<String,String> nameToIdMap = new Map<String,String>();
                for(ListView view : viewList) {
                    nameToIdMap.put(view.DeveloperName, view.Id);
                }
               
                for(String viewName : viewNameList) {
                    viewIdList.add(nameToIdMap.get(viewName).substring(0,15));
                }
                
            
            }
            hasPermission = true;
        }
        
    }
    
    @RemoteAction
    public static String getBlackFlagImageId()
    {
        String blackFlagImageId = '';
        List<Document> blackFlagImage = [
            SELECT id 
            FROM Document WHERE DeveloperName='flag_finish_png'
        ];
        if(!blackFlagImage.isEmpty())
        {
            blackFlagImageId = blackFlagImage[0].Id;
        }
        return blackFlagImageId;
    }
    
    private static String getUserType() {
        User usr = [SELECT Id, Forecasting_Channel__c, Title FROM User WHERE Id = :UserInfo.getUserId()];
        String forecastingChannel = usr.Forecasting_Channel__c;
        String title = usr.Title;
        
        //if forecasting channel matches, returns the respective user type
        if(forecastingChannel != null) {
            
            if(forecastingChannel.equalsIgnoreCase('Digital Solutions')) {
                return 'Digital';
            }
            if(forecastingChannel.equalsIgnoreCase('Truck')){
                return 'Truck';
            }
            if(forecastingChannel.equalsIgnoreCase('Canada')) {
                return 'Canada';
            }
            
        }
        // if forecasting channel doesnot match, executes this block of code
        if(title != null) {
            
            if(title.endsWithIgnoreCase('ADE')) {
                return 'ADE';
            }
            else {
                return 'Core Non-ADE';
            }
        }
        
        return null;
    }
    
    
}