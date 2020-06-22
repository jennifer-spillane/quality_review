#!/usr/bin/env perl

use strict;
use Bio::SeqIO;
use File::Copy;
use Cwd;

our $VERSION = 0.02;
our $LOG = 'gblock.log';

# originally by Casey Dunn and/or Stephen Smith
# edited by Joseph Ryan

MAIN: {
    @ARGV || die "usage: $0 FASTA_ALN_FILE(s)\n";
    my @files = ();
    foreach my $arg (@ARGV) {
        push @files, $arg;
    }

    foreach my $file (@files) {
        my $seq_in = Bio::SeqIO->new( '-format' => "fasta", '-file' => $file);
        my $count = 0;
        while (my $inseq = $seq_in->next_seq) {
            $count++;
        }
        print "   $count sequences\n";
        if ($count < 4) {
            print "   Too few sequences to proceed with $file\n";
            next;
        }
        my $b2 = 0.65 * $count;
        $b2 =~ s/\.\d*$//;
        
        open LOG, ">>$LOG" or die "cannot open $LOG:$!";
        my $cmd = "Gblocks $file -b2=$b2 -b3=10 -b4=5 -b5=a >> $LOG";
        print LOG "---------------------------------------------------------\n";
        print LOG "$cmd\n";
        close LOG;
        system $cmd;
    }
}


