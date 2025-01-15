package cpp;

#if windows
@:buildXml('<include name="${haxelib:hxvlc}/project/Build.xml" />')
@:include('vlc/vlc.h')
#end
@:native("ssize_t")
@:scalar
@:coreType
@:notNull
extern abstract SSizeT from Int to Int {}
