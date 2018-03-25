//2016-08-22- sanjay.ghanathey@cdk.com Discovery Project - Discovery Solutions.
//2016-12-16- anirudh.singh@cdk.com- Added code to disable Include Questions checkbox when Proposed or Proposed and Sold.
//2017-03-23- anirudh.singh@cdk.com- Added code for showing hiding Spinner.
jQuery.fn.reverse = [].reverse;
var j$; if(!j$) { j$ = jQuery.noConflict(); }  
var deleteRow;
var isValidationError;
j$( document ).ready(function() {           
    isValidationError = false;
    var footableFilter = j$('.tpstable').footable({
        breakpoints: {
            phone: 720,
            tablet: 1080
        }
    });                    
    
    j$("#searchtps").on("keyup", function() {
        var filterOn = j$('#searchFilter');        
        _this = this;          
        if(j$(filterOn).val() === 'All'){            
            j$.each(j$("#tpstable tbody tr"), function() {
                if(j$(this).text().toLowerCase().indexOf(j$(_this).val().toLowerCase()) === -1)
                    j$(this).hide();
                else
                    j$(this).show();                
            });
        }
        else{            
            j$("#tpstable").filterTable(j$(_this).val(),j$(filterOn).val());
        }                           
    });
    
    j$('#discProdSolSpinnerDiv').modal('hide');
    
    disableCheckBoxes(existingIds);
    disableCheckBoxes(existingDSIds);
    disableCheckBoxes(otherTPSIds);
    removeSoldProposedForTPS(disableTPSForSoldProposed);      
    disableCheckBoxes(existingProducts);
    
    //2016-11-21- anirudh.singh@cdk.com- Added the below line for pdf version of the component i.e. ALL_DiscoverySolutionForPDF.
    processCheckBoxesForSolutionPDF();
    
    //2016-12-20- anirudh.singh@cdk.com- Commented this as parentProduct is not defined.
    //I think this code was added and then not used.
    //set map for parent product check
    /*j$(parentProduct).each(function(index,object) {       
        var tempChildIds = j$(object).get(0).Child_Product_Id__c.split(',');
        j$(tempChildIds).each(function(index,childId) {
            console.log(childId);
            productHashmap[childId] = j$(object).get(0).Parent_Product_Id__c;            
        });        
    });*/
    
    j$("#tpstable").tablesorter({
        sortList: [[0,0]],
        headers: {3:{sorter:false}}
      }); 
    j$("#tpstable").freezeHeader();
});   

//parent product check
function checkParentProduct(selectedProductId){       
    var mapValue = productHashmap[selectedProductId];
    if(j$('.'+selectedProductId).is(':checked'))
    {
        j$('.'+mapValue).prop("checked",true);
    }
}
function solutionCheck(solution){  
    //2017-01-30 sanjay.ghanathey@cdk.com Requirements Changes - Need to remove Proposed and Proposed and Sold
    var tempId = solution.substr(4);    
    if(j$("."+solution).prop("checked") == true){
        if (solution.toLowerCase().indexOf("curr") >= 0){ 
            if(j$("."+tempId).prop("disabled") != true){
                j$("."+tempId).prop("checked",true);
            }            
            //j$(".prop"+tempId).attr("disabled","disabled");
            //j$(".sold"+tempId).attr("disabled","disabled");
        }else if (solution.toLowerCase().indexOf("prop") >= 0){
            if(j$("."+tempId).prop("disabled") != true){
                j$("."+tempId).prop("checked",true);
            }
            j$(".ques"+tempId).prop("checked",true);
            //j$(".curr"+tempId).attr("disabled","disabled");
            //j$(".sold"+tempId).attr("disabled","disabled");
        }else if (solution.toLowerCase().indexOf("sold") >= 0){
            if(j$("."+tempId).prop("disabled") != true){
                j$("."+tempId).prop("checked",true);
            }          
            j$(".ques"+tempId).prop("checked",true);
            //j$(".prop"+tempId).attr("disabled","disabled");
            //j$(".curr"+tempId).attr("disabled","disabled");
        }
    }
    else{
        if(j$("."+tempId).prop("disabled") != true){
            j$("."+tempId).prop("checked",false);
        }
        //j$(".prop"+tempId).removeAttr("disabled");
        //j$(".sold"+tempId).removeAttr("disabled");
        j$(".curr"+tempId).removeAttr("disabled"); 
        j$(".ques"+tempId).prop("checked",false);        
    }
}

function disableCheckBoxes(Ids) {
    var isError = true;    
    j$( Ids ).each(function( index , object) {                
        j$('.' + object.Id).attr('disabled','disabled').attr('title','Solution/Product already exists.').attr('checked','checked');//.hide();
        //this is to enable delete button
        j$('#del' + object.Id).css('display','block');  
        //2017-01-30 sanjay.ghanathey@cdk.com Requirements Changes - Need to remove Proposed and Proposed and Sold
        if(j$(".curr"+object.Id).prop("checked") == true){            
            //j$(".prop"+object.Id).attr("disabled","disabled");
            //j$(".sold"+object.Id).attr("disabled","disabled");
        }else if(j$(".prop"+object.Id).prop("checked") == true){             
            //j$(".curr"+object.Id).attr("disabled","disabled");
            //j$(".sold"+object.Id).attr("disabled","disabled");
            //2016-12-16- anirudh.singh@cdk.com- Added the below line to disable Include Questions checkbox.
            if(j$(".ques"+object.Id).prop('checked'))
            {
                j$(".ques"+object.Id).attr("disabled", "disabled");
            }
        }else if(j$(".sold"+object.Id).prop("checked") == true){            
            //j$(".prop"+object.Id).attr("disabled","disabled");
            //j$(".curr"+object.Id).attr("disabled","disabled");
            //2016-12-16- anirudh.singh@cdk.com- Added the below line to disable Include Questions checkbox.
            if(j$(".ques"+object.Id).prop('checked'))
            {
                j$(".ques"+object.Id).attr("disabled","disabled");
            }
        }else{            
            isError = false;  
            var referenceOfRow = j$("#checkerr"+object.Id).closest('tr');
            //2017-01-30 sanjay.ghanathey@cdk.com Requirements Changes - Need to remove Proposed and Proposed and Sold
            //referenceOfRow.attr('class','alert alert-danger');
            //j$("#checkerr"+object.Id).show().attr('title','Please check either current/proposed/sold.');            
        }                 
    });       
    //Move the Ids to top of the table       
    j$('#tpstable input[type=checkbox]:disabled').reverse().each(function() {                
        j$(this).parent().parent().prependTo("#tpstable");              
    });          
    return isError;
}

function removeSoldProposedForTPS(Ids) {     
    j$(Ids).each(function( index , Id) {            
        j$(".prop"+Id).attr("disabled","disabled").remove();
        //j$("#dummyprop"+Id).show().attr('title','Sold/Proposed is not available for Third Party Solution.');
        j$(".sold"+Id).attr("disabled","disabled").remove(); 
        //j$("#dummysold"+Id).show().attr('title','Sold/Proposed is not available for Third Party Solution.'); 
    });       
}

function validateOnSubmit(e){
    var selected = [];
    isValidationError = false;
    var returnValue = true;
    // j$('#tpstable input:checked')
    var checked = j$('#tpstable tr td:nth-child(1) input[type=checkbox]:checked');
    j$(checked).each(function() {        
        object = {};
        object['Id'] = j$(this).attr('class');
        selected.push(object);        
    });       
    if(disableCheckBoxes(selected)){
        returnValue = true;
    }
    //2017-01-30 sanjay.ghanathey@cdk.com Requirements Changes - Need to remove Proposed and Proposed and Sold
    /*else{
        j$('#checkboxError').modal('show');
        e.preventDefault();
        isValidationError = true;        
        returnValue = false;
    } */ 
    return returnValue;
}

function confirmDialog(thirdPartySolutionId,_this){          
    j$(".modal-body #tempId").val( thirdPartySolutionId );    
    deleteRow =  _this;        
}

function resetForm(){ 
    //will look into reset later
    window.location.reload();
}

function reloadPage(){
    if(!isValidationError){
        j$('#discProdSolSpinnerDiv').modal('show');
        window.location.reload();
    }
    else{
        j$('#discProdSolSpinnerDiv').modal('hide');
    }
}
function deleteTPS(thirdPartySolutionId){    
    j$('#discProdSolSpinnerDiv').modal('show');
    ALL_DiscoveryProductSolution_Controller.deleteTPS(
        thirdPartySolutionId,
        oppLocId,
        function(result, event) {
            if (event.status) {                               
                window.location.reload();
            } else if (event.type === 'exception') {
                j$('#discProdSolSpinnerDiv').modal('hide');
            } else {
                j$('#discProdSolSpinnerDiv').modal('hide');
            }
        });
}

function deleteProduct(productId){    
    j$('#discProdSolSpinnerDiv').modal('show');
    ALL_DiscoveryProductSolution_Controller.deleteProduct(
        productId,
        oppLocId,
        function(result, event) {
            if (event.status) {                               
                window.location.reload();
            } else if (event.type === 'exception') {
                j$('#discProdSolSpinnerDiv').modal('hide');
            } else {
                j$('#discProdSolSpinnerDiv').modal('hide');
            }
        });
}

function saveOtherSolution(){
    if(!j$("[id$='otherSolutionName']").val()){
        j$(errorInModal).html("Please enter the solution name.");
        j$(errorInModal).show();
    }else if(!j$("[id$='otherVendorName']").val()){
        j$(errorInModal).html("Please enter the vendor name.");
        j$(errorInModal).show();
    }//2017-01-30 sanjay.ghanathey@cdk.com Requirements Changes - Need to remove Proposed and Proposed and Sold
        /*else if(!j$("[id$='changedCurrentId']").is(':checked') && !j$("[id$='changedProposedId']").is(':checked') && !j$("[id$='changedSoldId']").is(':checked')){
        j$(errorInModal).html("Please check either sold,proposed or current.");
        j$(errorInModal).show(); 
    }*/else{               
        var solutionName = j$("[id$='otherSolutionName']").val();
        var vendorName = j$("[id$='otherVendorName']").val();
        var sold = false;
        var current = true;
        var proposed = false;        
       /* if(j$("[id$='changedSoldId']").is(':checked')){
           // sold = true;
        }else if(j$("[id$='changedCurrentId']").is(':checked')){
            current = true;
        }else if(j$("[id$='changedProposedId']").is(':checked')){
          //  proposed = true;
        } */        
        
        var notes = j$("[id$='notesComments']").val();
        ALL_DiscoveryProductSolution_Controller.saveOtherSolution( 
            oppLocId,solutionName,vendorName,
            sold,current,proposed,notes,
            function(result, event) {
                if (event.status) {
                    window.location.reload();
                } else if (event.type === 'exception') {
                    j$('#discProdSolSpinnerDiv').modal('hide');
                } else {
                    j$('#discProdSolSpinnerDiv').modal('hide');
                }
            });
    }
}

function saveOtherProduct(){
    if(!j$("[id$='otherProductName']").val()){
        j$(errorInModal).html("Please enter the product name.");
        j$(errorInModal).show();
    }//2017-01-30 sanjay.ghanathey@cdk.com Requirements Changes - Need to remove Proposed and Proposed and Sold
    else if(!j$("[id$='changedCurrentId']").is(':checked') && !j$("[id$='changedProposedId']").is(':checked') && !j$("[id$='changedSoldId']").is(':checked')){
        j$(errorInModal).html("Please check either sold,proposed or current.");
        j$(errorInModal).show(); 
    }else{               
        var productName = j$("[id$='otherProductName']").val();      
        // var department = j$("[id$='departmentId']").val();
        // var workflow = j$("[id$='workflowId']").val();
        var sold = false;
        var current = false;
        var proposed = false;
        if(j$("[id$='changedSoldId']").is(':checked')){
            //sold = true;
        }else if(j$("[id$='changedCurrentId']").is(':checked')){
            current = true;
        }else if(j$("[id$='changedProposedId']").is(':checked')){
           //proposed = true;
        }         
        
        var notes = j$("[id$='notesComments']").val();
        ALL_DiscoveryProductSolution_Controller.saveOtherProduct( 
            oppLocId,productName,
            sold,current,proposed,notes,
            function(result, event) {
                if (event.status) {                               
                    window.location.reload();
                } else if (event.type === 'exception') {
                    j$('#discProdSolSpinnerDiv').modal('hide');
                } else {
                    j$('#discProdSolSpinnerDiv').modal('hide');
                }
            });
    }
}

function disableFormCheckbox(selectedItem){
    if(j$("[id$='changedCurrentId']").is(':checked')){        
        j$("[id$='changedProposedId']").prop('disabled','disabled');
        j$("[id$='changedSoldId']").prop('disabled','disabled');
    }else if(j$("[id$='changedProposedId']").is(':checked')){         
        j$("[id$='changedCurrentId']").prop('disabled','disabled');
        j$("[id$='changedSoldId']").prop('disabled','disabled');
    }else if(j$("[id$='changedSoldId']").is(':checked')){         
        j$("[id$='changedProposedId']").prop('disabled','disabled');
        j$("[id$='changedCurrentId']").prop('disabled','disabled');
    }else{
        j$("[id$='changedProposedId']").removeProp('disabled');
        j$("[id$='changedCurrentId']").removeProp('disabled');
        j$("[id$='changedSoldId']").removeProp('disabled');
    }            
}

//2016-11-21- anirudh.singh@cdk.com- Added the below method for pdf version of the component i.e. ALL_DiscoverySolutionForPDF.
function processCheckBoxesForSolutionPDF()
{
    var pdfSolutionAtSiteComponent=j$('.pdfSolutionAtSiteComponent');
    var pdfCheckboxFields=pdfSolutionAtSiteComponent.find('.pdfCheckboxField');
    
    pdfCheckboxFields.each(function()
	{
        var checkboxValue=j$(this).prop('innerText');
        
        if(checkboxValue!=null && checkboxValue!='')
        {
            var checkboxIcon;
            
            if(checkboxValue=='true')
            {
                checkboxIcon='<i class="fa fa-check-square-o pdfCheckboxIcon" aria-hidden="true"></i>';
            }
            else
            {
                checkboxIcon='<i class="fa fa-square-o pdfCheckboxIcon" aria-hidden="true"></i>';
            }
            
            j$(this).replaceWith(checkboxIcon);
        }
    });
}

(function($) {
    $.fn.filterTable = function(filter, columnname) {
        var index = null;        
        this.find("thead > tr:first > th").each(function(i) {
            if ($.trim($(this).text()) == columnname) {
                index = i;
                return false;
            }
        });
        if (index == null)
            throw ("filter columnname: " + columnname + " not found");
        
        this.find("tbody:first > tr").each(function() {
            var row = $(this);
            if (filter == "") {
                row.show();
            }
            else {
                var cellText = row.find("td:eq(" + index + ")").find('option:selected').text().toLowerCase();
                if (cellText == "") {
                    cellText = $(row.find(("td:eq(" + index + ")"))).text().toLowerCase();
                }
                if (cellText.indexOf(filter.toLowerCase()) == -1) {
                    row.hide();
                }
                else {
                    row.show();
                }
            }            
        });
        return this;
    };
})(jQuery);

(function ($) {
    $.extend({
        tablesorter: new
        function () {

            var parsers = [],
                widgets = [];

            this.defaults = {
                cssHeader: "header",
                cssAsc: "headerSortUp",
                cssDesc: "headerSortDown",
                cssChildRow: "expand-child",
                sortInitialOrder: "asc",
                sortMultiSortKey: "shiftKey",
                sortForce: null,
                sortAppend: null,
                sortLocaleCompare: true,
                textExtraction: "simple",
                parsers: {}, widgets: [],
                widgetZebra: {
                    css: ["even", "odd"]
                }, headers: {}, widthFixed: false,
                cancelSelection: true,
                sortList: [],
                headerList: [],
                dateFormat: "us",
                decimal: '/\.|\,/g',
                onRenderHeader: null,
                selectorHeaders: 'thead th',
                debug: false
            };

            /* debuging utils */

            function benchmark(s, d) {
                log(s + "," + (new Date().getTime() - d.getTime()) + "ms");
            }

            this.benchmark = benchmark;

            function log(s) {
                if (typeof console != "undefined" && typeof console.debug != "undefined") {
                    console.log(s);
                } else {
                    alert(s);
                }
            }

            /* parsers utils */

            function buildParserCache(table, $headers) {

                if (table.config.debug) {
                    var parsersDebug = "";
                }

                if (table.tBodies.length == 0) return; // In the case of empty tables
                var rows = table.tBodies[0].rows;

                if (rows[0]) {

                    var list = [],
                        cells = rows[0].cells,
                        l = cells.length;

                    for (var i = 0; i < l; i++) {

                        var p = false;

                        if ($.metadata && ($($headers[i]).metadata() && $($headers[i]).metadata().sorter)) {

                            p = getParserById($($headers[i]).metadata().sorter);

                        } else if ((table.config.headers[i] && table.config.headers[i].sorter)) {

                            p = getParserById(table.config.headers[i].sorter);
                        }
                        if (!p) {

                            p = detectParserForColumn(table, rows, -1, i);
                        }

                        if (table.config.debug) {
                            parsersDebug += "column:" + i + " parser:" + p.id + "\n";
                        }

                        list.push(p);
                    }
                }

                if (table.config.debug) {
                    log(parsersDebug);
                }

                return list;
            };

            function detectParserForColumn(table, rows, rowIndex, cellIndex) {
                var l = parsers.length,
                    node = false,
                    nodeValue = false,
                    keepLooking = true;
                while (nodeValue == '' && keepLooking) {
                    rowIndex++;
                    if (rows[rowIndex]) {
                        node = getNodeFromRowAndCellIndex(rows, rowIndex, cellIndex);
                        nodeValue = trimAndGetNodeText(table.config, node);
                        if (table.config.debug) {
                            log('Checking if value was empty on row:' + rowIndex);
                        }
                    } else {
                        keepLooking = false;
                    }
                }
                for (var i = 1; i < l; i++) {
                    if (parsers[i].is(nodeValue, table, node)) {
                        return parsers[i];
                    }
                }
                // 0 is always the generic parser (text)
                return parsers[0];
            }

            function getNodeFromRowAndCellIndex(rows, rowIndex, cellIndex) {
                return rows[rowIndex].cells[cellIndex];
            }

            function trimAndGetNodeText(config, node) {
                return $.trim(getElementText(config, node));
            }

            function getParserById(name) {
                var l = parsers.length;
                for (var i = 0; i < l; i++) {
                    if (parsers[i].id.toLowerCase() == name.toLowerCase()) {
                        return parsers[i];
                    }
                }
                return false;
            }

            /* utils */

            function buildCache(table) {

                if (table.config.debug) {
                    var cacheTime = new Date();
                }

                var totalRows = (table.tBodies[0] && table.tBodies[0].rows.length) || 0,
                    totalCells = (table.tBodies[0].rows[0] && table.tBodies[0].rows[0].cells.length) || 0,
                    parsers = table.config.parsers,
                    cache = {
                        row: [],
                        normalized: []
                    };

                for (var i = 0; i < totalRows; ++i) {

                    /** Add the table data to main data array */
                    var c = $(table.tBodies[0].rows[i]),
                        cols = [];

                    // if this is a child row, add it to the last row's children and
                    // continue to the next row
                    if (c.hasClass(table.config.cssChildRow)) {
                        cache.row[cache.row.length - 1] = cache.row[cache.row.length - 1].add(c);
                        // go to the next for loop
                        continue;
                    }

                    cache.row.push(c);

                    for (var j = 0; j < totalCells; ++j) {
                        cols.push(parsers[j].format(getElementText(table.config, c[0].cells[j]), table, c[0].cells[j]));
                    }

                    cols.push(cache.normalized.length); // add position for rowCache
                    cache.normalized.push(cols);
                    cols = null;
                };

                if (table.config.debug) {
                    benchmark("Building cache for " + totalRows + " rows:", cacheTime);
                }

                return cache;
            };

            function getElementText(config, node) {

                var text = "";

                if (!node) return "";

                if (!config.supportsTextContent) config.supportsTextContent = node.textContent || false;

                if (config.textExtraction == "simple") {
                    if (config.supportsTextContent) {
                        text = node.textContent;
                    } else {
                        if (node.childNodes[0] && node.childNodes[0].hasChildNodes()) {
                            text = node.childNodes[0].innerHTML;
                        } else {
                            text = node.innerHTML;
                        }
                    }
                } else {
                    if (typeof(config.textExtraction) == "function") {
                        text = config.textExtraction(node);
                    } else {
                        text = $(node).text();
                    }
                }
                return text;
            }

            function appendToTable(table, cache) {

                if (table.config.debug) {
                    var appendTime = new Date()
                }

                var c = cache,
                    r = c.row,
                    n = c.normalized,
                    totalRows = n.length,
                    checkCell = (n[0].length - 1),
                    tableBody = $(table.tBodies[0]),
                    rows = [];


                for (var i = 0; i < totalRows; i++) {
                    var pos = n[i][checkCell];

                    rows.push(r[pos]);

                    if (!table.config.appender) {

                        //var o = ;
                        var l = r[pos].length;
                        for (var j = 0; j < l; j++) {
                            tableBody[0].appendChild(r[pos][j]);
                        }

                        // 
                    }
                }



                if (table.config.appender) {

                    table.config.appender(table, rows);
                }

                rows = null;

                if (table.config.debug) {
                    benchmark("Rebuilt table:", appendTime);
                }

                // apply table widgets
                applyWidget(table);

                // trigger sortend
                setTimeout(function () {
                    $(table).trigger("sortEnd");
                }, 0);

            };
function buildHeaders(table) {

                if (table.config.debug) {
                    var time = new Date();
                }

                var meta = ($.metadata) ? true : false;
                
                var header_index = computeTableHeaderCellIndexes(table);

                $tableHeaders = $(table.config.selectorHeaders, table).each(function (index) {

                    this.column = header_index[this.parentNode.rowIndex + "-" + this.cellIndex];
                    // this.column = index;
                    this.order = formatSortingOrder(table.config.sortInitialOrder);
                    
					
					this.count = this.order;

                    if (checkHeaderMetadata(this) || checkHeaderOptions(table, index)) this.sortDisabled = true;
					if (checkHeaderOptionsSortingLocked(table, index)) this.order = this.lockedOrder = checkHeaderOptionsSortingLocked(table, index);

                    if (!this.sortDisabled) {
                        var $th = $(this).addClass(table.config.cssHeader);
                        if (table.config.onRenderHeader) table.config.onRenderHeader.apply($th);
                    }

                    // add cell to headerList
                    table.config.headerList[index] = this;
                });

                if (table.config.debug) {
                    benchmark("Built headers:", time);
                    log($tableHeaders);
                }

                return $tableHeaders;

            };

            // from:
            // http://www.javascripttoolbox.com/lib/table/examples.php
            // http://www.javascripttoolbox.com/temp/table_cellindex.html


            function computeTableHeaderCellIndexes(t) {
                var matrix = [];
                var lookup = {};
                var thead = t.getElementsByTagName('THEAD')[0];
                var trs = thead.getElementsByTagName('TR');

                for (var i = 0; i < trs.length; i++) {
                    var cells = trs[i].cells;
                    for (var j = 0; j < cells.length; j++) {
                        var c = cells[j];

                        var rowIndex = c.parentNode.rowIndex;
                        var cellId = rowIndex + "-" + c.cellIndex;
                        var rowSpan = c.rowSpan || 1;
                        var colSpan = c.colSpan || 1
                        var firstAvailCol;
                        if (typeof(matrix[rowIndex]) == "undefined") {
                            matrix[rowIndex] = [];
                        }
                        // Find first available column in the first row
                        for (var k = 0; k < matrix[rowIndex].length + 1; k++) {
                            if (typeof(matrix[rowIndex][k]) == "undefined") {
                                firstAvailCol = k;
                                break;
                            }
                        }
                        lookup[cellId] = firstAvailCol;
                        for (var k = rowIndex; k < rowIndex + rowSpan; k++) {
                            if (typeof(matrix[k]) == "undefined") {
                                matrix[k] = [];
                            }
                            var matrixrow = matrix[k];
                            for (var l = firstAvailCol; l < firstAvailCol + colSpan; l++) {
                                matrixrow[l] = "x";
                            }
                        }
                    }
                }
                return lookup;
            }

            function checkCellColSpan(table, rows, row) {
                var arr = [],
                    r = table.tHead.rows,
                    c = r[row].cells;

                for (var i = 0; i < c.length; i++) {
                    var cell = c[i];

                    if (cell.colSpan > 1) {
                        arr = arr.concat(checkCellColSpan(table, headerArr, row++));
                    } else {
                        if (table.tHead.length == 1 || (cell.rowSpan > 1 || !r[row + 1])) {
                            arr.push(cell);
                        }
                        // headerArr[row] = (i+row);
                    }
                }
                return arr;
            };

            function checkHeaderMetadata(cell) {
                if (($.metadata) && ($(cell).metadata().sorter === false)) {
                    return true;
                };
                return false;
            }

            function checkHeaderOptions(table, i) {
                if ((table.config.headers[i]) && (table.config.headers[i].sorter === false)) {
                    return true;
                };
                return false;
            }
			
			 function checkHeaderOptionsSortingLocked(table, i) {
                if ((table.config.headers[i]) && (table.config.headers[i].lockedOrder)) return table.config.headers[i].lockedOrder;
                return false;
            }
			
            function applyWidget(table) {
                var c = table.config.widgets;
                var l = c.length;
                for (var i = 0; i < l; i++) {

                    getWidgetById(c[i]).format(table);
                }

            }

            function getWidgetById(name) {
                var l = widgets.length;
                for (var i = 0; i < l; i++) {
                    if (widgets[i].id.toLowerCase() == name.toLowerCase()) {
                        return widgets[i];
                    }
                }
            };

            function formatSortingOrder(v) {
                if (typeof(v) != "Number") {
                    return (v.toLowerCase() == "desc") ? 1 : 0;
                } else {
                    return (v == 1) ? 1 : 0;
                }
            }

            function isValueInArray(v, a) {
                var l = a.length;
                for (var i = 0; i < l; i++) {
                    if (a[i][0] == v) {
                        return true;
                    }
                }
                return false;
            }

            function setHeadersCss(table, $headers, list, css) {
                // remove all header information
                $headers.removeClass(css[0]).removeClass(css[1]);

                var h = [];
                $headers.each(function (offset) {
                    if (!this.sortDisabled) {
                        h[this.column] = $(this);
                    }
                });

                var l = list.length;
                for (var i = 0; i < l; i++) {
                    h[list[i][0]].addClass(css[list[i][1]]);
                }
            }

            function fixColumnWidth(table, $headers) {
                var c = table.config;
                if (c.widthFixed) {
                    var colgroup = $('<colgroup>');
                    $("tr:first td", table.tBodies[0]).each(function () {
                        colgroup.append($('<col>').css('width', $(this).width()));
                    });
                    $(table).prepend(colgroup);
                };
            }
            function updateHeaderSortCount(table, sortList) {
                var c = table.config,
                    l = sortList.length;
                for (var i = 0; i < l; i++) {
                    var s = sortList[i],
                        o = c.headerList[s[0]];
                    o.count = s[1];
                    o.count++;
                }
            }

            /* sorting methods */

            function multisort(table, sortList, cache) {

                if (table.config.debug) {
                    var sortTime = new Date();
                }

                var dynamicExp = "var sortWrapper = function(a,b) {",
                    l = sortList.length;

                // TODO: inline functions.
                for (var i = 0; i < l; i++) {

                    var c = sortList[i][0];
                    var order = sortList[i][1];
                    // var s = (getCachedSortType(table.config.parsers,c) == "text") ?
                    // ((order == 0) ? "sortText" : "sortTextDesc") : ((order == 0) ?
                    // "sortNumeric" : "sortNumericDesc");
                    // var s = (table.config.parsers[c].type == "text") ? ((order == 0)
                    // ? makeSortText(c) : makeSortTextDesc(c)) : ((order == 0) ?
                    // makeSortNumeric(c) : makeSortNumericDesc(c));
                    var s = (table.config.parsers[c].type == "text") ? ((order == 0) ? makeSortFunction("text", "asc", c) : makeSortFunction("text", "desc", c)) : ((order == 0) ? makeSortFunction("numeric", "asc", c) : makeSortFunction("numeric", "desc", c));
                    var e = "e" + i;

                    dynamicExp += "var " + e + " = " + s; // + "(a[" + c + "],b[" + c
                    // + "]); ";
                    dynamicExp += "if(" + e + ") { return " + e + "; } ";
                    dynamicExp += "else { ";

                }

                // if value is the same keep orignal order
                var orgOrderCol = cache.normalized[0].length - 1;
                dynamicExp += "return a[" + orgOrderCol + "]-b[" + orgOrderCol + "];";

                for (var i = 0; i < l; i++) {
                    dynamicExp += "}; ";
                }

                dynamicExp += "return 0; ";
                dynamicExp += "}; ";

                if (table.config.debug) {
                    benchmark("Evaling expression:" + dynamicExp, new Date());
                }

                eval(dynamicExp);

                cache.normalized.sort(sortWrapper);

                if (table.config.debug) {
                    benchmark("Sorting on " + sortList.toString() + " and dir " + order + " time:", sortTime);
                }

                return cache;
            };

            function makeSortFunction(type, direction, index) {
                var a = "a[" + index + "]",
                    b = "b[" + index + "]";
                if (type == 'text' && direction == 'asc') {
                    return "(" + a + " == " + b + " ? 0 : (" + a + " === null ? Number.POSITIVE_INFINITY : (" + b + " === null ? Number.NEGATIVE_INFINITY : (" + a + " < " + b + ") ? -1 : 1 )));";
                } else if (type == 'text' && direction == 'desc') {
                    return "(" + a + " == " + b + " ? 0 : (" + a + " === null ? Number.POSITIVE_INFINITY : (" + b + " === null ? Number.NEGATIVE_INFINITY : (" + b + " < " + a + ") ? -1 : 1 )));";
                } else if (type == 'numeric' && direction == 'asc') {
                    return "(" + a + " === null && " + b + " === null) ? 0 :(" + a + " === null ? Number.POSITIVE_INFINITY : (" + b + " === null ? Number.NEGATIVE_INFINITY : " + a + " - " + b + "));";
                } else if (type == 'numeric' && direction == 'desc') {
                    return "(" + a + " === null && " + b + " === null) ? 0 :(" + a + " === null ? Number.POSITIVE_INFINITY : (" + b + " === null ? Number.NEGATIVE_INFINITY : " + b + " - " + a + "));";
                }
            };

            function makeSortText(i) {
                return "((a[" + i + "] < b[" + i + "]) ? -1 : ((a[" + i + "] > b[" + i + "]) ? 1 : 0));";
            };

            function makeSortTextDesc(i) {
                return "((b[" + i + "] < a[" + i + "]) ? -1 : ((b[" + i + "] > a[" + i + "]) ? 1 : 0));";
            };

            function makeSortNumeric(i) {
                return "a[" + i + "]-b[" + i + "];";
            };

            function makeSortNumericDesc(i) {
                return "b[" + i + "]-a[" + i + "];";
            };

            function sortText(a, b) {
                if (table.config.sortLocaleCompare) return a.localeCompare(b);
                return ((a < b) ? -1 : ((a > b) ? 1 : 0));
            };

            function sortTextDesc(a, b) {
                if (table.config.sortLocaleCompare) return b.localeCompare(a);
                return ((b < a) ? -1 : ((b > a) ? 1 : 0));
            };

            function sortNumeric(a, b) {
                return a - b;
            };

            function sortNumericDesc(a, b) {
                return b - a;
            };

            function getCachedSortType(parsers, i) {
                return parsers[i].type;
            }; /* public methods */
            this.construct = function (settings) {
                return this.each(function () {
                    // if no thead or tbody quit.
                    if (!this.tHead || !this.tBodies) return;
                    // declare
                    var $this, $document, $headers, cache, config, shiftDown = 0,
                        sortOrder;
                    // new blank config object
                    this.config = {};
                    // merge and extend.
                    config = $.extend(this.config, $.tablesorter.defaults, settings);
                    // store common expression for speed
                    $this = $(this);
                    // save the settings where they read
                    $.data(this, "tablesorter", config);
                    // build headers
                    $headers = buildHeaders(this);
                    // try to auto detect column type, and store in tables config
                    this.config.parsers = buildParserCache(this, $headers);
                    // build the cache for the tbody cells
                    cache = buildCache(this);
                    // get the css class names, could be done else where.
                    var sortCSS = [config.cssDesc, config.cssAsc];
                    // fixate columns if the users supplies the fixedWidth option
                    fixColumnWidth(this);
                    // apply event handling to headers
                    // this is to big, perhaps break it out?
                    $headers.click(

                    function (e) {
                        var totalRows = ($this[0].tBodies[0] && $this[0].tBodies[0].rows.length) || 0;
                        if (!this.sortDisabled && totalRows > 0) {
                            // Only call sortStart if sorting is
                            // enabled.
                            $this.trigger("sortStart");
                            // store exp, for speed
                            var $cell = $(this);
                            // get current column index
                            var i = this.column;
                            // get current column sort order
                            this.order = this.count++ % 2;
							// always sort on the locked order.
							if(this.lockedOrder) this.order = this.lockedOrder;
							
							// user only whants to sort on one
                            // column
                            if (!e[config.sortMultiSortKey]) {
                                // flush the sort list
                                config.sortList = [];
                                if (config.sortForce != null) {
                                    var a = config.sortForce;
                                    for (var j = 0; j < a.length; j++) {
                                        if (a[j][0] != i) {
                                            config.sortList.push(a[j]);
                                        }
                                    }
                                }
                                // add column to sort list
                                config.sortList.push([i, this.order]);
                                // multi column sorting
                            } else {
                                // the user has clicked on an all
                                // ready sortet column.
                                if (isValueInArray(i, config.sortList)) {
                                    // revers the sorting direction
                                    // for all tables.
                                    for (var j = 0; j < config.sortList.length; j++) {
                                        var s = config.sortList[j],
                                            o = config.headerList[s[0]];
                                        if (s[0] == i) {
                                            o.count = s[1];
                                            o.count++;
                                            s[1] = o.count % 2;
                                        }
                                    }
                                } else {
                                    // add column to sort list array
                                    config.sortList.push([i, this.order]);
                                }
                            };
                            setTimeout(function () {
                                // set css for headers
                                setHeadersCss($this[0], $headers, config.sortList, sortCSS);
                                appendToTable(
	                                $this[0], multisort(
	                                $this[0], config.sortList, cache)
								);
                            }, 1);
                            // stop normal event by returning false
                            return false;
                        }
                        // cancel selection
                    }).mousedown(function () {
                        if (config.cancelSelection) {
                            this.onselectstart = function () {
                                return false
                            };
                            return false;
                        }
                    });
                    // apply easy methods that trigger binded events
                    $this.bind("update", function () {
                        var me = this;
                        setTimeout(function () {
                            // rebuild parsers.
                            me.config.parsers = buildParserCache(
                            me, $headers);
                            // rebuild the cache map
                            cache = buildCache(me);
                        }, 1);
                    }).bind("updateCell", function (e, cell) {
                        var config = this.config;
                        // get position from the dom.
                        var pos = [(cell.parentNode.rowIndex - 1), cell.cellIndex];
                        // update cache
                        cache.normalized[pos[0]][pos[1]] = config.parsers[pos[1]].format(
                        getElementText(config, cell), cell);
                    }).bind("sorton", function (e, list) {
                        $(this).trigger("sortStart");
                        config.sortList = list;
                        // update and store the sortlist
                        var sortList = config.sortList;
                        // update header count index
                        updateHeaderSortCount(this, sortList);
                        // set css for headers
                        setHeadersCss(this, $headers, sortList, sortCSS);
                        // sort the table and append it to the dom
                        appendToTable(this, multisort(this, sortList, cache));
                    }).bind("appendCache", function () {
                        appendToTable(this, cache);
                    }).bind("applyWidgetId", function (e, id) {
                        getWidgetById(id).format(this);
                    }).bind("applyWidgets", function () {
                        // apply widgets
                        applyWidget(this);
                    });
                    if ($.metadata && ($(this).metadata() && $(this).metadata().sortlist)) {
                        config.sortList = $(this).metadata().sortlist;
                    }
                    // if user has supplied a sort list to constructor.
                    if (config.sortList.length > 0) {
                        $this.trigger("sorton", [config.sortList]);
                    }
                    // apply widgets
                    applyWidget(this);
                });
            };
this.addParser = function (parser) {
                var l = parsers.length,
                    a = true;
                for (var i = 0; i < l; i++) {
                    if (parsers[i].id.toLowerCase() == parser.id.toLowerCase()) {
                        a = false;
                    }
                }
                if (a) {
                    parsers.push(parser);
                };
            };
            this.addWidget = function (widget) {
                widgets.push(widget);
            };
            this.formatFloat = function (s) {
                var i = parseFloat(s);
                return (isNaN(i)) ? 0 : i;
            };
            this.formatInt = function (s) {
                var i = parseInt(s);
                return (isNaN(i)) ? 0 : i;
            };
            this.isDigit = function (s, config) {
                // replace all an wanted chars and match.
                return /^[-+]?\d*$/.test($.trim(s.replace(/[,.']/g, '')));
            };
            this.clearTableBody = function (table) {
                if ($.browser.msie) {
                    function empty() {
                        while (this.firstChild)
                        this.removeChild(this.firstChild);
                    }
                    empty.apply(table.tBodies[0]);
                } else {
                    table.tBodies[0].innerHTML = "";
                }
            };
        }
    });
    
    // extend plugin scope
    $.fn.extend({
        tablesorter: $.tablesorter.construct
    });

    // make shortcut
    var ts = $.tablesorter;

    // add default parsers
    ts.addParser({
        id: "text",
        is: function (s) {
            return true;
        }, format: function (s) {
            return $.trim(s.toLocaleLowerCase());
        }, type: "text"
    });

    ts.addParser({
        id: "digit",
        is: function (s, table) {
            var c = table.config;
            return $.tablesorter.isDigit(s, c);
        }, format: function (s) {
            return $.tablesorter.formatFloat(s);
        }, type: "numeric"
    });
    // add default widgets
    ts.addWidget({
        id: "zebra",
        format: function (table) {
            if (table.config.debug) {
                var time = new Date();
            }
            var $tr, row = -1,
                odd;
            // loop through the visible rows
            $("tr:visible", table.tBodies[0]).each(function (i) {
                $tr = $(this);
                // style children rows the same way the parent
                // row was styled
                if (!$tr.hasClass(table.config.cssChildRow)) row++;
                odd = (row % 2 == 0);
                $tr.removeClass(
                table.config.widgetZebra.css[odd ? 0 : 1]).addClass(
                table.config.widgetZebra.css[odd ? 1 : 0])
            });
            if (table.config.debug) {
                $.tablesorter.benchmark("Applying Zebra widget", time);
            }
        }
    });
})(jQuery);


(function ($) {
    var TABLE_ID = 0;
    $.fn.freezeHeader = function (params) {

        var copiedHeader = false;

        function freezeHeader(elem) {
            var idObj = elem.attr('id') || ('tbl-' + (++TABLE_ID));
            if (elem.length > 0 && elem[0].tagName.toLowerCase() == "table") {

                var obj = {
                    id: idObj,
                    grid: elem,
                    container: null,
                    header: null,
                    divScroll: null,
                    openDivScroll: null,
                    closeDivScroll: null,
                    scroller: null
                };

                if (params && params.height !== undefined) {
                    obj.divScroll = '<div id="hdScroll' + obj.id + '" style="height: ' + params.height + '; overflow-y: scroll">';
                    obj.closeDivScroll = '</div>';
                }

                obj.header = obj.grid.find('thead');

                if (params && params.height !== undefined) {
                    if ($('#hdScroll' + obj.id).length == 0) {
                        obj.grid.wrapAll(obj.divScroll);
                    }
                }

                obj.scroller = params && params.height !== undefined
                   ? $('#hdScroll' + obj.id)
                   : $(window);

                if (params && params.scrollListenerEl !== undefined) {
                    obj.scroller = params.scrollListenerEl;
                }
                obj.scroller.on('scroll', function () {
                    if ($('#hd' + obj.id).length == 0) {
                        obj.grid.before('<div id="hd' + obj.id + '"></div>');
                    }

                    obj.container = $('#hd' + obj.id);

                    if (obj.header.offset() != null) {
                        if (limiteAlcancado(obj, params)) {
                            elem.trigger("freeze:on");
                            if (!copiedHeader) {
                                cloneHeaderRow(obj);
                                copiedHeader = true;
                            }
                        }
                        else {

                            if (($(document).scrollTop() > obj.header.offset().top)) {
                                obj.container.css("position", "absolute");
                                obj.container.css("top", (obj.grid.find("tr:last").offset().top - obj.header.height()) + "px");
                            }
                            else {
                                elem.trigger("freeze:off");
                                obj.container.css("visibility", "hidden");
                                obj.container.css("top", "0px");
                                obj.container.width(0);
                            }
                            copiedHeader = false;
                        }
                    }

                });
            }
        }

        function limiteAlcancado(obj, params) {
            if (params && (params.height !== undefined || params.scrollListenerEl !== undefined)) {
                return (obj.header.offset().top <= obj.scroller.offset().top);
            }
            else {
                var top = obj.header.offset().top;
                if (params) {
                    if (params.offset !== undefined) {
                       top -= parseInt(params.offset.replace('px',''),10);
                    }
                }

                var gridHeight = (obj.grid.height() - obj.header.height() - obj.grid.find("tr:last").height()) + obj.header.offset().top;
                return ($(document).scrollTop() > top && $(document).scrollTop() < gridHeight);
            }
        }

        function cloneHeaderRow(obj) {
            obj.container.html('');
            obj.container.val('');
            var tabela = $('<table style="margin: 0 0;"></table>');
            var atributos = obj.grid.prop("attributes");

            $.each(atributos, function () {
                if (this.name != "id") {
                    tabela.attr(this.name, this.value);
                }
            });

            var clone = obj.header.clone(true);
            
            clone.appendTo(tabela);

            obj.container.append(tabela);
            obj.container.width(obj.header.width());
            obj.container.height(obj.header.height);
            obj.container.find('th').each(function (index) {
                var cellWidth = obj.grid.find('th').eq(index).width();
                $(this).css('width', cellWidth);
            });

            obj.container.css("visibility", "visible");

            if (params && params.height !== undefined) {
               
                if(params.offset !== undefined){
                    obj.container.css("top", obj.scroller.offset().top + (params.offset.replace("px","") * 1) + "px");
                }
                else
                {
                    obj.container.css("top", obj.scroller.offset().top + "px");
                }
                
            obj.container.css("position", "absolute");
                
            } else if (params && params.scrollListenerEl!== undefined) { 
                obj.container.css("top", obj.scroller.find("thead > tr").innerHeight() + "px");
                obj.container.css("position", "absolute");
                obj.container.css("z-index", "2");
            } else if (params && params.offset !== undefined) {
                obj.container.css("top", params.offset);
                obj.container.css("position", "fixed");
            } else {
                obj.container.css("top", "50px");
                obj.container.css("position", "fixed");
            }
        }

        return this.each(function (i, e) {
            freezeHeader($(e));
        });

    };
})(jQuery);