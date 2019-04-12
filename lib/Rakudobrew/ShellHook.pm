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
    my $sep = $^O =~ /win32/i ? ';' : ':';
    my $path = shift;
    my $also_clean_path = shift;
    my $old_path;
    do {
        $old_path = $path;
        my $clean_dirs = "$versions_dir|$shim_dir";
        $clean_dirs = "$versions_dir|$shim_dir|$also_clean_path" if $also_clean_path;
        $path =~ s/($clean_dirs)[^$sep]*$sep?//g;
        $path =~ s/$sep?($clean_dirs)[^$sep]*//g;
        $path =~ s/$sep($clean_dirs)[^$sep]*$sep/$sep/g;
    } until $path eq $old_path;
    return $path;
}

1;
