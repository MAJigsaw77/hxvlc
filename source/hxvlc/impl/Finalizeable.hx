package hxvlc.impl;

import cpp.Function;
import cpp.vm.Gc;

class Finalizeable
{
	@:noCompletion
	private var owned:Bool;

	public function new(owned:Bool = true):Void
	{
		this.owned = owned;

		Gc.setFinalizer(this, Function.fromStaticFunction(finalize));
	}

	@:keep
	public function destroy():Void {}

	@:noCompletion
	@:noDebug
	@:unreflective
	private static function finalize(finalizeable:Finalizeable):Void
	{
		if (finalizeable.owned)
			finalizeable.destroy();
	}
}
