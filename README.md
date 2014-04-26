Adobe AIR SDK packaged with Nix
===============================

This repository contains Nix expressions for Adobe Air SDK and a simple launcher for .air applications,
heavily inspired by https://aur.archlinux.org/packages/adobe-air/ and https://aur.archlinux.org/packages/adobe-air-sdk/.

This expressions were only tested on Ubuntu, amd64, and only used to run polish ministry of finance's "e-Deklaracje".
They may get some more love, but only on demand (so if you want something chaged/fixed - create a Github issue or write me at tomasz.kontusz@gmail.com).

To use the launcher, nix-env -i -f path/to/repo -A adobe-air-launcher and then run adobe-air-launcher path/to/application.air
