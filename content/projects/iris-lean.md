+++
title = "Iris-Lean"
description = "Lean port of the Iris higher-order separation logic"
date = "2026-06-15"

[extra]
local_image = "/projects/iris-lean.svg"
link_to = "https://github.com/leanprover-community/iris-lean"
+++

In my second year internship at the [MPRI] I worked under the supervision of
Ralf Jung and Max Vistrup on the [Iris-Lean] project. There, I focused mainly
on porting the program logic interface, including the weakest precondition
definition and most relevant lemmas. I also contributed to the proof mode
with some tactics, such as `wp_bind`, `wp_pure` and `iloeb`.



<!-- porting effort, I also developed an automation tool based on [Diaframe]. -->

<!-- In my first year internship at the [MPRI] I worked with the EPI [Prosecco] team -->
<!-- at Inria Paris on proof automation in the specific context of verification of -->
<!-- cryptographic algorithms. In particular, I worked on developing a verified -->
<!-- implementation of the SHA3 family of functions in Rust, verified in Lean. -->

<!-- For this project, I translated the [SHA3 specification] as published by NIST -->
<!-- into Lean, and created a separate Lean package so that it could potentially be -->
<!-- used in the future by other people. The code can be found in -->
<!-- https://github.com/ayhon/sha3.lean -->

[MPRI]: https://mpri-master.ens.fr
[Iris-Lean]: https://github.com/leanprover-community/iris-lean/
