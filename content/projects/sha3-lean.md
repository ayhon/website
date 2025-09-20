+++
title = "SHA3 Lean specification"
description = "Translated specification of the SHA3 hash family of functions into Lean."
weight = 1

link_to = "https://github.com/ayhon/sha3.lean"
+++

In my first year internship at the [MPRI] I worked with the EPI [Prosecco] team
at Inria Paris on proof automation in the specific context of verification of
cryptographic algorithms. In particular, I worked on developing a verified
implementation of the SHA3 family of functions in Rust, verified in Lean.

For this project, I translated the [SHA3 specification] as published by NIST
into Lean, and created a separate Lean package so that it could potentially be
used in the future by other people. The code can be found in
https://github.com/ayhon/sha3.lean



[MPRI]: https://mpri-master.ens.fr
[Prosecco]: https://team.inria.fr/prosecco/
[SHA3 specification]: https://example.com
