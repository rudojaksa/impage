# filelib-0.1b (c) R.Jaksa 2019, GPLv3
# built: ~/prj/libraries/filelib/filelib.pl
# installed: /map/filelib/pl/filelib.pl

{

my $CR_="\033[31m"; # color red
my $CD_="\033[0m";  # color default

my sub error_ {
  print STDERR "$CR_$_[0]$CD_\n";
  exit 1; }

# return mtime of file (the last modification time of file content)
our sub getmtime {
  my  $file = $_[0];
  my $mtime = (stat($file))[9] if -e $file;
  return $mtime; }

# return ctime of file (last mode-modification time of the file)
our sub getmmtime {
  my   $file = $_[0];
  my $mmtime = (stat($file))[10] if -e $file;
  return $mmtime; }

# return file creation time
our sub getctime {
  my  $file = $_[0];
  my $ctime = `stat -c %W '$file'` if -e $file;
  return $ctime; }

# check if file f1 is newer then f2
our sub newer {
  my $f1 = $_[0]; return 0 if not -f $f1; # always none < f2 => 0 
  my $f2 = $_[1]; return 1 if not -f $f2; # always f1 > none => 1
  my $t1 = getmtime $f1;
  my $t2 = getmtime $f2;
  return 1 if $t1 > $t2;
  return 0; }

# check if directory d1 is newer then d2
our sub newerdir {
  my $d1 = $_[0]; return 0 if not -d $d1; # always none < d2 => 0 
  my $d2 = $_[1]; return 1 if not -d $d2; # always d1 > none => 1
  my $t1 = getmtime $d1;
  my $t2 = getmtime $d2;
  return 1 if $t1 > $t2;
  return 0; }

# write file from string
our sub writefile {
  my $file = shift;
  my $body = shift;
  my  %arg = @_; # msg=>sub{verbose "write file","$file" if $VERBOSE;}
  $arg{msg}->() if defined $arg{msg};
  error_ "Can't create file \"$file\" ($!)." if not open O,">$file";
  print O $body;
  close(O); }

# append string to file
our sub addtofile {
  my $file = shift;
  my $body = shift;
  my  %arg = @_; # msg=>sub{verbose "append to file","$file" if $VERBOSE;}
  $arg{msg}->() if defined $arg{msg};
  error_ "Can't append to file \"$file\" ($!)." if not open O,">>$file";
  print O $body;
  close(O); }

# read the first line
our sub firstline {
  my $file = $_[0];
  my $body;
  error_ "Can't read file \"$file\" ($!)." if not open FILE,"<$file";
  $body = <FILE>;
  close(FILE);
  return $body; }

# return basename without directory and without suffix
our sub basename {
  my $f = $_[0];
  $f =~ s/^.*\///;
  $f =~ s/\..*$//;
  return $f; }

# return file name from path
our sub fname {
  my $f = $_[0];
  $f =~ s/^.*\///;
  return $f; }

# return directory part of path
our sub dirname {
  return $1 if $_[0] =~ /^(.*)\/[^\/]*$/; }

# quote the file path
our sub quotepath {
  my $f = quotemeta $_[0];
  $f =~ s/\\\//\//g;
  $f =~ s/\\\././g;
  $f =~ s/\\\-/-/g;
  return $f; }

# create directory
use subs 'mkdir';				# to allow mkdir redefine
our sub mkdir {
  my $dir=shift;				# directory path
  my %arg = @_; # msg=>sub{verbose "make directory","$dir" if $VERBOSE;}
  my $qdir = quotepath($dir);			# quoted for shell
  if(not $dir eq "" and not -d $dir) {
    $arg{msg}->() if defined $arg{msg};
    system "mkdir -p $qdir"; }}			# can be done in-perl

}

