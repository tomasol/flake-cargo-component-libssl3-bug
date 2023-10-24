## Steps to reproduce

1. Clone repo and `cd` to it
1. Run `nix develop`, which builds cargo-component binary, places it to $(pwd)/.cargo/bin/
1. Run `cargo-component --version`
1. Confirm the linkage error: `cargo-component: error while loading shared libraries: libssl.so.3: cannot open shared object file: No such file or directory`
