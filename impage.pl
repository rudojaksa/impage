#!/usr/bin/perl
#use strict;
# include "CONFIG.pl"
# include "ext/colors.pl"
# include "ext/corelib.pl"
# include "ext/helpman.pl"
# include "ext/filelib.pl"

# TODO: 1st html then copy
# TODO: progress by dots, comma for new cluster

# --------------------------------------------------------------------------------- HELP
my $HELPMAN=<<EOF;

NAME
    impage - image browser using html

USAGE
    impage [OPTIONS] [CSV]... [CC(DIRECTORIES/FILES)]...

DESCRIPTION
    Impage creates webpage interlinked to in-place images to allow
    browsing them together.  Input is either the CSV file, or
    directories with images.

    CSV file expects fields: path, cluster, dist, pdist and bad
    form the CC(imclust) tool.

    For relative paths, the output location is current directory,
    for absolute paths it is the /tmp/impage... directory.  If at
    least one path is absolute, the rest is converted to absolute.

OPTIONS
      -h  This help.
      -v  More verbose.
 -r ROOT  Root directory, needed if relative path in CSV requires it.
   CC(-s/-m)  Singlepage/multipage output.
      -t  Use thumbnails (to speedup remote access).
     -tt  Also reference thumbnails when clicking on image (not orig).
   -tpng  Make png thumbnails.
   -topq  Make opaque thumbnails, ignore alpha channel.
    -tcp  Copy orig images as a thumbnails.
  -q=NUM  Quality for jpeg compression of thumbnails (dflt. CC(75)).
 -g=GEOM  Geometry of thumbnails (aka CC(128), CC(x196), CC(640x480)).
   -gmax  Don't limit the size of images displayed.
 CC(-rl/-rr)  Rotate images left/right, when making thumbnails.

EXAMPLES
    To browse two directories (of any depth) of images:
        CW(impage directory1 directory2
        firefox /tmp/impage/index.html)

    To browse clustered images:
        CW(imclust -csv -c 20 directory1 directory2 
        impage clust.csv
        firefox /tmp/impage/clust/index.html)

    To browse remotely use CW(impage -t) to speedup the transfer.
    On the local site, if ssh tunel is necessary, create it:
        CW(ssh -L 9000:localhost:9000 REMOTE_IP -p REMOTE_SSH_PORT)
    Where the CW(REMOTE_IP) is IP of remote host (aka 192.168.0.10)
    accesible through ssh using the CW(REMOTE_SSH_PORT) port.
    Then, on the remote site:
        CW(imclust -csv -c 20 directory1 directory2 
        impage -t clust.csv
        twistd -n web -l /dev/null -p tcp:9000 --path /)
    This setup exposes everything on disk visible to you, to
    allow you to see images located anywhere on disk.  If you
    don't want this, use only relative paths in the impage and
    expose only a selected directory (example below).  Then use
    the browser on the local site:
        CW(firefox localhost:9000/tmp/impage/clust)

    To browse remotely from self-contained directory: on the
    remote site, copy images to the target directory:
        CW(cp -a /absolutepath/directory1 /tmp/impage/img)
    Then cluster it and impage using only relative paths:
        CW(cd /tmp/impage
        imclust -csv -c 20 img
        impage -t clust.csv)
    Then expose only the target directory:
        CW(twistd -n web -l /dev/null -p tcp:9000 --path /tmp/impage)
     or CK(busybox httpd -f -p 9000 -h /tmp/impage)
    And browse:
        CW(firefox localhost:9000/clust)

REQUIRES
    CW(parallel) and CW(ImageMagick) to create thumbnails (with CC(-t))

EOF

# -------------------------------------------------------------------------------- ARGVS
my $VERBOSE;
for(@ARGV) { if($_ eq "-h") { printhelp($HELPMAN); exit 0; }}
for(@ARGV) { if($_ eq "-v") { $VERBOSE=1; $_=""; last; }}

my $THUMBNAILS;
my $THUMBPNG;
my $THUMBCOPY;
for(@ARGV) { if($_ eq "-t") { $THUMBNAILS=1; $_=""; last; }}
for(@ARGV) { if($_ eq "-tt") { $THUMBNAILS=1; $REFTHUMB=1; $_=""; last; }}
for(@ARGV) { if($_ eq "-tpng") { $THUMBNAILS=1; $THUMBPNG=1; $_=""; last; }}
for(@ARGV) { if($_ eq "-topq") { $THUMBNAILS=1; $THUMBOPQ=1; $_=""; last; }}
for(@ARGV) { if($_ eq "-tcp") { $THUMBNAILS=1; $THUMBCOPY=1; $_=""; last; }}
for(@ARGV) { if($_ eq "-rl") { $ROTLEFT=1; $_=""; last; }}
for(@ARGV) { if($_ eq "-rr") { $ROTRIGHT=1; $_=""; last; }}

my $SINGLEPAGE;
my $MULTIPAGE;
for(@ARGV) { if($_ eq "-s") { $SINGLEPAGE=1; $_=""; last; }}
for(@ARGV) { if($_ eq "-m") { $MULTIPAGE=1; $_=""; last; }}

my $GEOMETRY;
my $QUALITY;
for(@ARGV) { if($_ =~ /^-g=([0-9x]+)$/)	{ $GEOMETRY=$1; $_=""; last; }}
for(@ARGV) { if($_ =~ /^-q=([0-9]+)$/)	{ $QUALITY=$1; $_=""; last; }}
my $GMAX;
for(@ARGV) { if($_ eq "-gmax") { $GMAX=1; $_=""; last; }}

our $ROOT;
for($i=0;$i<$#ARGV;$i++) {
  next if $ARGV[$i] eq "";
  next if $ARGV[$i] ne "-r";
  $ROOT = $ARGV[$i+1];
  $ARGV[$i]=""; $ARGV[$i+1]=""; last; }

my $CSV;
for($i=0;$i<=$#ARGV;$i++) {
  next if $ARGV[$i] eq "";
  next if not $ARGV[$i] =~ /\.csv$/;
  $CSV=$ARGV[$i]; $ARGV[$i]=""; last; }

my @PATHS;
for($i=0;$i<=$#ARGV;$i++) {
  next if $ARGV[$i] eq "";
  push @PATHS,$ARGV[$i]; $ARGV[$i]=""; }

# print " - $_\n" for @PATHS;

# ------------------------------------------------------------------------------- PARSER
my $HASHDR = 0; # whether the CSV has a header
my %COL;	# columns map ($COL{row_name} = row_idx)
my @CLNM;	# cluster names ($CLNM[3] is name of third cluster)
my @CLST;	# array of arrays of paths per cluster (@{$CLST[3]} is third cluster)
my %CSVL;	# full CSV line for given path ($CSVL{02/44.jpg} = "02/44.jpg 96 66.0 71.9 0")
my @DIRS;	# list of dirs
my $N = 0;	# no. of images
my $M = 1;	# no. of clusters (start with the cluster1, not cluster0)
# --------------------------------------------------------------------- IMAGES FROM CSVS

if(defined $CSV) {

  # get columns map
  my $line1 = `head -n 1 "$CSV"`; chomp $line1;
  if($line1 =~ s/^#//) {
    $HASHDR = 1;
    my @line = split /\h/,$line1;
    $COL{$line[$_]}=$_ for 0..$#line;
    if($VERBOSE) {
      print "CSV row $COL{$_}: $_\n" for sort {$COL{$a} <=> $COL{$b}} keys %COL; }}
  # print "center: $COL{center}  \n" if defined $COL{center};

  # get clusters
  open my $fd,$CSV or die "Can't open $CSV: $!";
  while(my $l=<$fd>) {
    next if $l=~/^\#/;
    my @line = split /[\h\n]/,$l;
    my $c = @line[$COL{cluster}];

    # 1. use 1st column as a pathname
    my $p = @line[1];
    my $d = dirname $p;

    # 2. use "path" column
    if(defined $COL{path}) {
      $p = @line[$COL{path}];
      $d = dirname $p;
      if(defined $ROOT) {		# prepend the ROOT dir if defined
	$p = "$ROOT/".fname($p);
	$d = $ROOT; }}

    # 3. or use the "file" column
    elsif(defined $COL{file}) {
      $p = @line[$COL{file}];
      $d = "";
      if(defined $ROOT) {		# prepend the ROOT dir if defined
	$p = "$ROOT/$p";
	$d = $ROOT; }}

    # print "$c $p ($d) -> @line\n";
    pushq \@DIRS,$d;			# add new dir if it's new
    push @{$CLST[$c]},$p;		# add path to cluster
    $CSVL{$p} = \@line;			# save the CSV line
    $N++; }				# increment the no. of images
  close $fd or die "Couldn't write $CSV: $!\n"; }

# ---------------------------------------------------------------- DIRECT IMAGES BY PATH

if(not defined $CSV) {

  # find all potential images
  my @img;
  for my $p (@PATHS) {
    my $cmd = "find '$p' -type f -name '*.jpg' -o -name '*.png'";
    push @img,split(/\n/,`$cmd`); }

  # find all subdirs
  my %i2d;	# image-to-dir map
  my %dirmap;	# dirname to cluster-id map
  for my $p (@img) {
    my $d = dirname $p;
    if(not inar \@DIRS,$d) {
      push @DIRS,$d;
      $dirmap{$d} = $M;
      $CLNM[$M] = $d;
      $M++; }
    $i2d{$p} = $dirmap{$d}; }

  # define the CSV line
  $COL{path} = 0 if not defined $COL{path};
  if(not $HASHDR) {
    $COL{cluster} = 1;
    $COL{dist} = 2;
    $COL{pdist} = 3;
    $COL{bad} = 4; }

  # distribute images
  for my $p (@img) {
    my $m = $i2d{$p}; # cluster id (the path id)
    push @{$CLST[$m]},$p;
    $CSVL{$p} = ($p,$m,0,0,0);
    $N++; }

}

# ---------------------------------------------------------------------- ALL_IMAGES LIST
my @IMG;	# all images from CLST

my $k = 0;
for my $j (0..$#CLST) {
  next if $#{$CLST[$j]} < 0;
  for my $i (0..$#{$CLST[$j]}) {
    $IMG[$k++] = $CLST[$j][$i]; }}

# --------------------------------------------------------------------- DEBUG PRINT LIST

if(0) {
  for my $j (0..$#CLST) {
    next if $#{$CLST[$j]} < 0;
    print "$j ->";
    for my $i (0..$#{$CLST[$j]}) {
      print " $CLST[$j][$i]"; }
    print "\n"; }
exit; }

# print "$_ " for @IMG; exit;

# -------------------------------------------------------------------------------- FINAL

# number of clusters
$M = $#CLST + 1;

# singlepage logic
my $singlepage = 0;
   $singlepage = 1 if $N <= 2000;
if(defined $SINGLEPAGE) {}
elsif(defined $MULTIPAGE) { $SINGLEPAGE = 0; }
else { $SINGLEPAGE = $singlepage; }

# ------------------------------------------------------------------------------- OUTPUT

#my $OUTDIR = "/tmp/impage-$ENV{USER}";
my $OUTDIR = "/tmp/impage";
my $SUBDIR = "html";

if(defined $CSV) {
  $SUBDIR = fname $CSV;
  $SUBDIR =~ s/\.csv$//; }
elsif(@PATHS==1) {
  $SUBDIR = "/$PATHS[0]"; }

mkdir "$OUTDIR/$SUBDIR";

# ---------------------------------------------------------------------- MAKE THUMBNAILS
# include "thumbs.pl"

# ------------------------------------------------------------------------------ WEBPAGE
# include "web.pl"
our ($HTML,$CSS,$JAVASCRIPT);
$HTML =~ s/\{CSS\}/$CSS/;

$hover = "";

my $HDR = "$N images in ".($M-1)." clusters";
   $HDR = "$CSV:&nbsp; $HDR" if defined $CSV;
   $HDR = "<h1>$HDR</h1>\n\n";

# geometry
my $h = 196;
   $h = $1 if $GEOMETRY=~/x([0-9]+)$/;
my $height = " height=$h";
   $height = "" if defined $GMAX;

# overview page
my $body0 .= "<div class=line>\n";
for my $j (0..$#CLST) {
  next if $#{$CLST[$j]} < 0;
  my $p = $CLST[$j][0];
  my $bad = ""; $bad = " bad" if defined $COL{bad} and $CSVL{$p}[$COL{bad}];
  my $class = "k$j";
  my $n = $#{$CLST[$j]} + 1;
  my $title = "$n images in cluster $j";
     $title .= " $CLNM[$j]" if defined $CLNM[$j];
  my $src = $PATH{$p}; 
     $src = "../$src" if not $HASABS;
     $src = "../$THM{$p}" if $THUMBNAILS;
  $body0 .= "<a href=\"$class.html\"><div class=\"box $class$bad\">";
  $body0 .= "<div><img class=$class src=\"$src\" title=\"$title\"$height></div>";
  $body0 .= "$hover</div></a>\n"; }
$body0 .= "</div>\n\n";

# cluster pages (or singlepage view)
for my $j (0..$#CLST) {
  next if $#{$CLST[$j]} < 0;
  my $class = "k$j";
  my $n = $#{$CLST[$j]} + 1;
  my $title = "$n images in cluster $j";
     $title .= " $CLNM[$j]" if defined $CLNM[$j];
  my $body  = "";
     $body .= "<h2>$title</h2>\n" if $SINGLEPAGE;
     $body .= "<div class=line>\n";
  for my $i (0..$#{$CLST[$j]}) {
    my $p = $CLST[$j][$i];
    my $bad = ""; $bad = " bad" if defined $COL{bad} and $CSVL{$p}[$COL{bad}];
    my $id = sprintf "%.d:",$i+1;
    my $pdist = sprintf " %.0f\%",$CSVL{$p}[$COL{pdist}];
    my $dist = sprintf " %.0fcm",$CSVL{$p}[$COL{dist}];
    my $title = $id.$pdist.$dist;
       $title = "$id $NAME{$p}" if not defined $CSV;
    my $src = $PATH{$p}; 
       $src = "../$src" if not $HASABS;
       $src = "../$THM{$p}" if $THUMBNAILS;
    my $href = $PATH{$p};
       $href = "../$href" if not $HASABS;
       $href = "../$THM{$p}" if $REFTHUMB;
    $body .= "<a href=\"$href\"><div class=\"box $class$bad\">";
    $body .= "<div><img class=$class src=\"$src\" title=\"$title\"$height></div>";
    $body .= "$hover</div></a>\n"; }
  $body .= "</div>\n\n";

  if(not $SINGLEPAGE) {
    my $hdr = "<h1>$title</h1>\n\n";
    my $html = $HTML;
    $html =~ s/\{BODY\}/$hdr$body/;
    # print "write: $OUTDIR/$SUBDIR/$class.html\n";
    writefile "$OUTDIR/$SUBDIR/$class.html",$html; } 

  $BODY .= $body; }

$BODY = $body0 if not $SINGLEPAGE;

$HTML =~ s/\{BODY\}/$HDR$BODY/;

#print $BODY;

print "write: $OUTDIR/$SUBDIR/index.html\n";
writefile "$OUTDIR/$SUBDIR/index.html",$HTML;

# --------------------------------------------------------------------------------------
