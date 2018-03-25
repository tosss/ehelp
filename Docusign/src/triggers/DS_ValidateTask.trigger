trigger DS_ValidateTask on Task (before insert, before update) 
{
    DS_ValidateActivity.Validate(Trigger.New);
}