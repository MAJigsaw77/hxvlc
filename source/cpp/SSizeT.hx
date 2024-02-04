package cpp;

#if (mingw || !windows)
@:native("ssize_t")
@:scalar
@:coreType
@:notNull
#end
extern abstract SSizeT from Int to Int {}
