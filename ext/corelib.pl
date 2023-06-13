# corelib-0.1b (c) R.Jaksa 2012,2019, GPLv3
# built: ~/prj/libraries/corelib/corelib.pl
# installed: /map/corelib/pl/corelib.pl

{

# inar(\@a,$s) - check whether the string is in the array
our sub inar {
  my $a=$_[0];	# array ref
  my $s=$_[1];	# string
  for(@{$a}) { return 1 if $_ eq $s; }
  return 0; }
our sub ninar {	# not-inar
  my $a=$_[0];	# array ref
  my $s=$_[1];	# string
  for(@{$a}) { return 0 if $_ eq $s; }
  return 1; }

# innar(\@a,$n) - check whether the number is in the array
our sub innar {
  my $a=$_[0];	# array ref
  my $n=$_[1];	# number
  for(@{$a}) { return 1 if $_ == $n; }
  return 0; }
our sub ninnar {	# not-innar
  my $a=$_[0];	# array ref
  my $n=$_[1];	# number
  for(@{$a}) { return 0 if $_ == $n; }
  return 1; }

# pushq(\@a,$s) - string push unique, only if not there
our sub pushq {
  my $a=$_[0];	# array ref
  my $s=$_[1];	# string
  return if inar $a,$s;
  push @{$a},$s; }

# pushaq(\@a,\@r) - string per-array-element push unique, only if not there
our sub pushaq {
  my $a=$_[0];	# array ref
  my $r=$_[1];	# array ref
  for my $s (@{$r}) {
    next if inar $a,$s;
    push @{$a},$s; }}

# pushnq(\@a,$n) - number push unique, only if not there
our sub pushnq {
  my $a=$_[0];	# array ref
  my $n=$_[1];	# number
  return if innar $a,$n;
  push @{$a},$n; }

# pushaq(\@a,\@r) - number per-array-element push unique, only if not there
our sub pushnaq {
  my $a=$_[0];	# array ref
  my $r=$_[1];	# array ref
  for my $n (@{$r}) {
    next if innar $a,$n;
    push @{$a},$n; }}

# pushacp(\@a,\@a2) - make copy of a2 and push ref to it
our sub pushacp {
  my $a  = shift;	# target array ref
  my @a2 = @{shift()};	# copy of array
  push @{$a},\@a2; }

}

