@rem= 'PERL for Windows NT - perl must be in search path
@echo off

C:\Perl\bin\perl ParseCommit.bat%*

goto endofperl
@rem ';
use strict;

my $commitMsg = `git log -1 master --pretty=%s`;
chomp($commitMsg);
if($commitMsg =~ /\[(.+)\]/){
	print "Issue is $1\n";
}
else{
	print "No issue found\n";
}
__END__
:endofperl
pause
