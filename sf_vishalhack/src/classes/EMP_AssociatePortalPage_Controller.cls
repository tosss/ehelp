/*------------------------------------------------------------
Author:      Matt Keefe 
Company:     CDK Global
Description: Controller for EMP_AssociatePortalPage for CDK Employee Portal. 
Inputs: Dave Hanson     
Returns:     
History
8/3/2015     Vijay.Manimaran@cdk.com    Created
11/3/2015    Vijay.Manimaran@cdk.com    Updated -- Attachements from PageComponents and Mega menu logic. 
11/3/2015    Vijay.Manimaran@cdk.com    Updated -- Variable names Clean up . 
04/25/2016  Vijay.Manimaran@cdk.com     Updated -- PageComponent() and CheckSecurity() methods for portal security for each components. 
------------------------------------------------------------*/

public with sharing class EMP_AssociatePortalPage_Controller {
    
    public map<string, string> CommunityHomeOptions {get;set;}
    public String SelectedCommunityHome {get;set;}
    public list<Page_Component__c> CarouselPageComponents {get;set;}
    public list<Page_Component__c> PageComps {get;set;}
    public String ScrollingMessage {get;set;}
    public String TabName;
    public String PortalPageName;
    public list<String> MenuItemNames {get;set;} 
    public list<Node> MainNav {get;set;}
    
    public Tree MenuStructure ;
    
    // These cannot be included in a collection because of a vf error
    // change to ComponentOne, ComponentTwo, etc.
    public Page_Component__c ComponentZero{get;set;}
    public Page_Component__c ComponentOne{get;set;} 
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
    
    public Boolean showComponentZero{get;set;}
    public Boolean showComponentOne{get;set;} 
    public Boolean showComponentTwo{get;set;}
    public Boolean showComponentThree{get;set;}
    public Boolean showComponentFour{get;set;}
    public Boolean showComponentFive{get;set;}
    public Boolean showComponentSix{get;set;}
    public Boolean showComponentSeven{get;set;}
    public Boolean showComponentEight{get;set;}
    public Boolean showComponentNine{get;set;}
    public Boolean showComponentTen{get;set;}
    public Boolean showComponentEleven{get;set;}
    public Boolean showComponentTwelve{get;set;}
    public Boolean showComponentThirteen{get;set;}
    public Boolean showComponentFourteen{get;set;}
    public Boolean showComponentFifteen{get;set;} 
    public Boolean showComponentSixteen{get;set;}
    public Boolean showComponentSeventeen{get;set;}
    public Boolean showComponentEightteen{get;set;}
    public Boolean showComponentNineteen{get;set;}
    public Boolean showComponentTwenty{get;set;} 
      
    public EMP_AssociatePortalPage_Controller(){
        


        SelectedCommunityHome = 'US'; //default
        
        String HomeParameter = apexpages.currentpage().getparameters().get('home');
        if(HomeParameter != null && HomeParameter.trim() != ''){ 
            SelectedCommunityHome = HomeParameter;
        }
        
        TabName = apexpages.currentpage().getparameters().get('page');
        
        if(TabName == null || TabName == ''){
            PortalPageName = SelectedCommunityHome;
        }
        else{
            PortalPageName= TabName;
        }
        
        map<Id, Node> MainNavForSelectedRoot = getAllNodes();
        MainNav = MainNavForSelectedRoot.values();
    }
    
    // Wrapper class for the Menu 
    public Class HeaderMenuWrapper{ 
        public String MainMenuLabel {get;set;}
        public String mainMenuRecordType {get;set;}
        public List<SubMenuLabel> SubMenuLabels {get;set;}
        
        public HeaderMenuWrapper(){
            SubMenuLabels = new  List<SubMenuLabel>();
        } 
    }
    
    public Class SubMenuLabel{
        public String subMenuHeader {get;set;}
        public String menuIte1    {get;set;}
        
        public List<Portal_Menu__c> PortalSubMenuLabels {get;set;}
        public SubMenuLabel(){
            PortalSubMenuLabels = new  List<Portal_Menu__c>();
            
        }
    }
    
    // To Populate Data on Tabs
    public list<Node> populateNodeList(map<id, Node> subTrees){
        system.debug('@Developer --> subtree values'+subTrees.values());
        return subTrees.values();
    }
    
    public map<id, Node> getAllNodes(){
        
        list<Portal_Menu__c> MenuItems = new list<Portal_Menu__c>([
            Select Id, Name, RecordType.Name, Order__c, Label__c, Portal_Menu__c, 
            Portal_Page__c, URL__c, Style_Class__c, Portal_Page__r.Name, Portal_Menu__r.Name
            from Portal_Menu__c where RecordType.Name != 'Stand Alone'  Order By Order__c 
        ]); 
        
        MenuStructure = new Tree();
        MenuStructure.sObjectParentField = 'Portal_Menu__c';
        MenuStructure.AddListAndSort(MenuItems,'Order__c');
        //   system.debug('@developer ---> MenuStructire  '+MenuStructure);
        
        String SelectedMenuItemId = null;
        String ComponentOrder = null;
        CommunityHomeOptions = new map<string, string>();
        
        MenuItemNames = new list<String>();
        for(Portal_Menu__c item : MenuItems)
        {
            if(item.Name==SelectedCommunityHome) { 
                SelectedMenuItemId=item.id; 
            } 
            
            //For community home select options on Main menu
            if(item.Recordtype.Name == 'Portal Home')
            {
                CommunityHomeOptions.put(item.Name,item.URL__c);
                MenuItemNames.add(item.name);
                system.debug('@developer-->  MenuItemNames'+MenuItemNames);
            }
        }
        
        //list<Node> DropDownMenu = new list<Node>();
        map<Id, Node> Roots = MenuStructure.Roots;
        
        PageComponent(SelectedMenuItemId, Roots.get(SelectedMenuItemId).SubTrees);
        // system.debug('@Developer ---> 133'+Roots.get(ComponentOrder).SubTrees.keyset());
        map<Id, Node> subTrees = Roots.get(SelectedMenuItemId).SubTrees;
        return subTrees;
    
    }
    
    
    // Grab data from the Page components for the respective portal pages. 
    public void PageComponent(String ID, map<Id, Node> Roots)
    {
        system.debug('@Developer ---> PortalPageName ' +PortalPageName);

        Portal_Page__c PortalPage = [
            SELECT Id, Name, Parent_Portal_page__c, Parent_Portal_Page__r.Name, Page_Name__c, Scrolling_Message__c
            FROM Portal_Page__c 
            WHERE Id IN
            (
                Select Portal_Page__c 
                from Portal_Menu__c 
                where Name =: PortalPageName 
            )
        ];
        
        system.debug('******** portal page records.. ' +PortalPage.Name);
        
        // Grabs the Attachement from pagecomponents for every respective portal page   
        list<Page_Component__c> CarouselPageComponentList = [
            SELECT Id, Name, Main_Content__c, Recordtype.Name, Component_Order_Picklist__c, Custom_Style__c,Is_security_required__c,Security_Type__c,Error_Message__c,Idea_ID__c,
                (Select Id, ParentId From Attachments Limit 1)
            FROM Page_Component__c 
            where Parent_Component__r.Portal_Page__c=: PortalPage.id 
            ORDER BY Component_Order_Picklist__c
        ];
        
        CarouselPageComponents = new List<Page_Component__c>();
        
        for(Page_Component__c pc : CarouselPageComponentList) {
        	if(pc.Attachments.size() > 0) {
        		CarouselPageComponents.add(pc);
        	}
        }
        
        if(PortalPage.Scrolling_Message__c != null) 
        {
            // Grabs the scrolling message
            ScrollingMessage = PortalPage.Scrolling_Message__c; 
        }
        
        PageComps = [
            Select id, name, VFPageName__c, Main_Content__c, Chatter_Group__c, Video_ID__c,RecordType.Name,Component_Order_Picklist__c,Custom_Style__c,Idea_ID__c,
            Is_security_required__c,Security_Type__c,Error_Message__c
            From Page_Component__c
            Where Portal_Page__r.name = : PortalPage.Name
            And Component_Order_Picklist__c != null 
            ORDER BY Component_Order_Picklist__c ASC
        ];
        
        system.debug('********** components size '+pageComps.size());
        //If else loop is used to populate the page components (i.e) include tag
        if(!PageComps.isEmpty()){
            ComponentZero = new  Page_Component__c(VFPageName__c='EMP_NoPage');
            ComponentOne = new Page_Component__c(VFPageName__c='EMP_NoPage');
            ComponentTwo = new Page_Component__c(VFPageName__c='EMP_NoPage');
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
            
            
            for (Page_Component__c PageComp: PageComps) {
                System.debug('**** ' + PageComp.Component_Order_Picklist__c + '    ' + ComponentOne);
                if (PageComp.Component_Order_Picklist__c == '01') {
                    ComponentOne = PageComp;
                    showComponentOne = CheckSecurity(PageComp);
                } else if (PageComp.Component_Order_Picklist__c == '02') {
                    ComponentTwo = PageComp;
                    showComponentTwo = CheckSecurity(PageComp);
                } else if (PageComp.Component_Order_Picklist__c == '03') {
                    ComponentThree = PageComp;
                    showComponentThree = CheckSecurity(PageComp);
                } else if (PageComp.Component_Order_Picklist__c == '04') {
                    ComponentFour = PageComp;
                    showComponentFour = CheckSecurity(PageComp);
                } else if (PageComp.Component_Order_Picklist__c == '05') {
                    ComponentFive = PageComp;
                    showComponentFive = CheckSecurity(PageComp);
                } else if (PageComp.Component_Order_Picklist__c == '06') {
                    ComponentSix = PageComp;
                    showComponentSix = CheckSecurity(PageComp);
                } else if (PageComp.Component_Order_Picklist__c == '07') {
                    ComponentSeven = PageComp;
                    showComponentSeven = CheckSecurity(PageComp);
                } else if (PageComp.Component_Order_Picklist__c == '08') {
                    ComponentEight = PageComp;
                    showComponentEight = CheckSecurity(PageComp);
                } else if (PageComp.Component_Order_Picklist__c == '09') {
                    ComponentNine = PageComp;
                    showComponentNine = CheckSecurity(PageComp);
                } else if (PageComp.Component_Order_Picklist__c == '10') {
                    ComponentTen = PageComp;
                    showComponentTen = CheckSecurity(PageComp);
                } else if (PageComp.Component_Order_Picklist__c == '11') {
                    ComponentEleven = PageComp;
                    showComponentEleven = CheckSecurity(PageComp);
                } else if (PageComp.Component_Order_Picklist__c == '12') {
                    ComponentTwelve = PageComp;
                    showComponentTwelve = CheckSecurity(PageComp);
                } else if (PageComp.Component_Order_Picklist__c == '13') { 
                    ComponentThirteen = PageComp;
                    showComponentThirteen = CheckSecurity(PageComp);
                } else if (PageComp.Component_Order_Picklist__c == '14') {
                    ComponentFourteen = PageComp;
                    showComponentFourteen = CheckSecurity(PageComp);
                } else if (PageComp.Component_Order_Picklist__c == '15') {
                    ComponentFifteen = PageComp;
                    showComponentFifteen = CheckSecurity(PageComp);
                } else if (PageComp.Component_Order_Picklist__c == '16') {
                    ComponentSixteen = PageComp;
                    showComponentSixteen = CheckSecurity(PageComp);
                } else if (PageComp.Component_Order_Picklist__c == '17') {
                    ComponentSeventeen = PageComp;
                    showComponentSeventeen = CheckSecurity(PageComp);
                } else if (PageComp.Component_Order_Picklist__c == '18') {
                    ComponentEightteen = PageComp;
                    showComponentEightteen = CheckSecurity(PageComp);
                } else if (PageComp.Component_Order_Picklist__c == '19') {
                    ComponentNineteen = PageComp;
                    showComponentNineteen = CheckSecurity(PageComp);
                } else if (PageComp.Component_Order_Picklist__c == '20') {
                    ComponentTwenty = PageComp;
                    showComponentTwenty = CheckSecurity(PageComp);
                }else if (PageComp.Component_Order_Picklist__c == '00') {
                    ComponentZero = PageComp;
                    showComponentZero = CheckSecurity(PageComp);
                }
            } 
        }
    }
        
  public Boolean CheckSecurity(Page_Component__c PageComp) 
    {
    	if(PageComp.Is_security_required__c == true && PageComp.Security_Type__c == 'Chatter Group'){
        	return ALL_ChatterUtility.CollaborationGroupMember(pageComp.Chatter_Group__c);
        }else{
          return false;
    	} 
    }  
    
}