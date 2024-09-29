package hxvlc.util.macros;

#if macro
import haxe.macro.Context;
#end

class CodecSafety {
    public static inline macro function checkCodec() {
        #if hxCodec
        Context.fatalError("hxvlc and hxCodec cannot be used in the same project.", Context.currentPos());
        #end
        return macro {};
    }
}