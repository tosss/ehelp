trigger EMP_ContentVersion on ContentVersion (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
     if (Trigger.isAfter) {
         
        if(Trigger.isUpdate)
        {
            //update the policy of all valid user when a new policy Acknowledgement is created or when the policy Acknowledgement Required field is set from false to true
            EMP_UpdateUserPolicy_Helper.executeUpdateUserPolicy(Trigger.new);
        }
    }  
}