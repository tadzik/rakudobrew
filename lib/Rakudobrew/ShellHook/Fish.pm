package Rakudobrew::ShellHook::Fish;
use strict;
use warnings;
use 5.010;
use File::Spec::Functions qw(catdir splitpath);
use FindBin qw($RealBin $RealScript);

use Rakudobrew::Variables;
use Rakudobrew::Tools;
use Rakudobrew::VersionHandling;
use Rakudobrew::ShellHook;
use Rakudobrew::Build;

sub get_init_code {
    my $path = $ENV{PATH};
    $path = Rakudobrew::ShellHook::clean_path($path, $RealBin);

    my @path_components = split /:/, $path;
    @path_components = map { "'$_'" } @path_components;

    unshift @path_components, "'$RealBin'";

    $path =~ s/:/ /g;
    if (get_brew_mode() eq 'env') {
        if (get_global_version() && get_global_version() ne 'system') {
            unshift @path_components, map({ "'$_'" } get_bin_paths(get_global_version()));
        }
    }
    else { # get_brew_mode() eq 'shim'
        unshift @path_components, "'$shim_dir'";
    }

    $path = join(' ', @path_components);

    return <<EOT;
set -x PATH $path

function $brew_name
    command $brew_name internal_hooked \$argv
    and eval (command $brew_name internal_shell_hook Fish post_call_eval \$argv)
end

function _${brew_name}_is_not_register
    set args (commandline -poc)
    if [ (count \$args) -eq 3 -a \$args[1] = 'register' ]
        return 1
    else
        return 0
    end
end

complete -c $brew_name -f -n _${brew_name}_is_not_register -a '(command $brew_name internal_shell_hook Fish completions (commandline -poc) | string split " ")'
EOT

}

sub post_call_eval {
    Rakudobrew::ShellHook::print_shellmod_code('Bash', @_);
}

sub get_path_setter_code {
    my $path = shift;
    my @path_components = split /:/, $path;
    @path_components = map { "'$_'" } @path_components;
    return "set -gx PATH " . join(' ', @path_components);
}

sub get_shell_setter_code {
    my $version = shift;
    return "set -gx $env_var $version";
}

sub get_shell_unsetter_code {
    return "set -ex $env_var";
}

sub completions {
    my @words = @_;

    if (@words == 1) {
        my @commands = qw(version current versions list global switch shell local nuke unregister rehash list-available build register build-zef exec which whence mode self-upgrade triple test);
        my $candidate = @words < 2 ? '' : $words[1];
        say join(' ', grep({ substr($_, 0, length($candidate)) eq $candidate } @commands));
    }
    elsif(@words == 2 && ($words[1] eq 'global' || $words[1] eq 'switch' || $words[1] eq 'shell' || $words[1] eq 'local' || $words[1] eq 'nuke' || $words[1] eq 'test')) {
        my @versions = get_versions();
        push @versions, 'all'     if $words[1] eq 'test';
        push @versions, '--unset' if $words[1] eq 'shell';
        my $candidate = @words < 3 ? '' : $words[2];
        say join(' ', grep({ substr($_, 0, length($candidate)) eq $candidate } @versions));
    }
    elsif(@words == 2 && $words[1] eq 'build') {
        say join ' ', Rakudobrew::Build::available_backends(), 'all';
    }
    elsif(@words == 3 && $words[1] eq 'build') {
        my @installed = get_versions();
        my @installables = grep({ my $x = $_; !grep({ $x eq $_ } @installed) } Rakudobrew::Build::available_rakudos());

        my $candidate = @words < 4 ? '' : $words[3];
        say join(' ', grep({ substr($_, 0, length($candidate)) eq $candidate } @installables));
    }
    elsif(@words == 2 && $words[1] eq 'mode') {
        my @modes = qw(env shim);
        my $candidate = @words < 3 ? '' : $words[2];
        say join(' ', grep({ substr($_, 0, length($candidate)) eq $candidate } @modes));
    }
}

1;

