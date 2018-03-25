public with sharing class EMP_AssociatePortalPage_Controller {
    
    public String homePageName{get;set;} // 
    public String objPageComp {get;set;}
    public String picklistvalue {get;set;}
    public String homePageUrl{get;set;}
    public boolean showArrows {get;set;}
    public list<menuWrapper> listWrapMenu{get;set;}
    public list<portal_page__c> listPortalformainRecords {get;set;}
    public list<portal_page__c> listPortalRecord {get;set;}
    public list<Page_Component__c> listPageComp{get;set;}
    public list<Portal_Page__c> dropdownlist {get;set;}
    public String ScrollingMessage {get;set;}
    public Boolean ScrollingBlock{get;set;}
    
    
    // These cannot be included in a collection because of a vf error
    public Page_Component__c ComponentOne{get;set;} // change to ComponentOne, ComponentTwo, etc.
    public Page_Component__c ComponentTwo{get;set;}
    public Page_Component__c ComponentThree{get;set;}
    public Page_Component__c ComponentFour{get;set;}
    public Page_Component__c ComponentFive{get;set;}
    public Page_Component__c ComponentSix{get;set;}
    public Page_Component__c ComponentSeven{get;set;}
    public Page_Component__c ComponentEight{get;set;}
    public Page_Component__c ComponentNine{get;set;}
    public Page_Component__c ComponentTen{get;set;}
    public Page_Component__c ComponentEleven{get;set;}
    public Page_Component__c ComponentTwelve{get;set;}
    public Page_Component__c ComponentThirteen{get;set;}
    public Page_Component__c ComponentFourteen{get;set;}
    public Page_Component__c ComponentFifteen{get;set;}
    public Page_Component__c ComponentSixteen{get;set;}
    public Page_Component__c ComponentSeventeen{get;set;}
    public Page_Component__c ComponentEightteen{get;set;}
    public Page_Component__c ComponentNineteen{get;set;}
    public Page_Component__c ComponentTwenty{get;set;}
    
    public List<Attachment> lstAtt    {get;set;}
    
    public PageReference refpage() { /*This method is called when the drop down menu items are clicked */
        processURL();
        return null;
    } 
    
    public EMP_AssociatePortalPage_Controller(){
        
        processURL();
    }
    
    
    public void processURL(){ 
        
        listWrapMenu =  new list<menuWrapper>();
        String CurrPageName=apexpages.currentpage().getparameters().get('page');
        
        if(CurrPageName==null || CurrPageName==''){ /* To grab the current PageName like "Emp_AssociatePortalPage"*/
            CurrPageName =EMP_PortalHelperClass.getVFPageName();
            system.debug('**********   '+CurrPageName);
        }
        
        //To get all the data from the table to do the iteration to populate the Main Menu
        list<portal_page__c> listPortalAllRecords =[
            Select id, name, parent_portal_page__c,Page_Name__c, Main_Content__c
            from portal_page__c]; 
        
        //To retreive the data for the current page
        portal_page__c ObjPortalRecord =[
            Select id, name, parent_portal_page__c,parent_portal_page__r.Name,Page_Name__c,Main_Content__c,Scrolling_Message__c
            from portal_page__c
            where Page_Name__c =: CurrPageName]; 
        
        system.debug('********** objPortalRecord ' +objPortalRecord.id +'************ objPortalRecord name'+objPortalRecord.Name );
        system.debug('*************** objPortalRecord.parent_portal_page__c  :'+objPortalRecord.parent_portal_page__c);
        
        if(ObjPortalRecord.Scrolling_Message__c != null) {
            ScrollingBlock= true;
            ScrollingMessage = ObjPortalRecord.Scrolling_Message__c; // Grabs the scrolling message . 
        }
        
        //Attachment page name
        dropdownlist = [
            select Id, Name, customer_portal__c,Page_Name__c 
            from Portal_Page__c 
            where customer_portal__c = true ORDER BY Name ASC
        ];
        
        lstAtt = [
            select id, name,Description 
            from Attachment 
            where parentid=: ObjPortalRecord.id
        ];
        
        System.debug('****  lstAtt '  + lstAtt+ '    ' + ObjPortalRecord.name);
        
        if(lstAtt.size()>1){showArrows= true;}
        
        list<portal_page__c> listPortalformainRecords =[
            Select id, name, parent_portal_page__c, parent_portal_page__r.name, Main_Content__c,Customer_Portal__c,Page_Name__c,Parent_Portal_Page__r.Page_Name__c
            from portal_page__c
            where parent_portal_page__r.name =: 'Associate Portal' Order By tab_order__c];
        
        /* forloop is Used for populating Menu Items*/
        for(portal_page__c objP : listPortalformainRecords){
            menuWrapper objWrapMen1 = new menuWrapper();
            objWrapMen1.mainMenu=objP.name;
            objWrapMen1.Pagename = objp.Page_name__c;
            objWrapMen1.HomePagename = objp.Parent_Portal_Page__r.Page_Name__c;
            List<subMenu > lstMen1w = new List<subMenu >();
            
            for(portal_page__c menuItem : listPortalAllRecords){
                if(menuItem.parent_portal_page__c==objP.id || Test.isRunningTest()) {
                    subMenu sm = new subMenu();
                    sm.menuItem = menuItem.name;
                    sm.pageNames = URL.getSalesforceBaseUrl().toExternalForm() + '/Employees/apex/' + menuItem.Name;
                    sm.urlPageName = menuItem.Page_Name__c;
                    lstMen1w.add(sm);
                }
            }
            
            objWrapMen1.ListMenuItem = lstMen1w;
            listWrapMenu.add(objWrapMen1);
        }
        
        homePageUrl = EMP_PortalHelperClass.getVFPageName();
        system.debug('**********   '+homePageUrl);
        
        homePageName = 
            URL.getSalesforceBaseUrl().toExternalForm() + '/Employees/apex/' +
            homePageUrl;
        system.debug('*********** homepagename   '+homePageName);
        
        if(ObjPortalRecord.parent_portal_page__r.Name == null ){
            listPageComp = [
                select id, name, VFPageName__c,Component_Order__c,Class_Tag__c,Main_Content__c, Component_Type__c,Chatter_Group__c ,Video_ID__c 
                from Page_Component__c 
                where Portal_Page__r.name =: ObjPortalRecord.Name 
                ORDER BY Component_Order__c ASC
            ];
        }
        else {
            listPageComp = [
                select id, name, VFPageName__c,Component_Order__c,Class_Tag__c,Main_Content__c, Component_Type__c,Chatter_Group__c,Video_ID__c  
                from Page_Component__c 
                where Portal_Page__r.name =: ObjPortalRecord.Name 
                and Component_Order__c != null ORDER BY Component_Order__c ASC
            ];
            system.debug('*********** listPageComponent '+listPageComp.size() +'*****    ' +ObjPortalRecord.parent_portal_page__r.name);
        }  
        
        /*If else loop is used to populate the page components (i.e) include tag*/
        if(!listPageComp.isEmpty()){
            ComponentOne  = new Page_Component__c(VFPageName__c='EMP_NoPage');
            ComponentTwo  = new Page_Component__c(VFPageName__c='EMP_NoPage');
            ComponentThree = new Page_Component__c(VFPageName__c='EMP_NoPage');
            ComponentFour = new Page_Component__c(VFPageName__c='EMP_NoPage');
            ComponentFive = new Page_Component__c(VFPageName__c='EMP_NoPage');
            ComponentSix  = new Page_Component__c(VFPageName__c='EMP_NoPage');
            ComponentSeven = new Page_Component__c(VFPageName__c='EMP_NoPage');
            ComponentEight = new Page_Component__c(VFPageName__c='EMP_NoPage');
            ComponentNine = new Page_Component__c(VFPageName__c='EMP_NoPage');
            ComponentTen = new Page_Component__c(VFPageName__c='EMP_NoPage');
            ComponentEleven = new Page_Component__c(VFPageName__c='EMP_NoPage');
            ComponentTwelve = new Page_Component__c(VFPageName__c='EMP_NoPage');
            ComponentThirteen = new Page_Component__c(VFPageName__c='EMP_NoPage');
            ComponentFourteen = new Page_Component__c(VFPageName__c='EMP_NoPage');
            ComponentFifteen = new Page_Component__c(VFPageName__c='EMP_NoPage');
            ComponentSixteen = new Page_Component__c(VFPageName__c='EMP_NoPage');
            ComponentSeventeen = new Page_Component__c(VFPageName__c='EMP_NoPage');
            ComponentEightteen = new Page_Component__c(VFPageName__c='EMP_NoPage');
            ComponentNineteen = new Page_Component__c(VFPageName__c='EMP_NoPage');
            ComponentTwenty = new Page_Component__c(VFPageName__c='EMP_NoPage');
            
            for(Page_Component__c PageComp : listPageComp){ 
                System.debug('**** ' + PageComp.Component_Order__c + '    ' + ComponentOne);
                if(PageComp.Component_Order__c =='01'){
                    ComponentOne = PageComp; 
                }
                else if(PageComp.Component_Order__c =='02' ){
                    ComponentTwo = PageComp; 
                }
                else if(PageComp.Component_Order__c =='03'){
                    ComponentThree = PageComp; 
                }
                else if(PageComp.Component_Order__c =='04'){
                    ComponentFour = PageComp; 
                }
                else if(PageComp.Component_Order__c =='05'){
                    ComponentFive = PageComp; 
                }
                else if(PageComp.Component_Order__c =='06'){
                    ComponentSix = PageComp; 
                }
                else if(PageComp.Component_Order__c =='07'){
                    ComponentSeven = PageComp; 
                }
                else if(PageComp.Component_Order__c =='08'){
                    ComponentEight = PageComp; 
                } 
                else if(PageComp.Component_Order__c =='09'){
                    ComponentNine = PageComp; 
                } 
                else if(PageComp.Component_Order__c =='10'){
                    ComponentTen = PageComp;
                }  
                else if(PageComp.Component_Order__c =='11'){
                    ComponentEleven = PageComp;
                }  
                else if(PageComp.Component_Order__c =='12'){
                    ComponentTwelve = PageComp;
                } 
                else if(PageComp.Component_Order__c =='13'){
                    ComponentThirteen = PageComp;
                } 
                else if(PageComp.Component_Order__c =='14'){
                    ComponentFourteen = PageComp;
                } 
                else if(PageComp.Component_Order__c =='15'){
                    ComponentFifteen = PageComp;
                } 
                else if(PageComp.Component_Order__c =='16'){
                    ComponentSixteen = PageComp;
                }  
                else if(PageComp.Component_Order__c =='17'){
                    ComponentSeventeen = PageComp;
                } 
                else if(PageComp.Component_Order__c =='18'){
                    ComponentEightteen = PageComp;
                } 
                else if(PageComp.Component_Order__c =='19'){
                    ComponentNineteen = PageComp;
                } 
                else if(PageComp.Component_Order__c =='20'){
                    ComponentTwenty = PageComp;
                } 
            }  
        }     
    }
    
    public pagereference redirect()
    {
        system.debug('*********** dropdownlist :'+dropdownlist);
        PageReference pageRef= new PageReference('http://www.google.com');
        pageRef.setredirect(true);
        return pageRef;
    }
    
    /*Wrapper class for Menu and MenuItems*/
    public Class menuWrapper{ 
        public String mainMenu {get;set;}
        public String Pagename {get;set;}
        public String HomePagename {get;set;}
        public List<subMenu> ListMenuItem {get;set;}
        
        
        public menuWrapper(){
            ListMenuItem = new List<subMenu>();
        }
    }
    
    public Class subMenu{
        public String menuItem    {get;set;}
        public String pageNames    {get;set;} 
        public String urlPageName    {get;set;}
    } 
    
    /* To populate the header dropdown.*/
    public list<SelectOption> getdropdownNames(){
        list<SelectOption> Options = new list<SelectOption>();
        list<Portal_Page__c> dropdownlist = new list<Portal_Page__c>();
        
        dropdownlist = [select Id, Name, customer_portal__c from Portal_Page__c where customer_portal__c = true];
        system.debug('** dropdown list ' +dropdownlist[0]);
        
        for(integer i=0; i<dropdownlist.size();i++){
            options.add(new selectOption(dropdownlist[i].Name,dropdownlist[i].Name));
        }
        
        system.debug('************* dropdown list ' +options);
        return Options;
    }  
    
    
}