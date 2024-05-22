package hxvlc.externs;

#if !cpp
#error 'LibVLC supports only C++ target platforms.'
#end
import hxvlc.externs.Types;

@:buildXml('<include name="${haxelib:hxvlc}/project/Build.xml" />')
@:include('vlc/vlc.h')
@:unreflective
extern class LibVLC
{
	@:native('libvlc_new')
	static function alloc(argc:Int, argv:cpp.ConstCharStarConstStar):cpp.RawPointer<LibVLC_Instance_T>;

	@:native('libvlc_release')
	static function release(p_instance:cpp.RawPointer<LibVLC_Instance_T>):Void;

	@:native('libvlc_errmsg')
	static function errmsg():cpp.ConstCharStar;

	@:native('libvlc_get_version')
	static function get_version():cpp.ConstCharStar;

	@:native('libvlc_get_compiler')
	static function get_compiler():cpp.ConstCharStar;

	@:native('libvlc_get_changeset')
	static function get_changeset():cpp.ConstCharStar;

	@:native('libvlc_event_attach')
	static function event_attach(p_event_manager:cpp.RawPointer<LibVLC_Event_Manager_T>, i_event_type:Int, f_callback:LibVLC_Callback_T,
		user_data:cpp.RawPointer<cpp.Void>):Int;

	@:native('libvlc_event_detach')
	static function event_detach(p_event_manager:cpp.RawPointer<LibVLC_Event_Manager_T>, i_event_type:Int, f_callback:LibVLC_Callback_T,
		user_data:cpp.RawPointer<cpp.Void>):Void;

	@:native('libvlc_log_unset')
	static function log_unset(p_instance:cpp.RawPointer<LibVLC_Instance_T>):Void;

	@:native('libvlc_log_set')
	static function log_set(p_instance:cpp.RawPointer<LibVLC_Instance_T>, cb:LibVLC_Log_CB, data:cpp.RawPointer<cpp.Void>):Void;

	@:native('libvlc_clock')
	static function clock():cpp.Int64;

	@:native('libvlc_media_new_location')
	static function media_new_location(p_instance:cpp.RawPointer<LibVLC_Instance_T>, psz_mrl:cpp.ConstCharStar):cpp.RawPointer<LibVLC_Media_T>;

	@:native('libvlc_media_new_path')
	static function media_new_path(p_instance:cpp.RawPointer<LibVLC_Instance_T>, path:cpp.ConstCharStar):cpp.RawPointer<LibVLC_Media_T>;

	@:native('libvlc_media_new_fd')
	static function media_new_fd(p_instance:cpp.RawPointer<LibVLC_Instance_T>, fd:Int):cpp.RawPointer<LibVLC_Media_T>;

	#if (mingw || HXCPP_MINGW || !windows)
	@:native('libvlc_media_new_callbacks')
	static function media_new_callbacks(p_instance:cpp.RawPointer<LibVLC_Instance_T>, open_cb:LibVLC_Media_Open_CB, read_cb:LibVLC_Media_Read_CB,
		seek_cb:LibVLC_Media_Seek_CB, close_cb:LibVLC_Media_Close_CB, opaque:cpp.RawPointer<cpp.Void>):cpp.RawPointer<LibVLC_Media_T>;
	#end

	@:native('libvlc_media_add_option')
	static function media_add_option(p_md:cpp.RawPointer<LibVLC_Media_T>, psz_options:cpp.ConstCharStar):Void;

	@:native('libvlc_media_release')
	static function media_release(p_md:cpp.RawPointer<LibVLC_Media_T>):Void;

	@:native('libvlc_media_get_duration')
	static function media_get_duration(p_md:cpp.RawPointer<LibVLC_Media_T>):LibVLC_Time_T;

	@:native('libvlc_media_get_mrl')
	static function media_get_mrl(p_md:cpp.RawPointer<LibVLC_Media_T>):cpp.CharStar;

	@:native('libvlc_media_player_get_media')
	static function media_player_get_media(p_mi:cpp.RawPointer<LibVLC_Media_Player_T>):cpp.RawPointer<LibVLC_Media_T>;

	@:native('libvlc_media_player_set_media')
	static function media_player_set_media(p_mi:cpp.RawPointer<LibVLC_Media_Player_T>, p_md:cpp.RawPointer<LibVLC_Media_T>):Void;

	@:native('libvlc_media_player_play')
	static function media_player_play(p_mi:cpp.RawPointer<LibVLC_Media_Player_T>):Int;

	@:native('libvlc_media_player_stop')
	static function media_player_stop(p_mi:cpp.RawPointer<LibVLC_Media_Player_T>):Void;

	@:native('libvlc_media_player_pause')
	static function media_player_pause(p_mi:cpp.RawPointer<LibVLC_Media_Player_T>):Void;

	@:native('libvlc_media_player_set_pause')
	static function media_player_set_pause(p_mi:cpp.RawPointer<LibVLC_Media_Player_T>, do_pause:Int):Void;

	@:native('libvlc_media_player_is_playing')
	static function media_player_is_playing(p_mi:cpp.RawPointer<LibVLC_Media_Player_T>):Int;

	@:native('libvlc_media_player_is_seekable')
	static function media_player_is_seekable(p_mi:cpp.RawPointer<LibVLC_Media_Player_T>):Int;

	@:native('libvlc_media_player_can_pause')
	static function media_player_can_pause(p_mi:cpp.RawPointer<LibVLC_Media_Player_T>):Int;

	@:native('libvlc_media_player_will_play')
	static function media_player_will_play(p_mi:cpp.RawPointer<LibVLC_Media_Player_T>):Int;

	@:native('libvlc_media_player_release')
	static function media_player_release(p_mi:cpp.RawPointer<LibVLC_Media_Player_T>):Void;

	@:native('libvlc_media_player_event_manager')
	static function media_player_event_manager(mp:cpp.RawPointer<LibVLC_Media_Player_T>):cpp.RawPointer<LibVLC_Event_Manager_T>;

	@:native('libvlc_media_player_get_time')
	static function media_player_get_time(p_mi:cpp.RawPointer<LibVLC_Media_Player_T>):LibVLC_Time_T;

	@:native('libvlc_media_player_set_time')
	static function media_player_set_time(p_mi:cpp.RawPointer<LibVLC_Media_Player_T>, i_time:LibVLC_Time_T):Int;

	@:native('libvlc_media_player_get_position')
	static function media_player_get_position(p_mi:cpp.RawPointer<LibVLC_Media_Player_T>):Single;

	@:native('libvlc_media_player_set_position')
	static function media_player_set_position(p_mi:cpp.RawPointer<LibVLC_Media_Player_T>, f_pos:Single):Void;

	@:native('libvlc_media_player_get_chapter')
	static function media_player_get_chapter(p_mi:cpp.RawPointer<LibVLC_Media_Player_T>):Int;

	@:native('libvlc_media_player_set_chapter')
	static function media_player_set_chapter(p_mi:cpp.RawPointer<LibVLC_Media_Player_T>, i_chapter:Int):Void;

	@:native('libvlc_media_player_get_chapter_count')
	static function media_player_get_chapter_count(p_mi:cpp.RawPointer<LibVLC_Media_Player_T>):Int;

	@:native('libvlc_media_player_previous_chapter')
	static function media_player_previous_chapter(p_mi:cpp.RawPointer<LibVLC_Media_Player_T>):Void;

	@:native('libvlc_media_player_next_chapter')
	static function media_player_next_chapter(p_mi:cpp.RawPointer<LibVLC_Media_Player_T>):Void;

	@:native('libvlc_media_player_get_rate')
	static function media_player_get_rate(p_mi:cpp.RawPointer<LibVLC_Media_Player_T>):Single;

	@:native('libvlc_media_player_set_rate')
	static function media_player_set_rate(p_mi:cpp.RawPointer<LibVLC_Media_Player_T>, rate:Single):Int;

	@:native('libvlc_media_player_get_length')
	static function media_player_get_length(p_mi:cpp.RawPointer<LibVLC_Media_Player_T>):LibVLC_Time_T;

	@:native('libvlc_media_player_new')
	static function media_player_new(p_libvlc_instance:cpp.RawPointer<LibVLC_Instance_T>):cpp.RawPointer<LibVLC_Media_Player_T>;

	@:native('libvlc_video_set_format_callbacks')
	static function video_set_format_callbacks(mp:cpp.RawPointer<LibVLC_Media_Player_T>, setup:LibVLC_Video_Format_CB, cleanup:LibVLC_Video_Cleanup_CB):Void;

	@:native('libvlc_video_set_callbacks')
	static function video_set_callbacks(mp:cpp.RawPointer<LibVLC_Media_Player_T>, lock:LibVLC_Video_Lock_CB, unlock:LibVLC_Video_Unlock_CB,
		display:LibVLC_Video_Display_CB, opaque:cpp.RawPointer<cpp.Void>):Void;

	@:native('libvlc_audio_set_callbacks')
	static function audio_set_callbacks(mp:cpp.RawPointer<LibVLC_Media_Player_T>, play:LibVLC_Audio_Play_CB, pause:LibVLC_Audio_Pause_CB, resume:LibVLC_Audio_Resume_CB,
		flush:LibVLC_Audio_Flush_CB, drain:LibVLC_Audio_Drain_CB, opaque:cpp.RawPointer<cpp.Void>):Void;

	@:native('libvlc_audio_set_format_callbacks')
	static function audio_set_format_callbacks(mp:cpp.RawPointer<LibVLC_Media_Player_T>, setup:LibVLC_Audio_Setup_CB, cleanup:LibVLC_Audio_Cleanup_CB):Void;

	@:native('libvlc_audio_output_list_get')
	static function audio_output_list_get(p_instance:cpp.RawPointer<LibVLC_Instance_T>):cpp.RawPointer<LibVLC_Audio_Output_T>;

	@:native('libvlc_audio_output_list_release')
	static function audio_output_list_release(p_list:cpp.RawPointer<LibVLC_Audio_Output_T>):Void;

	@:native('libvlc_audio_output_set')
	static function audio_output_set(p_mi:cpp.RawPointer<LibVLC_Media_Player_T>, psz_name:cpp.ConstCharStar):Int;

	@:native('libvlc_audio_get_delay')
	static function audio_get_delay(p_mi:cpp.RawPointer<LibVLC_Media_Player_T>):cpp.Int64;

	@:native('libvlc_audio_set_delay')
	static function audio_set_delay(p_mi:cpp.RawPointer<LibVLC_Media_Player_T>, i_delay:cpp.Int64):Int;

	@:native('libvlc_audio_get_volume')
	static function audio_get_volume(p_mi:cpp.RawPointer<LibVLC_Media_Player_T>):Int;

	@:native('libvlc_audio_set_volume')
	static function audio_set_volume(p_mi:cpp.RawPointer<LibVLC_Media_Player_T>, i_volume:Int):Int;

	@:native('libvlc_audio_get_track_count')
	static function audio_get_track_count(p_mi:cpp.RawPointer<LibVLC_Media_Player_T>):Int;

	@:native('libvlc_audio_get_track')
	static function audio_get_track(p_mi:cpp.RawPointer<LibVLC_Media_Player_T>):Int;

	@:native('libvlc_audio_set_track')
	static function audio_set_track(p_mi:cpp.RawPointer<LibVLC_Media_Player_T>, i_track:Int):Int;

	@:native('libvlc_audio_get_mute')
	static function audio_get_mute(p_mi:cpp.RawPointer<LibVLC_Media_Player_T>):Int;

	@:native('libvlc_audio_set_mute')
	static function audio_set_mute(p_mi:cpp.RawPointer<LibVLC_Media_Player_T>, i_status:Int):Int;

	@:native('libvlc_audio_get_channel')
	static function audio_get_channel(p_mi:cpp.RawPointer<LibVLC_Media_Player_T>):Int;

	@:native('libvlc_audio_set_channel')
	static function audio_set_channel(p_mi:cpp.RawPointer<LibVLC_Media_Player_T>, channel:Int):Int;

	@:native('libvlc_media_player_get_role')
	static function media_player_get_role(p_mi:cpp.RawPointer<LibVLC_Media_Player_T>):Int;

	@:native('libvlc_media_player_set_role')
	static function media_player_set_role(p_mi:cpp.RawPointer<LibVLC_Media_Player_T>, role:cpp.UInt32):Int;
}
