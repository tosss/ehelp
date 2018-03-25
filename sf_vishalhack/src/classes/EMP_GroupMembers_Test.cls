//2017-05-19- anirudh.singh@cdk.com- Created this class for RQ-09062.
@isTest
public class EMP_GroupMembers_Test
{
    @TestSetup
    private static void setupData()
    {
        User standardUser=DS_TestObjects.NewUser();
        insert standardUser;
            
        List<EMP_GroupMembersFields__c> grpMembrsFieldsList=new List<EMP_GroupMembersFields__c>();
        
        EMP_GroupMembersFields__c rec1=new EMP_GroupMembersFields__c();
        rec1.Name='CollaborationRole';
        rec1.Field_Label__c='Group Member Role';
        rec1.Order__c=5;
        grpMembrsFieldsList.add(rec1);
        
        EMP_GroupMembersFields__c rec2=new EMP_GroupMembersFields__c();
        rec2.Name='Member.Name';
        rec2.Field_Label__c='Name';
        rec2.Order__c=10;
        grpMembrsFieldsList.add(rec2);
        insert grpMembrsFieldsList;
        
        CollaborationGroup groupRec=new CollaborationGroup();
        groupRec.Name='EMP_GroupMembers_Test Group';
        groupRec.CollaborationType='Public';
        insert groupRec;
        
        List<CollaborationGroupMember> grpMembrsList=new List<CollaborationGroupMember>();
        
        CollaborationGroupMember memberRec2=new CollaborationGroupMember();
        memberRec2.MemberId=standardUser.Id;
        memberRec2.CollaborationRole='Standard';
        memberRec2.CollaborationGroupId=groupRec.Id;
        grpMembrsList.add(memberRec2);
        insert grpMembrsList;
    }
    
    private static testMethod void fetchGrpMembrsFieldsListTest()
    {
        List<EMP_GroupMembersFields__c> grpMembrsFieldsList=EMP_GroupMembersFields__c.getAll().values();
        
        Test.startTest();
        EMP_GroupMembers_Controller.FieldsCommunityInfoWrapper wrapperRec=EMP_GroupMembers_Controller.fetchGrpMembrsFieldsList();
        List<EMP_GroupMembersFields__c> fetchedGrpMembrsFieldsList=wrapperRec.grpMembrsFieldsList;
        Test.stopTest();
        
        system.assertEquals(grpMembrsFieldsList.size(), fetchedGrpMembrsFieldsList.size(), 'Correct No of records');
    }
    
    private static testMethod void fetchGrpMembrsListTestOne()
    {
        Test.startTest();
        List<CollaborationGroupMember> fetchedGrpMembrsList=EMP_GroupMembers_Controller.fetchGrpMembrsList(Null);
        Test.stopTest();
        
        system.assertEquals(0, fetchedGrpMembrsList.size(), 'Correct No of records');
    }
    
    private static testMethod void fetchGrpMembrsListTestTwo()
    {
        CollaborationGroup grpRec=[SELECT Id FROM CollaborationGroup WHERE Name='EMP_GroupMembers_Test Group' LIMIT 1];
        
        List<CollaborationGroupMember> grpMembrsList=new List<CollaborationGroupMember>([
            SELECT Id 
            FROM CollaborationGroupMember 
            WHERE CollaborationGroupId=:grpRec.Id
        ]);
        
        Test.startTest();
        List<CollaborationGroupMember> fetchedGrpMembrsList=EMP_GroupMembers_Controller.fetchGrpMembrsList(grpRec.Id);
        Test.stopTest();
        
        system.assertEquals(grpMembrsList.size(), fetchedGrpMembrsList.size(), 'Correct No of records');
    }
    
    private static testMethod void saveMembershipTestOne()
    {
        CollaborationGroup grpRec=[SELECT Id, OwnerId FROM CollaborationGroup WHERE Name='EMP_GroupMembers_Test Group' LIMIT 1];
        
        List<CollaborationGroupMember> grpMembrsList=new List<CollaborationGroupMember>([
            SELECT Id, CollaborationRole, Member.Name 
            FROM CollaborationGroupMember 
            WHERE CollaborationGroupId=:grpRec.Id
        ]);
        
        Id grpMemId;
        for(CollaborationGroupMember memRec: grpMembrsList)
        {
            if(grpRec.OwnerId==memRec.Member.Id)
            {
                grpMemId=memRec.Id;
            }
        }
        
        Test.startTest();
        String returnString=EMP_GroupMembers_Controller.saveMembership('Standard', grpMemId);
        Test.stopTest();
        
        system.assert(returnString.contains('You can\'t convert a group owner'));
    }
    
    private static testMethod void saveMembershipTestTwo()
    {
        CollaborationGroup grpRec=[SELECT Id, OwnerId FROM CollaborationGroup WHERE Name='EMP_GroupMembers_Test Group' LIMIT 1];
        
        List<CollaborationGroupMember> grpMembrsList=new List<CollaborationGroupMember>([
            SELECT Id, CollaborationRole, Member.Name 
            FROM CollaborationGroupMember 
            WHERE CollaborationGroupId=:grpRec.Id
        ]);
        
        Id grpMemId;
        for(CollaborationGroupMember memRec: grpMembrsList)
        {
            if(grpRec.OwnerId!=memRec.Member.Id)
            {
                grpMemId=memRec.Id;
            }
        }
        
        Test.startTest();
        String returnString=EMP_GroupMembers_Controller.saveMembership('Admin', grpMemId);
        Test.stopTest();
        
        system.assertEquals('', returnString, 'Membership Edit Successful.');
    }
    
    private static testMethod void deleteMemberTestOne()
    {
        CollaborationGroup grpRec=[SELECT Id, OwnerId FROM CollaborationGroup WHERE Name='EMP_GroupMembers_Test Group' LIMIT 1];
        
        List<CollaborationGroupMember> grpMembrsList=new List<CollaborationGroupMember>([
            SELECT Id, CollaborationRole, Member.Name 
            FROM CollaborationGroupMember 
            WHERE CollaborationGroupId=:grpRec.Id
        ]);
        
        Id grpMemId;
        for(CollaborationGroupMember memRec: grpMembrsList)
        {
            if(grpRec.OwnerId==memRec.Member.Id)
            {
                grpMemId=memRec.Id;
            }
        }
        
        Test.startTest();
        String returnString=EMP_GroupMembers_Controller.deleteMember(grpMemId);
        Test.stopTest();
        
        system.assert(returnString.contains('You cannot delete the owner from a group'));
    }
    
    private static testMethod void deleteMemberTestTwo()
    {
        CollaborationGroup grpRec=[SELECT Id, OwnerId FROM CollaborationGroup WHERE Name='EMP_GroupMembers_Test Group' LIMIT 1];
        
        List<CollaborationGroupMember> grpMembrsList=new List<CollaborationGroupMember>([
            SELECT Id, CollaborationRole, Member.Name 
            FROM CollaborationGroupMember 
            WHERE CollaborationGroupId=:grpRec.Id
        ]);
        
        Id grpMemId;
        for(CollaborationGroupMember memRec: grpMembrsList)
        {
            if(grpRec.OwnerId!=memRec.Member.Id)
            {
                grpMemId=memRec.Id;
            }
        }
        
        Test.startTest();
        String returnString=EMP_GroupMembers_Controller.deleteMember(grpMemId);
        Test.stopTest();
        
        system.assertEquals('', returnString, 'Membership Edit Successful.');
    }
}