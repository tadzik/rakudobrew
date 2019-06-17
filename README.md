# rakudobrew

Rakudobrew helps to build one or more versions of Rakudo and quickly switch between them.
It's a perlbrew and plenv look alike and supports both flavours of commands.

Rakudobrew can work by modifying $PATH in place (which is a more down to the metal) as well
as with shims (which enables advanced features, such as local versions).

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

Rakudobrew requires Perl 5 and Git to be installed. You can download and install these from
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

to build the latest [Rakudo](https://github.com/rakudo/rakudo) release
(in this case, on the [MoarVM](https://github.com/MoarVM/MoarVM) backend).

- Once that's build switch to it (substitute the version rakudobrew just built):

```
$ rakudobrew switch moar-2019.03.1
```

- To install [zef](https://github.com/ugexe/zef) (the Perl 6 module manager), do:


```
$ rakudobrew build-zef
```

## global vs shell vs local

The `global` version is the one that is active when none of the overrides of `shell`
and `local` are triggered.

The `shell` version changes the active Rakudo version just in the current shell.
Closing the current shell also looses the `shell` version.

The `local` version is specific to a folder. When CWD is in that folder or a sub folder
that version of Rakudo is used. Only works in `shim` mode. To unset a local version
one must delete the `.PL6ENV_VERSION` file in the respective folder.

## Modes

Rakudo brew has two modes of operation: `env` and `shim`.

In `env` mode rakudobrew modifies the `$PATH` variable as needed when switching between
versions. This is neat because one then runs the executables directly. This is the default mode
on \*nix.

In `shim` mode rakudobrew generates wrapper scripts called shims for all
executables it can find in all the different Rakudo installations. These
shims forward to the actual executable when called. This mechanism allows for
some advanced features, such as local versions. When installing a module that
adds scripts one must make rakudobrew aware of these new scripts. This is done
with

```
$ rakudobrew rehash
```
In `env` mode this is not necessary.

## Registering external versions

To add a Rakudo installation to rakudobrew that was created without rakudobrew
one should do:

```
$ rakudobrew register name-of-version /path/to/rakudo/install/directory
```

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

### `version` or `current`
Show the currently active Rakudo version.

### `versions` or `list`
List all installed Rakudo installations.

### `global [version]` or `switch [version]`
Show or set the globally configured Rakudo version.

### `shell [--unset|version]`
Show, set or unset the shell version.

### `local [version]
Show or set the local version.

### `nuke [version]` or `unregister [version]`
Removes an installed or registered version. Versions built by rakudobrew are
actually deleted, registered versions are only unregistered but not deleted.

### `rehash`
Regenerate all shims. Newly installed scripts will not work unless this is
called. This is only necessary in `shim` mode.

### `list-available`
List all Rakudo versions that can be installed.

### `build [jvm|moar|moar-bleed|all] [tag|branch|sha-1] [--configure-opts=]`
Build a Rakudo version. The arguments are:
- The backend.
    - `moar-bleed` is the moar and nqp backends at the master branch.
    - `all` will build all backends.
- The version to build. Call `list-available` to see a list of available
  versions. When left empty the latest release is built.
  It is also possible to specify a commit sha or branch to build.
- Configure options.

### `triple [rakudo-ver [nqp-ver [moar-ver]]]`
Build a specific set of Rakudo, NQP and MoarVM commits.

### `register <name> <path>`
Register an externaly built / installed Rakudo version with Rakudobrew.

### `build-zef`
Install Zef into the current Rakudo version.

### `exec <command> [command-args]`
Explicitly call an executable. You normally shouldn't need to do this.

### `rakudobrew which <command>`
Show the full path to the executable.

### `whence [--path] <command>`
List all versions that contain the given command. when `--path` is given the
path of the executables is given instead.

### `mode [env|shim]`
Show or set the mode of operation.

### `self-upgrade`
Upgrade Rakudobrew itself.

### `init`
Show installation instructions.

### `test [version|all]`
Run Rakudo tests in the current or given version.

