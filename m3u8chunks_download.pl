use strict;
use warnings;
use Data::Dumper;

# Usage: perl m3u8chunks_letoltes.txt "url_to_media_manifest.m3u8"

# This perl script needs Parallel::ForkManager module, which is installable from internet by command:
# sudo cpan Parallel::ForkManager
# this will install the module's dependecies as well

use Parallel::ForkManager;
use File::Basename;

if (not defined $ARGV[0]){
	die "\nUsage:\nperl $0 \"http://Link_to_m3u8_file\" [outpath/outfile.mp4]\n";
}

my $m3u8link = $ARGV[0];
my $output = '';
my $tempdir = 'm3u8tmp';
my $outputfile = 'tj.mp4';

if (defined $ARGV[1]){
	if ( ( $ARGV[0] =~ m/\:\/\// ) && ( $ARGV[1] !~ m/\:\/\// ) ){
		$m3u8link = $ARGV[0];
		$output = $ARGV[1];
	}
	elsif( ( $ARGV[1] =~ m/\:\/\// ) && ( $ARGV[0] !~ m/\:\/\// ) ){
		$m3u8link = $ARGV[1];
		$output = $ARGV[0];
	}
	else{
		die "Only one of the arguments should be internet link!\n";
	}
}

#print "m3u8link: $m3u8link\n";
#print "output  : $output\n";

basename($m3u8link) =~ m/([^\?]+)\??/;
my $chunklistname = $1;
my $chunklistlocation = dirname($m3u8link);
my $fullpathinm3u8 = 0;

if($output ne ''){$tempdir = dirname($output); $outputfile = basename($output);}

`mkdir -p $tempdir`;
if ($? > 0){die "\nCould not create output directory $tempdir\n";}
`wget -c "$m3u8link" -O $tempdir/$chunklistname`;
if ($? != 0){die "Could not download manifest file. Exiting\n"}
open (CHUNKFILE, "< $tempdir/$chunklistname") || die "can't open $tempdir/$chunklistname\n";
my @chunks=(); # chunkid, chunkfilename (e.g. 0, something.mp4)
my @chunkstodownload=(); # chunkid, chunkbasename (e.g. 0, something.mp4?v=dalklkfaio&fjoaei=feohdfg)
my $chunkid = 0;
my $chunkname = '';
print "\nParsing chunkfile...";
while(<CHUNKFILE>){
	if ((/^\s*?#/) || (/^$/) ){next;}
	if ( /\:\/\// ){$fullpathinm3u8 = 1;}
	chomp();
	basename($_) =~ m/([^\?]+)\??/;
	$chunkname = $1;
	$chunks[$chunkid] = $chunkname;
	if($fullpathinm3u8){
		$chunkstodownload[$chunkid] = $_;
	}
	else{
		$chunkstodownload[$chunkid] = basename($_);
	}
	$chunkid++;
}
close(CHUNKFILE);
my $numofchunks = scalar @chunks;
print " $numofchunks chunks\n";

my $MAX_PROCESSES = 50;

my $chunkordinal = 0;
my $chunksdownloaded = 1;
my $finishedchildren = 0;
my $unsuccessfuldownloads = 0;

my $pm = Parallel::ForkManager->new($MAX_PROCESSES);

$pm->run_on_start(
	sub { 
		$chunkordinal++;
		print "\rStarted ".$chunkordinal."/".$numofchunks."   Finished ".$finishedchildren."/".$numofchunks."   Unsuccessful ".$unsuccessfuldownloads."/".$numofchunks."   Active ".($chunkordinal - $finishedchildren)."     ";
	}
);

$pm->run_on_finish(
	sub {
		my ($pid, $exit_code) = @_;
		$finishedchildren++;
		if ($exit_code > 0) {
			$unsuccessfuldownloads++;
		}
		print "\rStarted ".$chunkordinal."/".$numofchunks."   Finished ".$finishedchildren."/".$numofchunks."   Unsuccessful ".$unsuccessfuldownloads."/".$numofchunks."   Active ".($chunkordinal - $finishedchildren)."     ";
	}
);

$pm->run_on_wait(
	sub {
		print "\rStarted ".$chunkordinal."/".$numofchunks."   Finished ".$finishedchildren."/".$numofchunks."   Unsuccessful ".$unsuccessfuldownloads."/".$numofchunks."   Active ".($chunkordinal - $finishedchildren)."     ";
	},
	1
);
CHUNK_LOOP:
foreach my $chunk (@chunkstodownload){
	# Forks and returns the pid for the child:

	my $pid = $pm->start and next CHUNK_LOOP;

	my $tries = 0;
	my $errcode = 1;
	while ( ($tries <= 10) && ($errcode > 0) ){
		$tries++;
		$chunk =~ m/([^\?]+)\??/;
		$chunkname = basename($1);
		if ($fullpathinm3u8){
			`wget -qc "$chunk" -O $tempdir/$chunkname -o /dev/null &> /dev/null`;
			$errcode = $?;
		}
		else {
			`wget -qc "$chunklistlocation/$chunk" -O $tempdir/$chunkname -o /dev/null &> /dev/null`;
			$errcode = $?;
		}
	}

	$pm->finish($errcode); # Terminates the child process
}
$pm->wait_all_children;
print "\rStarted ".$chunkordinal."/".$numofchunks."   Finished ".$finishedchildren."/".$numofchunks."   Unsuccessful ".$unsuccessfuldownloads."/".$numofchunks."   Active ".($chunkordinal - $finishedchildren)."     ";
print "\nParallel download processes finished.\n";

my $cnt = 0;
print "\n";
if($unsuccessfuldownloads == 0){
	`echo > $tempdir/$outputfile`;
	foreach my $chunk (@chunks){
		print "\rDownload finished, merging... ".++$cnt."/".$numofchunks;
#		print "cat $tempdir/$chunk >> $tempdir/$outputfile\n";
		`cat $tempdir/$chunk >> $tempdir/$outputfile`;
		unlink "$tempdir/$chunk";
	}
	unlink "$tempdir/$chunklistname";
}
else{
	print STDERR "ERROR: Download incomplete! At least one chunk is incomplete.\n";
	print STDERR "       You may try to run the same command again.\n";
}
