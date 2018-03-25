//this is used to prevent a trigger from being called recursively 
// 2014-unknown-unknown - siva.pragada@cdk.com and matt.keefe@cdk.com
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
        if(runCodeBlock != null && runCodeBlock.containsKey(CodeBlock))
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
        }       
    }
    
    private static boolean run = true;
    private static boolean runOther = true;
    private static boolean runOneMore = true; 
    private static boolean runFourthTime = true;
    private static boolean runFifthTime = true;
    
    public static boolean runOnce() 
    {
        if (run) { run = false; return true; }
        else { return run; }      
    }
    
    public static boolean runOtherOnce() 
    {
        if (runOther) { runOther = false; return true; }
        else { return runOther; }
    }
    
    public static boolean runOneMoreTime() 
    {
        if (runOneMore) { runOneMore = false; return true; }
        else { return runOneMore; }
    }
    
    public static boolean runFourthTime() 
    {
        if (runFourthTime) { runFourthTime = false; return true; }
        else { return runFourthTime; }
    } 
    
    public static boolean runFifthTime() 
    {
        if (runFifthTime) { runFifthTime = false; return true; }
        else { return runFifthTime; }
    }  
    
    public static void reset()
    {
        run = true; runOther = true;
    }
}