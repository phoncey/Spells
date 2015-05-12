@rem= 'PERL for Windows NT - perl must be in search path
@echo off

C:\Perl\bin\perl mkHOLpkg.bat%*

goto endofperl
@rem ';
#############################################################################################
# Revision History                                                                          #
# HOL mkpkg 2/9/2015                                                                        #
# Initial Revision                                                                          #
#############################################################################################

use strict;
use File::Path;
use File::Copy;
#use Switch;
my $userPRnum;
my $inspectPath;
my $inspectPDrivePath;
my $userlen;
my $dev_branch;
my $gpp_dev_branch = "";
my $merge_branch;
my $before_hash;
my $after_hash;
my $gppOrIPM;
my $DEBUG = 0;
my @reviewableBranches;
my @releaseBranches;
my @fileManifest;
my $fileManifestCorrections = 0;
my $correctionsMode = 0;
my $ccollab = "C:\\Program Files\\Collaborator\ Client\\ccollab.exe";
# a comment here
#another ccomment here
#one last one here
    #Check if B: Drive or IPM dir Exist
    if(-d "B:\\" && -d "C:\\DTE\\Release\\GIT\\IPM"){
        print "mkHOLpkg Version 1.0\n";
        print "\n";
        print "Please enter PR number:";
        $userPRnum = <STDIN>; #User enter PR number
        $userlen = length $userPRnum;
        chomp $userPRnum;
		#DMTODO:
        #$inspectPath = "H:\\HOL_Inspections\\PR_$userPRnum\\";
		#$inspectPDrivePath set path here for check below
		$inspectPath = "C:\\Temp\\PR_$userPRnum\\";
        #Check if path already exsit
       if(-d "$inspectPath"){
            print "\n";
            print "PR package already Exists!\n";
            print "\n";     
			print "Do you wish to run corrections on PR_$userPRnum? ([y]es or [n]o)\n";
			my $yesOrNo = <STDIN>;
			chomp($yesOrNo);
			if($yesOrNo =~ /n/ig)
			{
				print "Thank you and goodnight!\n";
				exit();
			}
			else{
				#$inspectPath = $inspectPDrivePath;
				$correctionsMode = 1;
				print "****************************************************************\n";
				print "*****CORRECTIONS MODE*******************************************\n";
				print "****************************************************************\n";
				&processCorrections();
			}
        }
        
		if($userPRnum eq "" || $userlen != 6){
            print "\n";
            print "PR number is Invalid!\n";
            print "\n";
        }
        #Check PR number validity
        else{
			if(!$correctionsMode)
			{
				&createDirectoryStructure();
			}
			else{
				#create batch file for Corrections mode
				&createBatchFileForCollaborator();
			}
			
			do{
				print "Do you have:\n";
				print "(1) GPP changes\n";
				print "(2) IPM changes\n";
				print "(3) GPP and IPM changes\n";
				print "Press enter for default GPP only changes (1)\n";
				$gppOrIPM = <STDIN>;
				chomp($gppOrIPM);
				&DebugMsg($gppOrIPM);
				if($gppOrIPM eq "")
				{
					$gppOrIPM = 1;
				}
			}while($gppOrIPM > 3);

				if($gppOrIPM == 1){
					&DebugMsg("GPP Only Changes\n");
					&getGPPChanges();
				}
				elsif($gppOrIPM == 2){
					&DebugMsg("IPM Only Changes\n");
					&getIPMChanges();
				}
				elsif($gppOrIPM == 3){
					&DebugMsg("GPP and IPM Changes\n");
					&getGPPChanges();
					$gpp_dev_branch = $dev_branch;
					&getIPMChanges();
				}
				else{
					&DebugMsg("This should never happen\n");
				}
			print "\n";
			print "PR package path $inspectPath\n";
			print "\n";
        }
    }
    else{
        print "B: or C:\\DTE\\Release\\GIT\\IPM Drive Does not Exist\n";
    }


sub createDiffBatchFile{

    open(OUT, ">$inspectPath\\BeyondCompare_DIFF.bat") or die $!;
	print OUT "set var=%cd%\n";
    print OUT "set Path=C:\\Program Files (x86)\\Beyond Compare 3;%Path%\n";
    print OUT "BCompare.exe /expandall \"%var%\\Original Files\" \"%var%\\Changed Files\"";
   
    close OUT;

}

sub createDirectoryStructure{
    #Create Package Path
    mkpath($inspectPath) or die $!;
    mkdir "$inspectPath\Changed_Files";
    mkdir "$inspectPath\Original_Files";
    mkdir "$inspectPath\Info_Only";
    &createDiffBatchFile();
	&createBatchFileForCollaborator();
    open(OUT, ">$inspectPath\\file_manifest.txt");
	close(OUT);
    open(OUT, ">$inspectPath\\Reviewer's Notes.doc");
	close(OUT);

}
## DebugMsg should be used for all debug information. If this script becomes
## more heavily used it should be relatively simple to add a file logging feature/g
## similar to legacy mkpkg.
sub DebugMsg{

	if($DEBUG)
	{
		print @_;
	}
}

sub getBranches{
	&DebugMsg("Get branches\n");
	&getDevBranch();
	&getMergeBranch();
}
## getDevBranch tries to get information for the branch getting submitted for review
sub getDevBranch{
	my @branches = `git branch`;
	&DebugMsg(@branches);
	
    foreach my $item(@branches) {
		if($item !~ /master/ig && $item !~ /release/ig && $item !~ /develop/ig && $item !~ /Boeing/ig)
		{
			push(@reviewableBranches, $item);
		}
    }
	print "\nAvailable branches for review:\n";
	my $selection = 1;
	foreach my $item(@reviewableBranches) {
        print"$selection. $item";
        $selection++;
    }
    $selection--;
	
	my $selectionOptions = "[1]";
        if ($selection > 1) {
			$selectionOptions = "[1-$selection]";
    }
	my $userInputs;
	do {
        if($selectionOptions eq "[1]")
		{
            print "Press enter to use default branch [1]: "
        }
        else{
            print"\nPlease select one of the branches above $selectionOptions: ";
        }
        $userInputs = <STDIN>;
        chomp($userInputs);
        if($userInputs eq ""){
            $userInputs = 1;
        }
        &DebugMsg("userInput: $userInputs\n");
        } while ($userInputs > $selection);
		
		chomp($reviewableBranches[($userInputs-1)]);
		$dev_branch = $reviewableBranches[($userInputs-1)];
		#if(substr($dev_branch, 0, 1) ne "*")
		#{	
		#	my $teststring = substr($dev_branch, 0, 1);
		#	print "test string is $teststring bob\n";
		#	print "Please checkout the dev branch you plan on creating a package for!\n";
		#	#note: delete $inspectionPath
		#	exit();
		#}
		$dev_branch = substr $dev_branch, 2;
		&DebugMsg("Dev branch is: $dev_branch\n");
}
## getMergeBranch tries to figure out which branch the developer is going to try and merge into
## this is necessary for getting the merge-base commit, which will serve as the "Before" commit
## where we get "Original_Files" from. The merge_branch is also useful when creating the patch.
sub getMergeBranch{
	my @branches = `git branch`;
	&DebugMsg(@branches);
	
    foreach my $item(@branches) {
		if($item =~ /master/gi || $item =~ /release/gi || $item =~ /develop/gi || $item =~ /Boeing/ig)
		{
			push(@releaseBranches, $item);
		}
    }
	print "\nAvailable branches for merge:\n";
	my $selection = 1;
	foreach my $item(@releaseBranches) {
        print"$selection. $item";
        $selection++;
    }
    $selection--;
	
	my $selectionOptions = "[1]";
        if ($selection > 1) {
			$selectionOptions = "[1-$selection]";
    }
	my $userInputs;
	do {
        if($selectionOptions eq "[1]")
		{
            print "Press enter to use default branch [1]: "
        }
        else{
            print"\nPlease select one of the branches above $selectionOptions: ";
        }
        $userInputs = <STDIN>;
        chomp($userInputs);
        if($userInputs eq ""){
            $userInputs = 1;
        }
        &DebugMsg("userInput: $userInputs\n");
        } while ($userInputs > $selection);
		
		chomp($releaseBranches[($userInputs-1)]);
		$merge_branch = $releaseBranches[($userInputs-1)];
		$merge_branch = substr $merge_branch, 2;
		&DebugMsg("Merge branch is: $merge_branch\n");
}
sub getGPPChanges{
	&DebugMsg("Get GPP changes\n");
	print("Getting GPP changes...\n");
	chdir "B:\\";
	&getBranches();
	$after_hash = `git rev-parse $dev_branch`;
	chomp($after_hash);
	&DebugMsg("after hash for $dev_branch: $after_hash\n");
	$before_hash = `git show-branch --merge-base $dev_branch $merge_branch`;
	chomp($before_hash);
	&DebugMsg("before hash for $merge_branch: $before_hash\n");
	
	@fileManifest = `git diff --name-only $merge_branch $dev_branch`;
	&DebugMsg("FileManifest:\n");
	&DebugMsg(@fileManifest);
	if(!$correctionsMode)
	{
		open(OUT, ">>$inspectPath\\file_manifest.txt");
		print OUT @fileManifest;
		close(OUT);
	}
	else{
		if(-e "$inspectPath\\file_manifest.txt")
		{
			$fileManifestCorrections = 1;
			unlink "$inspectPath\\file_manifest.txt";
			open(OUT, ">>$inspectPath\\file_manifest.txt");
			print OUT @fileManifest;
			close(OUT);
		}
		else{
			&DebugMsg("file_manifest doesn't exist for some reason!\n");
		}
	}

	if(!$correctionsMode)
	{
		`git format-patch -k --stdout $merge_branch..$dev_branch > "$inspectPath/Info_Only/GPP_PR_$userPRnum.patch"`;
	}
	else
	{
		#assume corrections mode
		if(-e "$inspectPath/Info_Only/GPP_PR_$userPRnum.patch")
		{
			unlink "$inspectPath/Info_Only/GPP_PR_$userPRnum.patch";
			`git format-patch -k --stdout $merge_branch..$dev_branch > "$inspectPath/Info_Only/GPP_PR_$userPRnum.patch"`;
		}
		else
		{
			&DebugMsg("GPP_PR_$userPRnum.patch doesn't exist for some reason!\n");
		}
	}

	`git stash`;
	if(!$correctionsMode)
	{
		#Only get original file when not in corrections mode
		print("Getting GPP Original_Files...\n");
		&getOriginalFiles();
	}
	print("Getting GPP Changed_Files...\n");
	&getChangesFiles();
	print("Checkout original HEAD files...\n");
	&getHeadFiles();
	`git stash pop`;
}

## getIPMChanges gets all changes from $dev_branch, nearly identical to how getGPPChanges works.
## TODO: since getGPPChanges is run first error checking should be possible to make sure than
## developers haven't screwed up branch name
sub getIPMChanges{
	&DebugMsg("Get IPM changes\n");
	print("Getting IPM changes...\n");
	chdir "C:\\DTE\\Release\\GIT\\IPM";
	if($gpp_dev_branch ne "")
	{
		#my @branchCheck = `git branch`;
		#my $branchflag = 1;
		#&DebugMsg("branchCheck: @branchCheck\n");
		#foreach my $br (@branchCheck)
		#{
		#	chomp($br);
		#	my $my_branch = quotemeta($br);
		#	my $lookingfor = quotemeta($gpp_dev_branch);
		#	&DebugMsg("branch check item: $my_branch\n");
		#	&DebugMsg("looking for branch $lookingfor\n");
		#	if($lookingfor =~ m/$my_branch/gi)
		#	{
		#		&DebugMsg("$lookingfor found!");
		#		$branchflag = 0;
		#		last;
		#	}
		#}
		
		#if($branchflag)
		#{
		#	print "$gpp_dev_branch doesn't exist in IPM repo!\n";
		#	exit();
		#}
		
	}
	else{
		&getBranches();
	}
	
	$after_hash = `git rev-parse $dev_branch`;
	chomp($after_hash);
	&DebugMsg("after hash for $dev_branch: $after_hash\n");
	$before_hash = `git show-branch --merge-base $dev_branch $merge_branch`;
	chomp($before_hash);
	&DebugMsg("before hash for $merge_branch: $before_hash\n");
	
	@fileManifest = `git diff --name-only $merge_branch $dev_branch`;
	&DebugMsg("FileManifest:\n");
	&DebugMsg(@fileManifest);
	#$fileManifestCorrections flag meant to indicate when a new file manifest
	#for corrections has already been made by for the GPPs
	#also the file manifest should be created automatically if not in corrections mode
	if($fileManifestCorrections || !$correctionsMode)
	{
		open(OUT, ">>$inspectPath\\file_manifest.txt");
		print OUT @fileManifest;
		close(OUT);
	}
	else{
		if(-e "$inspectPath\\file_manifest.txt")
		{
			$fileManifestCorrections = 1;
			unlink "$inspectPath\\file_manifest.txt";
			open(OUT, ">>$inspectPath\\file_manifest.txt");
			print OUT @fileManifest;
			close(OUT);
		}
		else{
			&DebugMsg("file_manifest doesn't exist for some reason!\n");
		}
	}
	
	if(!$correctionsMode)
	{
		`git format-patch -k --stdout $merge_branch..$dev_branch > "$inspectPath/Info_Only/IPM_PR_$userPRnum.patch"`;
	}
	else
	{
		#assume corrections mode
		if(-e "$inspectPath/Info_Only/IPM_PR_$userPRnum.patch")
		{
			unlink "$inspectPath/Info_Only/IPM_PR_$userPRnum.patch";
			`git format-patch -k --stdout $merge_branch..$dev_branch > "$inspectPath/Info_Only/IPM_PR_$userPRnum.patch"`;
		}
		else
		{
			&DebugMsg("IPM_PR_$userPRnum.patch doesn't exist for some reason!\n");
		}
	}
	
	`git stash`;
	if(!$correctionsMode)
	{
		#Only get original file when not in corrections mode
		print("Getting IPM Original_Files...\n");
		&getOriginalFiles();
	}
	print("Getting IPM Changed_Files...\n");
	&getChangesFiles();
	print("Getting IPM original HEAD files...\n");
	&getHeadFiles();
	`git stash pop`;
}

## getOriginalFiles uses $before_hash to get the files before changes where made on $dev_branch
sub getOriginalFiles{
	foreach my $file(@fileManifest)
	{
		chomp($file);
		`git checkout $before_hash -- $file`;
		&DebugMsg("$file $inspectPath\Original_Files");
		copy("$file", "$inspectPath\Original_Files") or die "couldn't copy $!";
	}
}

## getChangesFiles uses $after_hash to get the latest file changes on the $dev_branch
sub getChangesFiles{
	foreach my $file(@fileManifest)
	{
		chomp($file);
		`git checkout $after_hash -- $file`;
		&DebugMsg("$file $inspectPath\Changed_Files");
		copy("$file", "$inspectPath\Changed_Files") or die "couldn't copy $!";
	}
}
## getHeadFiles uses HEAD to get the file changes from getGetChangesFiles and getOriginalFiles "reset"
## so that after mkHOLpkg is run all files are at the state they wouldn't been before mkHOLpkg was run
sub getHeadFiles()
{
	foreach my $file(@fileManifest)
	{
		chomp($file);
		`git reset HEAD $file`;
		`git checkout -- $file`;
		&DebugMsg("$file $inspectPath\Changed_Files");
	}
}
## createBatchFileForCollaborator creates the batch file that
## developers can use to upload their changes to collaborator
sub createBatchFileForCollaborator{
	&DebugMsg("createBatchFileForCollaborator\n");
	
	#ccollab adddiffs Original_Files Changes_Files
	#ccollab addfiles *.xls* *.txt Info_Only/*
	if(!$correctionsMode)
	{
		open(OUT, ">$inspectPath/GenerateCollaboratorHOLReview.bat") or die;
		print OUT "\@echo off\n";
		print OUT "\"$ccollab\" adddiffs new Original_Files Changed_Files\n";
		print OUT "\"$ccollab\" addfiles last *.txt *.pdf *.html *.doc* *.xls* Info_Only/*\n";
		close OUT;
	}
	else{
		#assume corrections mode
		if (!-e "$inspectPath"."//Corrections")
		{
			mkpath("$inspectPath"."//Corrections") or die $!;
			open(OUT, ">$inspectPath/Corrections/GenerateCollaboratorHOLReview.bat") or die;
			print OUT "\@echo off\n";
			print OUT "cd ..\n";
			print OUT "\"$ccollab\" adddiffs ask Original_Files Changed_Files\n";
			print OUT "\"$ccollab\" addfiles last *.txt *.pdf *.html *.doc* *.xls* Info_Only/*\n";
			close OUT;
		}
		
	}

}

## processCorrections is the top level routine to process corrections
sub processCorrections{
	&DebugMsg("Processing corrections\n");
	#could re-prompt the user for branch info
}
__END__
:endofperl
pause
