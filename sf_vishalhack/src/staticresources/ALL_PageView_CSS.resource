/* 2015-05-29 PH TIME Rey Austral - change all the class to handle the hiding and showing of the tree  */
.container_page {
    position:relative;width:100%;
    float:left;
    display:block;
}

.container_tree {
    position :relative;
    float:left;
    left:100%;
    width: 405px;   
    height:100%;
    margin-left:-100%;
     
}

.container_datatable {        
    position :relative;
    float:left;
}

.container_tree_toggle {
    position :relative;
    float:left;
    left:100%;
    
    cursor:pointer;
    height:90px;
    display:none;
    margin-left:-100%;   
    top:1px;    
}

.toggleButton {
    background:url(/img/alohaSkin/sidebar_sprite.png) 0 0 no-repeat;
}

.return_btn {
    width : 230px;
    height: 31px;
}

#handlebarContainer {
    left: 411px ;
}

.sidebarCollapsible {
    padding:0;
}

.sidebarCollapsed #handlebarContainer {
    left:-20px;
}