@IsTest
public class DSCB_CloseAnything_Test {
	public static testmethod void InitializePageWithParentCase()
    {	
        // prepare records for testing
        Account a = DS_TestObjects.NewAccount_Inserted();
        Case ParentCase = DS_TestObjects.NewCase() ;       
        ParentCase.AccountId = a.Id; insert ParentCase;
        
        Case CloneCase = DS_TestObjects.NewCase();
        CloneCase.ParentId =ParentCase.id;insert CloneCase;
        Case CloneCase1 = DS_TestObjects.NewCase();
        CloneCase1.ParentId=ParentCase.id;insert CloneCase1;
        
        // test with invalid settings
        PageReference CloseAnythingPage = Page.DSCB_CloseAnything;
        CloseAnythingPage.getParameters().put('sourceid', ParentCase.Id);        
        Test.setCurrentPage(CloseAnythingPage);
        DSCB_CloseAnything CloseAnything = new DSCB_CloseAnything(); 
        CloseAnything.DestinationObjectsToClose();
    }
    
    public static testmethod void InitializePageWithCloneCase()
    {	
       // prepare records for testing
        Account a = DS_TestObjects.NewAccount_Inserted();
        Case ParentCase = DS_TestObjects.NewCase() ;       
        ParentCase.AccountId = a.Id; insert ParentCase;
        
        Case CloneCase = DS_TestObjects.NewCase();
        CloneCase.ParentId =ParentCase.id;insert CloneCase;
        Case CloneCase1 = DS_TestObjects.NewCase();
        CloneCase1.ParentId=ParentCase.id;insert CloneCase1;
        
        // test with invalid settings
        PageReference CloseAnythingPage = Page.DSCB_CloseAnything;
        CloseAnythingPage.getParameters().put('sourceid', CloneCase.Id);        
        Test.setCurrentPage(CloseAnythingPage);
        DSCB_CloseAnything CloseAnything = new DSCB_CloseAnything();
        CloseAnything.DestinationObjectsToClose();        
    }
    
   
     public static testmethod void CloseToSelected()
    {	
        // prepare records for testing
        List<ID> CloseIds= new List<ID>();
        
         Account a = DS_TestObjects.NewAccount_Inserted();
        Case ParentCase = DS_TestObjects.NewCase() ;       
        ParentCase.AccountId = a.Id; insert ParentCase;
        
        Case CloneCase = DS_TestObjects.NewCase();
        CloneCase.ParentId =ParentCase.id;insert CloneCase;
        CloseIds.add(CloneCase.id);
        Case CloneCase1 = DS_TestObjects.NewCase();
        CloneCase1.ParentId=ParentCase.id;insert CloneCase1;
        CloseIds.add(CloneCase1.id);
               
        DSCB_CloseAnything.CloseSObjectsParameters Parameters = new DSCB_CloseAnything.CloseSObjectsParameters();
        Parameters.Comments='Test Close';
        Parameters.SelectedEvent='Close';
        Parameters.CloseIds=CloneCase.id;
        
        DSCB_CloseAnything.CloseResult ClosingResult= DSCB_CloseAnything.CloseToSelected(Parameters);
        system.debug('ClosingResult='+ClosingResult);
        system.debug(ClosingResult.Results);       
    }
    
    public static testmethod void CloseToSelectedFail()
    {	
        // prepare records for testing
        List<String> CloseIds= new List<String>();
        
         Account a = DS_TestObjects.NewAccount_Inserted();
        Case ParentCase = DS_TestObjects.NewCase() ;       
        ParentCase.AccountId = a.Id; insert ParentCase;
        
        //get tier 2 content owner SF id
        Group GroupOwnerid=[select id from Group where name='Tier 2 - Content Queue' limit 1];
        
        Case CloneCase = DS_TestObjects.NewCase();
        CloneCase.ParentId =ParentCase.id;
        CloneCase.ownerid =GroupOwnerid.id;  
        CloneCase.status='Open';
        insert CloneCase;      
        
        
        system.debug('CloneCase='+CloneCase);
        
        CloseIds.add(CloneCase.id);
        Case CloneCase1 = DS_TestObjects.NewCase();
        CloneCase1.ParentId=ParentCase.id;
        CloneCase1.ownerid =GroupOwnerid.id;
        CloneCase1.status='Open';
        insert CloneCase1;
        CloseIds.add(CloneCase1.id);
               
        DSCB_CloseAnything.CloseSObjectsParameters Parameters = new DSCB_CloseAnything.CloseSObjectsParameters();
        Parameters.Comments='Test Close';
        Parameters.SelectedEvent='Close';
        Parameters.CloseIds=CloneCase.id;
        
        DSCB_CloseAnything.CloseResult ClosingResult= DSCB_CloseAnything.CloseToSelected(Parameters);
        System.assertEquals(ClosingResult.Success, true);
        system.debug('ClosingResult='+ClosingResult);
        system.debug(ClosingResult.Results);         
    }
    
}