#! /usr/bin/perl 

use strict;
use Term::ANSIColor;

my $cmd  = shift;
my $testname = shift;
if($cmd =~ m/help/) { Usage(); }
elsif($cmd =~ m/check/) { Check(); }
elsif($cmd =~ m/clean/) { Clean(); }
elsif($cmd =~ m/gen_asm/) { GenASMSource(); }
else  { Usage(); }

sub Check {
  my $p_uvmFail = qr/^(UVM_ERROR|UVM_FATAL)( \S+ | )(@\s*\d+:) (\S+) (\[\S+\]) (.*)$/;
  my $p_astFail = qr/Error/;
  my $p_astWarn = qr/Warning/;
  my $p_othFail = qr/((?<!UVM_)ERROR)/;

  my $p_discardRate = qr/UVM_INFO.+\[FINAL_CHECK\] RVV.+discarded ([0-9.]+)%/;
  foreach (@ARGV) {
    open my $fh, '+<', $_ or die "Open $_ failed: $!";

    my @texts = <$fh>;
    my $uvmFail = grep m/$p_uvmFail/g, @texts;
    my $astFail = grep m/$p_astFail/g, @texts;
    my $astWarn = grep m/$p_astWarn/g, @texts;
    my $othFail = grep m/$p_othFail/g, @texts;
    my $match = $uvmFail + $astFail + $othFail;
    my $discardRate = undef;
    map { $discardRate = $1 if m/$p_discardRate/g; } @texts;


    if($match) {
      print color "bold red";
      print "====FAIL==== $testname\n";
      print $fh "====FAIL==== $testname\n";
      print "Assert Fail: $astFail\n";
      print $fh "Assert Fail: $astFail\n";
      print "Assert Warning: $astWarn\n";
      print $fh "Assert Warning: $astWarn\n";
      print color "reset";
    } else {
      print color "bold green";
      print "====PASS==== $testname\n";
      print $fh "====PASS==== $testname\n";
      print "Assert Warning: $astWarn\n";
      print $fh "Assert Warning: $astWarn\n";
      print color "reset";
    }
    if(defined $discardRate) {
      if($discardRate > 50.0) {
        print color "bold red";
        print "WARNING: Discarded rate $discardRate% > 50%\n";
        print $fh "WARNING: Discarded rate: $discardRate% > 50%\n";
        print color "reset";
      } else {
        print color "bold green";
        print "Discarded rate: $discardRate%\n";
        print $fh "Discarded rate: $discardRate%\n";
        print color "reset";
      }
    }

    close $fh;
  }
}

sub Clean {
  my $p_uvmInfo = qr/^(UVM_\S+) (\S+) (@\s*\d+:) (\S+) (\[\S+\]) (.*)$/;
  #                   $1       $2:path $3:time  $4:hier $5:label  $6:info
  foreach (@ARGV) {
    open my $fh, '+<', $_ or die "Open $_ failed: $!";
    my @lines = <$fh>;
    seek($fh, 0, 0);
    truncate($fh, 0);
    foreach my $line (@lines) {
      $line =~ s/$p_uvmInfo/$3 $6/g;
      print $fh $line;
    }
    close $fh;
  }
}


sub Usage {
  die <<EOU;
  Usage:
    perl ./check_test.pl <check|clean> <test_name> <files ...> 
      check: check logs failures
      clean: clean up UVM logs
EOU
}
