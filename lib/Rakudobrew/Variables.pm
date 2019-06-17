package Rakudobrew::Variables;
require Exporter;
our @ISA = qw( Exporter );
our @EXPORT = qw( $brew_name $env_var $local_filename $prefix $versions_dir $shim_dir $git_reference $GIT $GIT_PROTO $PERL5 %git_repos %impls );

use strict;
use warnings;
use 5.010;

use FindBin qw($RealBin);
use File::Spec::Functions qw(catfile catdir updir);

our $brew_name = 'rakudobrew';
our $env_var = 'PL6ENV_VERSION';
our $local_filename = '.perl6-version';

our $prefix = catdir($RealBin, updir());
our $versions_dir = catdir($prefix, 'versions');
our $shim_dir = catdir($prefix, 'shims');
our $git_reference = catdir($prefix, 'git_reference');

our $GIT       = $ENV{GIT_BINARY} // 'git';
our $GIT_PROTO = $ENV{GIT_PROTOCOL} // 'git';
our $PERL5     = $^X;

sub get_git_url {
    my ($protocol, $host, $user, $project) = @_;
    if ($protocol eq "ssh") {
        return "git\@${host}:${user}/${project}.git";
    } else {
        return "${protocol}://${host}/${user}/${project}.git";
    }
}

our %git_repos = (
    rakudo => get_git_url($GIT_PROTO, 'github.com', 'rakudo', 'rakudo'),
    MoarVM => get_git_url($GIT_PROTO, 'github.com', 'MoarVM', 'MoarVM'),
    nqp    => get_git_url($GIT_PROTO, 'github.com', 'perl6',  'nqp'),
    zef    => get_git_url($GIT_PROTO, 'github.com', 'ugexe',  'zef'),
);

our %impls = (
    jvm => {
        name      => "jvm",
        weight    => 20,
        configure => "$PERL5 Configure.pl --backends=jvm --gen-nqp --git-reference=\"$git_reference\" --make-install",
        need_repo => ['rakudo', 'nqp'],
    },
    moar => {
        name      => "moar",
        weight    => 30,
        configure => "$PERL5 Configure.pl --backends=moar --gen-moar --git-reference=\"$git_reference\" --make-install",
        need_repo => ['rakudo', 'nqp', 'MoarVM'],
    },
    'moar-bleed' => {
        name      => "moar-bleed",
        weight    => 35,
        configure => "$PERL5 Configure.pl --backends=moar --gen-moar=master --gen-nqp=master --git-reference=\"$git_reference\" --make-install",
        need_repo => ['rakudo', 'nqp', 'MoarVM'],
    },
);

1;

