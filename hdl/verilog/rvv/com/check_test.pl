#! /usr/bin/perl 

my $cmd;

my $pass = 1;

if(@ARGV<2) {print "usage:\n   check_test.pl <test.log> <test_name>\n"; exit;};

$cmd = `grep -s "^\s*UVM_ERROR" $ARGV[0]`;

$cmd =~ m/UVM_ERROR\s*:\s*(\d+)\s*$/;
if (! defined $1 ) {$pass = 0 ;}
if ($1 != 0)
{
  $pass = 0 ;
}

$cmd = `grep -s "^\s*UVM_FATAL" $ARGV[0] `;

$cmd =~ m/UVM_FATAL\s*:\s*(\d+)\s*$/;
if (! defined $1 ) {$pass = 0 ;}

if ($1 != 0)
{
  $pass = 0 ;
}

$cmd = `grep -s "^\s*UVM_WARNING" $ARGV[0]`;

$cmd =~ m/UVM_WARNING\s*:\s*(\d+)\s*$/;
if (! defined $1 ) {$pass = 0 ;}
if ($1 != 0)
{
  $pass = 0 ;
}

if(!$pass){
   print "====failed====$ARGV[1]\n";
   `echo "====failed====$ARGV[1]" >> $ARGV[0]`;
}
else {
   print "====pass====$ARGV[1]\n";
  `echo "====pass====$ARGV[1]" >> $ARGV[0]`;
}
exit;
