#!/usr/bin/perl
use strict;
use LWP::Simple;
use Getopt::Std;

## Global truths
my $pageUrl = "http://www.furaffinity.net/view/";
my $version = "0.1";

## Defaults
# Default folder is "downloads" in the current folder.
my $folder = "downloads";
# Not verbose by default.
my $verbose = 0;

## Standard getopts
my %args;
getopts("u:d:hv", \%args);

print "FurAffinity Favorites Downloader version $version\n"
    . "By thingywhat (https://github.com/thingywhat)\n\n"
    . "\t-h\t\t\tThis help screen.\n"
    . "\t-u <user> \t\tThe user to work with. (Required)\n"
    . "\t-d [folder]\t\tWhere to download the files.\n"
    . "\t-v\t\t\tMake downloads verbose.\n\n"
    . "For example, to download the favorites of thingywhat we could:\n\n"
    . "\t$0 -u thingywhat\n\n"
    . "Or to specify a place for them to be downloaded:\n\n"
    . "\t$0 -u thingywhat -d ~/Downloads/FA\n\n"
    and exit if defined $args{h} or not defined $args{u};

## Settings according to parameters
$folder = $args{d} if defined $args{d};
$verbose = 1 if defined $args{v};
my $user = $args{u};
my $favoriteUrl = "http://www.furaffinity.net/favorites/$user";

# Make the download folder if it doesn't exist already
mkdir($folder, 0755) unless(-d $folder);

# Returns a list of image IDs that are the favorites of the user
# this script is downloading for.
sub getFavorites{
    my $page = 1;
    my %favorites;

    do {
        my %currentPage;

        if($verbose){
            print "Grabbing page $page... ";
        }

        my $content = get("$favoriteUrl/$page");

        while ($content =~ /\/view\/(\d+)/g){
            @currentPage{$1} = ();
        }

        if($verbose){
            print "Found " . keys(%currentPage) . " favorites!\n";
        }

        if(keys(%currentPage)){
            %favorites = {%favorites, %currentPage};
        } else {
            return keys(%favorites);
        }
    } while($page++);
}

# Downloads an individual image from FurAffinity based on its ID.
sub download($){
    (my $favorite) = @_;
    my $content = get("$pageUrl$favorite");

    $content =~ /<a href="\/\/([^"]+)">\s*Download\s*<\/a>/;
    my $url = $1;

    $url =~ /\/([^\/]+)$/;
    my $filename = $1;

    if($verbose) {
        print "Downloading $url to $folder/$filename!\n";
    } else {
        print "Fetching $filename\n";
    }

    getstore("http://$url", "$folder/$filename");
}

foreach my $favorite (getFavorites()){
    download($favorite);
}

print "Done!\n";
