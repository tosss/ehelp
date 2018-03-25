//Request - 04926: RFP to USIM contacts via VF Page and route to LMA Strategist
// 08/31/15 smitha.simhadri@cdk.com Created
// 2015-12-08 smitha.simhadri@cdk.com Updated RQ-05897 Alphabetize LMA drop down field
// 2016-06-15 matt.keefe@cdk.com, Lalitha.Adduru@cdk.com - updated contact references to contact relationship
public class CB_LMARFPCreate_Extension
{
	public LMA_RFP__c rfp { get; set; }

	public String selectedRecType { get; set; }
	public String selectedLMA { get; set; }
	public String selectedModelOne { get; set; }
	public String selectedModelTwo { get; set; }
	public String selectedModelThree { get; set; }
	public String selectedModelFour { get; set; }
	public Boolean ReadOnly { get; set; }
	public List<selectOption> LMAAccts { get; set; }
	public List<selectOption> LMAModels { get; set; }
	public set<Id> agencyIds;

	public CB_LMARFPCreate_Extension(ApexPages.StandardController stdCtrl)
	{
		rfp = (LMA_RFP__C) stdCtrl.getRecord();
	}

	public Set<String> rfpRecTypes
	{
		get {
			System.debug(UserInfo.getUserId());
			System.debug(UserInfo.getUserName());

			id userId = UserInfo.getUserId();

			//List<contact> agencyContacts = [
			//    select id, name, account.id, account.name 
			//    from contact 
			//    where user__r.id = :userId
			//    and account.name != 'CDK Global'
			//]; 

			// 2016-06-15 matt.keefe@cdk.com - added contact relationship subquery
			list<Contact> agencyContacts = [
			                                Select
			                                id, name, account.id, account.name,
			(Select
			 id, name, Account__c, Account__r.Name
			 From Contact_Relationships__r)
			                                From
			                                Contact
			                                Where user__r.id = :userId
			                                AND account.name != 'CDK Global'
			                               ];

			rfpRecTypes = new Set<String> ();
			agencyIds = new Set<Id> ();

			iF (agencyContacts != null && !agencyContacts.isEmpty())
			{
				for (Contact agencyContact : agencyContacts)
				{
					// 2016-06-15 matt.keefe@cdk.com - looping through contact relationships instead of contact
					for (Contact_Relationship__c cr : agencyContact.getSObjects('Contact_Relationships__r'))
					{
						agencyIds.add(cr.Account__c);

						// 2016-06-15 matt.keefe@cdk.com - instead of querying account, just get the data
						Account agencyAcct = new Account(id = cr.Account__c, Name = cr.Account__r.Name);

						if (cr.Account__c != null)
						{
							//2016-06-16 - lalitha.adduru@cdk.com - changed the below variable to list to avoid 'no rows for assignment error'
							list<Manufacturer_at_Dealership__C> mfgDlr = [
							                                              select id, name, account__r.name, account__r.id, manufacturer__r.id, manufacturer__r.name
							                                              from manufacturer_at_dealership__c
							                                              where account__r.id = :agencyAcct.id
							                                             ];

							if (mfgDlr != null && !mfgDlr.isEmpty())
							{
								for (Manufacturer_at_Dealership__C mfgDlrOne : mfgDlr)
								{
									String mfgName = mfgDlrOne.manufacturer__r.name;
									CB_LMA_MFgr_record_types__C recTypeCS = CB_LMA_MFgr_record_types__C.getInstance(mfgName);

									if (recTypeCS != null)
									{
										String recTypeVal = recTypeCS.record_type__c;
										rfpRecTypes.add(recTypeVal);
									}
								}
							}

						}
					}
				}

			}
			else
			{
				rfpRecTypes = null;
			}
			return rfpRecTypes;
		}
		set;
	}

	public List<SelectOption> getRFPrecTypeOptions()
	{
		List<SelectOption> RFPrecTypeOptions = new List<SelectOption> ();
		RFPrecTypeOptions.add(new SelectOption('', '---Select One---'));

		if (rfpRecTypes != null && !rfpRecTypes.isEmpty())
		{
			for (String rfpRecTypesOne : rfpRecTypes)
			{
				RFPrecTypeOptions.add(new SelectOption(rfpRecTypesOne, rfpRecTypesOne));
			}
		}
		return RFPrecTypeOptions;
	}

	public List<account> lmas
	{
		get {
			List<CB_LMA_MFgr_record_types__C> mfgRecTypesCS = [
			                                                   select name, franchise__c, Record_Type__c
			                                                   from CB_LMA_MFgr_record_types__C
			                                                   where record_type__c = :selectedRecType
                                                               ORDER BY Name DESC
			                                                  ];

			String mfgrNameCS;
			String franchise;

			if (mfgRecTypesCS != null && !mfgRecTypesCS.isEmpty())
			{
				for (CB_LMA_MFgr_record_types__C mfgRecTypesCSOne : mfgRecTypesCS)
				{
					mfgrNameCS = mfgRecTypesCSOne.name;
					franchise = mfgRecTypesCSOne.franchise__c;
				}
                
				List<manufacturer_at_dealership__c> mfgrParent = new List<manufacturer_at_dealership__c> ();
				mfgrParent = [
				              select id, name, account__r.id, account__r.name
				              from manufacturer_at_dealership__c
				              where manufacturer__r.name = :mfgrNameCS
				              and account__r.site_type__r.name = 'Advertisers'
				              and account__r.id in :agencyIds
				              LIMIT 1
				             ];
                
				if (mfgrParent != null && !mfgrParent.isEmpty())
				{
					lmas = [
					        select id, name
					        from account
					        where id IN(
					                    select account__c
					                    from business_site__c
					                    where franchise__c = :franchise
					                    and status__c = 'A'
					                    and account__r.parent.id = :mfgrParent[0].account__r.id
					                    and account__r.site_type__r.name = 'Local Marketing'
					                   )
					        //2015-12-08 smitha.simhadri@cdk.com Updated RQ-05897 Alphabetize LMA drop down field
					        order by name
					       ];
				  }
			}
			else
			{
				lmas = null;
			}
			return lmas;

		}
		set;
	}

	public void getlmaoptions()
	{ //Fetch all LMA Accounts of OEM/Record Type Selected
        try{
            String currLMAAcct;
            LMAAccts = new List<SelectOption> ();
            LMAAccts.add(new SelectOption('', '---Select One---'));
            
            if (selectedRecType != 'null' && lmas != null)
            {
                for (account lmaOne : lmas)
                {
                    LMAAccts.add(new SelectOption(lmaOne.name, lmaOne.name));
                }
            }
            
            //Fetch all models of OEM/Record Type selected
            LMAModels = new List<selectOption> ();
            LMAModels.add(new selectOption('', '--Select One--'));
            
            Set<String> modelNames = new Set<String> ();
            
            for (CB_LMA_RFP_Models__c model : CB_LMA_RFP_Models__c.getAll().values())
            {
                if (selectedRecType == model.manufacturer__c)
                {
                    modelNames.add(model.name);                   
                }
                
            }
            
            for (String modelNamesOne : modelNames)
            {
                LMAModels.add(new selectOption(modelNamesOne, modelNamesOne));
            }
        }
        catch(Exception exp)
        {
            ALL_UtilitiesMiscellaneous.logException(exp);
        }
	}
    
    public PageReference Save()
    {
        try
        {
            ID RecordTypeId = selectedRecType != null ? ALL_UtilitiesDescribe.getRecordTypeIdOfAnySObject('LMA_RFP__c', selectedRecType) : null;
            
            rfp.RecordTypeId = RecordTypeId;
            
            
            list<Account>accList = [
                select id
                from account
                where name = :selectedLMA
                LIMIT 1
            ];
            
            
            id selLMAAcct = !accList.isEmpty() ? accList.get(0).id : null;
            
            rfp.LMA__c = selLMAAcct;
            
            rfp.Model_1__c = selectedModelOne;
            rfp.Model_2__c = selectedModelTwo;
            rfp.Model_3__c = selectedModelThree;
            rfp.Model_4__c = selectedModelFour;
            
            rfp.status__c = 'Created';
                      
            Database.saveResult result = database.insert(rfp);            
            
            if(!result.isSuccess())
            {
                for(Database.Error dr: result.getErrors())
                {
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.FATAL, dr.getMessage());
                    ApexPages.addMessage(myMsg); system.debug(dr.getMessage());                    
                }
            }            
            
            PageReference PageRef = new PageReference('/apex/CB_LMARFPCreate?id=' + rfp.id);
            PageRef.setredirect(true);
            
            return PageRef;
        }
        Catch(Exception Exp)
        {
            ApexPages.addMessages(Exp);
        }
        return null;        
    }
}