#!/usr/bin/perl -w

###############################################################################
# Setup
###############################################################################

use strict;
use File::Path qw(make_path);
use File::Basename;
use File::Copy;
use Data::Dumper;

if (scalar(@ARGV) == 0) {
	die "Expected to see one parameter, the results dir."
}

###############################################################################
# Main
###############################################################################

my $results_dir = shift @ARGV;
die "Couldn't Find $results_dir" if (! -e $results_dir);

my @files = <"$results_dir*">;

my $images_dir = "$results_dir/images";
make_path($images_dir);

for (@files) {
	next if -d $_;
	
	move($_,"$images_dir");
}

@files = <"$images_dir/*">;
#Fix sorting problem with leading zero on time slot
for (@files) {
	my $filename = basename($_);
	if ($filename =~ /(.*_w.*_s\d+_t)(\d)(\.TIF)/) {
		my $fixed_filename = sprintf('%s%02d%s',$1,$2,$3);
		move($_, "$images_dir/$fixed_filename");
	}
}

@files = <"$images_dir/*">;

my @unrefed_files;

for (@files) {
	my $filename = basename($_);
	if ($_ =~ /bsa_pre_(.*?)_w.*_s(\d+)/) {
		my $stage = sprintf('%02d',$2);
		my $target_folder = "$results_dir/$stage/Acceptor";
		make_path($target_folder);
		system("ln -s \"../../images/$filename\" \"$target_folder/$filename\"\n");
	} elsif ($_ =~ /cna_pre_(.*?)_w.*_s(\d+)/) {
		my $stage = sprintf('%02d',$2);
		my $target_folder = "$results_dir/$stage/FRET";
		make_path("$target_folder");
		system("ln -s \"../../images/$filename\" \"$target_folder/$filename\"\n");
	} elsif ($_ =~ /bsd_pre_(.*?)_w.*_s(\d+)/) {
		my $stage = sprintf('%02d',$2);
		my $target_folder = "$results_dir/$stage/Donor";
		make_path("$target_folder");
		system("ln -s \"../../images/$filename\" \"$target_folder/$filename\"\n");
	} elsif ($_ =~ /pre_(.*?)_w.*FWTR_s(\d+)/) {
		my $stage = sprintf('%02d',$2);
		my $target_folder = "$results_dir/$stage/Cherry";
		make_path("$target_folder");
		system("ln -s \"../../images/$filename\" \"$target_folder/$filename\"\n");
	} elsif ($filename =~ /(.*?)_w.*DIC_s(\d+)/) {
		my $stage = sprintf('%02d',$2);
		my $target_folder = "$results_dir/$stage/DIC";
		make_path("$target_folder");
		system("ln -s \"../../images/$filename\" \"$target_folder/$filename\"\n");
	} elsif ($filename =~ /(.*?)_w.*BF_s(\d+)/) {
		my $stage = sprintf('%02d',$2);
		my $target_folder = "$results_dir/$stage/BF";
		make_path("$target_folder");
		system("ln -s \"../../images/$filename\" \"$target_folder/$filename\"\n");
	} elsif ($_ =~ /dpa_pre_(.*?)_w.*_s(\d+)/) {
		my $stage = sprintf('%02d',$2);
		my $target_folder = "$results_dir/$stage/DPA";
		make_path("$target_folder");
		system("ln -s \"../../images/$filename\" \"$target_folder/$filename\"\n");
	} elsif ($_ =~ /eff_pre_(.*?)_w.*_s(\d+)/) {
		my $stage = sprintf('%02d',$2);
		my $target_folder = "$results_dir/$stage/Efficiency";
		make_path("$target_folder");
		system("ln -s \"../../images/$filename\" \"$target_folder/$filename\"\n");
	} elsif ($_ =~ /SaveParams/) {
		#don't mark SaveParams for deletion
	} else {
		push @unrefed_files, $_;
	}
}

# unlink @unrefed_files;
