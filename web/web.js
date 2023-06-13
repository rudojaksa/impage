/* switches "iteration" display from patterns to epochs */
function toepo(yes) {
  var s1 = "spat"; /* class name of pats span */
  var s2 = "sepo"; /* class name of epochs span */
  if(!yes) { var s=s1; s1=s2; s2=s; }

  var e1 = document.getElementsByClassName(s1);
  var e2 = document.getElementsByClassName(s2);

  for(i=0;i<e1.length;i++) {
    e1[i].style.display = "inline";
    e1[i].style.display = "none"; }

  for(i=0;i<e2.length;i++) {
    e2[i].style.display = "none";
    e2[i].style.display = "inline"; }}

/* switch on/off all class-name specified objects if obj is checked */
function onoff(obj,cls) {
  var el = document.getElementsByClassName(cls);
  if(obj.checked) {
    for(i=0;i<el.length;i++) el[i].style.display = "inline-block"; }
  else {
    for(i=0;i<el.length;i++) el[i].style.display = "none"; }}

/* init the setup on page load and on reload */
function initit() {
  {INITIT}
  onoff(document.getElementById("idsc"),"dsc");
  if(document.getElementById("iepo").checked) toepo(1); }
