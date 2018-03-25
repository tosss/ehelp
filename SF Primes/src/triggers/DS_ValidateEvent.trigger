trigger DS_ValidateEvent on Event (before insert, before update) 
{
	DS_ValidateActivity.Validate(Trigger.New);
}