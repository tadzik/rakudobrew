# rakudobrew

Put this in `~/.rakudobrew`, and add aliases for convenience.

It's quick and dirty, and may be broken on your system. Please report any breakages.

## Installation

- On \*nix do:
```
git clone https://github.com/tadzik/rakudobrew ~/.rakudobrew
export PATH=~/.rakudobrew/bin:$PATH
# or fish shell: set -U fish_user_paths ~/.rakudobrew/bin/ $fish_user_paths
rakudobrew init # Instructions for permanent installation.
```

- On Windows CMD do:
```
git clone https://github.com/tadzik/rakudobrew %USERPROFILE%\rakudobrew
SET PATH=%USERPROFILE%\rakudobrew\bin;%PATH%
rakudobrew init # Instructions for permanent installation.
```

- On Windows PowerShell do:
```
git clone https://github.com/tadzik/rakudobrew $Env:USERPROFILE\rakudobrew
$Env:PATH = "$Env:USERPROFILE\rakudobrew\bin;$Env:PATH"
rakudobrew init # Instructions for permanent installation.
```

## Windows notes

Rakudobrew requires Perl 5 and git to be installed. You can download and install these from
* http://strawberryperl.com/
* https://www.git-scm.com/downloads

If you want to use the Microsoft compiler `cl`, you have to make sure the compiler is on
your `PATH` and you have the environment variables `cl` requires set.
This happens automatically when using the *Native Tools Command Prompt* but has to be done
manually when using a normal terminal (or PowerShell). The script `vcvars32.bat` (which is in the same
folder as `cl`) can set these variables up automatically for you.

On PowerShell this requires
some additional trickery as described on StackOverflow: <http://stackoverflow.com/q/6140864>

It might be necessary to use an Administrative console to work
around a problem with permissions that go wrong during the build process.

## Bootstrapping a Perl 6 implementation

- Run something like:

```
$ rakudobrew build moar
```

to build the latest [Rakudo](https://github.com/rakudo/rakudo)
(in this case, on the [MoarVM](https://github.com/MoarVM/MoarVM) backend),
which should then be available as `perl6`.

- You now need a module management tool, you can use [zef](https://github.com/ugexe/zef) (a Perl 6 Management Tool), do:

```
$ rakudobrew build zef
```

## Making new scripts available

After you have installed new modules and scripts with zef or panda, you can run

```
$ rakudobrew rehash
```

to make the scripts available in `~/.rakudobrew/bin` and thus your PATH.

## Upgrading your Perl 6 implementation

```
$ rakudobrew build moar
```

## Upgrading rakudobrew itself

```
$ rakudobrew self-upgrade
```

## Uninstall rakudobrew and its Perl 6(s)

To remove rakudobrew and any Perl 6 implementations it's installed on your system,
just remove or rename the `~/.rakudobrew` directory.

## Specifying custom git path

In case git is not in any standard `PATH` on your system, you can specify a custom path
to the git binary using a `GIT_BINARY` environment variable:

```
$ GIT_BINARY="%USERPROFILE%\Local Settings\Application Data\GitHub\PORTAB~1\bin\git.exe" rakudobrew build all
```

## Specifying a git protocol

By default, rakudobrew will use the git protocol when it clones repositories.
To override this setting, use the `GIT_PROTOCOL` environment variable.

```
$ GIT_PROTOCOL=ssh rakudobrew list-available
# uses git@github.com:/rakudo/rakudo.git

$ GIT_PROTOCOL=https rakudobrew list-available
# uses https://github.com/rakudo/rakudo.git
```

## Command-line switches

Run `rakudobrew`
