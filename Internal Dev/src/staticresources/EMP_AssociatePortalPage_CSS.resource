body {
    /*background-image: url("{!URLFOR($Resource.EMP_PortalImages, 'noise.png')}");*/
    /*background-image: url("./img/noise.png");*/
    /*background-image: url("./img/noise-inverse.png");*/
    background-repeat: repeat scroll;
    background-color: #EEE;
} 
.wrapper {
    padding: 0px !important;
    box-shadow: 0px 0px 4px 0px rgba(0, 0, 0, 0.2);
    /*box-shadow: 0px 0px 6px 0px rgba(255, 255, 255, 0.8);*/
}
.container {
    background-color: #fff;
}
.center {
    text-align:center;
}
.ScrollingMsg{
    width: 100%;
    font-size: 1.5em;
    background-color: #F9F9F9;
    color: #82C600;
    text-shadow: 1px 1px #DDD;
    border-top: solid 1px #a7a9ac;
    border-bottom: solid 1px #a7a9ac;
}
.cdk-green-hr {
    border-bottom: solid 4px #83c900;
}
.navbar {
    margin-bottom: 0px !important;
    border-bottom: solid 4px #83c900 !important;
}
.navbar .navbar-brand, .navbar div ul li a {
    color: #777;
    /*color: #a7a9ac;*/ /* CDK Grey */
    /*color: #83c900;*/ /* CDK Green */
}
.navbar-inverse {
    background-color: transparent !important;
}
.navbar-inverse .navbar-brand:focus,.navbar-inverse .navbar-brand:hover {
    color: #333;
}
.navbar-inverse .navbar-nav > li > a:focus, .navbar-inverse .navbar-nav > li > a:hover {
    color: #666;
}
.navbar-inverse .navbar-nav > .active > a, .navbar-inverse .navbar-nav > .active > a:focus, .navbar-inverse .navbar-nav > .active > a:hover {
    background-color: transparent;
    font-weight: bold;
    color: #000;
}
.navbar-inverse .navbar-nav > .open > a, .navbar-inverse .navbar-nav > .open > a:focus, .navbar-inverse .navbar-nav > .open > a:hover {
    background-color: transparent;
    color: #666;
}
.navbar-toggle .icon-bar {
    background-color: #83c900;
}
.page-messages {
    font-weight: bold;
    font-size: 1.3em;
    color:red;
}
.header-right {
    padding-top: 10px;
    text-align: right; 
    color: #777;
}

/* Fix Carousel Responsive Height Issue */
.carousel-inner > .item > a > img, .carousel-inner > .item > img, .img-responsive, .thumbnail a > img, .thumbnail > img {
    min-height: auto !important;
}
.carousel-control.left {
    background-image: none;
}
.carousel-control.right {
    background-image: none;
}
.carousel-control {
    z-index: 50;
}
.custom-carousel-control.left {
    left: 0px;
    right: auto;
    top: auto;
}
.custom-carousel-control.right {
    right: 0px;
    left: auto;
    top: auto;
}
.custom-carousel-control {
    z-index: 50;
    background-image: none;
    position: absolute;
    top: 0px;
    bottom: 0px;
    left: 0px;
    width: 20px;
    font-size: 20px;
    color: #FFF;
    text-align: center;
    text-shadow: 0px 1px 2px rgba(0, 0, 0, 0.6);
    opacity: 0.5;
    cursor: pointer; 
}
.custom-carousel-caption {
    position: absolute;
    left: 0;
    right: 0;
    bottom: 20px;
    color: #FFF;
    text-align: center;
    z-index: 10;
    padding-top: 0;
    padding-bottom: 0;
    color: #FFF;
    line-height: 1;
}
.custom-carousel-caption p {
    margin: 0 !important;
}
.custom-carousel-caption .btn-default, .custom-carousel-caption .btn-primary, .custom-carousel-caption .btn-info, .custom-carousel-caption .btn-danger {
    /* text-shadow: 0px 1px 2px rgba(0, 0, 0, 0.6); */ /* 2016-12-14 matt.keefe@cdk.com - commented due to weird fuzzy look on carousel buttons */
}
.custom-carousel-caption .btn-success, .custom-carousel-caption .btn-warning {
    /* text-shadow: 0px 1px 2px rgba(131, 192, 65, 0.8); */ /* 2016-12-14 matt.keefe@cdk.com - commented due to weird fuzzy look on carousel buttons */
}
.carousel-indicators {
    bottom: 0px !important;
    margin-bottom: 0px !important;
    opacity: 0.7;
}
.carousel-indicators li {
    box-shadow: 0px 1px 2px rgba(0, 0, 0, 0.6);
}
.custom-carousel-control:hover {
    opacity: 0.8;
}

/* Chatter Styles */
.chatter-scrolling-area {
    max-height: 600px;
    overflow-x: auto;
}
.chatter-scrolling-area a {
    word-break: break-word;
}
.chatter-date {
    color: #a7a9ac;
    font-size: 0.8em;
}

/* Misc */
.nopadding {
   padding: 0 !important;
   margin: 0 !important;
}
.cdk-green-hr h1 {
    padding: 10px 0 !important;
    margin: 0px !important;
}
.image-size {
    width: 100%;
}
.margin-bottom {
    margin-bottom: 0px;
}
.pad-bottom {
    padding-bottom: 10px;
}
.pad-top {
    padding-top: 10px;
}
.nav-pills > li.active > a, .nav-pills > li.active > a:focus, .nav-pills > li.active > a:hover {
    background-color: #a7a9ac;
}
.leadership_ul {
    line-style-type:none;
    padding: 0px;
}
.leadership_li {
    font-family: "HelveticaNeue","Helvetica Neue",Helvetica,Arial,"Open Sans",sans-serif;
    font-size: 12px;
    font-weight: 400;
    color: #666;
    line-height: 1.5em;
    list-style:none;
    height: 70px;
}
.leadership_li img {
    padding-right:10px;
    float:left;
}
.footer {
    border-top: solid 4px #82c600;
    margin-top: 20px;
    padding-top: 10px;
}
.input-width-100-percent {
    width: 100% !important;
}
.width-80-percent {
    width: 80% !important;
}
.component-min-height-320 {
    min-height: 380px;
}
.hr-min-height {
    min-height: 550px;
}
.float-left {
    float:left;
}
.branded-links a:not(.btn) {
    color: #00a9ce;
}
.page-component li a:not(.btn) {
    color: #00a9ce;
    /*font-weight: bold;*/
}
.page-component a:hover:not(.btn), .page-component a:active:not(.btn) {
    color: #82c600 !important;
}
.page-component {
    font-family: "Open Sans","HelveticaNeue","Helvetica Neue",Helvetica,Arial,sans-serif !important;
    font-size: 12pt;
}
.small-table-label {
    font-weight: bold;
    font-size: 10pt;
    color: #555;
    padding: 2px 0;
}
.small-table-data {
    font-size: 10pt;
    max-width: 180px;
    overflow-x: auto;
}
.it-support-button {
    width:100%;
    margin-bottom:10px !important;
}
.small-photo {
    height: 64px;
    width: 74px;
}
.acknowledgement_disabled {
    display:none;
}
.hide {
    display:none;
}
.fa-5em {
    font-size:5em !important;
}
.fa-margin-top {
    margin-top:20px;
}

/* Promo/Social Box Styles */
.social-box {
  display: inline-block;
  width: 8em;
  height: 8em;
  text-align: center;
  border-radius: 100px;
}

.social-box:before {
  content: '';
  display: inline-block;
  height: 100%;
  vertical-align: middle;
  margin-right: 1.25em; /* Adjusts for spacing */
}

.social-box i {  
  color: #FFF;
  font-size: 5em;
  margin: auto;
  text-align: center;
  vertical-align: middle;
} 

/* tile styles */
.community-tile {
    color: #FFF;
    width: 100%;
    height: 200px;
    margin-top: 20px;
    display: block;
    border-radius: 5px;
    background-color: #00a9cE;
}

.pointer {
    cursor: pointer;
}

.community-tile a {
    text-shadow: none !important;
}

.community-tile.community-tile-green {
    background: #82c600;
}

.community-tile.community-tile-black {
    background: #000;
}

.community-tile.community-tile-white {
    background: #fff;
    border: solid 1px #ccc;
    color: #333;
}

.community-tile.community-tile-darkgreen {
    background: #619400;
}

.community-tile.community-tile-blue {
    background: #00a9cE;
}

.community-tile.community-tile-teal {
    background: #00b2a9;
}

.community-tile.community-tile-altgreen {
    background: #00c389;
}

.community-tile.community-tile-lightgreen {
    background: #a4d65e;
}

.community-tile.community-tile-yellow {
    background: #d0df00;
}

.community-tile.community-tile-khaki {
    background: #e1d7b0;
}

.community-tile.community-tile-purple {
    background: #8714a3;
}

.community-tile.community-tile-bluetread {
    background: #00a9cE url(/Employees/resource/CDK_Patterns/Patterns/Backgrounds/Tread1.png) no-repeat scroll center;
}

.community-tile.community-tile-greentread {
    background: #82c600 url(/Employees/resource/CDK_Patterns/Patterns/Backgrounds/Tread2.png) no-repeat scroll center;
}

.community-tile.community-tile-carbon {
    background: #82c600 url(/Employees/resource/CDK_Patterns/Patterns/Backgrounds/Carbon1.png) no-repeat scroll center;
}

.community-tile.community-tile-chain {
    background: #00a9cE url(/Employees/resource/CDK_Patterns/Patterns/Backgrounds/Chain1.png) no-repeat scroll center;
}

.community-tile.community-tile-circles {
    background: #82c600 url(/Employees/resource/CDK_Patterns/Patterns/Backgrounds/Circles1.png) no-repeat scroll center;
}

.community-tile.community-tile-dots {
    background: #00b2a9 url(/Employees/resource/CDK_Patterns/Patterns/Backgrounds/Dots1.png) no-repeat scroll center;
}

.communitytilebluetread {
    background: #00a9cE url(/Employees/resource/CDK_Patterns/Patterns/Backgrounds/Tread1.png) no-repeat scroll center;
}
.community-tile > .community-tile-overlay {
    background: rgba(0, 0, 0, 0.7);
    border-radius: 5px;
    height: 100%;
    width: 100%;
    opacity: 0.1;
    -webkit-transition: all 0.4s ease-in-out 0s;
    -moz-transition: all 0.4s ease-in-out 0s;
    transition: all 0.4s ease-in-out 0s;
}

.community-tile:hover .community-tile-overlay {
    opacity: 0.8;
}

.community-tile:hover .community-tile-details {
    text-shadow: 1px 1px 1px #111;
}

.community-tile > .community-tile-details {
    position: absolute;
    left: 0; 
    top: 0; 
    text-shadow: 1px 1px 1px #333;
    margin: 6px;
    overflow: none;
    padding-left: 1em;
    padding-right: 1em;
    width: 100%;
    opacity: 1 !important;
    -webkit-transition: all 0.4s ease-in-out 0s;
    -moz-transition: all 0.4s ease-in-out 0s;
    transition: all 0.4s ease-in-out 0s;
}

.panel-highlight-green {
    border: solid 1px #82c600 !important;
    background: rgba(255, 255, 255, 0);
    background: -webkit-linear-gradient(top left, rgba(164, 214, 94, 0.24), rgba(255, 255, 255, 0)); 
    background: -o-linear-gradient(top left, rgba(164, 214, 94, 0.24), rgba(255, 255, 255, 0));
    background: -moz-linear-gradient(top left, rgba(164, 214, 94, 0.24), rgba(255, 255, 255, 0));
    background: linear-gradient(to top left, rgba(164, 214, 94, 0.24), rgba(255, 255, 255, 0));
}

.panel-highlight-blue {
    border: solid 1px #00A9CE !important;
    background: rgba(255, 255, 255, 0);
    background: -webkit-linear-gradient(top left, rgba(0, 169, 206, 0.15), rgba(255, 255, 255, 0)); 
    background: -o-linear-gradient(top left, rgba(0, 169, 206, 0.15), rgba(255, 255, 255, 0));
    background: -moz-linear-gradient(top left, rgba(0, 169, 206, 0.15), rgba(255, 255, 255, 0));
    background: linear-gradient(to top left, rgba(0, 169, 206, 0.15), rgba(255, 255, 255, 0));
}

/* contact styles */
.div_contact {
    display:none;
    border-top:1px solid #DBDBDB !important;
}
.div_container_call {
    margin-right: 10px;
    display: inline-block;
    float: left;
}
.div_container_case  {
    display:inline-block;
}
.div_container_ideas{
    margin-right: 10px;
    display: inline-block;
    float: left;
}
.div_container_chat {
    display:inline-block;
}
.contact_button_border  {
    width: 136px;
    color: #000 !important;
    height: 136px !important;
    margin-right: 5px;
    display:inline-block;
    box-shadow: 0px 0px 7px #888888;
    border-radius: 6px;
    cursor:pointer;
}
.contact_button  {
    background-color: rgb(240, 240, 240);
    height: 130px;
    border-radius: 3px;
    margin: 3px;
    text-align:center;
    font-weight:bold;
}
.contact_label {
    cursor:default !important;
}
.contact_button_img {
    padding-top:15px;
    width:50px
}
.contact_button_label_call {
    padding-top: 18%;
}
.contact_button_label_case {
    padding-top: 18%;
}
.contact_button_label_community {
    padding-top: 18%;
}
.contact_button_label_chat {
    padding-top: 18%;
}
.contact_description {
    display:inline-block;
    white-space: normal;
    width:200px;
    vertical-align:top;
    padding-top: 5px;
}
.red-text {
    color: red;
}
.zen .zen-pageFooter {
	display: none;
}
.jumbotron{
    min-height: 200px;

}
/* Auto-resize according to device */
@media screen and (min-width: 300px) {
    .carousel-caption {
        font-size: 18px;
    }
}
@media screen and (min-width: 768px) {
    .carousel-caption {
        font-size: 48px;
    }
}
@media screen and (min-width: 992px) {
    .carousel-caption {
        font-size: 72px;
    }
}
@media screen and (min-width: 300px) {
    .custom-carousel-caption {
        font-size: 14px;
    }
}
@media screen and (min-width: 768px) {
    .custom-carousel-caption {
        font-size: 32px;
    }
}
@media screen and (min-width: 992px) {
    .custom-carousel-caption {
        font-size: 48px;
    }
}

/*Style for reponsive table */
/* **** code starts here **** */
table#HR_MyInfo {
  margin: 0 auto;
  border-collapse: collapse;
  font-family: Agenda-Light, sans-serif;
  font-weight: 100;
  background: #333;
  color: #fff;
  text-rendering: optimizeLegibility;
  border-radius: 5px;
}

table#HR_MyInfo caption {
  font-size: 2rem;
  color: #444;
  margin: 1rem;
  background-image: url(https://s3-us-west-2.amazonaws.com/s.cdpn.io/4273/HR_MyInfo.png), url(https://s3-us-west-2.amazonaws.com/s.cdpn.io/4273/HR_MyInfo2.png);
  background-size: contain;
  background-repeat: no-repeat;
  background-position: center left, center right;
}

table#HR_MyInfo thead th {
  font-weight: 600;
}

table#HR_MyInfo thead th,
table#HR_MyInfo tbody td {
  padding: .8rem;
  font-size: 1.4rem;
}

table#HR_MyInfo tbody td {
  padding: .8rem;
  font-size: 1.4rem;
  color: #444;
  background: #eee;
}

table#HR_MyInfo tbody tr:not(:last-child) {
  border-top: 1px solid #ddd;
  border-bottom: 1px solid #ddd;
}

@media screen and (max-width: 768px) {
  table#HR_MyInfo caption {
    background-image: none;
  }
  table#HR_MyInfo thead {
    display: none;
  }
  table#HR_MyInfo tbody td {
    display: block;
    padding: .6rem;
  }
  table#HR_MyInfo tbody tr td:first-child {
    background: #666;
    color: #fff;
  }
  table#HR_MyInfo tbody td:before {
    content: attr(data-th);
    font-weight: bold;
    display: inline-block;
    width: 6rem;
  }
}

/** **** code ends here for reponsive table **** */


/************/


.cdktile
{
  width:380px;
  height:380px;
  margin:10px;
  background-color:#99aeff;
  display:inline-block;
  background-size:cover;
  position:relative;
  cursor:pointer;
  overflow:hidden;
  color:white;
  font-family:'Roboto';
  
}
.cdktile img
{
  height:100%;
  width:100%;
  position:absolute;
  top:0;
  left:0;
  z-index:0;
 
}
.cdktile .cdktext
{
/*   z-index:99; */
  position:absolute;
  padding:30px;
  height:calc(100% - 60px);
  height:calc(100% - 60px);
}
.cdktile h1
{
 
  font-weight:300;
  margin:0;
 
}
.cdktile h2
{
  font-weight:100;
  margin:20px 0 0 0;
  font-style:italic;
   transform: translateX(200px);
}
.cdktile p
{
  font-weight:300;
  margin:20px 0 0 0;
  line-height: 25px;
/*   opacity:0; */
  transform: translateX(-200px);
  transition-delay: 0.2s;
}
.cdkanimate-text
{
  opacity:0;
  transition: all 0.6s ease-in-out;
}
.cdktile:hover
{
/*   background-color:#99aeff; */

}
.cdktile:hover img
{
  opacity: 0.2;
}
.cdktile:hover .cdkanimate-text
{
  transform:translateX(0);
  opacity:1;
}
.cdkdots
{
  position:absolute;
  bottom:20px;
  right:30px;
  margin: 0 auto;
  width:30px;
  height:30px;
  color:currentColor;
  display:flex;
  flex-direction:column;
  align-items:center;
  justify-content:space-around;
  
}

.cdkdots span
{
    width: 5px;
    height:5px;
    background-color: currentColor;
    border-radius: 50%;
    display:block;
  opacity:0;
  transition: transform 0.4s ease-out, opacity 0.5s ease;
  transform: translateY(30px);
 
}

.cdktile:hover span
{
  opacity:1;
  transform:translateY(0px);
}

.cdkdots span:nth-child(1)
{
   transition-delay: 0.05s;
}
.cdkdots span:nth-child(2)
{
   transition-delay: 0.1s;
}
.dots span:nth-child(3)
cdkwrap{
   transition-delay: 0.15s;
}

}


/*********** */
	#crumbs {
		list-style: none;
		display: inline-table;
	}
		#crumbs {
			display: inline;
		}
/* start goals */
#crumbs .goals a {
			display: block;
			float: left;
			height: 50px;
			background: #8D0E57;
			text-align: center;
			padding: 30px 40px 50px 80px;
			position: relative;
			margin: 0 10px 0 0; 
			
			font-size: 20px;
			text-decoration: none;
			color: #fff;
		}
			#crumbs .goals a:after {
				content: "";  
				border-top: 40px solid transparent;
	 			border-bottom: 40px solid transparent;
	  			border-left: 40px solid #8d0E57;
				position: absolute; right: -40px; top: 0;
				z-index: 1;
			}
			
			#crumbs .goals a:before {
				content: "";  
				border-top: 40px solid transparent;
	  			border-bottom: 40px solid transparent;
	  			border-left: 40px solid;
				position: absolute; left: 0; top: 0;
			}/*end goals*/
	
	

       
			#crumbs a:hover {
				background: #fa5ba5;
			}
				#crumbs a:hover:after {
					border-left-color: #fa5ba5;
				}
}

/**************/







