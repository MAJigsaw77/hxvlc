package hxvlc.util.typeLimit;

/**
 * An abstract type that can represent one of three possible types.
 * 
 * @see https://github.com/HaxeFlixel/flixel/blob/master/flixel/util/typeLimit/OneOfThree.hx
 */
abstract OneOfThree<T1, T2, T3>(Dynamic) from T1 from T2 from T3 to T1 to T2 to T3 {}
