package hxvlc.impl;

import cpp.Function;
import cpp.vm.Gc;

class Finalizeable
{
	private var name:Null<String>;

	public function new(?name:String):Void
	{
		this.name = name;

		Gc.setFinalizer(this, Function.fromStaticFunction(finalize));
	}

	public function destroy():Bool
	{
		return false;
	}

	@:noCompletion
	@:noDebug
	@:unreflective
	private static function finalize(finalizeable:Finalizeable):Void
	{
		if (finalizeable.name != null)
		{
			untyped __cpp__('printf("Destroying %s\\n", {0}.__s)', finalizeable.name);
			untyped __cpp__('fflush(stdout)');
		}

		if (finalizeable.destroy())
		{
			if (finalizeable.name != null)
			{
				untyped __cpp__('printf("Destroyed %s\\n", {0}.__s)', finalizeable.name);
				untyped __cpp__('fflush(stdout)');
			}
		}
		else
		{
			if (finalizeable.name != null)
			{
				untyped __cpp__('printf("Already Destroyed or Handled %s\\n", {0}.__s)', finalizeable.name);
				untyped __cpp__('fflush(stdout)');
			}
		}
	}
}
