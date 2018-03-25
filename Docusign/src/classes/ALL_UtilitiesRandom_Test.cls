@isTest
public class ALL_UtilitiesRandom_Test
{
    public static testmethod void RandomInteger()
    {
        Integer Random = ALL_UtilitiesRandom.RandomInteger(1, 10);
        system.assert(1 <= Random && Random <= 10);
    }
    
    public static testmethod void TrueRandomUpToAMillion() 
    {
        // string length compare
        string TrueRandom = ALL_UtilitiesRandom.TrueRandomUpToAMillion();
        system.assert(1 <= TrueRandom.length() && TrueRandom.length() <= 7);
    }
    
    public static testmethod void CryptoRandom()
    {
        // long max value is 9223372036854775807 ((2^63)-1)
        long CryptoRandom = ALL_UtilitiesRandom.CryptoRandom();
        system.assert(1 <= CryptoRandom && CryptoRandom <= 9223372036854775807L);
    }
    
    public static testmethod void RandomUserName() 
    {
        string RandomUserName = ALL_UtilitiesRandom.RandomUserName('UtilitiesTest');
        system.assert(RandomUserName != null && RandomUserName.contains('UtilitiesTest'));
    }
    
}