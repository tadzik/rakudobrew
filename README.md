Put this in ~/.rakudobrew, and add symlinks/aliases for convenience.

It's quick and dirty, may be broken on your system. Please report any breakages.

Installing rakudobrew
---------------------

```
$ git clone https://github.com/tadzik/rakudobrew ~/.rakudobrew
$ export PATH=~/.rakudobrew/bin:$PATH
```

Bootstrapping a Perl 6 implementation
-------------------------------------

Run something like:

```
$ rakudobrew build moar
```

to build the latest [Rakudo](https://github.com/rakudo/rakudo)
(in this case, on the [MoarVM](https://github.com/MoarVM/MoarVM) backend),
which should then be available as `perl6`. Then, to get the
[Panda module management tool](https://github.com/tadzik/panda), do:

```
$ rakudobrew build-panda
```
