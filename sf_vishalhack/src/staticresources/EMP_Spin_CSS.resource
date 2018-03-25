/*
* created by: cloudsherpas
* updated by: Matt Keefe, 2014-07-08
*/

@font-face {
    font-family: "Amasis", Georgia, serif;
}

body {
    margin-top: 0;
    background: url(images/banner.jpg) no-repeat top #fff;
}

p {
    font: 12px/1.5 Helvetica, sans-serif;
    color: #555;
    text-align: left;
    margin-top: 0;
    margin-bottom: 12px;
}

h1 {
   font-family: "Amasis", Georgia, serif;
   font-weight: normal;
   font-size: 24px;
   margin: 0;
   padding: 0;
   color: #cc092f;
}

h2 {
    font: 18px/1.5 Helvetica, Verdana, sans-serif;
    color:#fff;
    padding: 0;
    margin:0 20px 0 0;
    position:relative;
    text-align:right;
    top:90px;
}

h3 {
    font: 500 18px/1.5 Palatino, Book Antiqua, serif;
    margin: 0;
    padding: 15px 0 0 0;
    color:#cb1d2b;
    text-align:left;
    line-height:112%;
}

ul {
    list-style-type:none;
    margin-top:0;
    padding:0;
    text-align:left;
}

lh {
    color:#5c73ac; font-size:18px;
    font: 700 14px/1.5 Helvetica, Verdana, sans-serif;
}

a {
    font: 12px/1.5 Helvetica, sans-serif;
    font-weight:700;
    text-decoration: none;
    color: #5c73ac;
    padding-left:0;
}

img {
    max-width: 100%;
    height: auto;
    margin:4px 0 0 10px;
    float:left;
}

hr {
    max-width:950px;
    color:#e3e3e3;
    border-top: dashed 1px;
    border-bottom: 0;
    border-left: 0;
    border-right: 0;
    padding-bottom: 10px;
}

.header-tag {
    width:200px;
}

.page-logo { 
    margin:168px 0 0 12px; 
    padding:2px;
    background-color: #fff;
}

.adplogo {
    position:relative;
    margin:168px 0 0 12px; 
}

.biopic {
    margin:0px 35px 12px 0;
    vertical-align:text-top;
    border:2px solid #e3e3e3;
}

.news {
    margin-bottom:0;
}

.wrapper {
    margin:150px auto; 
    padding:18px; 
    background-color:#fff; 
    border:0 4px 4px 4px solid #e3e3e3; 
    max-width:900px; 
    box-shadow:0 1px 3px rgba(0, 0, 0, 0.2);
}

.recent-updates-table {
    width: 100%;
    border-collapse: collapse;
    border-spacing: 0px;
}

/*  SECTIONS  */

.header {
    max-width:960px;    
    min-height:150px; 
    background:transparent;
    padding:0; 
    margin:auto; 
}

.header p {
    font-family:"Amasis", Georgia, serif;
    font-weight:600;
    font-size:16px;
    color:#fff;
    margin-top:20px;
    padding:20px 10px 20px 25px;
    background-color:#cc092f;
    width:200px;
}

.shaded-block { 
    border:1px solid #e3e3e3; 
    background:linear-gradient(#ffffff, #f2f2f2) white; 
    box-shadow:0 1px 3px rgba(0, 0, 0, 0.2); 
}

.footer {
    text-align:left;
    color:#fff;
    margin-top:20px;
    padding:20px 20px 20px 25px;
}

.section {
    clear: both;
    padding: 0px;
    margin: 0 0 10px 0;
    max-width: 960px;
    text-align: left;
}

/*  COLUMN SETUP  */

.col {
    display: block;
    margin: 1% 1.5% 1% 0;
}

.col:first-child {
    margin-left: 0; 
}

.last-col { 
    margin-right: 0 !important; 
}

/*  GROUPING  */

.group:before,
.group:after {
    content:"";
    display:table;
}
.group:after {
    clear:both;
}
.group {
    zoom:1; /* For IE 6/7 */
}


.span_2_of_2 {
    max-width: 260px;
    float:left;
    margin-top:4px;
    margin-left:10px;
}
.span_1_of_2 {
    max-width: 570px;
    float:left;
    border:1px solid #e3e3e3; 
    padding:20px 10px; 
    background:linear-gradient(#ffffff, #f2f2f2) white; 
    box-shadow:0 1px 3px rgba(0, 0, 0, 0.2);
}


/*  GRID OF THREE  */

.span_3_of_3 {
    width: 31.0%;
    float:left;
    margin-bottom:0;
    border: 1px solid #e3e3e3;
    padding: 10px 0 0 10px;
    min-height:225px;
    background:linear-gradient(#ffffff, #f2f2f2) white;
    box-shadow:0 1px 3px rgba(0, 0, 0, 0.2);
}

.span_2_of_3 {
    width: 31.0%;
    float:left;
    margin-bottom:0;
    border: 1px solid #e3e3e3;
    padding: 10px 0 0 10px;
    min-height:225px;
    background:linear-gradient(#ffffff, #f2f2f2) white;
    box-shadow:0 1px 3px rgba(0, 0, 0, 0.2);
}

.span_1_of_3 {
    width: 31.0%;
    float:left;
    margin-bottom:0;
    border: 1px solid #e3e3e3;
    padding: 10px 0 0 10px;
    min-height:225px;
    background:linear-gradient(#ffffff, #f2f2f2) white;
    box-shadow:0 1px 3px rgba(0, 0, 0, 0.2);
}

/*  GO FULL WIDTH AT LESS THAN 480 PIXELS */

@media only screen and (max-width: 480px) {
    .col { 
        margin: 1% 0 1% 0%;
    }
}

@media only screen and (max-width: 480px) {
    .span_3_of_3 {
        width: 98%;
         
    }
    .span_2_of_3 {
        width: 98%;
         
    }
    .span_1_of_3 {
        width: 98%;
        
    }
    
    .span_1_of_2 {
        width: 95%;
		padding-bottom:0px !important;
        padding-top:10px;
		padding-left:10px;
		padding-right:10px;
        
    }
    .span_2_of_2 {
        width: 95%;
        
    }
}

@media only screen and (max-width: 480px) {
    h2 { 
        top:110px;
    }
}   
@media only screen and (max-width: 480px) {
    #wrapper { 
        padding:18px;
    }
}