package hxvlc.externs;

import hxvlc.externs.Types;

/**
 * This class provides static methods to interact with the LibVLC library.
 * It allows for the creation and management of VLC instances, media players,
 * and media objects, as well as the handling of audio, video, and events.
 */
@:buildXml('<include name="${haxelib:hxvlc}/project/Build.xml" />')
@:include('vlc/vlc.h')
@:unreflective
extern class LibVLC
{
	/**
	 * Allocates and initializes a LibVLC instance.
	 *
	 * @param argc Number of arguments.
	 * @param argv Argument values.
	 * @return Pointer to the new LibVLC instance.
	 */
	@:native('libvlc_new')
	static function alloc(argc:Int, argv:cpp.ConstCharStarConstStar):cpp.RawPointer<LibVLC_Instance_T>;

	/**
	 * Releases a LibVLC instance.
	 *
	 * @param p_instance Pointer to the LibVLC instance.
	 */
	@:native('libvlc_release')
	static function release(p_instance:cpp.RawPointer<LibVLC_Instance_T>):Void;

	/**
	 * Sets the application name and HTTP user agent string for LibVLC.
	 *
	 * @param p_instance Pointer to the LibVLC instance.
	 * @param name Human-readable application name, e.g., "FooBar player 1.2.3".
	 * @param http HTTP User Agent string, e.g., "FooBar/1.2.3 Python/2.6.0".
	 */
	@:native('libvlc_set_user_agent')
	static function set_user_agent(p_instance:cpp.RawPointer<LibVLC_Instance_T>, name:cpp.ConstCharStar, http:cpp.ConstCharStar):Void;

	/**
	 * Gets the last error message.
	 *
	 * @return The last error message.
	 */
	@:native('libvlc_errmsg')
	static function errmsg():cpp.ConstCharStar;

	/**
	 * Gets the LibVLC version.
	 *
	 * @return The LibVLC version string.
	 */
	@:native('libvlc_get_version')
	static function get_version():cpp.ConstCharStar;

	/**
	 * Gets the LibVLC compiler information.
	 *
	 * @return The compiler information string.
	 */
	@:native('libvlc_get_compiler')
	static function get_compiler():cpp.ConstCharStar;

	/**
	 * Gets the LibVLC changeset.
	 *
	 * @return The changeset string.
	 */
	@:native('libvlc_get_changeset')
	static function get_changeset():cpp.ConstCharStar;

	/**
	 * Attaches an event callback.
	 *
	 * @param p_event_manager Pointer to the event manager.
	 * @param i_event_type Type of the event.
	 * @param f_callback Event callback function.
	 * @param user_data User data to pass to the callback.
	 * @return 0 on success, -1 on failure.
	 */
	@:native('libvlc_event_attach')
	static function event_attach(p_event_manager:cpp.RawPointer<LibVLC_Event_Manager_T>, i_event_type:Int, f_callback:LibVLC_Callback_T,
		user_data:cpp.RawPointer<cpp.Void>):Int;

	/**
	 * Detaches an event callback.
	 *
	 * @param p_event_manager Pointer to the event manager.
	 * @param i_event_type Type of the event.
	 * @param f_callback Event callback function.
	 * @param user_data User data passed to the callback.
	 */
	@:native('libvlc_event_detach')
	static function event_detach(p_event_manager:cpp.RawPointer<LibVLC_Event_Manager_T>, i_event_type:Int, f_callback:LibVLC_Callback_T,
		user_data:cpp.RawPointer<cpp.Void>):Void;

	/**
	 * Unsets the logging callback.
	 *
	 * @param p_instance Pointer to the LibVLC instance.
	 */
	@:native('libvlc_log_unset')
	static function log_unset(p_instance:cpp.RawPointer<LibVLC_Instance_T>):Void;

	/**
	 * Sets the logging callback.
	 *
	 * @param p_instance Pointer to the LibVLC instance.
	 * @param cb Logging callback function.
	 * @param data User data to pass to the callback.
	 */
	@:native('libvlc_log_set')
	static function log_set(p_instance:cpp.RawPointer<LibVLC_Instance_T>, cb:LibVLC_Log_CB, data:cpp.RawPointer<cpp.Void>):Void;

	/**
	 * Sets up logging to a file.
	 *
	 * @param p_instance Pointer to the LibVLC instance.
	 * @param stream FILE pointer opened for writing.
	 *               The FILE pointer must remain valid until libvlc_log_unset().
	 */
	@:native('libvlc_log_set_file')
	static function log_set_file(p_instance:cpp.RawPointer<LibVLC_Instance_T>, stream:cpp.FILE):Void;

	/**
	 * Gets the LibVLC clock time.
	 *
	 * @return The clock time.
	 */
	@:native('libvlc_clock')
	static function clock():cpp.Int64;

	/**
	 * Creates a new media descriptor from a location.
	 *
	 * @param p_instance Pointer to the LibVLC instance.
	 * @param psz_mrl The location string.
	 * @return Pointer to the new media descriptor.
	 */
	@:native('libvlc_media_new_location')
	static function media_new_location(p_instance:cpp.RawPointer<LibVLC_Instance_T>, psz_mrl:cpp.ConstCharStar):cpp.RawPointer<LibVLC_Media_T>;

	/**
	 * Creates a new media descriptor from a file path.
	 *
	 * @param p_instance Pointer to the LibVLC instance.
	 * @param path The file path.
	 * @return Pointer to the new media descriptor.
	 */
	@:native('libvlc_media_new_path')
	static function media_new_path(p_instance:cpp.RawPointer<LibVLC_Instance_T>, path:cpp.ConstCharStar):cpp.RawPointer<LibVLC_Media_T>;

	/**
	 * Creates a new media descriptor from a file descriptor.
	 *
	 * @param p_instance Pointer to the LibVLC instance.
	 * @param fd The file descriptor.
	 * @return Pointer to the new media descriptor.
	 */
	@:native('libvlc_media_new_fd')
	static function media_new_fd(p_instance:cpp.RawPointer<LibVLC_Instance_T>, fd:Int):cpp.RawPointer<LibVLC_Media_T>;

	/**
	 * Creates a new media descriptor from custom callbacks.
	 *
	 * @param p_instance Pointer to the LibVLC instance.
	 * @param open_cb Open callback function.
	 * @param read_cb Read callback function.
	 * @param seek_cb Seek callback function.
	 * @param close_cb Close callback function.
	 * @param opaque User data to pass to the callbacks.
	 * @return Pointer to the new media descriptor.
	 */
	@:native('libvlc_media_new_callbacks')
	static function media_new_callbacks(p_instance:cpp.RawPointer<LibVLC_Instance_T>, open_cb:LibVLC_Media_Open_CB, read_cb:LibVLC_Media_Read_CB,
		seek_cb:LibVLC_Media_Seek_CB, close_cb:LibVLC_Media_Close_CB, opaque:cpp.RawPointer<cpp.Void>):cpp.RawPointer<LibVLC_Media_T>;

	/**
	 * Adds an option to a media descriptor.
	 *
	 * @param p_md Pointer to the media descriptor.
	 * @param psz_options The option string.
	 */
	@:native('libvlc_media_add_option')
	static function media_add_option(p_md:cpp.RawPointer<LibVLC_Media_T>, psz_options:cpp.ConstCharStar):Void;

	/**
	 * Releases a media descriptor.
	 *
	 * @param p_md Pointer to the media descriptor.
	 */
	@:native('libvlc_media_release')
	static function media_release(p_md:cpp.RawPointer<LibVLC_Media_T>):Void;

	/**
	 * Gets the media resource locator (MRL) of a media descriptor.
	 *
	 * @param p_md Pointer to the media descriptor.
	 * @return The MRL string.
	 */
	@:native('libvlc_media_get_mrl')
	static function media_get_mrl(p_md:cpp.RawPointer<LibVLC_Media_T>):cpp.CastCharStar;

	/**
	 * Gets the metadata of a media descriptor.
	 *
	 * @param p_md Pointer to the media descriptor.
	 * @param e_meta Metadata type.
	 * @return The metadata string.
	 */
	@:native('libvlc_media_get_meta')
	static function media_get_meta(p_md:cpp.RawPointer<LibVLC_Media_T>, e_meta:LibVLC_Meta_T):cpp.CastCharStar;

	/**
	 * Sets the metadata of a media descriptor.
	 *
	 * @param p_md Pointer to the media descriptor.
	 * @param e_meta Metadata type.
	 * @param psz_value New metadata value.
	 */
	@:native('libvlc_media_set_meta')
	static function media_set_meta(p_md:cpp.RawPointer<LibVLC_Media_T>, e_meta:LibVLC_Meta_T, psz_value:cpp.ConstCharStar):Void;

	/**
	 * Saves the metadata of a media descriptor.
	 *
	 * This function commits any metadata modifications to the underlying storage, if applicable.
	 *
	 * @param p_md Pointer to the media descriptor.
	 * @return 0 on failure, a non-zero value if the metadata was saved successfully.
	 */
	@:native('libvlc_media_save_meta')
	static function media_save_meta(p_md:cpp.RawPointer<LibVLC_Media_T>):Int;

	/**
	 * Gets the statistics of a media descriptor.
	 *
	 * @param p_md Pointer to the media descriptor.
	 * @param p_stats Pointer to the statistics structure.
	 * @return 0 on success, -1 on failure.
	 */
	@:native('libvlc_media_get_stats')
	static function media_get_stats(p_md:cpp.RawPointer<LibVLC_Media_T>, p_stats:cpp.RawPointer<LibVLC_Media_Stats_T>):Int;

	/**
	 * Gets the subitems of a media descriptor.
	 *
	 * @param p_md Pointer to the media descriptor.
	 * @return Pointer to the media list containing subitems.
	 */
	@:native('libvlc_media_subitems')
	static function media_subitems(p_md:cpp.RawPointer<LibVLC_Media_T>):cpp.RawPointer<LibVLC_Media_List_T>;

	/**
	 * Gets the event manager of a media descriptor.
	 *
	 * @param p_md Pointer to the media descriptor.
	 * @return Pointer to the event manager.
	 */
	@:native('libvlc_media_event_manager')
	static function media_event_manager(p_md:cpp.RawPointer<LibVLC_Media_T>):cpp.RawPointer<LibVLC_Event_Manager_T>;

	/**
	 * Gets the duration of a media descriptor.
	 *
	 * @param p_md Pointer to the media descriptor.
	 * @return The duration in milliseconds.
	 */
	@:native('libvlc_media_get_duration')
	static function media_get_duration(p_md:cpp.RawPointer<LibVLC_Media_T>):LibVLC_Time_T;

	/**
	 * Parses a media descriptor with options.
	 *
	 * @param p_md Pointer to the media descriptor.
	 * @param parse_flag Parse flags.
	 * @param timeout Timeout in milliseconds.
	 * @return 0 on success, -1 on failure.
	 */
	@:native('libvlc_media_parse_with_options')
	static function media_parse_with_options(p_md:cpp.RawPointer<LibVLC_Media_T>, parse_flag:LibVLC_Media_Parse_Flag_T, timeout:Int):Int;

	/**
	 * Stops the parsing of a media descriptor.
	 *
	 * @param p_md Pointer to the media descriptor.
	 */
	@:native('libvlc_media_parse_stop')
	static function media_parse_stop(p_md:cpp.RawPointer<LibVLC_Media_T>):Void;

	/**
	 * Gets the parsed status of a media descriptor.
	 *
	 * @param p_md Pointer to the media descriptor.
	 * @return The parsed status.
	 */
	@:native('libvlc_media_get_parsed_status')
	static function media_get_parsed_status(p_md:cpp.RawPointer<LibVLC_Media_T>):LibVLC_Media_Parsed_Status_T;

	/**
	 * Releases a media list.
	 *
	 * @param p_ml Pointer to the media list.
	 */
	@:native('libvlc_media_list_release')
	static function media_list_release(p_ml:cpp.RawPointer<LibVLC_Media_List_T>):Void;

	/**
	 * Gets the number of items in a media list.
	 *
	 * @param p_ml Pointer to the media list.
	 * @return Number of items in the list.
	 */
	@:native('libvlc_media_list_count')
	static function media_list_count(p_ml:cpp.RawPointer<LibVLC_Media_List_T>):Int;

	/**
	 * Gets the media item at the specified index in a media list.
	 *
	 * @param p_ml Pointer to the media list.
	 * @param i_pos Index of the media item to retrieve.
	 * @return Pointer to the media descriptor.
	 */
	@:native('libvlc_media_list_item_at_index')
	static function media_list_item_at_index(p_ml:cpp.RawPointer<LibVLC_Media_List_T>, i_pos:Int):cpp.RawPointer<LibVLC_Media_T>;

	/**
	 * Gets the media descriptor from a media player.
	 *
	 * @param p_mi Pointer to the media player.
	 * @return Pointer to the media descriptor.
	 */
	@:native('libvlc_media_player_get_media')
	static function media_player_get_media(p_mi:cpp.RawPointer<LibVLC_Media_Player_T>):cpp.RawPointer<LibVLC_Media_T>;

	/**
	 * Sets the media descriptor for a media player.
	 *
	 * @param p_mi Pointer to the media player.
	 * @param p_md Pointer to the media descriptor.
	 */
	@:native('libvlc_media_player_set_media')
	static function media_player_set_media(p_mi:cpp.RawPointer<LibVLC_Media_Player_T>, p_md:cpp.RawPointer<LibVLC_Media_T>):Void;

	/**
	 * Starts playback of the media player.
	 *
	 * @param p_mi Pointer to the media player.
	 * @return 0 on success, -1 on failure.
	 */
	@:native('libvlc_media_player_play')
	static function media_player_play(p_mi:cpp.RawPointer<LibVLC_Media_Player_T>):Int;

	/**
	 * Stops playback of the media player.
	 *
	 * @param p_mi Pointer to the media player.
	 */
	@:native('libvlc_media_player_stop')
	static function media_player_stop(p_mi:cpp.RawPointer<LibVLC_Media_Player_T>):Void;

	/**
	 * Pauses playback of the media player.
	 *
	 * @param p_mi Pointer to the media player.
	 */
	@:native('libvlc_media_player_pause')
	static function media_player_pause(p_mi:cpp.RawPointer<LibVLC_Media_Player_T>):Void;

	/**
	 * Sets pause state for the media player.
	 *
	 * @param p_mi Pointer to the media player.
	 *
	 * @param do_pause 1 to pause, 0 to play.
	 */
	@:native('libvlc_media_player_set_pause')
	static function media_player_set_pause(p_mi:cpp.RawPointer<LibVLC_Media_Player_T>, do_pause:Int):Void;

	/**
	 * Checks if the media player is playing.
	 *
	 * @param p_mi Pointer to the media player.
	 * @return 1 if playing, 0 otherwise.
	 */
	@:native('libvlc_media_player_is_playing')
	static function media_player_is_playing(p_mi:cpp.RawPointer<LibVLC_Media_Player_T>):Int;

	/**
	 * Checks if the media player is seekable.
	 *
	 * @param p_mi Pointer to the media player.
	 * @return 1 if seekable, 0 otherwise.
	 */
	@:native('libvlc_media_player_is_seekable')
	static function media_player_is_seekable(p_mi:cpp.RawPointer<LibVLC_Media_Player_T>):Int;

	/**
	 * Checks if the media player can pause.
	 *
	 * @param p_mi Pointer to the media player.
	 * @return 1 if can pause, 0 otherwise.
	 */
	@:native('libvlc_media_player_can_pause')
	static function media_player_can_pause(p_mi:cpp.RawPointer<LibVLC_Media_Player_T>):Int;

	/**
	 * Checks if the media player will play.
	 *
	 * @param p_mi Pointer to the media player.
	 * @return 1 if will play, 0 otherwise.
	 */
	@:native('libvlc_media_player_will_play')
	static function media_player_will_play(p_mi:cpp.RawPointer<LibVLC_Media_Player_T>):Int;

	/**
	 * Releases a media player.
	 *
	 * @param p_mi Pointer to the media player.
	 */
	@:native('libvlc_media_player_release')
	static function media_player_release(p_mi:cpp.RawPointer<LibVLC_Media_Player_T>):Void;

	/**
	 * Gets the event manager of a media player.
	 *
	 * @param mp Pointer to the media player.
	 * @return Pointer to the event manager.
	 */
	@:native('libvlc_media_player_event_manager')
	static function media_player_event_manager(mp:cpp.RawPointer<LibVLC_Media_Player_T>):cpp.RawPointer<LibVLC_Event_Manager_T>;

	/**
	 * Gets the current playback time.
	 *
	 * @param p_mi Pointer to the media player.
	 * @return The current playback time in milliseconds.
	 */
	@:native('libvlc_media_player_get_time')
	static function media_player_get_time(p_mi:cpp.RawPointer<LibVLC_Media_Player_T>):LibVLC_Time_T;

	/**
	 * Sets the current playback time.
	 *
	 * @param p_mi Pointer to the media player.
	 * @param i_time The new playback time in milliseconds.
	 * @return 0 on success, -1 on failure.
	 */
	@:native('libvlc_media_player_set_time')
	static function media_player_set_time(p_mi:cpp.RawPointer<LibVLC_Media_Player_T>, i_time:LibVLC_Time_T):Int;

	/**
	 * Gets the current playback position.
	 *
	 * @param p_mi Pointer to the media player.
	 * @return The current playback position as a float between 0.0 and 1.0.
	 */
	@:native('libvlc_media_player_get_position')
	static function media_player_get_position(p_mi:cpp.RawPointer<LibVLC_Media_Player_T>):Single;

	/**
	 * Sets the current playback position.
	 *
	 * @param p_mi Pointer to the media player.
	 * @param f_pos The new playback position as a float between 0.0 and 1.0.
	 */
	@:native('libvlc_media_player_set_position')
	static function media_player_set_position(p_mi:cpp.RawPointer<LibVLC_Media_Player_T>, f_pos:Single):Void;

	/**
	 * Gets the current chapter.
	 *
	 * @param p_mi Pointer to the media player.
	 * @return The current chapter.
	 */
	@:native('libvlc_media_player_get_chapter')
	static function media_player_get_chapter(p_mi:cpp.RawPointer<LibVLC_Media_Player_T>):Int;

	/**
	 * Sets the current chapter.
	 *
	 * @param p_mi Pointer to the media player.
	 * @param i_chapter The new chapter.
	 */
	@:native('libvlc_media_player_set_chapter')
	static function media_player_set_chapter(p_mi:cpp.RawPointer<LibVLC_Media_Player_T>, i_chapter:Int):Void;

	/**
	 * Gets the total number of chapters.
	 *
	 * @param p_mi Pointer to the media player.
	 * @return The total number of chapters.
	 */
	@:native('libvlc_media_player_get_chapter_count')
	static function media_player_get_chapter_count(p_mi:cpp.RawPointer<LibVLC_Media_Player_T>):Int;

	/**
	 * Moves to the previous chapter.
	 *
	 * @param p_mi Pointer to the media player.
	 */
	@:native('libvlc_media_player_previous_chapter')
	static function media_player_previous_chapter(p_mi:cpp.RawPointer<LibVLC_Media_Player_T>):Void;

	/**
	 * Moves to the next chapter.
	 *
	 * @param p_mi Pointer to the media player.
	 */
	@:native('libvlc_media_player_next_chapter')
	static function media_player_next_chapter(p_mi:cpp.RawPointer<LibVLC_Media_Player_T>):Void;

	/**
	 * Gets the current playback rate.
	 *
	 * @param p_mi Pointer to the media player.
	 * @return The current playback rate.
	 */
	@:native('libvlc_media_player_get_rate')
	static function media_player_get_rate(p_mi:cpp.RawPointer<LibVLC_Media_Player_T>):Single;

	/**
	 * Sets the playback rate.
	 *
	 * @param p_mi Pointer to the media player.
	 * @param rate The new playback rate.
	 * @return 0 on success, -1 on failure.
	 */
	@:native('libvlc_media_player_set_rate')
	static function media_player_set_rate(p_mi:cpp.RawPointer<LibVLC_Media_Player_T>, rate:Single):Int;

	/**
	 * Gets the media length.
	 *
	 * @param p_mi Pointer to the media player.
	 * @return The media length in milliseconds.
	 */
	@:native('libvlc_media_player_get_length')
	static function media_player_get_length(p_mi:cpp.RawPointer<LibVLC_Media_Player_T>):LibVLC_Time_T;

	/**
	 * Creates a new media player.
	 *
	 * @param p_libvlc_instance Pointer to the LibVLC instance.
	 * @return Pointer to the new media player.
	 */
	@:native('libvlc_media_player_new')
	static function media_player_new(p_libvlc_instance:cpp.RawPointer<LibVLC_Instance_T>):cpp.RawPointer<LibVLC_Media_Player_T>;

	/**
	 * Sets the video format callbacks.
	 *
	 * @param mp Pointer to the media player.
	 * @param setup Video format setup callback.
	 * @param cleanup Video format cleanup callback.
	 */
	@:native('libvlc_video_set_format_callbacks')
	static function video_set_format_callbacks(mp:cpp.RawPointer<LibVLC_Media_Player_T>, setup:LibVLC_Video_Format_CB, cleanup:LibVLC_Video_Cleanup_CB):Void;

	/**
	 * Sets the video callbacks.
	 *
	 * @param mp Pointer to the media player.
	 * @param lock Video lock callback.
	 * @param unlock Video unlock callback.
	 * @param display Video display callback.
	 * @param opaque Pointer to the opaque data.
	 */
	@:native('libvlc_video_set_callbacks')
	static function video_set_callbacks(mp:cpp.RawPointer<LibVLC_Media_Player_T>, lock:LibVLC_Video_Lock_CB, unlock:LibVLC_Video_Unlock_CB,
		display:LibVLC_Video_Display_CB, opaque:cpp.RawPointer<cpp.Void>):Void;

	/**
	 * Sets the video format.
	 *
	 * @param mp Pointer to the media player.
	 * @param chroma Four-character string identifying the chroma format (e.g., "RV32" for 32-bit RGBA).
	 * @param width Width of the video in pixels.
	 * @param height Height of the video in pixels.
	 * @param pitch Number of bytes per row of pixels in the video.
	 */
	@:native('libvlc_video_set_format')
	static function video_set_format(mp:cpp.RawPointer<LibVLC_Media_Player_T>, chroma:cpp.ConstCharStar, width:cpp.UInt32, height:cpp.UInt32,
		pitch:cpp.UInt32):Void;

	/**
	 * Gets the pixel dimensions of a video.
	 *
	 * @param mp Pointer to the media player.
	 * @param num The index of the video (starting from 0, and most commonly 0).
	 * @param px Pointer to store the width of the video in pixels [OUT].
	 * @param py Pointer to store the height of the video in pixels [OUT].
	 * @return 0 on success, -1 if the specified video does not exist.
	 */
	@:native('libvlc_video_get_size')
	static function video_get_size(mp:cpp.RawPointer<LibVLC_Media_Player_T>, num:cpp.UInt32, px:cpp.RawPointer<cpp.UInt32>, py:cpp.RawPointer<cpp.UInt32>):Int;

	/**
	 * Sets the audio format callbacks.
	 *
	 * @param mp Pointer to the media player.
	 * @param setup Audio format setup callback.
	 *        This callback is invoked to configure the audio format.
	 * @param cleanup Audio format cleanup callback.
	 *        This callback is invoked to clean up after the audio format is no longer needed.
	 */
	@:native('libvlc_audio_set_format_callbacks')
	static function audio_set_format_callbacks(mp:cpp.RawPointer<LibVLC_Media_Player_T>, setup:LibVLC_Audio_Setup_CB, cleanup:LibVLC_Audio_Cleanup_CB):Void;

	/**
	 * Sets the audio callbacks.
	 *
	 * @param mp Pointer to the media player.
	 * @param play Audio play callback.
	 * @param pause Audio pause callback.
	 * @param resume Audio resume callback.
	 * @param flush Audio flush callback.
	 * @param drain Audio drain callback.
	 * @param opaque Pointer to the opaque data.
	 */
	@:native('libvlc_audio_set_callbacks')
	static function audio_set_callbacks(mp:cpp.RawPointer<LibVLC_Media_Player_T>, play:LibVLC_Audio_Play_CB, pause:LibVLC_Audio_Pause_CB,
		resume:LibVLC_Audio_Resume_CB, flush:LibVLC_Audio_Flush_CB, drain:LibVLC_Audio_Drain_CB, opaque:cpp.RawPointer<cpp.Void>):Void;

	/**
	 * Sets the audio volume callback.
	 *
	 * @param mp Pointer to the media player.
	 * @param set_volume Audio set volume callback.
	 */
	@:native('libvlc_audio_set_volume_callback')
	static function audio_set_volume_callback(mp:cpp.RawPointer<LibVLC_Media_Player_T>, set_volume:LibVLC_Audio_Set_Volume_CB):Void;

	/**
	 * Sets the audio format.
	 *
	 * @param mp Pointer to the media player.
	 * @param format Audio format string.
	 * @param rate Sample rate.
	 * @param channels Number of audio channels.
	 */
	@:native('libvlc_audio_set_format')
	static function audio_set_format(mp:cpp.RawPointer<LibVLC_Media_Player_T>, format:cpp.ConstCharStar, rate:cpp.UInt32, channels:cpp.UInt32):Void;

	/**
	 * Gets the audio delay.
	 *
	 * @param p_mi Pointer to the media player.
	 * @return The audio delay in microseconds.
	 */
	@:native('libvlc_audio_get_delay')
	static function audio_get_delay(p_mi:cpp.RawPointer<LibVLC_Media_Player_T>):cpp.Int64;

	/**
	 * Sets the audio delay.
	 *
	 * @param p_mi Pointer to the media player.
	 * @param i_delay The new audio delay in microseconds.
	 * @return 0 on success, -1 on failure.
	 */
	@:native('libvlc_audio_set_delay')
	static function audio_set_delay(p_mi:cpp.RawPointer<LibVLC_Media_Player_T>, i_delay:cpp.Int64):Int;

	/**
	 * Gets the number of audio tracks.
	 *
	 * @param p_mi Pointer to the media player.
	 * @return The number of audio tracks.
	 */
	@:native('libvlc_audio_get_track_count')
	static function audio_get_track_count(p_mi:cpp.RawPointer<LibVLC_Media_Player_T>):Int;

	/**
	 * Gets the current audio track.
	 *
	 * @param p_mi Pointer to the media player.
	 * @return The current audio track.
	 */
	@:native('libvlc_audio_get_track')
	static function audio_get_track(p_mi:cpp.RawPointer<LibVLC_Media_Player_T>):Int;

	/**
	 * Sets the current audio track.
	 *
	 * @param p_mi Pointer to the media player.
	 * @param i_track The new audio track.
	 * @return 0 on success, -1 on failure.
	 */
	@:native('libvlc_audio_set_track')
	static function audio_set_track(p_mi:cpp.RawPointer<LibVLC_Media_Player_T>, i_track:Int):Int;

	/**
	 * Gets the current audio channel.
	 *
	 * @param p_mi Pointer to the media player.
	 * @return The current audio channel.
	 */
	@:native('libvlc_audio_get_channel')
	static function audio_get_channel(p_mi:cpp.RawPointer<LibVLC_Media_Player_T>):Int;

	/**
	 * Sets the current audio channel.
	 *
	 * @param p_mi Pointer to the media player.
	 * @param channel The new audio channel.
	 * @return 0 on success, -1 on failure.
	 */
	@:native('libvlc_audio_set_channel')
	static function audio_set_channel(p_mi:cpp.RawPointer<LibVLC_Media_Player_T>, channel:Int):Int;

	/**
	 * Gets the role of the media player.
	 *
	 * @param p_mi Pointer to the media player.
	 * @return The role of the media player.
	 */
	@:native('libvlc_media_player_get_role')
	static function media_player_get_role(p_mi:cpp.RawPointer<LibVLC_Media_Player_T>):Int;

	/**
	 * Sets the role of the media player.
	 *
	 * @param p_mi Pointer to the media player.
	 * @param role The new role.
	 * @return 0 on success, -1 on failure.
	 */
	@:native('libvlc_media_player_set_role')
	static function media_player_set_role(p_mi:cpp.RawPointer<LibVLC_Media_Player_T>, role:cpp.UInt32):Int;
}
