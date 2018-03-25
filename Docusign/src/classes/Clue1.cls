public class Clue1 
{
    public static List<String> getNames(List<String> allNames)
    {
        List<String> filtered = new List<String>();
        System.debug(allNames.size());
        for(String name: allNames)
        {
            System.debug(name);
            name = name.substringbetween('<','.');
            System.debug(name);
            name = name.replace(' ', '').replace('@cdk.com', '').toLowerCase();
            if(name.containsAny('vishalbandari'))
            {
                Set<String> s = new Set<String>(name.split(''));
                Set<String> d= new Set<String>('vishal'.split(''));
                integer existing = d.size();
                d.removeAll(s);
                integer newnum = d.size();
                if(existing-newnum > 3)
                {
                    filtered.add(name);
                }
            }
        }
         System.debug(filtered.size());
        return filtered;
    }
}