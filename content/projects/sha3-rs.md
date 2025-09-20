+++
title = "Verified SHA3 in Rust"
description = "A verified implementation of the SHA3 hash family of functions in Rust. Verification was done in Lean."
weight = 1

link_to = "https://github.com/ayhon/sha3.rs"
+++

In my first year internship at the [MPRI] I worked with the EPI [Prosecco] team
at Inria Paris on proof automation in the specific context of verification of
cryptographic algorithms. In particular, I worked on developing a verified
implementation of the SHA3 family of functions in Rust, verified in Lean.

The code of this effort can be found in https://github.com/ayhon/sha3.rs. The
implementation does not make use of any loop unrolling or specific vectorized
instructions, but it does represent the Keccak permutation function's state
using packed machine integers, for efficiency.


[MPRI]: https://mpri-master.ens.fr
[Prosecco]: https://team.inria.fr/prosecco/
