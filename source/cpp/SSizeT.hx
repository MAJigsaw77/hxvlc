package cpp;

#if (mingw || HXCPP_MINGW || !windows)
@:native("ssize_t")
@:scalar
@:coreType
@:notNull
#end
extern abstract SSizeT from Int to Int {}
