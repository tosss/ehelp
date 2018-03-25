/* Page Styles */
body {
    background-color: #EEE !important;
} 
h2 {
    font-size: 0.5em;
}
.wrapper {
    padding: 0px !important;
    box-shadow: 0px 0px 4px 0px rgba(0, 0, 0, 0.2);
    /*box-shadow: 0px 0px 6px 0px rgba(255, 255, 255, 0.8);*/
}
.container {
    background-color: #fff;
    width: 100% !important;
}

/* Associate Community Navbar Link */
.navbar {
    margin: 0 !important;
}
.navbar .navbar-brand, .navbar div ul li a {
    color: #777;
    /*color: #a7a9ac;*/ /* CDK Grey */
    /*color: #83c900;*/ /* CDK Green */
}

.globalHeaderBar .zen-select, .zen .globalHeaderBar .zen-select {
    z-index: 1001;
    font-size: .75em;
}

/* Generic Hide */
.hide {
    display: none !important;
}

/* Hide Standard Salesforce Portal Footer */
.zen-pageFooter {
    display: none !important;
}

/* Hide Standard Salesforce Portal Tabs */
#tabContainer {
    display: none !important;
}

/* Hide Standard Salesforce Sidebar */
#sidebarCell, .sidebarCell {
    display: none !important;
}

/* Fix Chatter Styles */
.publishercontainer .bottomBar {
    min-height: 50px;
}

.chatterHover .hoverInfo {
    padding: 10px 0;
}

.feedcontainer .feeditemcommentplaceholder input {
    height: 1.8em;
    min-height: 1.8em;
}

.newcommenttextwrapper textarea {
    min-height: 52px !important;
}

.userProfilePage .leftContent .photoSection {
    width: 202px !important;
}

.threecolumn .leftContent, .userProfilePage .leftContent {
    width: 202px !important;
}

.userProfilePage .leftContent .profileImage { 
    border: 1px solid #dbefe4 !important;
    width: 202px !important;
}

.sidetabsContainer {
    display: none !important;
}
input[type=text] {
    min-height: 24px;
}