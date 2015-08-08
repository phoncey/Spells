#!/bin/perl
#####################################################################
#  WINDOWS ONLY     WINDOWS ONLY     WINDOWS ONLY     WINDOWS ONLY  #
#####################################################################
#
# This script is designed to alter FILE_NAME HERE  file on the fly
#

use strict;

if(@ARGV == 0)
{
   die("must enter CWD name!");
}

open(FILE, "FILE_NAME_HERE") or die ("Couldn't open FILE_NAME_HERE file!");
my @SettingContent = <FILE>;
close(FILE);

foreach my $item (@SettingContent)
{
   $item =~ s/%BAMBOO%/$ARGV[0]/g;
}

open(FILE, "> FILE_NAME_HERE ") or die ("Couldn't open FILE_NAME_HERE file!");
print FILE @SettingContent;
close (FILE);