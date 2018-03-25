body {
    background-image: url("{!URLFOR($Resource.EMP_PortalImages, 'noise.png')}");
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
.navbar {
    border-bottom: solid 4px #83c900;
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
.chatter-scrolling-area {
    max-height: 600px;
    overflow-x: auto;
}
.chatter-date {
    color: #a7a9ac;
    font-size: 0.8em;
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
    min-height: 440px;
}
.float-left {
    float:left;
}
.branded-links a:not(.btn) {
    color: #82c600 !important;
}
.page-component li a:not(.btn) {
    color: #555 !important;
    /*font-weight: bold;*/
}
.page-component li a:hover, .page-component li a:active {
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
    margin-bottom:10px;
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
    font-size:5em;
}
.fa-margin-top {
    margin-top:20px;
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
