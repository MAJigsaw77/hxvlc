package hxvlc.openfl;

#if openfl
/** Represents a location which can be either a local filesystem path, a media location URL or a bitstream input. */
typedef Location = hxvlc.util.typeLimit.OneOfTwo<String, haxe.io.Bytes>;
#end
