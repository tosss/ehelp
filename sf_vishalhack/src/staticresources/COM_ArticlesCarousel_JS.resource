//2017-06-07- anirudh.singh@cdk.com- Created this JS file for RQ-09402.
(function(w)
{
    "use strict";
    var j$;
    if(typeof jQuery!=='undefined' && typeof j$==='undefined')
    {
        j$=jQuery.noConflict(true);
    }
    w.j$=j$;
})(window);