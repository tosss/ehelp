//this is used to prevent a trigger from being called recursively
// unknown Date - matt.keefe@cdk.com - created the class
// 2014-unknown-unknown - siva.pragada@cdk.com - added runCodeBlockOnce method
// 2015-10-14 - siva.pragada@cdk.com added new method runCodeBlockGivenTimes

global class ALL_CheckRecursive
{
    private static map<string, boolean> runCodeBlock = new map<string, boolean>(); 
    private static map<string, integer> countMap = new map<string, integer>();   
        
    global static boolean runCodeBlockGivenTimes(string CodeBlock, integer noOfTimes)
    { 
        integer i = -1;
        
        if(countMap != null && countMap.get(CodeBlock) != null)
        {
           i =  countMap.get(CodeBlock) + 1;
        }
        else
        {
            i++; 
        }
                
        if(runCodeBlock != null && runCodeBlock.containsKey(CodeBlock))
        {
            i = countMap.get(CodeBlock);
            
            if(i != null && i < noOfTimes)
            {
               return true;
            }
            else if(i != null && i >= noOfTimes)
            {
                return false;
            }
            
            return null;
        }
        else
        {
            countMap.put(CodeBlock, i);
            
            if(i < noOfTimes)
            {
                return true;
            }
            else if(i >= noOfTimes)
            {
                return false;
            }
            else
            {
                return null;
            }
        }
    }    
   
    global static boolean runCodeBlockOnce(string CodeBlock)
    {  
    	boolean bool = ALL_CheckRecursive.runCodeBlockGivenTimes(CodeBlock, 1);     
       /* if(runCodeBlock != null && runCodeBlock.containsKey(CodeBlock))
        {
            return runCodeBlock.get(CodeBlock); 
        }
        else if(runCodeBlock != null && !runCodeBlock.containsKey(CodeBlock))
        {
            runCodeBlock.put(CodeBlock, false);
            return true;
        }
        else 
        {
            runCodeBlock.put(CodeBlock, false); 
            return true;
        }  */ 
        
        return bool;    
    }
}