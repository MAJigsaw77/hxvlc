package cpp;

@:include('vector')
@:nativeArrayAccess
@:unreflective
@:structAccess
@:native('std::vector')
extern class StdVector<T> implements ArrayAccess<Reference<T>>
{
	//function new():Void;
	function new(?size:Int);
	function at(index:Int):T;
	function back():T;
	function data():RawPointer<T>;
	function front():T;
	function pop_back():Void;
	function push_back(value:T):Void;
	function size():Int;
}
