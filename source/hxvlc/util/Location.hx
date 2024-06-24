package hxvlc.util;

import haxe.io.Bytes;
import hxvlc.util.typeLimit.OneOfThree;

/**
 * Represents a location which can be:
 *
 * - a local filesystem path or a media location URL.
 *
 * - an open file descriptor ID.
 *
 * - a bitstream input.
 */
typedef Location = OneOfThree<String, Int, Bytes>;
