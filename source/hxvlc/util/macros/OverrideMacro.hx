package hxvlc.util.macros;

#if macro
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;
import haxe.macro.TypeTools;
#end

class OverrideMacro {
    #if macro
    public static function overrideEmpty(name:String):Array<Field> {
        final cls = Context.getLocalClass();
        final tcls = cls.get();

        var parent:Null<ClassType> = tcls.superClass != null ? tcls.superClass.t.get() : null;
        var method:Null<ClassField> = null;

        while (parent != null) {
            final fields:Array<ClassField> = parent.fields.get();
            for (f in fields) {
                if (f.name == name && f.kind.match(FMethod(_))) {
                    method = f;
                    break;
                }
            }
            if (method != null) break;
            parent = parent.superClass != null ? parent.superClass.t.get() : null;
        }

        if (method == null)
            Context.error('Method "$name" not found in superclasses', Context.currentPos());

        var fargs = [];
        var fret = null;
        switch (method.type) {
            case TFun(args, ret):
              for (arg in args)
                fargs.push({name: arg.name, opt: arg.opt, type: TypeTools.toComplexType(arg.t), value: null, meta: null});
              fret = TypeTools.toComplexType(ret);
            case TLazy(f):
              switch (f()) {
                case TFun(args, ret):
                  for (arg in args)
                    fargs.push({name: arg.name, opt: arg.opt, type: TypeTools.toComplexType(arg.t), value: null, meta: null});
                  fret = TypeTools.toComplexType(ret);
                case _: Context.error('"$name" is not a function', Context.currentPos());
            };
            case _: Context.error('"$name" is not a function', Context.currentPos());
        };

      final fields:Array<Field> = Context.getBuildFields().copy();

      fields.push({
        name: name,
        doc: null,
        meta: [{ name: ":noCompletion", params: [], pos: Context.currentPos() }],
        access: [Access.APrivate, Access.AOverride],
        kind: FFun({
            ret: fret,
            args: fargs,
            expr: macro {}
        }),
        pos: Context.currentPos()
        });

        return fields;
    }
    #end
}
