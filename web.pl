# do not edit! auto-generated from: web/web.html web/web.css web/web.js

our $JAVASCRIPT=<<EOF;
function toepo(yes) {
  var s1 = "spat"; 
  var s2 = "sepo"; 
  if(!yes) { var s=s1; s1=s2; s2=s; }
  var e1 = document.getElementsByClassName(s1);
  var e2 = document.getElementsByClassName(s2);
  for(i=0;i<e1.length;i++) {
    e1[i].style.display = "inline";
    e1[i].style.display = "none"; }
  for(i=0;i<e2.length;i++) {
    e2[i].style.display = "none";
    e2[i].style.display = "inline"; }}
function onoff(obj,cls) {
  var el = document.getElementsByClassName(cls);
  if(obj.checked) {
    for(i=0;i<el.length;i++) el[i].style.display = "inline-block"; }
  else {
    for(i=0;i<el.length;i++) el[i].style.display = "none"; }}
function initit() {
  {INITIT}
  onoff(document.getElementById("idsc"),"dsc");
  if(document.getElementById("iepo").checked) toepo(1); }
EOF

our $CSS=<<EOF;
html {
  background-color: #444051;
  font-family: 'Roboto Condensed', sans-serif; }
div {
  display: inline-block; }
div.plot {
  position: fixed; display: block;
  top: 8px; right: 8px;
  border: 4px solid #3584E4;
  border-radius: 12px;
  padding: 8px 12px;
  background-color: #D0D0D060;
  z-index: 10; }
div.menu {
  position: fixed; display: block;
  bottom: 33px; right: 8px;
  border: 4px solid #3584E4;
  border-radius: 12px;
  padding: 8px 12px;
  background-color: #D0D0D060;
  z-index: 10; }
div.menu hr {
  border: 0;
  border-top: 2px solid black; }
div.copy {
  position: fixed; display: block;
  bottom: 0px; right: 8px;
  color: #3584E4;
  padding: 8px 12px;
  z-index: 10; }
div.dsc {
  vertical-align: bottom;
  text-align: right;
  color: #D0D0D0;
  width: 120px;
  padding: 0 4px 2px 2px; }
div.dsc hr {
  margin: 6px 0 6px auto;
  width: 80px;
  border: 0;
  border-top: 2px solid #D0D0D0; }
span.sepo {
  display: none; }
input {
  vertical-align: top;
  margin: 2px 8px 4px 2px; }
label {
  vertical-align: top; }
div.box {
  position: relative; }
div.box div.hi {
  position: absolute;
  top: 0;
  left: 0;
  display: none; }
div.box:hover div.hi {
  display: block; }
div.divider {
  display: inline-block;
  vertical-align: middle;
  width: 0px;
  height: 60px;
  margin: 6px;
  border: 6px solid white; }
.bad {
  position: relative;
  overflow: hidden; }
.bad:before, .bad:after {
  position: absolute;
  content: '';
  background: red;
  display: block;
  width: 75%;
  height: 8px;
  -webkit-transform: rotate(-45deg);
  transform: rotate(-45deg);
  left: 0;
  right: 0;
  top: 0;
  bottom: 0;
  margin: auto; }
.bad:after {
  -webkit-transform: rotate(45deg);    
  transform: rotate(45deg); }
h1 {
  color: white; }
h2 {
  color: white; }
EOF

our $HTML=<<EOF;
<!DOCTYPE html>
<html>
<head>
<title>impage</title>
<link rel="preconnect" href="https://fonts.gstatic.com">
<link href="https://fonts.googleapis.com/css2?family=Roboto+Condensed&display=swap" rel="stylesheet">
<link href="https://fonts.googleapis.com/css2?family=Roboto+Condensed:wght@700&display=swap" rel="stylesheet">
<style type="text/css">
{CSS}
</style>
<script type='text/javascript'>
{JAVASCRIPT}
</script>
</head>
<body>
{BODY}
<script type='text/javascript'>document.onload=initit()</script>
</body>
</html>
EOF

