package hxvlc.util.typeLimit;

/**
 * An abstract type that can represent one of two possible types.
 * 
 * @see https://github.com/HaxeFlixel/flixel/blob/master/flixel/util/typeLimit/OneOfTwo.hx
 */
abstract OneOfTwo<T1, T2>(Dynamic) from T1 from T2 to T1 to T2 {}
