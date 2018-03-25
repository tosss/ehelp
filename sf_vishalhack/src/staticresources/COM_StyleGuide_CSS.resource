/* 2016-11-22 matt.keefe@cdk.com - modified CSS - Link Collection */
.lc > div{
    border-radius: 3px;
}

.lc .lc-header {
    border-top-left-radius: 1px;
    border-top-right-radius: 1px;
    padding: 4px 10px; 
    font-size: 12pt; 
    font-weight: bold;
    color: #fff;
    text-shadow: 1px 1px #333;
}

.lc .category
{
    border-top: solid 1px #82c600;
    border-bottom: solid 1px #82c600;
    padding: 4px 10px;
}

.lc .info-message
{
    font-size: 0.9rem;
    padding: 4px 10px 4px 10px;
}

.lc ul {
    padding-left: 0px; 
    padding-top: 6px;
}

.lc li i {
    transition: all .25s ease-in-out;
    -moz-transition: all .25s ease-in-out;
    -webkit-transition: all .25s ease-in-out;
}

.lc li a:first-child {
    color: #53565A;
    position: relative; 
    left: -10px;
}

.lc li a:hover {
    color: #619400;
}

.lc .link-collection-row:hover a
{
    color: rgb(105, 190, 40);
    text-decoration: underline;
}

.lc ul:last-child {
    padding-bottom: 4px; 
}

/* hide hidden icons to start */
.lc .link-collection-row i.fa-hidden-icon {
    opacity: 0;
}

.lc .link-collection-row i.fa-plus-circle,
.lc .link-collection-row i.fa-times-circle {
    cursor: pointer;
}

.lc .link-collection-row i.fa-plus-circle {
    color: #619400;
}

.lc .link-collection-row i.fa-times-circle {
    color: #A30400; /*#BB0E0E;*/
}

.lc .link-collection-row i.fa-check {
    color: #00A9CE;
}

/* on hover hide default icon */
.lc .link-collection-row:hover i.fa-default-icon {
    opacity: 0;
}

/* on hover show action/info icons */
.lc .link-collection-row:hover i.fa-plus-circle,
.lc .link-collection-row:hover i.fa-check,
.lc .link-collection-row:hover i.fa-times-circle
{
    opacity: 1;
}

.bg-Green {
    text-shadow: 1px 1px #333;
    background-color: #82C600;
}

.bg-Black {
    background-color: #000000;
}

.bg-White {
    color: #333;
    text-shadow: 0px 0px 0px rgba(0,0,0,0);
    background-color: #FFFFFF;
    border: solid 1px #999;
    border-radius: 5px;
}

.bg-Dark-Green {
    background-color: #619400;
}

.bg-Blue {
    background-color: #00A9CE;
}

.bg-Teal {
    background-color: #00B2A9;
}

.bg-Alt-Green {
    background-color: #00C489;
}

.bg-Light-Green {
    background-color: #A4D65E;
}

.bg-Yellow {
    background-color: #D0DF00;
}

.bg-Khaki {
    background-color: #E1D7B0;
}

.bg-Purple {
    background-color: #8714A3;
}

.bg-Burgundy {
    background-color: #8D0E57;
}

.bg-Soft-Black {
    background-color: #53565A;
}

.bg-Medium-Grey {
    background-color: #A7A8AA;
}

.bg-Light-Grey {
    background-color: #D0D0CE;
}

.bg-Beige {
    background-color: #DBC893;
}

.bg-None {
    
}

.bg-BlueTread {
    background: url('/sfsites/c/resource/CDKPatterns/Patterns/1170x300/BlueTread.png') repeat left top;
}

.bg-Carbon {
    background: url('/sfsites/c/resource/CDKPatterns/Patterns/1170x300/Carbon.png') repeat left top;
}

.bg-Chain {
    background: url('/sfsites/c/resource/CDKPatterns/Patterns/1170x300/Chain.png') repeat left top;
}

.bg-Circles {
    background: url('/sfsites/c/resource/CDKPatterns/Patterns/1170x300/Circles.png') repeat left top;
}

.bg-Dots {
    background: url('/sfsites/c/resource/CDKPatterns/Patterns/1170x300/Dots.png') repeat left top;
}

.bg-GreenTread {
    background: url('/sfsites/c/resource/CDKPatterns/Patterns/1170x300/GreenTread.png') repeat left top;
}

.bg-Rectangles {
    background: url('/sfsites/c/resource/CDKPatterns/Patterns/1170x300/BlueTread.png') repeat left top;
}

.bg-Spirals {
    background: url('/sfsites/c/resource/CDKPatterns/Patterns/1170x300/Spirals.png') repeat left top;
}

.bg-Zebra {
    background: url('/sfsites/c/resource/CDKPatterns/Patterns/600x600/Zebra.png') repeat left top;
}

/* Border and Background Colors */
.lc .lc-BorderTop-Green { border-top: solid 1px #82c600; }
.lc .lc-Green { border: solid 1px #82c600; }
.lc .lc-Green .lc-header { background-color: #82c600; }

.lc .lc-BorderTop-Blue { border-top: solid 1px #00A9CE; }
.lc .lc-Blue { border: solid 1px #00A9CE; }
.lc .lc-Blue .lc-header { background-color: #00A9CE; }

.lc .lc-BorderTop-Teal { border-top: solid 1px #00B2A9; }
.lc .lc-Teal { border: solid 1px #00B2A9; }
.lc .lc-Teal .lc-header { background-color: #00B2A9; }

.lc .lc-BorderTop-Alt-Green { border-top: solid 1px #00C489; }
.lc .lc-Alt-Green { border: solid 1px #00C489; }
.lc .lc-Alt-Green .lc-header { background-color: #00C489; }

.lc .lc-BorderTop-Light-Green { border-top: solid 1px #A4D65E; }
.lc .lc-Light-Green { border: solid 1px #A4D65E; }
.lc .lc-Light-Green .lc-header { background-color: #A4D65E; }

.lc .lc-BorderTop-Yellow { border-top: solid 1px #D0DF00; }
.lc .lc-Yellow { border: solid 1px #D0DF00; }
.lc .lc-Yellow .lc-header { background-color: #D0DF00; }

.lc .lc-BorderTop-Khaki { border-top: solid 1px #E1D7B0; }
.lc .lc-Khaki { border: solid 1px #E1D7B0; }
.lc .lc-Khaki .lc-header { background-color: #E1D7B0; }

.lc .lc-BorderTop-Dark-Green { border-top: solid 1px #619400; }
.lc .lc-Dark-Green { border: solid 1px #619400; }
.lc .lc-Dark-Green .lc-header { background-color: #619400; }

.lc .lc-BorderTop-Purple { border-top: solid 1px #8714A3; }
.lc .lc-Purple { border: solid 1px #8714A3; }
.lc .lc-Purple .lc-header { background-color: #8714A3; }

.lc .lc-BorderTop-Burgundy { border-top: solid 1px #8D0E57; }
.lc .lc-Burgundy { border: solid 1px #8D0E57; }
.lc .lc-Burgundy .lc-header { background-color: #8D0E57; }

.lc .lc-BorderTop-Black { border-top: solid 1px #333; }
.lc .lc-Black { border: solid 1px #333; }
.lc .lc-Black .lc-header { background-color: #333; }

.lc .lc-BorderTop-Soft-Black { border-top: solid 1px #53565A; }
.lc .lc-Soft-Black { border: solid 1px #53565A; }
.lc .lc-Soft-Black .lc-header { background-color: #53565A; }

.lc .lc-BorderTop-Medium-Grey { border-top: solid 1px #A7A8AA; }
.lc .lc-Medium-Grey { border: solid 1px #A7A8AA; }
.lc .lc-Medium-Grey .lc-header { background-color: #A7A8AA; }

.lc .lc-BorderTop-Light-Grey { border-top: solid 1px #D0D0CE; }
.lc .lc-Light-Grey { border: solid 1px #D0D0CE; }
.lc .lc-Light-Grey .lc-header { background-color: #D0D0CE; }

.lc .lc-BorderTop-White { border: solid 1px #ccc; }
.lc .lc-White { border: solid 1px #ccc; }
.lc .lc-White .lc-header { background-color: #f5f5f5; border-bottom: solid 1px #ccc; color: #333 !important; text-shadow: none !important; }

.lc .lc-BorderTop-Beige { border: solid 1px #DBC893; }
.lc .lc-Beige { border: solid 1px #DBC893; }
.lc .lc-Beige .lc-header { background-color: #DBC893; }

.lc .lc-Green .lc-icon { background-color: #82c600; }
.lc .lc-Blue .lc-icon { background-color: #00A9CE; }
.lc .lc-Teal .lc-icon { background-color: #00B2A9; }
.lc .lc-Alt-Green .lc-icon { background-color: #00C489; }
.lc .lc-Light-Green .lc-icon { background-color: #A4D65E; }
.lc .lc-Yellow .lc-icon { background-color: #D0DF00; }
.lc .lc-Khaki .lc-icon { background-color: #E1D7B0; }
.lc .lc-Dark-Green .lc-icon { background-color: #619400; }
.lc .lc-Purple .lc-icon { background-color: #8714A3; }
.lc .lc-Burgundy .lc-icon { background-color: #8D0E57; }
.lc .lc-Black .lc-icon { background-color: #333; }
.lc .lc-Soft-Black .lc-icon { background-color: #53565A; }
.lc .lc-Medium-Grey .lc-icon { background-color: #A7A8AA; }
.lc .lc-Light-Grey .lc-icon { background-color: #D0D0CE; }
.lc .lc-White .lc-icon { background-color: #f5f5f5; border-bottom: solid 1px #ccc; color: #333 !important; text-shadow: none !important; }
.lc .lc-Beige .lc-icon { background-color: #DBC893; }