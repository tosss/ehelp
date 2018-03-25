//2016-02-10 endiem@endiem.com - RQ-05509 - Whenever EPC/PSC/Proecss Coach on Consulting Project record is filled/modified, holding the email of 
//Resource in corresponding email fields on Consulting Project to send emails
public class TRV_ConsultingProject_Handler {
    
    //Verifying whether EPC/PSC/Process Coach fields are holding values or not and collecting list of resource Id's
    public void onBeforeInsert(List<Traver_Project__c> lstNewProject) {
        
        map<Id, Traver_Project__c> mapEPC_Project = new map<Id, Traver_Project__c>(); //Map of EPC to Traver Project
        map<Id, Traver_Project__c> mapPC_Project = new map<Id, Traver_Project__c>(); //Map of Process Coach to Traver Project
        map<Id, Traver_Project__c> mapPSC_Project = new map<Id, Traver_Project__c>(); //Map of PSC to Traver Project
        set<Id> setResourceId = new set<Id>(); //Holds EPC/Process Coach/PSC id
        
        for(Traver_Project__c objProject : lstNewProject) {
        
            if(objProject.TRV_EPC__c != null) {
                
                mapEPC_Project.put(objProject.TRV_EPC__c, objProject);
                setResourceId.add(objProject.TRV_EPC__c);
            }
            
            if(objProject.TRV_Process_Coach__c != null) {
            
                mapPC_Project.put(objProject.TRV_Process_Coach__c , objProject);
                setResourceId.add(objProject.TRV_Process_Coach__c);
            }
            
            if(objProject.TRV_PSC__c != null) {
            
                mapPSC_Project.put(objProject.TRV_PSC__c , objProject);
                setResourceId.add(objProject.TRV_PSC__c);
            }
        }
        
        if(setResourceId.isEmpty()) {
         
            return;   
        }
            
        populateEPC_ProcessCoach_PSC_Email(mapEPC_Project, mapPC_Project, mapPSC_Project, setResourceId);
    }
    
    //Verifying whether EPC/PSC/Process Coach field values are modified or not and collecting list of resource Id's
    public void onBeforeUpdate(map<Id, Traver_Project__c> mapNewProject, map<Id, Traver_Project__c> mapOldProject) {
        
        map<Id, Traver_Project__c> mapEPC_Project = new map<Id, Traver_Project__c>(); //Map of EPC to Traver Project
        map<Id, Traver_Project__c> mapPC_Project = new map<Id, Traver_Project__c>(); //Map of Process Coach to Traver Project
        map<Id, Traver_Project__c> mapPSC_Project = new map<Id, Traver_Project__c>(); //Map of PSC to Traver Project
        set<Id> setResourceId = new set<Id>(); //Holds EPC/Process Coach/PSC id
        
        for(Traver_Project__c objNewProject : mapNewProject.values()) {
            
            Traver_Project__c objOldProject = mapOldProject.get(objNewProject.Id);
            
            if(objNewProject.TRV_EPC__c == null) {
                
                objNewProject.TRV_EPC_Email__c = '';
            }
            else if(objNewProject.TRV_EPC__c != objOldProject.TRV_EPC__c) {
                
                mapEPC_Project.put(objNewProject.TRV_EPC__c, objNewProject);
                setResourceId.add(objNewProject.TRV_EPC__c);
            }
            
            if(objNewProject.TRV_Process_Coach__c == null) {
                
                objNewProject.TRV_Process_Coach_Email__c = '';
            }
            else if(objNewProject.TRV_Process_Coach__c != objOldProject.TRV_Process_Coach__c) {
                
                mapPC_Project.put(objNewProject.TRV_Process_Coach__c, objNewProject);
                setResourceId.add(objNewProject.TRV_Process_Coach__c);
            }
            
            if(objNewProject.TRV_PSC__c == null) {
                
                objNewProject.TRV_PSC_Email__c = '';
            }
            else if(objNewProject.TRV_PSC__c != objOldProject.TRV_PSC__c) {
                
                mapPSC_Project.put(objNewProject.TRV_PSC__c, objNewProject);
                setResourceId.add(objNewProject.TRV_PSC__c);
            }
        }
        
        if(setResourceId.isEmpty()) {
         
            return;   
        }
        
        populateEPC_ProcessCoach_PSC_Email(mapEPC_Project, mapPC_Project, mapPSC_Project, setResourceId);
    }
    
    //Updating EPC Email/PSC Email/Process Coach Email fields with corresponding email values
    private void populateEPC_ProcessCoach_PSC_Email(map<Id, Traver_Project__c> mapEPC_Project, map<Id, Traver_Project__c> mapPC_Project, map<Id, Traver_Project__c> mapPSC_Project, set<Id> setResourceId) {
        
        for(TRV_Resource__c objResource : [
            SELECT Id, TRV_Resource__c, TRV_Resource__r.Email 
            FROM TRV_Resource__c 
            WHERE TRV_Resource__c != null 
            AND (Id IN: setResourceId)
        ]) {
        
            if(mapEPC_Project.containsKey(objResource.Id)) {
                
                mapEPC_Project.get(objResource.Id).TRV_EPC_Email__c = objResource.TRV_Resource__r.Email; 
            }
            
            if(mapPC_Project.containsKey(objResource.Id)) {
                
                mapPC_Project.get(objResource.Id).TRV_Process_Coach_Email__c = objResource.TRV_Resource__r.Email; 
            }
            
            if(mapPSC_Project.containsKey(objResource.Id)) {
                
                mapPSC_Project.get(objResource.Id).TRV_PSC_Email__c = objResource.TRV_Resource__r.Email; 
            }
            
            setResourceId.remove(objResource.Id);
        }

        if(!setResourceId.isEmpty()) {
            
            for(Id reosurceId : setResourceId) {
                
                if(mapEPC_Project.containsKey(reosurceId)) {
                
                    mapEPC_Project.get(reosurceId).TRV_EPC_Email__c = ''; 
                }
                
                if(mapPC_Project.containsKey(reosurceId)) {
                    
                    mapPC_Project.get(reosurceId).TRV_Process_Coach_Email__c = ''; 
                }
                
                if(mapPSC_Project.containsKey(reosurceId)) {
                    
                    mapPSC_Project.get(reosurceId).TRV_PSC_Email__c = ''; 
                }
            }
        }
    }
}