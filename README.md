# Kernel Playground for Beaglebone

Playground for experimenting with the linux kernel on a Beaglebone or a Beaglebone Black.

Installation simplified by using `nix`. 

## Motivation
Compiling in a embedded system directly is not feasible, either for memory or time requirements.
This can be fixed by compiling in a different machine (host), with a much more potent CPU and higher RAM.

However, this process, called cross-compilation, becomes quite troublesome when the architectures don't match,
which is usually the case when compiling to embedded systems.

In order to generate code for another architecture, it is required to use the compiler of the target architecture.

> So it's just a simple `apt install gcc-arm` right?

Unfortunally, the majority of packet distributors don't package compilers for the porpuse of cross-compiling,
mainly due to the giant diversity of possible architectures and configurations.

So the only options left are either downloading a prebuilt binary of the compiler matching both the `host` and `target` architectures,
usually provided as toolkits from the manufacters of embedded systems, 
or compile the compiler yourself.

This procedure drastically increase the complexity and reproducability of your project. Now anyone not running the same 
`host` architecture as you can't make use of any of the cross-compilers needed to compiler your project.

This used to not be that big of an issue when everyone was using x86_64 a few years back, but with the release of the new
Mac M1 chips, backed by an ARM architecture, this is no longer the case, and show precedence that the architecture spectrum may 
expand more in the future.

Also, for any dynamic library you would want to use, you will need to get the source code and compile it yourself, then link it,
and hope nothing breaks. This becomes especially hard when compiling big projects such as openssl, and are in general, great time sinks.

> So, it's all hope lost? 

No, there is actually a way to distribute reproducable developer environtments, containing all the required compilers and dependencies, in their
required architecture, for almost any popular `host` architecture.

How? Welcome `Nix`. 

Nix is a purely functional package manager. Which if you dedicate the time to learn it's weird functional syntax,
would give you an incredible feature, complete reproducibility anywhere Nix is supported.

## Nix installation

If you already have nix installed on your machine, skip to `How to use?`.

Note: 
If you are on MacOS, it is preferable to use the [official image installer](https://install.determinate.systems/determinate-pkg/stable/Universal).

You can install Nix in any Linux, darwin (MacOS), or in Windows via WSL.
Simply run the following command:
```
curl -fsSL https://install.determinate.systems/nix | sh -s -- install --determinate
```

You can learn more about the nix installer and instructions on how to uninstall it [here](https://github.com/DeterminateSystems/nix-installer).

As explained in `Motivation`, you need to compile the compiler for the target architecture.
This is not a quick compilation, i.e. it took my laptop about ~15 minutes.

### Binary Cache

If you are on a "x86_64-linux" machine, you can avoid the compilation process and 
directly download the compiler from my binary cache. 

To opt-in to the binary cache, add the two following lines of code to `/etc/nix/nix.custom.conf`
```
extra-trusted-substituters = https://cache.cornago.net/cache
extra-trusted-public-keys = cache:Zmntlu1k2L4u4wbdF4FLIfjsjs4/QkVYch2Tt7/ZGQ8=
```

Or if you prefer copy-pasting to the terminal directly:
```
sudo echo "extra-trusted-substituters = https://cache.cornago.net/cache" >> /etc/nix/nix.custom.conf
sudo echo "extra-trusted-public-keys = cache:Zmntlu1k2L4u4wbdF4FLIfjsjs4/QkVYch2Tt7/ZGQ8=" >> /etc/nix/nix.custom.conf
```

## How to use?

Simply execute the following command:
```
nix develop github:hugocornago-unizar/BeagleboneKernelPlayground
```

This will create two folders: `kernel` and `bootloader`.

In `kernel`, you will find the linux kernel sources for version `...`, patched with the real-time patch. 
You can use any regular compilation commands, such as `make`, and it will automatically use the 
crosscompilation to Beaglebone.

In `bootloader`, you will find the compiled bootloader for BBG black.

There are included some useful commands to aliviate the `make` bloat:
- `makeKernel`: Simplifies the different repetitive `make` commands into a single command. 
                You can take a look how it works at ``.
