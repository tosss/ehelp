public with sharing class IMP_TestFactoryTemporary_Helper 
{
    /*
    public static final String LITERAL_DASH_SMALL_AUTO = 'Dash - Small Auto';
    public static final String LITERAL_DMS_AGNOSTIC_APP_SHARED = 'DMS Agnostic APP - Shared';
    public static final String LITERAL_DRIVE_BASELINE = 'Drive - Baseline';
    public static final String LITERAL_LIGHTSPEED_POWERSPORTS = 'Lightspeed - Powersports';
    public static final String LITERAL_PFW_HEAVY_EQUIPMENT = 'PFW - Heavy Equipment';
    public static final String LITERAL_ADD_ON = 'Add-on';
    public static final String LITERAL_BUY_SELL = 'Buy/Sell';
    public static final String LITERAL_UNHOOK = 'Unhook';
    public static final String LITERAL_UPGRADE = 'Upgrade';
    
    public enum Enum_MarketList { 
        DASH_SMALL_AUTO, 
        DMS_AGNOSTIC_APP_SHARED, 
        DRIVE_BASELINE, 
        LIGHTSPEED_POWERSPORTS, 
        PFW_HEAVY_EQUIPMENT, 
        MANUAL_INPUT_OF_DEFAULT_VALS 
    }
    
    public enum Enum_ProjectTypeList {
        ADD_ON,
        BUY_SELL,
        UNHOOK,
        UPGRADE,
        MANUAL_INPUT_OF_DEFAULT_VALS
    }
    public enum Enum_AutoSaveTimers {
        AUTO_SAVE,
        MANUAL_INPUT_OF_DEFAULT_VALS
    }
    /*-----IMPLEMENTATION DISCOVERY OBJECT REFERENCES------*/
    
   /* public static Question_Category__c buildDealershipNeed() {
        Question_Category__c dealershipNeeded = new Question_Category__c();
        dealershipNeeded.Name = 'Test Dealership';
        dealershipNeeded.Active__c = true;
        return dealershipNeeded;
    }
    
    public static Solution__c buildSolution(Id dealershipNeededId) {
        Solution__c solution = new Solution__c();
        solution.Name = 'Test Solution';
        solution.Question_Category__c = dealershipNeededId;
        solution.Active__c = true;
        return solution;
    }
    
    public static Product__c buildProduct(Id solutionId) {
        Product__c product = new Product__c();
        product.Name = 'Test Product';
        product.Solution__c = solutionId;
        return product;
    }
    public static Site_Product__c buildSiteProduct(Id subProjectSiteId, Id productId, Id subProjectId)
    {
        Site_Product__c siteProduct = new Site_Product__c();
        siteProduct.SubProjectSite__c = subProjectSiteId;
        siteProduct.Product__c = productId;
        siteProduct.SubProject__c = subProjectId;
        return siteProduct;
    }
    public static Site_Workbook__c buildSiteWorkbook(Id projectId, Id subProjectId) {
        Site_Workbook__c siteWorkbook = new Site_Workbook__c();
        siteWorkbook.SubProject__c = subProjectId;
        siteWorkbook.Project__c = projectId;
        return siteWorkbook;
    }

    public static Discovery_Workbook_Category__c buildDiscoveryWorkbookCategory(Id dealershipNeedId) {
        Discovery_Workbook_Category__c dwc = new Discovery_Workbook_Category__c();
        dwc.Question_Category__c = dealershipNeedId;
        return dwc;
    }

    public static Discovery_Question_Product__c buildDiscoveryQuestionProduct(Id productId, Id questionId) {
        Discovery_Question_Product__c dqp = new Discovery_Question_Product__c();
        dqp.Product__c = productId;
        dqp.Question__c = questionId;
        return dqp;
    }
    
    public static Discovery_Question_Category__c buildDiscoveryQuestionCategory(Id questionId, Id questionCategoryId) {
        Discovery_Question_Category__c dqc = new Discovery_Question_Category__c();
        dqc.Discovery_Question__c = questionId;
        dqc.Question_Category__c = questionCategoryId;
        return dqc;
    }
    
    
    
    public static Question__c buildQuestion(Enum_MarketList em, Enum_ProjectTypeList ep) {
        Question__c q = new Question__c();
        q.Question_Text__c = 'Test Question';
        q.Order__c = 'Order';
        q.Answer_Type__c = 'Text';

        if (em == Enum_MarketList.DASH_SMALL_AUTO) {
            q.Market__c = LITERAL_DASH_SMALL_AUTO;
        } else if (em == Enum_MarketList.DMS_AGNOSTIC_APP_SHARED) {
            q.Market__c = LITERAL_DMS_AGNOSTIC_APP_SHARED;
        } else if (em == Enum_MarketList.DRIVE_BASELINE) {
            q.Market__c = LITERAL_DRIVE_BASELINE;
        } else if (em == Enum_MarketList.LIGHTSPEED_POWERSPORTS) {
            q.Market__c = LITERAL_LIGHTSPEED_POWERSPORTS;
        } else if (em == Enum_MarketList.PFW_HEAVY_EQUIPMENT) {
            q.Market__c = LITERAL_PFW_HEAVY_EQUIPMENT;
        } else if (em == Enum_MarketList.MANUAL_INPUT_OF_DEFAULT_VALS) {
            q.Market__c = '';
        }

        if (ep == Enum_ProjectTypeList.ADD_ON) {
            q.Project_Type__c = LITERAL_ADD_ON;
        } else if (ep == Enum_ProjectTypeList.BUY_SELL) {
            q.Project_Type__c = LITERAL_BUY_SELL;
        } else if (ep == Enum_ProjectTypeList.UNHOOK) {
            q.Project_Type__c = LITERAL_UNHOOK;
        } else if (ep == Enum_ProjectTypeList.UPGRADE) {
            q.Project_Type__c = LITERAL_UPGRADE;
        } else if (ep == Enum_ProjectTypeList.MANUAL_INPUT_OF_DEFAULT_VALS) {
            q.Project_Type__c = '';
        }

        //q.Question_Category__c = dealershipNeededId;
        return q;
    }

    public static Answer__c buildAnswer(Id questionId) {
        Answer__c a = new Answer__c();
        //a.Discovery_Workbook_Category__c = discoveryWkbkCategory;
        a.Question__c = questionId;
        a.Text_Answer__c = 'Test Answer';
        return a;
    }
    public static IMP_AutoSaveTimers__c buildAutoSaveTimerItem(Enum_AutoSaveTimers csda) {
        IMP_AutoSaveTimers__c timer = new IMP_AutoSaveTimers__c();

        if (csda == Enum_AutoSaveTimers.AUTO_SAVE) {
            timer.Name     = 'Auto_Save';
            timer.Value__c = 60000;
        } else if (csda == Enum_AutoSaveTimers.MANUAL_INPUT_OF_DEFAULT_VALS) {
            timer.Name     = '';
            timer.Value__c = null;
        }

        return timer;
    }
    
    public static IMP_MarketList__c buildMarketListItem(Enum_MarketList csdm) {
        IMP_MarketList__c market = new IMP_MarketList__c();

        if (csdm == Enum_MarketList.DASH_SMALL_AUTO) {
            market.Name    = LITERAL_DASH_SMALL_AUTO;
            market.Text__c = LITERAL_DASH_SMALL_AUTO;
        } else if (csdm == Enum_MarketList.DMS_AGNOSTIC_APP_SHARED) {
            market.Name    = LITERAL_DMS_AGNOSTIC_APP_SHARED;
            market.Text__c = LITERAL_DMS_AGNOSTIC_APP_SHARED;
        } else if (csdm == Enum_MarketList.DRIVE_BASELINE) {
            market.Name    = LITERAL_DRIVE_BASELINE;
            market.Text__c = LITERAL_DRIVE_BASELINE;
        } else if (csdm == Enum_MarketList.LIGHTSPEED_POWERSPORTS) {
            market.Name    = LITERAL_LIGHTSPEED_POWERSPORTS;
            market.Text__c = LITERAL_LIGHTSPEED_POWERSPORTS;
        } else if (csdm == Enum_MarketList.PFW_HEAVY_EQUIPMENT) {
            market.Name    = LITERAL_PFW_HEAVY_EQUIPMENT;
            market.Text__c = LITERAL_PFW_HEAVY_EQUIPMENT;
        } else if (csdm == Enum_MarketList.MANUAL_INPUT_OF_DEFAULT_VALS) {
            market.Name    = '';
            market.Text__c = '';
        }

        return market;
    }

    public static IMP_ProjectTypeList__c buildProjectTypeItem(Enum_ProjectTypeList csdp) {
        IMP_ProjectTypeList__c product = new IMP_ProjectTypeList__c();

        if (csdp == Enum_ProjectTypeList.ADD_ON) {
            product.Name    = LITERAL_ADD_ON;
            product.Text__c = LITERAL_ADD_ON;
        } else if (csdp == Enum_ProjectTypeList.BUY_SELL) {
            product.Name    = LITERAL_BUY_SELL;
            product.Text__c = LITERAL_BUY_SELL;
        } else if (csdp == Enum_ProjectTypeList.UNHOOK) {
            product.Name    = LITERAL_UNHOOK;
            product.Text__c = LITERAL_UNHOOK;
        } else if (csdp == Enum_ProjectTypeList.UPGRADE) {
            product.Name    = LITERAL_UPGRADE;
            product.Text__c = LITERAL_UPGRADE;
        } else if (csdp == Enum_ProjectTypeList.MANUAL_INPUT_OF_DEFAULT_VALS) {
            product.Name    = '';
            product.Text__c = '';
        }

        return product;
    }
*/
}