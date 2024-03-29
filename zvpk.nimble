# Package

version       = "0.1.0"
author        = "Zack Guard"
description   = "Read VPK files on the command line"
license       = "GPL-3.0-or-later"
srcDir        = "."
bin           = @["zvpk"]


# Dependencies

requires "nim >= 1.4.8"
requires "https://github.com/z-------------/vpk.git >= 0.1.2"
requires "cligen >= 1.6.13"
