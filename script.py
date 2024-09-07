#!/usr/bin/env python3
# title:   game title
# author:  game developers, email, etc.
# desc:    short description
# site:    website link
# license: MIT License (change this to your license of choice)
# version: 0.0.1
# script:  python
""" tic80 script """

# pylint: disable=unused-import
from typing import TYPE_CHECKING  # noqa: F401


# pylint: disable=redefined-builtin
if TYPE_CHECKING:  # noqa: F401
    # Doing this ugly without parentheses for lack of support by pocketpy, TIC80's
    # embedded Python implementation
    from tic80_types import btn, btnp, circ, circb, clip, cls, elli  # noqa: F401
    from tic80_types import ellib, exit, fget, font, fset, key, keyp  # noqa: F401
    from tic80_types import line, map, memcpy, memset, mget, mouse, mset  # noqa: F401
    from tic80_types import music, peek, peek1, peek2, peek4, pix, pmem  # noqa: F401
    from tic80_types import poke, poke1, poke2, poke4, print, rect  # noqa: F401
    from tic80_types import rectb, reset, sfx, spr, sync, time, trace  # noqa: F401
    from tic80_types import tri, trib, tstamp, ttri, vbank  # noqa: F401
# pylint: enable=unused-import
# pylint: enable=redefined-builtin

T = 0
X = 96
Y = 24


# pylint: disable-next=invalid-name
def TIC():
    """ Game loop """
    global T
    global X
    global Y

    if btn(0):
        Y -= 1
    if btn(1):
        Y += 1
    if btn(2):
        X -= 1
    if btn(3):
        X += 1

    cls(13)
    spr(1 + T % 60 // 30 * 2, X, Y, colorkey=14, scale=3, w=2, h=2)
    print("HELLO WORLD!", 84, 84)
    T += 1
