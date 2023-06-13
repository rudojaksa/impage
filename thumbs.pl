my @THMD = @DIRS; # thumbnails dirs
my %THM;	  # thumbnails paths
my %NAME;	  # image names (without redundat part of path)
my %PATH;	  # image path (converted to absolute if needed)

# return toplevel directory from the path (incl. slash), or empty string
sub topdir {
  my $dir = $_[0];
  return $1 if $dir =~ /^(\/?[^\/]*\/?)/;
  return ""; }

# return 1 if prefix in all paths
sub preinall {
  my $dirs = $_[0];
  my $pre  = $_[1];
  return 0 if $pre eq "";
  for my $i (0..$#{$dirs}) {
    my $p = $$dirs[$i];
    return 0 if not $p =~ /^$pre/; }
  return 1; }

# remove prefix from whole array
sub rmpre {
  my $dirs = $_[0];
  my $pre  = $_[1];
  for my $i (0..$#{$dirs}) {
    $$dirs[$i] =~ s/^$pre//; }}

# current working directory
use Cwd qw(getcwd);
my $CWD = getcwd;

# check whether absolute path is present
my $HASABS;
for my $p (@IMG) {
  if($p =~ /^\//) {
    $HASABS = 1;
    last; }}
# print "hasabs = $HASABS\ncwd = $CWD\n";

# convert to absolute path if needed
for my $p (@IMG) {
  $PATH{$p} = "$p"; }
if(defined $HASABS) {
  for my $p (@IMG) {
    $PATH{$p} = "$CWD/$p" if $p =~ /^[^\/]/; }
  for my $p (@THMD) {
    $p = "$CWD/$p" if $p =~ /^[^\/]/; }
  for my $p (@DIRS) {
    $p = "$CWD/$p" if $p =~ /^[^\/]/; }}

# remove redundant-path prefix from THMD (present in all dirs)
if(0) {

my $top = topdir $THMD[0]; # print "[$THMD[0]] -> [$top]\n";
my $pre = "";		  # total path prefix to remove
while(preinall(\@THMD,$top)) {
  # print "[$THMD[0]] -> [$top] ($pre)\n";
  rmpre \@THMD,$top;
  $pre .= $top;
  $top = topdir $THMD[0]; }
$pre .= "/" if $pre ne "" and not $pre =~ /\/$/;
# print "redundant prefix: $pre\n";

}

# thumbnails root directory
my $thmdir = "$OUTDIR/thm";

# prepare THM names
for my $p (@IMG) {
  ($NAME{$p}=$PATH{$p}) =~ s/^$pre//;
  ( $THM{$p}=$PATH{$p}) =~ s/^$pre/$thmdir\//;
  next if $THUMBCOPY;
  if($THUMBPNG)	{ $THM{$p} =~ s/\....$/\.png/; }
  else		{ $THM{$p} =~ s/\....$/\.jpg/; }}
# print "$_ -> $PATH{$_} -> $NAME{$_} -> $THM{$_}\n" for @IMG; exit;

# batch-parallel create thumbnails
if($THUMBNAILS) {

  # prepar dirs for thumbnails
  mkdir $thmdir;
  for my $p (@THMD) {
    $p = "$thmdir/$p";
    mkdir $p; }
  # print "$pre => $thmdir/\n"; print "$DIRS[$_] -> $THMD[$_]\n" for 0..$#DIRS;

  # set up the geometry
  $GEOMETRY = "x196" if not defined $GEOMETRY;
  $QUALITY  = 80     if not defined $QUALITY;
  my $pre = "";
     $pre = "-alpha off" if $THUMBOPQ;
  my $con = "-resize $GEOMETRY -quality $QUALITY";
     $con .= " -rotate -90" if $ROTLEFT;
     $con .= " -rotate 90" if $ROTRIGHT;
  my $cmd = "convert $pre IN $con OU";
     $cmd = "cp -a IN OU" if $THUMBCOPY;
     $cmd =~ s/IN/"\$IN"/g;
     $cmd =~ s/OU/"\$OU"/g;

  # prepare the conversion script
  my $CONV = "$OUTDIR/conv";
  my $conv=<<EOF;
#!/bin/bash
for s in \$*; do
  IN=`echo \$s | sed 's:%%%.*\$::'`
  OU=`echo \$s | sed 's:^.*%%%::'`
  if test "\$OU" -nt "\$IN"; then break; fi
# echo "__CMD__"
        __CMD__
  echo -n "."
done
EOF
  $conv =~ s/__CMD__/$cmd/g;
  writefile $CONV,$conv;
  system "chmod 775 $CONV";

  # batchsize, limited to 64 max
  my $BATCH = ($#IMG+1)/8;
  $BATCH=64 if $BATCH>64;
  $BATCH=1  if $BATCH<1;

  # make thumbnails
  open $pipe, "| parallel -u -L $BATCH $CONV" or die "Can't pipe: $!";
  for(@IMG) { print $pipe "$_%%%$THM{$_}\n" if -f $_; }
  close $pipe or die "Can't close pipe: $!";

  # remove thumbnailer
  #system "rm -f $CONV";
}

# make thumbnails paths back relative if needed
if(not $HASABS) {
  for my $p (@IMG) {
    $THM{$p} =~ s/^$OUTDIR\///; }}

