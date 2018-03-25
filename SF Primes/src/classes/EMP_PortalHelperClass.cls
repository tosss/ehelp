public class EMP_PortalHelperClass{
     public static  string getVFPageName()  {
        // THIS IS THE CLOSEST YOU CAN GET SO FAR
        String pageName = ApexPages.CurrentPage().getUrl();  
        // IT ALWAYS STARTS WITH /APEX/ SO REMOVE IT
        pageName = pageName.replaceFirst('/apex/','');         
        pageName = EncodingUtil.urlEncode(pageName, 'UTF-8');  
        // %3F IS THE VALUE OF THE QUESTION MARK IN UTF-8 
        string[] pageNameExtra = pageName.split('%3F',0);   
        // SO YOU MAY SPLIT THE STRING AT THAT POINT
          // FOR THIS PURPOSE YOU ONLY NEED THE FIRST
        // IN THE RESULTING ARRAY
        pageName = pageNameExtra[0]; 
        // HERE IS YOUR PRODUCT  
        system.debug('pageName-->'+pageName);                       
        return pageName;                                        
    }
    
}