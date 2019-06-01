package Rakudobrew::ShellHook::Sh;
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
export PATH="$path"
$brew_name() {
    command $brew_name internal_hooked "\$@" &&
    eval "`command $brew_name internal_shell_hook Sh post_call_eval "\$@"`"
}
EOT

}

sub post_call_eval {
    Rakudobrew::ShellHook::print_shellmod_code('Sh', @_);
}

sub get_path_setter_code {
    my $path = shift;
    return "export PATH=\"$path\"";
}

sub get_shell_setter_code {
    my $version = shift;
    return "export $env_var=\"$version\"";
}

sub get_shell_unsetter_code {
    return "unset $env_var";
}

1;

