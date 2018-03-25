global class ALL_UtilitiesRandom 
{
    //createdby Matt.Keefe@cdk.com
    public static integer RandomInteger( integer min, integer max )
    {
        integer range = Math.abs( max - min ) + 1;
        return integer.valueOf(  ( Math.random() * range ) + ( min <= max ? min : max )  );
    }
    
    //createdby Matt.Keefe@cdk.com
    global static string TrueRandomUpToAMillion()
    {
        // RandomNumber is at max 999000 ( 1000*999 ) to begin with
        //   note zero is not an included possibility
        integer RandomNumber = ALL_UtilitiesRandom.RandomInteger( 1,1000 ) * DateTime.now().millisecond();
        
        // add remaining random to get up to but not including one million
        RandomNumber += ALL_UtilitiesRandom.RandomInteger( 1,999 );
        
        string Random = string.valueOf(  RandomNumber  );
        return Random;
    }
    
    //createdby Siva.Pragada@cdk.com
    public static long CryptoRandom()
    {
        return Math.abs( Crypto.getRandomLong() ); 
    }
    
    //createdby Matt.Keefe@cdk.com
    public static string RandomUserName( string Context )
    {
        string Random = ALL_UtilitiesRandom.TrueRandomUpToAMillion();
        string InstanceName = ALL_UtilitiesMiscellaneous.GetCurrentInstanceName();
        
        return 'test-'+Random+'-'+Context+'@cdk.com.'+InstanceName;
    }
}