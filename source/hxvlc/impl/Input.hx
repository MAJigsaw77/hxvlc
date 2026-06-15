package hxvlc.impl;

import cpp.NativeArray;
import cpp.RawConstPointer;
import cpp.RawPointer;
import cpp.SizeT;
import cpp.Stdlib;
import cpp.UInt64;
import cpp.UInt8;

import haxe.io.Bytes;

/** Represents a input stream using unmanaged memory so it can be safely passed as a stable pointer without being affected by GC. */
@:nativeGen
@:structAccess
class Input
{
	/** The total size of the input buffer in bytes. */
	public var size:UInt64;

	/** The current read offset within the input buffer. */
	public var offset:UInt64;

	/** Pointer to the unmanaged input byte buffer. */
	public var data:RawPointer<UInt8>;

	/**
	 * Initializes the Input with a copy of the provided bytes.
	 *
	 * @param bytes The source bytes to copy into unmanaged memory.
	 */
	public function new(bytes:Bytes):Void
	{
		if (bytes == null || bytes.length == 0)
			return;

		size = bytes.length;
		offset = 0;
		data = untyped __cpp__('new unsigned char[{0}]', size);

		Stdlib.nativeMemcpy(untyped data, untyped NativeArray.getBase(bytes.getData()).getBase(), untyped size);
	}

	/**
	 * Sets the current read offset.
	 *
	 * @param pos The position to seek to.
	 * 
	 * @return `true` if the seek position is within the input bounds, `false` otherwise.
	 */
	public function seek(pos:UInt64):Bool
	{
		if (untyped __cpp__('{0} > {1}', pos, size))
			return false;

		offset = pos;

		return true;
	}

	/**
	 * Reads bytes from the current offset into the provided buffer.
	 *
	 * @param buf The destination buffer to write into.
	 * @param len The maximum number of bytes to read.
	 * 
	 * @return The number of bytes actually read.
	 */
	public function read(buf:RawPointer<UInt8>, len:SizeT):UInt64
	{
		final remaining:UInt64 = untyped __cpp__('{0} - {1}', size, offset);

		if (untyped __cpp__('{0} > {1}', remaining, 0))
		{
			final read:UInt64 = untyped __cpp__('{0} < {1} ? {0} : {1}', len, remaining);

			Stdlib.nativeMemcpy(untyped buf, untyped RawConstPointer.addressOf(untyped __cpp__('{0}[{1}]', data, offset)), untyped __cpp__('{0}', read));

			untyped __cpp__('{0} += {1}', offset, read);

			return read;
		}

		return 0;
	}
}
