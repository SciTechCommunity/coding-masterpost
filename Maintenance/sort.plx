#!/usr/bin/env perl
# Sort all entrys in a list of links in this repo (https://github.com/TumblrCommunity/coding-masterpost/tree/PythonNerd-patch-1)
# Author: redrock9 (https://github.com/redrock9)
# This script modifies files. The modifications are permanent, but a backup with a ".backup" extention will
# be made in the directory in which the file is located before any modifications take place.
# How to use: execute this script with the path to a file as argument, for example: ./sort.plx Resources/test.md
use strict;
use warnings;

use File::Copy qw(move);

# Take filehandle as agrument
my $file = $ARGV[0];

# Open file and put line sin an array
open (TEXT, "< $file") or die "Can't open $file for read: $!";
my @lines = <TEXT>;
map {s/\s+$//} @lines;
close TEXT or die "Cannot close $file: $!";

# get keys for each line and store each line in a hash
my @keys;
my %linesToSort;
my $i = -1; # Switches between categories (increments when a line starting with # is encountered)
my $a = 1; # in this loop: number to append to keys that are otherwise double in the hash

for (0..$#lines) {
    if ($lines[$_] =~ /^\#(?:.*)/){
        $i++
    }
    elsif ($lines[$_] =~ /(?:^\[)(.*?)(?:\])/){
        my($key) = $1;
        if ($linesToSort{$key}){
            $linesToSort{"${key}$a"} = "$lines[$_]";
            push @{$keys[$i]}, "${key}$a";
            $a++;
        }
        else {
            $linesToSort{$key} = "$lines[$_]";
            push @{$keys[$i]}, "$key";
        }
    }
}

# Print the number of lines in the file before modification
print "the number of lines before sorting is: $#lines\n";

# Sort keys lexicographically
map {@{$_} = sort @{$_}} @keys;

# Make a backup of the file
move("$file", "${file}.backup");

# Print the sorted lines into the file
$i = -1; # Switches between categories (increments when a line starting with # is encountered)
$a = 0; # In this loop: The amount of lines per category (is set to 0 every time a # is encountered)

open (NEWTEXT, "> $file") or die "Can't open $file for read: $!";
for (0..$#lines) {
    if ($lines[$_] =~ /^\#(?:.*)/){
        print NEWTEXT "$lines[$_]\n";
        $i++;
        $a = 0;
    }
    elsif  ($lines[$_] !~ /(?:^\[)(.*?)(?:\])/){
        print NEWTEXT "$lines[$_]\n"
    }
    elsif($keys[$i][$a]){
        print NEWTEXT "$linesToSort{$keys[$i][$a]}\n";
        print "$keys[$i][$a]\n";
        $a++;
    }
}
close NEWTEXT or die "Cannot close file $file: $!";
print "-----SORTING COMPLETED-----\n";
