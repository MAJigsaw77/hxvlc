@echo off
haxe docs/docs.hxml
haxelib run dox -i docs -o pages --title "hxVLC Documentation" -in "hxvlc"
