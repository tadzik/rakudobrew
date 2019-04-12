package Rakudobrew::ShellHook::Zsh;
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
    $path = "$RealBin:$path";
    if (get_brew_mode() eq 'env') {
        if (get_global_version() && get_global_version() ne 'system') {
            $path = join(':', get_bin_paths(get_global_version()), $path);
        }
    }
    else { # get_brew_mode() eq 'shim'
        $path = join(':', $shim_dir, $path);
    }

    return <<EOT;
export PATH=$path
$brew_name() {
    command $brew_name internal_hooked "\$@" &&
    eval "`command $brew_name internal_shell_hook Zsh post_call_eval "\$@"`"
}

compctl -K _${brew_name}_completions -x 'p[2] w[1,register]' -/ -- $brew_name

_${brew_name}_completions() {
    local WORDS POS RESULT
    read -cA WORDS
    read -cn POS
    reply=(\$(command $brew_name internal_shell_hook Zsh completions \$POS \$WORDS))
}
EOT

}

sub post_call_eval {
    Rakudobrew::ShellHook::print_shellmod_code('Zsh', @_);
}

sub get_path_setter_code {
    my $path = shift;
    return "export PATH=$path";
}

sub get_shell_setter_code {
    my $version = shift;
    return "export $env_var=\"$version\"";
}

sub get_shell_unsetter_code {
    return "unset $env_var";
}

sub completions {
    my $index = shift;
    $index--;
    my @words = @_;

    if ($index == 1) {
        my @commands = qw(version current versions list global switch shell local nuke unregister rehash list-available build register build-zef exec which whence mode self-upgrade triple test);
        my $candidate = @words < 2 ? '' : $words[1];
        say join(' ', grep({ substr($_, 0, length($candidate)) eq $candidate } @commands));
    }
    elsif($index == 2 && ($words[1] eq 'global' || $words[1] eq 'switch' || $words[1] eq 'shell' || $words[1] eq 'local' || $words[1] eq 'nuke' || $words[1] eq 'test')) {
        my @versions = get_versions();
        push @versions, 'all'     if $words[1] eq 'test';
        push @versions, '--unset' if $words[1] eq 'shell';
        my $candidate = @words < 3 ? '' : $words[2];
        say join(' ', grep({ substr($_, 0, length($candidate)) eq $candidate } @versions));
    }
    elsif($index == 2 && $words[1] eq 'build') {
        say join ' ', Rakudobrew::Build::available_backends(), 'all';
    }
    elsif($index == 3 && $words[1] eq 'build') {
        my @installed = get_versions();
        my @installables = grep({ my $x = $_; !grep({ $x eq $_ } @installed) } Rakudobrew::Build::available_rakudos());

        my $candidate = @words < 4 ? '' : $words[3];
        say join(' ', grep({ substr($_, 0, length($candidate)) eq $candidate } @installables));
    }
    elsif($index == 2 && $words[1] eq 'mode') {
        my @modes = qw(env shim);
        my $candidate = @words < 3 ? '' : $words[2];
        say join(' ', grep({ substr($_, 0, length($candidate)) eq $candidate } @modes));
    }
}

1;

