# Note that this script can accept some limited command-line arguments, run
# `julia build_tarballs.jl --help` to see a usage message.
using BinaryBuilder, BinaryBuilderBase

name = "TreeSitter"
version = v"0.25.6"

# Collection of sources required to complete build
sources = [
    GitSource(
        "https://github.com/tree-sitter/tree-sitter.git",
        "bf655c0beaf4943573543fa77c58e8006ff34971"),  # v0.25.6
]

# Bash recipe for building across all platforms
script = raw"""
cd $WORKSPACE/srcdir/tree-sitter
cd crates/cli
cargo build --locked --release
install -Dvm 755 "../../target/${rust_target}/release/tree-sitter${exeext}" -t "${bindir}"
cd ../..
install_license LICENSE
"""

# These are the platforms we will build for by default, unless further
# platforms are passed in on the command line
platforms = supported_platforms()
# Rust toolchain for i686 Windows is unusable
filter!(p -> !Sys.iswindows(p) || arch(p) != "i686", platforms)
# Rust toolchain seems to not be available for RISC-V or FreeBSD/aarch64
filter!(p -> arch(p) != "riscv64", platforms)
filter!(p -> os(p) != "freebsd" || arch(p) != "aarch64", platforms)

# The products that we will ensure are always built
products = [
    ExecutableProduct("tree-sitter", :tree_sitter),
]

# Dependencies that must be installed before this package can be built
dependencies = Dependency[
]

# Build the tarballs, and possibly a `build.jl` as well.
build_tarballs(ARGS, name, version, sources, script, platforms, products, dependencies;
               julia_compat="1.6", compilers=[:c, :rust], lock_microarchitecture=false)