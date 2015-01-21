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

print "Furaffinity Favorites Downloader version $version\n"
    . "By thingywhat (https://github.com/thingywhat)\n\n"
    . "\t-h\t\t\tThis help screen.\n"
    . "\t-u\t<username>\tSpecify the user who's favorites to download.\n"
    . "\t-d\t<folder>\tWhere to download the files.\n\n"
    . "\t-v\t\t\tMake downloads verbose.\n\n"
    . "For example, to download the favorites of thingywhat we could:\n\n"
    . "\t$0 -u thingywhat\n\n"
    . "Or to specify a palce for them to be downloaded:\n\n"
    . "\t$0 -u thingywhat -d ~/Downloads/FA\n\n"
    and exit if defined $args{h} or not defined $args{u};

## Settings according to parameters
$folder = $args{d} if defined $args{d};
$verbose = 1 if defined $args{v};
my $user = $args{u};
my $favoriteUrl = "http://www.furaffinity.net/favorites/$user";

# Make the download folder if it doesn't exist already
mkdir($folder, 0755) unless(-d $folder );

# Returns a list of image IDs that are the favorites of the user
# this script is downloading for.
sub getFavorites{
    my $page = 1;

    my @favorites;

    do {
	my @currentPage = ();
	my $content = get("$favoriteUrl/$page");
	
	while ($content =~ /\/view\/(\d+)/g){
	    push(@currentPage, $1);
	}
	if(@currentPage){
	    push(@favorites, @currentPage);
	} else {
	    return @favorites;
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
	print "Fething $filename\n";
    }
    getstore("http://$url", "$folder/$filename");
}

foreach my $favorite (getFavorites()){
    download($favorite);
}

print "Done!\n";
