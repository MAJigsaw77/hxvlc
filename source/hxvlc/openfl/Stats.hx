package hxvlc.openfl;

#if (!cpp && !(desktop || mobile))
#error 'The current target platform isn\'t supported by hxvlc.'
#end
import hxvlc.externs.Types;

/**
 * Represents various statistics related to media processing.
 */
class Stats
{
	/** 
	 * Number of bytes read from the input.
	 */
	public var i_read_bytes:Int;

	/** 
	 * Bitrate of the input in bits per second.
	 */
	public var f_input_bitrate:Single;

	/** 
	 * Number of bytes read by the demuxer.
	 */
	public var i_demux_read_bytes:Int;

	/** 
	 * Bitrate of the demuxer in bits per second.
	 */
	public var f_demux_bitrate:Single;

	/** 
	 * Number of corrupted packets encountered by the demuxer.
	 */
	public var i_demux_corrupted:Int;

	/** 
	 * Number of discontinuities encountered by the demuxer.
	 */
	public var i_demux_discontinuity:Int;

	/** 
	 * Number of video frames decoded.
	 */
	public var i_decoded_video:Int;

	/** 
	 * Number of audio frames decoded.
	 */
	public var i_decoded_audio:Int;

	/** 
	 * Number of pictures displayed.
	 */
	public var i_displayed_pictures:Int;

	/** 
	 * Number of pictures lost.
	 */
	public var i_lost_pictures:Int;

	/** 
	 * Number of audio buffers played.
	 */
	public var i_played_abuffers:Int;

	/** 
	 * Number of audio buffers lost.
	 */
	public var i_lost_abuffers:Int;

	/** 
	 * Number of packets sent by the stream output.
	 */
	public var i_sent_packets:Int;

	/** 
	 * Number of bytes sent by the stream output.
	 */
	public var i_sent_bytes:Int;

	/** 
	 * Bitrate of the stream output in bits per second.
	 */
	public var f_send_bitrate:Single;

	/**
	 * Creates a new instance of Stats with default values.
	 */
	public function new():Void
	{
		this.i_read_bytes = 0;
		this.f_input_bitrate = 0.0;
		this.i_demux_read_bytes = 0;
		this.f_demux_bitrate = 0.0;
		this.i_demux_corrupted = 0;
		this.i_demux_discontinuity = 0;
		this.i_decoded_video = 0;
		this.i_decoded_audio = 0;
		this.i_displayed_pictures = 0;
		this.i_lost_pictures = 0;
		this.i_played_abuffers = 0;
		this.i_lost_abuffers = 0;
		this.i_sent_packets = 0;
		this.i_sent_bytes = 0;
		this.f_send_bitrate = 0.0;
	}

	/**
	 * Returns a string representation of the Stats object.
	 *
	 * @return A string containing all the properties of the Stats object.
	 */
	public function toString():String
	{
		return 'Stats[i_read_bytes=$i_read_bytes, f_input_bitrate=$f_input_bitrate, i_demux_read_bytes=$i_demux_read_bytes, '
			+ 'f_demux_bitrate=$f_demux_bitrate, i_demux_corrupted=$i_demux_corrupted, i_demux_discontinuity=$i_demux_discontinuity, '
			+ 'i_decoded_video=$i_decoded_video, i_decoded_audio=$i_decoded_audio, i_displayed_pictures=$i_displayed_pictures, '
			+ 'i_lost_pictures=$i_lost_pictures, i_played_abuffers=$i_played_abuffers, i_lost_abuffers=$i_lost_abuffers, '
			+ 'i_sent_packets=$i_sent_packets, i_sent_bytes=$i_sent_bytes, f_send_bitrate=$f_send_bitrate]';
	}

	/**
	 * Constructs a Stats object from raw LibVLC media statistics.
	 *
	 * @param media_stats The structure to LibVLC media statistics.
	 *
	 * @return A Stats object populated with the provided media statistics.
	 */
	public static function fromMediaStats(media_stats:cpp.Struct<LibVLC_Media_Stats_T>):Stats
	{
		var stats:Stats = new Stats();

		if (media_stats == null)
			return stats;

		stats.i_read_bytes = media_stats.i_read_bytes;
		stats.f_input_bitrate = media_stats.f_input_bitrate;

		stats.i_demux_read_bytes = media_stats.i_demux_read_bytes;
		stats.f_demux_bitrate = media_stats.f_demux_bitrate;
		stats.i_demux_corrupted = media_stats.i_demux_corrupted;
		stats.i_demux_discontinuity = media_stats.i_demux_discontinuity;

		stats.i_decoded_video = media_stats.i_decoded_video;
		stats.i_decoded_audio = media_stats.i_decoded_audio;

		stats.i_displayed_pictures = media_stats.i_displayed_pictures;
		stats.i_lost_pictures = media_stats.i_lost_pictures;

		stats.i_played_abuffers = media_stats.i_played_abuffers;
		stats.i_lost_abuffers = media_stats.i_lost_abuffers;

		stats.i_sent_packets = media_stats.i_sent_packets;
		stats.i_sent_bytes = media_stats.i_sent_bytes;
		stats.f_send_bitrate = media_stats.f_send_bitrate;

		return stats;
	}
}
