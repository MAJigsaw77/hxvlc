package cpp;

@:include('vector')
@:unreflective
@:structAccess
@:native('std::vector<const char *>')
extern class VectorConstCharStar
{
	@:native('std::vector<const char *>')
	static function alloc():VectorConstCharStar;

	function at(index:Int):ConstCharStar;
	function back():ConstCharStar;
	function data():RawPointer<ConstCharStar>;
	function front():ConstCharStar;
	function pop_back():Void;
	function push_back(value:ConstCharStar):Void;
	function size():Int;
}
