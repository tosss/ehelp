$j = jQuery.noConflict();
function loadTree(jsonRawData,treeId) {
	$j('#' + treeId).jstree({
		"checkbox" : {
			"tie_selection" : false,
			"whole_node" : false
		},
		"plugins" : ["checkbox"],
		"core" : {
			"multiple" : false,
			"data" : function (node, cb) {
				loadNodes(this, node, cb, jsonRawData);
			}
		}
	}).on('hover_node.jstree', function (e, data) {
		$j("#" + data.node.id).prop('title', $j('#jstree_div').jstree(true).get_node(data.node.id).data.description);
	});

}

function loadNodes(tree, node, cb, jsonData) {
	var nodes = [];
	$j.each(jsonData.jsonTreeData, function () {
		nodes.push({
			id : this.id,
			text : this.text,
			parent : this.parent,
			state : this.state,
			data : this.data
		});
	});

	cb.call(tree, nodes);
}

function jsTreeExpandAll(treeId) {
	$j('#' + treeId).jstree('open_all');
}

function jsTreeCollapseAll(treeId) {
	$j('#' + treeId).jstree('close_all');
}

function resetTree(treeId) {
	$j('#' + treeId).jstree('uncheck_all').jstree('close_all');
}

function getAllCheckNodes(treeId,parent, child, parentDescription, childDescription,maxSelected) {
	var checkedParent_ids = [];
	var checkedChild_ids = [];
	var allOpenedNode_ids = [];
	//get all checked and undertermined values
	var selected = $j('#' + treeId).jstree(true).get_checked(),
	i,
	j;
	for (i = 0, j = selected.length; i < j; i++) {
		selected = selected.concat($j('#' + treeId).jstree(true).get_node(selected[i]).parents);
	}
	//remove all duplicate id
	selected = $j.vakata.array_unique(selected);
    var numberOfSelectedRecord = 0;
	$j(selected).each
	(
		function (i, element) {
		if (element != '#' && element != '') {
			var nodeObject = $j('#' + treeId).jstree(true).get_node(element).data.objectName;
           
			if (nodeObject == parent) {
				checkedParent_ids.push('\'' + element + '\'');               
			} else if (nodeObject == child) {
				checkedChild_ids.push('\'' + element + '\'');
			}
			if (nodeObject != child) {
				allOpenedNode_ids.push('\'' + element + '\'');
			}
            //2015-10-05 Rey Austral - count all the selected root parent
            if ($j('#' + treeId).jstree(true).get_parent(element) == '#') {
                 numberOfSelectedRecord++;
            }
		}

	});
    
	if (checkedParent_ids == '' && checkedChild_ids == '') {
		alert('No records selected. Please check/select at least one record in the tree');
    } else if (maxSelected < numberOfSelectedRecord){ 
    	alert('You selected ' + numberOfSelectedRecord +' parent records, only ' + maxSelected + ' parents can be selected.');
    } else if (checkedChild_ids == '') {
		alert('No record selected in the ' + childDescription);
	} else if (checkedParent_ids == '') {
		alert('No record selected in the ' + parentDescription);
	} else {		
		somethingSelected(checkedParent_ids.toString(), checkedChild_ids.toString(), allOpenedNode_ids.toString(), parent, child);
		disableNode(treeId);
	}

}

/* 2015-05-29 PH TIME Rey Austral - Added to disable the tree  */ 
function disableNode(treeId) {
    var allNode = $j('#' + treeId).jstree(true).get_json('#', {flat:true});
    $j(allNode).each
    (
        function (i, element) {            
            $j('#' + treeId).jstree(true).disable_node(element);            
        }
    );    
    $j('.edit_button').attr("disabled", "disabled").addClass('disabled_button');
    $j('#btnRest').attr("disabled", "disabled").addClass('disabled_button');
    
}

function showTreePanel(toShow) {
	//to update, toShow value would be derive in the custom settings
	if (toShow != null && toShow== false) 
    {
        //hide the tree
        $j('.container_tree').css('display','none');  
        //show the toggle panel
        $j('#sidebarCell').show();     
    }	
}

function closePage(redirect) {
	var message = confirm("If you have unsaved data, press Cancel and save before you proceed. Otherwise press Ok to proceed?");
	if (message) {
		window.open(redirect,'_self');
	}
}

/* 2015-05-29 PH TIME Rey Austral - Added to hide or show the tree  */ 
function togglePanel() {
    //check if the tree panel is visible, if no the show the tree panel and adjust the position of the datatable
    if ($j('.container_tree').css('display') == 'none')
    {
        //show the tree panel
        $j('.container_tree').css('display','block');
        //manual move the datatable location because it will not automatically move even the tree is shown
        //change the left css value, + 23 is the space between the tree and datatable
        $j('.container_datatable').css('left',$j('.container_tree').width() + 23);
        //+ 23 is the space between the tree and datatable
        $j('.container_page').css('width', $j('.container_datatable').width() +  $j('.container_tree').width() + 23);  
       	//set again because the datatable width change after the first initialization of the width of the page
        $j('.container_page').css('width', $j('.container_datatable').width() +  $j('.container_tree').width() + 23);   
       //remove the class sidebarCollapsed to change the appearance of the toggle       
        $j('#sidebarCell').removeClass('sidebarCollapsed');
    }
    else
    {
        //hide the tree
        $j('.container_tree').css('display','none'); 
        //move the datatable going to the left most of the scree
        $j('.container_datatable').css('left','0');
       //add the class to change the appearance of the toggle
        $j('#sidebarCell').addClass('sidebarCollapsed');
        //revert to the original size of the page
        $j('.container_page').css('width','100%');        
        
    }
}