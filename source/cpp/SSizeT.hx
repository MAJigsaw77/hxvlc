package cpp;

#if (!windows || HXCPP_MINGW)
@:native("ssize_t")
@:scalar
@:coreType
@:notNull
#end
extern abstract SSizeT from Int to Int {}
