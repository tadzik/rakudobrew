package Rakudobrew::ShellHook;
require Exporter;
our @ISA = qw( Exporter );
our @EXPORT = qw();

use strict;
use warnings;
use 5.010;
use File::Spec::Functions qw(catdir updir);
use Cwd qw(cwd);
use Rakudobrew::Variables;
use Rakudobrew::Tools;
use Rakudobrew::VersionHandling;

sub print_shellmod_code {
    no strict 'refs';
    my @params = @_;
    my $shell = shift(@params);
	my $command = shift(@params) // '';
    my $mode = get_brew_mode(1);

    eval "require Rakudobrew::ShellHook::$shell";
    if ($@) {
        die "Shell hook '$shell' not found.";
    }

    if ($mode eq 'shim') {
        if ($command eq 'shell' && @params) {
            if ($params[0] eq '--unset') {
                say "Rakudobrew::ShellHook::${shell}::get_shell_unsetter_code"->();
            }
            else {
                say "Rakudobrew::ShellHook::${shell}::get_shell_setter_code"->($params[0]);
            }
        }
        elsif ($command eq 'mode') { # just switched to shim mode
            my $path = $ENV{PATH};
            $path = clean_path($path);
            $path = $shim_dir . ':' . $path;
            say "Rakudobrew::ShellHook::${shell}::get_path_setter_code"->($path);
        }
    }
    else { # get_brew_mode() eq 'env'
        my $version = get_version();
        my $path = $ENV{PATH};
        $path = clean_path($path);
        if ($version ne 'system') {
            $path = join(':', get_bin_paths($version), $path);
        }
        if ($path ne $ENV{PATH}) {
            say "Rakudobrew::ShellHook::${shell}::get_path_setter_code"->($path);
        }
    }
}

sub clean_path {
    my $path = shift;
    my $also_clean_path = shift;

    my $sep = $^O =~ /win32/i ? ';' : ':';

    my @paths;
    for my $version (get_versions()) {
        push @paths, get_bin_paths($version) if $version ne 'system';
    }
    push @paths, $versions_dir;
    push @paths, $shim_dir;
    push @paths, $also_clean_path if $also_clean_path;
    my $paths_regex = join "|", @paths;

    my $old_path;
    do {
        $old_path = $path;
        $path =~ s/($paths_regex)[^$sep]*$sep?//g;
        $path =~ s/$sep?($paths_regex)[^$sep]*//g;
        $path =~ s/$sep($paths_regex)[^$sep]*$sep/$sep/g;
    } until $path eq $old_path;
    return $path;
}

1;
