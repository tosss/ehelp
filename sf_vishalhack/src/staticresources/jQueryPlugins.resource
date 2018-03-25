// http://stackoverflow.com/a/19259752/549141
jQuery.fn.findDeepest = function() 
{
    var results = [];
    this.each(function() {
        var deepLevel = 0;
        var deepNode = this;
        treeWalkFast(this, function(node, level) {
            if (level > deepLevel) { deepLevel = level; deepNode = node; }
        });
        results.push(deepNode);
    });
    return this.pushStack(results);
};

var treeWalkFast = (function() 
{
    var skipTags = {"SCRIPT": true, "IFRAME": true, "OBJECT": true, "EMBED": true}; // close constants
    return function(parent, fn, allNodes) 
    {
        var node = parent.firstChild, nextNode;
        var level = 1;
        
        while (node && node != parent) 
        {
            if (allNodes || node.nodeType === 1) {
                if (fn(node, level) === false) { return(false); }
            }
            
            // if it is an element && has children && has a tagname && is not in the skipTags list
            //   then, enumerate children
            if (node.nodeType === 1 && node.firstChild && !(node.tagName && skipTags[node.tagName])) {                
                node = node.firstChild; ++level;
            } 
            else if (node.nextSibling) {
                node = node.nextSibling;
            } 
            else // no child and no nextsibling, find parent that has a nextSibling
            { 
                --level;
                
                while ((node = node.parentNode) != parent) 
                {
                    if (node.nextSibling) {
                        node = node.nextSibling; break;
                    }
                    --level;
                }
            }
        } // end while
    } // end return function
})();
// end http://stackoverflow.com/a/19259752/549141