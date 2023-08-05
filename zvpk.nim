# Copyright (C) 2021 Zack Guard
# 
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.

import pkg/vpk/read
import std/[
  terminal,
  options,
  strformat,
]

template fatal(msg: varargs[untyped]) =
  stderr.styledWrite fgRed, msg, "\p"
  quit QuitFailure

proc zvpk(filenames: seq[string]; checkHashes = false) =
  if filenames.len < 1:
    fatal "No filename specified"
  if filenames.len > 2:
    fatal "Too many arguments"

  let
    filename = filenames[0]
    entryName =
      if filenames.len > 1: filenames[1].some
      else: string.none

  var v: Vpk
  try:
    v = readVpk(filename)
  except CatchableError as e:
    fatal "Failed to read VPK: ", e.msg

  if entryName.isSome:
    let entry =
      try:
        v.entries[entryName.get]
      except KeyError:
        fatal &"Entry '{entryName.get}' not found"
    if entry.totalLength > 0:
      var fileBuf = newString(entry.totalLength)
      v.readFile(entry, addr fileBuf[0], entry.totalLength)
      stdout.write(fileBuf)
  else:
    for fullpath in v.entries.keys:
      echo fullpath
    if checkHashes:
      let (checkResult, checkMessage) = v.checkHashes()
      if not checkResult:
        fatal "Hash check failed: ", checkMessage

when isMainModule:
  import pkg/cligen

  dispatch(
    zvpk,
    help = {
      "filenames": "<filename> <entry name>",
    }
  )
