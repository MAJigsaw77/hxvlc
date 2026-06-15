package hxvlc.impl;

import cpp.Function;
import cpp.vm.Gc;

/**
 * Represents a GC-integrated object that can manage native resources and automatically free them when collected by the garbage collector.
 *
 * When `owned` is `true`, the object is responsible for releasing its native resources by overriding `destroy()`, which is invoked during GC finalization.
 */
class Finalizeable
{
	@:noCompletion
	private var owned:Bool;

	/**
	 * Initializes the Finalizeable
	 * 
	 * @param owned Whether the native data is allocated by the object itself or its gotten from smth else
	 */
	public function new(owned:Bool = true):Void
	{
		this.owned = owned;

		Gc.setFinalizer(this, Function.fromStaticFunction(finalize));
	}

	/**
	 * Represents the cleanup hook for releasing native resources.
	 * 
	 * Called automatically by the GC finalizer when `owned` is true.
	 */
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
