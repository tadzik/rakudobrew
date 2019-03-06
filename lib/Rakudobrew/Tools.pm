package Rakudobrew::Tools;
require Exporter;
our @ISA = qw( Exporter );
our @EXPORT = qw(run slurp spurt trim check_prog_name_match uniq slurp_dir my_fileparse);

use strict;
use warnings;
use 5.010;
use File::Spec::Functions qw(catfile);
use File::Basename;
use Carp qw(croak);

sub run {
    system(@_) and croak "Failed running ".$_[0]
}

sub slurp {
    my $file = shift;
    open(my $fh, '<', $file);
    local $/ = '';
    my $ret = <$fh>;
    close($fh);
    return $ret;
}

sub spurt {
    my ($file, $cont) = @_;
    open(my $fh, '>', $file);
    say $fh $cont;
    close($fh);
}

sub trim {
    my $text = shift;
    $text =~ s/^\s+|\s+$//g;
    return $text;
}

sub check_prog_name_match {
    my ($prog, $filename) = @_;
    my ($basename, undef, undef) = my_fileparse($filename);
    return $prog =~ /^\Q$basename\E\z/i;
}

sub uniq {
    my %seen;
    return grep { !$seen{$_}++ } @_;
}

sub slurp_dir {
    my $name = shift;
    opendir(my $dh, $name) or return;
    my @ret;
    while (my $entry = readdir $dh) {
        next if $entry =~ /^\./;
        next if !-f catfile($name, $entry);
        push @ret, $entry
    }
    closedir $dh;
    return @ret;
}

sub my_fileparse {
    return fileparse(shift, ('.dll.lib', qr/\.[^.]+/));
}

1;

