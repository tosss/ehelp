/*
--2/20/15 - Venkata Shrivol Created 

******Status of Entitlments****** 
Active = if (system date>=StartDate && system date<=EndDate)
Expired = if(system date>= EndDate)
Inactive if(system date<= StartDate)
******Status of Entitlments******
*/

public with sharing class CB_EntitlementsToWebIdAssignment_Handler 
{
	
	public static Boolean isFirstRun = true;
	
	//To Pass the Id of WebId object which are 'Active' on Insert
	public static void createEntitlementOnInsert(map<id,WebID__c> newMap )
	{
		map<id,WebID__c> insertMap = new map<id,WebID__c>();
		for(Id webId : newMap.keySet()){
			if(newMap.get(webId).Status__c == 'Active' || newMap.get(webId).Status__c == 'New'){
				insertMap.put(webId, newMap.get(webId));
			}
		}
		if(!insertMap.isEmpty()){
			createEntitlements(insertMap.keySet(), false); // To create Entitlements on Insert of WebId
		}
	}
	
	//To Pass the Id's of WebId object which are either updating their OEM's or 'Inactive'
	public static void createEntitlementOnUpdate(map<id,WebID__c> oldMap, map<id,WebID__c> newMap )
	{
		map<id,WebID__c> updateMap = new map<id,WebID__c>();
		map<id,WebID__c> closeMap = new map<id,WebID__c>();
		for(Id webId : newMap.keySet())
		{
			if(((oldMap.get(webId).Status__c != newMap.get(webId).Status__c) || (oldMap.get(webId).OEM__c != newMap.get(webId).OEM__c)) && 
               (((newMap.get(webId).Status__c == 'Active')||(newMap.get(webId).Status__c == 'New')) && ((oldMap.get(webId).Status__c == 'Inactive')||(oldMap.get(webId).Status__c == null)) ))
			{
				updateMap.put(webId, newMap.get(webId));
			}else if(((oldMap.get(webId).Status__c != newMap.get(webId).Status__c) || (oldMap.get(webId).OEM__c != newMap.get(webId).OEM__c)) && (newMap.get(webId).Status__c == 'Inactive'))
			{
				closeMap.put(webId, newMap.get(webId));
			}
		}
		if(!updateMap.isEmpty()){
		    createEntitlements(updateMap.keySet(), true); // Create Entitlments on Update of WebId
		    
		}
		if(!closeMap.isEmpty()){
		closeEntitlements(closeMap.keySet()); // Close Entitlements on Update of WebId
		}
	}
	
	@future
	public static void createEntitlements(set<id> webIds, boolean isUpdate)
	{
		map<id,WebID__c> mainWebIdMap = new map<id,WebID__c>([Select Id, Name, OEM__c, Account__c from WebID__c where Id in :webIds]);
		list<Entitlement> entLst = new list<Entitlement>(); // List to add/update Entitlements
		String oemType = '';
		set<String> removeDuplicateEprocessSet = new set<String>();
		map<String, SlaProcess> slaProcessMap = new map<String,SlaProcess>(); // SlaProcess - Entitlement Process
		
		/* Entitlement Process Map - Start */
		string slaProcQuery = 'Select id, BusinessHoursId, Name, isActive from SlaProcess where isActive = true ';
		list<SlaProcess_Settings__c> customSettings = SlaProcess_Settings__c.getAll().values(); //Custom settings for the entitlement processes name
		if(customSettings!=null && !customSettings.isEmpty())
		{
			for(SlaProcess_Settings__c slaSet :customSettings)
			{
				removeDuplicateEprocessSet.add(slaSet.EntitlementProcessName__c);
			} 
		}
		if(removeDuplicateEprocessSet!=null && !removeDuplicateEprocessSet.isEmpty())
		{
			slaProcQuery += 'and ('; 
		
            for(String s :removeDuplicateEprocessSet)
            {
                
                slaProcQuery += 'Name =\''+ s +'\' or ';
            }
		
			slaProcQuery = slaProcQuery.RemoveEnd(' or ');
			slaProcQuery += ')'; 
		}
		slaProcQuery += ' limit 20';
		system.debug('-----------Database Query------'+slaProcQuery);
		
		/*for(SlaProcess slaProc : [Select id, BusinessHoursId, Name, isActive from SlaProcess where isActive = true and IsVersionDefault = true and
		                         (Name = 'GM OEM Tech Support' or Name = 'Holden Tech Support' or Name = 'US Canada OEM Tech Support' 
							      or Name = 'Creative Support') limit 20])
        */
		for(SlaProcess slaProc: Database.Query(slaProcQuery)){
			slaProcessMap.put(slaProc.Name, slaProc);
		}
		
		
		system.debug('-----mainWebIdMap----'+mainWebIdMap);
		system.debug('-----slaProcessMap----'+slaProcessMap);
		/* Entitlement Process Map - End */
		
		
		Map<id,list<Entitlement>> entMap = new Map<id,list<Entitlement>>();
		for(Entitlement ent: [Select Id, Name, StartDate, EndDate, WebId__c from Entitlement where WebId__c in :WebIds]){
			list<Entitlement> webEntLst = entMap.containsKey(ent.WebId__c) ? entMap.get(ent.WebId__c) :  new list<Entitlement>();
			webEntLst.add(ent);
			entMap.put(ent.WebId__c, webEntLst);
		}
		system.debug('-------------entMap in Existing Section----------'+entMap);
		
		/* Entitlement Creation - Start */
		for(WebID__c webId : mainWebIdMap.values()){
			oemType = '';
            if(webId.OEM__c!=null)
            {
                if(SlaProcess_Settings__c.getInstance(webId.OEM__c)!=null)
                {
                    if(SlaProcess_Settings__c.getInstance(webId.OEM__c).EntitlementProcessName__c!=null)
                    {
                    	oemType = SlaProcess_Settings__c.getInstance(webId.OEM__c).EntitlementProcessName__c;
                	}
                }
            }
			system.debug('-----oemType---'+oemType);
			
			/* Exisiting Entitlements - Start; Not useful as of now, have to check with Cami */
			/* Only for Update - Start ; */
			list<Entitlement> webEntLst = entMap.containsKey(webId.id) ? entMap.get(webId.id) : new list<Entitlement>();
			if(webEntLst.size() > 0){
				for(Entitlement ent : webEntLst){
					if(ent.Name != oemType && ent.Name != 'Creative Support'){
						ent.endDate = date.Today();
						entLst.add(ent);
					}
				}
			}
			/* Only for Update - End*/
			/* Exisiting Entitlements - End */
            // For Creation of TechSupport Ent
            Entitlement techSupportEnt = createEnt(oemType,webid,slaProcessMap,'Technical Support');
			entLst.add(techSupportEnt);
            //For Creation of CreativeSupport Ent		
            Entitlement creativeSuppEnt = createEnt('Creative Support',webid,slaProcessMap,'Creative Support');
			entLst.add(creativeSuppEnt);
		}
		/* Entitlement Creation - End */
		system.debug('----entLst---'+entLst);
		try{
			Database.UpsertResult[] resultList = Database.upsert(entLst,false);
			system.debug(resultList);
		}
		catch(Exception ex){
			system.debug('----Exception-----'+ex);
		}
		
		if(isUpdate){
		//For Updating the cases if the WebID is turned to active again
		CB_EntitlementsToCaseAssignment_Handler.updateEntToCaseOnWebIdUpdate(webIds);
		}			
		
	}
    public static Entitlement createEnt(string oemType, WebID__c webId, Map<string,SlaProcess> slaProcessMap, string supportType)
    {
            Entitlement oemSupportEnt = new Entitlement();
			SlaProcess curOem = slaProcessMap.get(oemType);
			system.debug('----curOem----'+curOem);
			if(curOem != null)
            {
				oemSupportEnt.name = oemType;
				oemSupportEnt.AccountId = webId.Account__c;
				oemSupportEnt.BusinessHoursId = curOem.BusinessHoursId;
				oemSupportEnt.SlaProcessId = curOem.Id;
				oemSupportEnt.WebID__c = webid.Id;
				oemSupportEnt.Type = supportType;
				oemSupportEnt.StartDate = Date.Today();
			}
        return oemSupportEnt;
    }
	public static void closeEntitlements(set<id> webIds)
	{
		map<id,WebID__c> mainWebIdMap = new map<id,WebID__c>([Select Id, Name, OEM__c, Account__c from WebID__c where Id in :webIds]);
		list<Entitlement> entLst = new list<Entitlement>();
		Map<id,list<Entitlement>> entMap = new Map<id,list<Entitlement>>();
		list<Entitlement> webEntLst = new list<Entitlement>();
		/* Exisiting Entitlements - Start */
		for(Entitlement ent: [Select Id, Name, StartDate, EndDate, WebId__c from Entitlement where WebId__c in :WebIds])
		{
			webEntLst = entMap.containsKey(ent.WebId__c) ? entMap.get(ent.WebId__c) :  new list<Entitlement>();
			webEntLst.add(ent);
			entMap.put(ent.WebId__c, webEntLst);
		}
		/* Exisiting Entitlements - End */
		system.debug('----entMap---'+entMap);
		
		for(WebID__c webId : mainWebIdMap.values())
		{
			
			/* Only for Update - Start*/
			//webEntLst = entMap.containsKey(webId.id) ? entMap.get(webId.id) : new list<Entitlement>();
			if(entMap.containsKey(webId.id)){
				webEntLst = entMap.get(webId.id);
			}
			system.debug('---------webEntLst-----------'+webEntLst);
			if(webEntLst.size() > 0)
			{
				for(Entitlement ent : webEntLst){
					if(ent.endDate==null){
					    ent.endDate = date.Today();
					    entLst.add(ent);
					}
				}
			}
			/* Only for Update - End*/
			
		}
		system.debug('----entLst---'+entLst);
		try{
			Database.SaveResult[] resultList = Database.update(entLst,false);
			system.debug(resultList);
		}
		catch(Exception ex){
			system.debug('----Exception-----'+ex);
		}	
	}
}