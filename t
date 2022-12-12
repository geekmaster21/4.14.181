Error: incorrect number of arguments or unrecognized option
Usage: diffconfig [-h] [-m] [<config1> <config2>]

Diffconfig is a simple utility for comparing two .config files.
Using standard diff to compare .config files often includes extraneous and
distracting information.  This utility produces sorted output with only the
changes in configuration values between the two files.

Added and removed items are shown with a leading plus or minus, respectively.
Changed items show the old and new values on a single line.

If -m is specified, then output will be in "merge" style, which has the
changed and new values in kernel config option format.

If no config files are specified, .config and .config.old are used.

Example usage:
 $ diffconfig .config config-with-some-changes
-EXT2_FS_XATTR  n
 CRAMFS  n -> y
 EXT2_FS  y -> n
 LOG_BUF_SHIFT  14 -> 16
 PRINTK_TIME  n -> y

