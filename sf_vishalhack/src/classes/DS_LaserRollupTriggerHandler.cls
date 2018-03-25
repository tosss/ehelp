public class DS_LaserRollupTriggerHandler 
{   
        
    public static void RollupMethod(List<Laser_Ordered_Forms__c> NewList, List<Laser_Ordered_Forms__c> OldList)
    {
        //DS_LAO_SetFieldsBasedOnStatus.IsThisTrigger_LaserOrderForms = true;   
        
        if(Trigger.IsInsert || Trigger.IsUpdate) 
        {
            list<string> LaoIdList = new list<string> ();           
            
            for (Laser_Ordered_Forms__c l : NewList) 
            {
                LaoIdList.add(l.Laser_Artwork_Order__c);               
            }
            
            map<ID, Laser_Artwork_Order__c> laoMap;
            
            LaoMap = new map<ID, Laser_Artwork_Order__c>([
                select id, stock_Order_Total__c, Total_Number_of_Forms__c, LAO_Value__c,
                (select id, Laser_Artwork_Order__c, total__c, Quantity__c, Unit_Price__c, Unit_Price_Override__c,
                Catalog_Number__c, Catalog_Number__r.Exclude_from_SO_Total__c, 
                Catalog_Number__r.Exclude_from_Quote__c, Catalog_Number__r.Exclude_from_Total_Number_Of_Forms__c
                From Forms__r)
                From Laser_Artwork_Order__c 
                where id IN : LaoIdList
            ]);            
                     
            list<Laser_Ordered_Forms__c> LofList;
            
            for (Laser_Artwork_Order__c lao : LaoMap.Values()) 
            {
                LofList = new list<Laser_Ordered_Forms__c>();
                LofList = lao.Forms__r;
                
                for (integer i = 0; i < LofList.size(); i++) 
                {
                    if (LofList[i].Laser_Artwork_Order__c == lao.id) 
                    {
                        if (i == 0) 
                        {
                            LaoMap.get(LofList[i].Laser_Artwork_Order__c).Stock_Order_Total__c = 0;
                            LaoMap.get(LofList[i].Laser_Artwork_Order__c).Total_Number_of_Forms__c = 0;
                            LaoMap.get(LofList[i].Laser_Artwork_Order__c).LAO_Value__c = 0;
                        }                
                        
                        boolean Include_SoTotal_From_Catalog_number = true;
                        boolean Include_Quote_From_Catalog_Number = true;
                        boolean Include_Total_NumberOf_Forms_Catalog_Number = true;
                        
                        
                        Laser_Ordered_Forms_Catalog_Numbers__c CatalogNumberRecord = new Laser_Ordered_Forms_Catalog_Numbers__c();
                        //CatalogNumberRecord = LofCatalognumbersMap.get(LofList[i].Catalog_Number__c);
                        CatalogNumberRecord = LofList[i].Catalog_Number__r;
                        
                        system.debug(CatalogNumberRecord);
                        
                        if(CatalogNumberRecord != null)
                        {                            
                            if(LofList[i].Unit_Price_Override__c == null)
                            {
                                //getting Exclude_from_SO_Total__c field value from the catalog numbers object instead of laser order forms(
                                //Exclude_from_SO_Total__c is formula field in the laser order forms object)
                                if(CatalogNumberRecord.Exclude_from_SO_Total__c == true)
                                {
                                    Include_SoTotal_From_Catalog_number = false;
                                }
                            }
                            
                            if(CatalogNumberRecord.Exclude_from_Quote__c == true)
                            {
                                Include_Quote_From_Catalog_Number = false;
                            }
                            
                            if(CatalogNumberRecord.Exclude_from_Total_Number_Of_Forms__c == true)
                            {
                                Include_Total_NumberOf_Forms_Catalog_Number = false;
                            }
                            
                        }
                        
                        system.debug(Include_SoTotal_From_Catalog_number);
                        
                        LaoMap.get(LofList[i].Laser_Artwork_Order__c).Stock_Order_Total__c 
                            = LaoMap.get(LofList[i].Laser_Artwork_Order__c).Stock_Order_Total__c 
                            + (Include_SoTotal_From_Catalog_number == true ? LofList[i].total__c : 0);
                        
                        system.debug(LofList[i].total__c);
                        
                        LaoMap.get(LofList[i].Laser_Artwork_Order__c).Total_Number_of_Forms__c 
                            = LaoMap.get(LofList[i].Laser_Artwork_Order__c).Total_Number_of_Forms__c 
                            + (Include_Total_NumberOf_Forms_Catalog_Number == true ? LofList[i].Quantity__c : 0);
                        
                        LaoMap.get(LofList[i].Laser_Artwork_Order__c).LAO_Value__c 
                            = LaoMap.get(LofList[i].Laser_Artwork_Order__c).LAO_Value__c 
                            + (Include_Quote_From_Catalog_Number == true ? (LofList[i].Quantity__c * LofList[i].Unit_Price__c) : 0);
                    }
                }
            }
            
            
            try 
            {
                update LaoMap.values();
            } catch (DmlException e) 
            {
                for (Laser_Ordered_Forms__c l : NewList)
                    l.addError('There was an error updating the Laser Artwork Order. '
                         + 'Please go back to the the Laser Artwork Order parent record and re-save to correct the errors in that record. ');
            }
        }
        
        if (Trigger.IsDelete) 
        {
            list<string> LaoIds = new list<string> ();
            //set<ID> CatalogNumberIds = new set<ID>();
            
            if(OldList != null && !OldList.IsEmpty()) 
            {
                for (Laser_Ordered_Forms__c l : OldList) 
                { 
                    LaoIds.add(l.Laser_Artwork_Order__c);
                    //CatalogNumberIds.add(l.Catalog_Number__c);
                } 
            }
            
            map<ID, Laser_Artwork_Order__c> LaoMap;
            
            LaoMap = new map<ID, Laser_Artwork_Order__c>([
                select id, stock_Order_Total__c, Total_Number_of_Forms__c, LAO_Value__c,
                (select id, Laser_Artwork_Order__c, total__c, Quantity__c, Unit_Price__c, Unit_Price_Override__c,
                Catalog_Number__c, Catalog_Number__r.Exclude_from_SO_Total__c, 
                Catalog_Number__r.Exclude_from_Quote__c, Catalog_Number__r.Exclude_from_Total_Number_Of_Forms__c
                From Forms__r)
                From Laser_Artwork_Order__c 
                where id IN : LaoIds
            ]);           
            
            list<Laser_Ordered_Forms__c> LofList;
            
            for (Laser_Artwork_Order__c lao : LaoMap.values()) 
            {
                LofList = new list<Laser_Ordered_Forms__c> ();
                LofList = lao.Forms__r;
                
                for (integer i = 0; i < LofList.size(); i++) 
                {
                    if (LofList[i].Laser_Artwork_Order__c == lao.id) 
                    {
                        if (i == 0) 
                        {
                            LaoMap.get(LofList[i].Laser_Artwork_Order__c).Stock_Order_Total__c = 0;
                            LaoMap.get(LofList[i].Laser_Artwork_Order__c).Total_Number_of_Forms__c = 0;
                            LaoMap.get(LofList[i].Laser_Artwork_Order__c).LAO_Value__c = 0;
                        }
                        
                        boolean Include_SoTotal_From_Catalog_number = true;
                        boolean Include_Quote_From_Catalog_Number = true;
                        boolean Include_Total_NumberOf_Forms_Catalog_Number = true;
                        
                        Laser_Ordered_Forms_Catalog_Numbers__c CatalogNumberRecord = new Laser_Ordered_Forms_Catalog_Numbers__c();
                        //CatalogNumberRecord = LofCatalognumbersMap.get(LofList[i].Catalog_Number__c);
                        CatalogNumberRecord = LofList[i].Catalog_Number__r;
                        
                        if(CatalogNumberRecord != null)
                        {
                            if(LofList[i].Unit_Price_Override__c == null)
                            {
                                //getting Exclude_from_SO_Total__c field value from the catalog numbers object instead of laser order forms(
                                //Exclude_from_SO_Total__c is formula field in the laser order forms object)
                                if(CatalogNumberRecord.Exclude_from_SO_Total__c == true)
                                {
                                    Include_SoTotal_From_Catalog_number = false;
                                }
                            }
                            
                            if(CatalogNumberRecord.Exclude_from_Quote__c == true)
                            {
                                Include_Quote_From_Catalog_Number = false;
                            }
                            
                            system.debug(Include_SoTotal_From_Catalog_number);
                            
                            if(CatalogNumberRecord.Exclude_from_Total_Number_Of_Forms__c == true)
                            {
                                Include_Total_NumberOf_Forms_Catalog_Number = false;
                            }
                        }
                        
                        LaoMap.get(LofList[i].Laser_Artwork_Order__c).Stock_Order_Total__c 
                            = LaoMap.get(LofList[i].Laser_Artwork_Order__c).Stock_Order_Total__c 
                            + (Include_SoTotal_From_Catalog_number == true ? LofList[i].total__c : 0);
                        
                        system.debug(LofList[i].total__c);
                        
                        LaoMap.get(LofList[i].Laser_Artwork_Order__c).Total_Number_of_Forms__c 
                            = LaoMap.get(LofList[i].Laser_Artwork_Order__c).Total_Number_of_Forms__c 
                            + (Include_Total_NumberOf_Forms_Catalog_Number == true ? LofList[i].Quantity__c : 0);
                        
                        LaoMap.get(LofList[i].Laser_Artwork_Order__c).LAO_Value__c 
                            = LaoMap.get(LofList[i].Laser_Artwork_Order__c).LAO_Value__c 
                            + (Include_Quote_From_Catalog_Number == true ? (LofList[i].Quantity__c * LofList[i].Unit_Price__c) : 0);   
                    }
                }
            }            
            update LaoMap.values();
        }
    }
}