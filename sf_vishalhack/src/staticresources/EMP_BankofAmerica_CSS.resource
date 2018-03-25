
.faded-block .box {
    background: rgba(71, 109, 147, 0.3) !important;
}
/* make keyframes that tell the start state and the end state of our object */

@-webkit-keyframes fadeIn {
    from {
        opacity: 0;
        opacity: 1\9;
        /* IE9 only */
    }
    to {
        opacity: 1;
    }
}

@-moz-keyframes fadeIn {
    from {
        opacity: 0;
        opacity: 1\9;
        /* IE9 only */
    }
    to {
        opacity: 1;
    }
}

@keyframes fadeIn {
    from {
        opacity: 0;
        opacity: 1\9;
        /* IE9 only */
    }
    to {
        opacity: 1;
    }
}

.fade-in {
    opacity: 0;
    /* make things invisible upon start */
    -webkit-animation: fadeIn ease-in 1;
    /* call our keyframe named fadeIn, use animattion ease-in and repeat it only 1 time */
    -moz-animation: fadeIn ease-in 1;
    animation: fadeIn ease-in 1;
    -webkit-animation-fill-mode: forwards;
    /* this makes sure that after animation is done we remain at the last keyframe value (opacity: 1)*/
    -moz-animation-fill-mode: forwards;
    animation-fill-mode: forwards;
    -webkit-animation-duration: 0.5s;
    -moz-animation-duration: 0.5s;
    animation-duration: 0.5s;
}

.fade-in.one {
    -webkit-animation-delay: 0.7s;
    -moz-animation-delay: 0.7s;
    animation-delay: 0.7s;
}

.fade-in.two {
    -webkit-animation-delay: 1.2s;
    -moz-animation-delay: 1.2s;
    animation-delay: 1.2s;
}

.fade-in.three {
    -webkit-animation-delay: 1.6s;
    -moz-animation-delay: 1.6s;
    animation-delay: 1.6s;
}


/*---make a basic box ---*/



*, *:before, *:after{
    -webkit-box-sizing: border-box;
    -moz-box-sizing:border-box;
    box-sizing: border-box;
    margin: 0;
    padding: 0;
}

.main-title{
    color: #1d1d1d;
    text-align: center;
    text-transform: capitalize;
    padding: 0.7em 0;
}

.box-md {
    height: 220px;
}

.box-sm {
    height: 110px;
}

.box {
    color: white;
    padding: 0px;
    float: left;
    border: 1px solid #fff;
    background: #00A9CE;
    border-radius: 6px;
    background-repeat: no-repeat;
}

.content {
    position: relative;
    width: 90%;
    // max-width: 400px;
    margin: auto;
    overflow: hidden;
    min-height:220px;
}

.content .content-overlay {
    background: rgba(0,0,0,0.7);
    position: absolute;
    height: 100%;
    width: 100%;
    left: 0;
    top: 0;
    bottom: 0;
    right: 0;
    opacity: 0;
    -webkit-transition: all 0.4s ease-in-out 0s;
    -moz-transition: all 0.4s ease-in-out 0s;
    transition: all 0.4s ease-in-out 0s;
}

.selected .content .content-overlay {
    opacity: 50 !important;
}

.content:hover .content-overlay{
    opacity: 1;
}

.content-image{
    width: 100%;
    min-height:220px;
}

.content-details {
    position: absolute;
    text-align: center;
    padding-left: 1em;
    padding-right: 1em;
    width: 100%;
    top: 50%;
    left: 50%;
    opacity: 12;
    -webkit-transform: translate(-50%, -50%);
    -moz-transform: translate(-50%, -50%);
    transform: translate(-50%, -50%);
    -webkit-transition: all 0.3s ease-in-out 0s;
    -moz-transition: all 0.3s ease-in-out 0s;
    transition: all 0.3s ease-in-out 0s;
}

.content:hover .content-details{
    top: 50%;
    left: 50%;
    opacity: 12;
}

.content-details h3{
    color: #fff;
    font-weight: 500;
    letter-spacing: 0.15em;
    margin-bottom: 0.5em;
    text-transform: uppercase;
}

.content-details p{
    color: #fff;
    font-size: 0.8em;
}

.ui-datepicker-title {
    color: black !important;
}

.fadeIn-bottom{
    top: 80%;
}

.fadeIn-top{
    top: 20%;
}

.fadeIn-left{
    left: 20%;
}

.fadeIn-right{
    left: 80%;
}
.modal.fade .modal-dialog {
    z-index: 9999;
}
.modal.fade .modal-dialog {
    z-index: 9999;
    width: 820px;
}