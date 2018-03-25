/*
* created by: cloudsherpas
* updated by: Rey Austral
* Source : EMP_Spin_CSS
*/

@font-face {
    font-family: "Amasis", Georgia, serif;
}

.ADP-Body {
    margin-top: 0;
    background: url(images/banner.jpg) no-repeat top #fff;
}

.wrapper p {
    font: 12px/1.5 Helvetica, sans-serif;
    color: #555;
    text-align: left;
    margin-top: 0;
    margin-bottom: 12px;
}

.wrapper h1 {
   font-family: "Amasis", Georgia, serif;
   font-weight: normal;
   font-size: 24px;
   margin: 0;
   display: inline;
   padding: 0;
   color: #cc092f;
}

.wrapper h2 {
    font: 18px/1.5 Helvetica, Verdana, sans-serif;
    color:#fff;
    padding: 0;
    margin:0 20px 0 0;
    position:relative;
    text-align:right;
    top:90px;
}

.wrapper h3 {
    font: 500 18px/1.5 Palatino, Book Antiqua, serif;
    margin: 0;
    padding: 15px 0 0 0;
    color:#cb1d2b;
    text-align:left;
    line-height:112%;
}

.wrapper ul {
    list-style-type:none;
    margin-top:0;
    padding:0;
    text-align:left;
}

.wrapper lh {
    color:#5c73ac; font-size:18px;
    font: 700 14px/1.5 Helvetica, Verdana, sans-serif;
}

.wrapper a {
    font: 12px/1.5 Helvetica, sans-serif;
    font-weight:700;
    text-decoration: none;
    color: #5c73ac;
    padding-left:0;
}

.wrapper img {
    max-width: 100%;
    height: auto;
    margin:4px 0 0 10px;
    float:left;
}

.wrapper hr {
    max-width:950px;
    color:#e3e3e3;
    border-top: dashed 1px;
    border-bottom: 0;
    border-left: 0;
    border-right: 0;
    padding-bottom: 10px;
}



.wrapper .adplogo {
    position:relative;
    margin:168px 0 0 12px; 
}

.wrapper .biopic {
    margin:0px 35px 12px 0;
    vertical-align:text-top;
    border:2px solid #e3e3e3;
}

.wrapper .news {
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

.wrapper .recent-updates-table {
    width: 100%;
    border-collapse: collapse;
    border-spacing: 0px;
}

/*  SECTIONS  */

.wrapper .header {
    max-width:960px;    
    min-height:150px; 
    background:transparent;
    padding:0; 
    margin:auto; 
}

.wrapper .header p {
    font-family:"Amasis", Georgia, serif;
    font-weight:600;
    font-size:16px;
    color:#fff;
    margin-top:20px;
    padding:20px 10px 20px 25px;
    background-color:#cc092f;
    width:200px;
}

.wrapper .shaded-block { 
    border:1px solid #e3e3e3; 
    background:linear-gradient(#ffffff, #f2f2f2) white; 
    box-shadow:0 1px 3px rgba(0, 0, 0, 0.2); 
}

.wrapper .footer {
    text-align:left;
    color:#fff;
    margin-top:20px;
    padding:20px 20px 20px 25px;
}

.wrapper .section {
    clear: both;
    padding: 0px;
    margin: 0 0 10px 0;
    max-width: 960px;
    text-align: left;
}

/*  COLUMN SETUP  */

.wrapper .col {
    display: block;
    margin: 1% 1.5% 1% 0;
}

.wrapper .col:first-child {
    margin-left: 0; 
}

.wrapper .last-col { 
    margin-right: 0 !important; 
}

/*  GROUPING  */

.wrapper .group:before,
.wrapper .group:after {
    content:"";
    display:table;
}
.wrapper .group:after {
    clear:both;
}
.wrapper .group {
    zoom:1; /* For IE 6/7 */
}


.wrapper .span_2_of_2 {
    max-width: 260px;
    float:left;
    margin-top:4px;
    margin-left:10px;
}
.wrapper .span_1_of_2 {
    max-width: 570px;
    float:left;
    border:1px solid #e3e3e3; 
    padding:20px 10px; 
    background:linear-gradient(#ffffff, #f2f2f2) white; 
    box-shadow:0 1px 3px rgba(0, 0, 0, 0.2);
}


/*  GRID OF THREE  */

.wrapper .span_3_of_3 {
    width: 31.0%;
    float:left;
    margin-bottom:0;
    border: 1px solid #e3e3e3;
    padding: 10px 0 0 10px;
    min-height:225px;
    background:linear-gradient(#ffffff, #f2f2f2) white;
    box-shadow:0 1px 3px rgba(0, 0, 0, 0.2);
}

.wrapper .span_2_of_3 {
    width: 31.0%;
    float:left;
    margin-bottom:0;
    border: 1px solid #e3e3e3;
    padding: 10px 0 0 10px;
    min-height:225px;
    background:linear-gradient(#ffffff, #f2f2f2) white;
    box-shadow:0 1px 3px rgba(0, 0, 0, 0.2);
}

.wrapper .span_1_of_3 {
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
    .wrapper .col { 
        margin: 1% 0 1% 0%;
    }
}

@media only screen and (max-width: 480px) {
    .wrapper .span_3_of_3 {
        width: 98%;
         
    }
    .wrapper .span_2_of_3 {
        width: 98%;
         
    }
    .wrapper .span_1_of_3 {
        width: 98%;
        
    }
    
    .wrapper .span_1_of_2 {
        width: 95%;
		padding-bottom:0px !important;
        padding-top:10px;
		padding-left:10px;
		padding-right:10px;
        
    }
    .wrapper .span_2_of_2 {
        width: 95%;
        
    }
}

@media only screen and (max-width: 480px) {
    .wrapper h2 { 
        top:110px;
    }
}   
@media only screen and (max-width: 480px) {
    #wrapper { 
        padding:18px;
    }
}