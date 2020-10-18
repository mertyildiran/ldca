# Last Digital Common Ancestor (LDCA)

Self-replicating, self-modifying Assembly program that can evolve into every possible computer program in the universe.

[NASM](https://www.nasm.us/) is required to compile the Assembly program.

## Compiling & Running

> **CAUTION:** Since this program executes random CPU instructions, it might run potentialy harmful machine code of any kind.
> The program runs its offsprings in multiple subprocesses and creates an ever growing tree of processes. Because of this,
> it eventually freezes any machine that runs it. The reason for that is; it consumes all of the CPU resources and free memory.

Go into the directory that matches your operating system and CPU architecture combination. For example: `cd linux_x86`

Run: `make`

The binary should be ready on `outs/0000000000000000000000000000000000000000000000000`

Go into the `outs/` directory and run it:

```bash
cd outs/
./0000000000000000000000000000000000000000000000000
```

After letting the descendants of this program live for a while you should be able to kill those processes
by sending `SIGINT` signal (by pressing <kbd>CTRL + C</kbd>) It might even require you to physically
restart your machine since your machine must be frozen at this point.

Go back into the parent directory of `outs/` and run `make diff` This command will show you the hex dump difference
between all the descendants and the initial program `0000000000000000000000000000000000000000000000000`

### Where are the descendants?

The descendants are in the same directory that you run the initial program `0000000000000000000000000000000000000000000000000`.
Don't try to run `ls` to see the list of files if you run the program for a few minutes. Use `ls --sort=none` instead.

### How do I remove these generated programs?

Do not try to run `rm *` inside the `outs/` because `rm` cannot handle that amount files.
Go into parent directory `cd ..` and use `rm -f outs/` instead.

### Why is it called Last Digital Common Ancestor?

Because it's the digital version of [Last Universal Common Ancestor](https://en.wikipedia.org/wiki/Last_universal_common_ancestor).
If you look at it from a philosophical point of view, LDCA is actually a descendant of LUCA.

## Algorithm

The Assembly program first executes the subroutine named `program` which is the section that actually evolves.
Then the program replicates itself. While replicating, with 50% probability one of the random mutations, that are
listed below, happens:

- with 80% probability replace a randomly chosen byte in the `program` section with a random byte.
- with 5% probability shrink the `program` section randomly by a factor of 1 byte to `program` section's size.
- with 15% probability grow the `program` section randomly by a factor of 1 byte to 256 bytes and fill it with random bytes.

Replication creates a new binary using system calls by copying the memory region which the program's itself loaded into.
Then executes the newly created binary by forking using system calls. Replication happens two times for each successful
program execution. So the number of processes increases exponentially.

Programs that created after a random mutation might fail to reach to `replicate` subroutine. Such programs cannot
produce its offsprings.

To be able to fully understand the algorithm you should go through the lines of [`ldca.asm`](/linux_x86/ldca.asm)
Assembly code and read the comments.

## Constants

There are some constants that hard-coded into the Assembly program which are open to optimization:

- Filename length: `49`
- Body of the subroutine named `program`
- 50% evolution rate: `rndNum  0, 1`
- Grow size: Between 1 byte and 256 bytes (`rndNum  1, 256`)
- 80% random byte mutation chance: `cmp     eax, 80`
- 5% shrink mutation chance: `cmp     eax, 85`
- 15% grow mutation chance: `100 - 85`

## License

**Last Digital Common Ancestor** is licensed under the [**GNU General Public License v2.0**](/LICENSE).
