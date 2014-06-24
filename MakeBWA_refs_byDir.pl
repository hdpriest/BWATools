#!/usr/bin/perl
use warnings;
use strict;
use threads;
use Thread::Queue;


my $usage="perl $0 <number of threads> <directory> <path to BWA>\n\n";
die $usage unless $#ARGV==2;

my $q=Thread::Queue->new();

my $threads=$ARGV[0];
my $directory=$ARGV[1];
my $bwa=$ARGV[2];

opendir(DIR,$directory) || die "cannot open directory $directory!\n$!\nexiting...\n";
my @files=grep {m/\.fa/} readdir DIR;
closedir DIR;

foreach my $file (@files){
	$q->enqueue($file);
}

for(my$i=0;$i<=$threads;$i++){
        my $thr=threads->create(\&workerThread);
}

while(threads->list()>0){
        my @thr=threads->list();
        $thr[0]->join();
}

sub workerThread {
	while(my$file=$q->dequeue_nb()){
		my $path=$directory."/".$file;
		die "Cannot find file: $path\n" unless -e $path;
		my $command=$bwa." index $path";
		warn $command."\n";
		`$command`;
	}
}
