/* Derived from: http://stackoverflow.com/a/7558600/549141 */
function sortTable(name, cellnumber, comparison) {
    var tbl = document.getElementById(name).tBodies[0];
    var store = [];
    
    for(var i=0, len=tbl.rows.length; i<len; i++){
        var row = tbl.rows[i]; 
        var sorter = row.cells[cellnumber].innerHTML; 
        store.push([sorter, row]);
    }
    
    store.sort(comparison);
    
    for(var i=0, len=store.length; i<len; i++){
        tbl.appendChild(store[i][1]);
    }
    
    store = null;
}; 