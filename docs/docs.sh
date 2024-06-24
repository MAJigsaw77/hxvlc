#!/bin/bash
haxe docs/docs.hxml
haxelib run dox -theme ./docs/theme -i docs -o pages --title "hxVLC Documentation" -in "hxvlc" --toplevel-package hxvlc
