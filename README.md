---
labels:
- 'Stage-Beta'
summary: Random MOTD messages from directory.
...

Introduction
============

mod\_motd\_random\_file is a variant of
[mod\_motd](https://prosody.im/doc/modules/mod_motd) inspired by
[mod\_motd\_sequential](https://prosody.im/doc/modules/mod_motd_sequential)
that lets you specify a directory of MOTD messages, chosen at random, instead
of a single static one.

Configuration
=============

``` lua
modules_enabled = {
  -- other modules
    "motd_random_file";
}

motd_random_file_dir = "/path/to/my/dir/" -- defaults to "./motd"
```
