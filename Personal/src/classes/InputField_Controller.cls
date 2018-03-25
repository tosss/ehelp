public class InputField_Controller 
{
    public static String inputType{get;set;}
    public static String SobjectAPIName{get;set;}
    boolean isLookUp;
    public InputField_Controller()
    {
        if(SobjectAPIName!=null)
        {
            inputType = 'Lookup';
            isLookUp = true;
        }
        else if(SobjectAPIName==null)
        {
            SobjectAPIName = 'Account';
            inputType = 'Lookup';
            isLookUp = true;
        }
        if(inputType==null)
        {
            inputType = 'TextBox';
            isLookUp = false;
        }
    }
}