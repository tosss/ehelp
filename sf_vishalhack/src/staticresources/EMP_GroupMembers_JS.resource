//2017-05-25- anirudh.singh@cdk.com- Created this JS file for RQ-09062.
(function(w)
{
    "use strict"; //Optional LockerService runs in strict mode. 
    var j$;
    if(typeof jQuery!=='undefined' && typeof j$==='undefined')
    {
        j$=jQuery.noConflict(true);
    }
    w.j$=j$;
})(window);