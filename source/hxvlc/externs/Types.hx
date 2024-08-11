package hxvlc.externs;

/**
 * Dummy class for importing LibVLC native structures.
 */
#if !cpp
#error 'LibVLC supports only C++ target platforms.'
#end
class Types {}

@:dox(hide)
@:buildXml('<include name="${haxelib:hxvlc}/project/Build.xml" />')
@:include('vlc/vlc.h')
@:native('libvlc_instance_t')
extern class LibVLC_Instance_T {}

@:dox(hide)
@:buildXml('<include name="${haxelib:hxvlc}/project/Build.xml" />')
@:include('vlc/vlc.h')
@:native('libvlc_time_t')
@:scalar
@:coreType
@:notNull
extern abstract LibVLC_Time_T from cpp.Int64 to cpp.Int64 {}

@:dox(hide)
@:buildXml('<include name="${haxelib:hxvlc}/project/Build.xml" />')
@:include('vlc/vlc.h')
@:native('libvlc_media_t')
extern class LibVLC_Media_T {}

@:dox(hide)
@:buildXml('<include name="${haxelib:hxvlc}/project/Build.xml" />')
@:include('vlc/vlc.h')
@:native('libvlc_media_list_t')
extern class LibVLC_Media_List_T {}

@:dox(hide)
extern enum abstract LibVLC_Meta_T(LibVLC_Meta_T_Impl)
{
	@:native('libvlc_meta_Title')
	var LibVLC_Meta_Title;
	@:native('libvlc_meta_Artist')
	var LibVLC_Meta_Artist;
	@:native('libvlc_meta_Genre')
	var LibVLC_Meta_Genre;
	@:native('libvlc_meta_Copyright')
	var LibVLC_Meta_Copyright;
	@:native('libvlc_meta_Album')
	var LibVLC_Meta_Album;
	@:native('libvlc_meta_TrackNumber')
	var LibVLC_Meta_TrackNumber;
	@:native('libvlc_meta_Description')
	var LibVLC_Meta_Description;
	@:native('libvlc_meta_Rating')
	var LibVLC_Meta_Rating;
	@:native('libvlc_meta_Date')
	var LibVLC_Meta_Date;
	@:native('libvlc_meta_Setting')
	var LibVLC_Meta_Setting;
	@:native('libvlc_meta_URL')
	var LibVLC_Meta_URL;
	@:native('libvlc_meta_Language')
	var LibVLC_Meta_Language;
	@:native('libvlc_meta_NowPlaying')
	var LibVLC_Meta_NowPlaying;
	@:native('libvlc_meta_Publisher')
	var LibVLC_Meta_Publisher;
	@:native('libvlc_meta_EncodedBy')
	var LibVLC_Meta_EncodedBy;
	@:native('libvlc_meta_ArtworkURL')
	var LibVLC_Meta_ArtworkURL;
	@:native('libvlc_meta_TrackID')
	var LibVLC_Meta_TrackID;
	@:native('libvlc_meta_TrackTotal')
	var LibVLC_Meta_TrackTotal;
	@:native('libvlc_meta_Director')
	var LibVLC_Meta_Director;
	@:native('libvlc_meta_Season')
	var LibVLC_Meta_Season;
	@:native('libvlc_meta_Episode')
	var LibVLC_Meta_Episode;
	@:native('libvlc_meta_ShowName')
	var LibVLC_Meta_ShowName;
	@:native('libvlc_meta_Actors')
	var LibVLC_Meta_Actors;
	@:native('libvlc_meta_AlbumArtist')
	var LibVLC_Meta_AlbumArtist;
	@:native('libvlc_meta_DiscNumber')
	var LibVLC_Meta_DiscNumber;
	@:native('libvlc_meta_DiscTotal')
	var LibVLC_Meta_DiscTotal;

	@:from
	static public inline function fromInt(i:Int):LibVLC_Meta_T
		return cast i;

	@:to extern public inline function toInt():Int
		return untyped this;
}

@:buildXml('<include name="${haxelib:hxvlc}/project/Build.xml" />')
@:include('vlc/vlc.h')
@:native('libvlc_meta_t')
private extern class LibVLC_Meta_T_Impl {}

@:dox(hide)
@:buildXml('<include name="${haxelib:hxvlc}/project/Build.xml" />')
@:include('vlc/vlc.h')
@:unreflective
@:structAccess
@:native('libvlc_media_stats_t')
extern class LibVLC_Media_Stats_T
{
	@:native('libvlc_media_stats_t')
	static function alloc():LibVLC_Media_Stats_T;

	/* Input */
	var i_read_bytes:Int;
	var f_input_bitrate:Single;

	/* Demux */
	var i_demux_read_bytes:Int;
	var f_demux_bitrate:Single;
	var i_demux_corrupted:Int;
	var i_demux_discontinuity:Int;

	/* Decoders */
	var i_decoded_video:Int;
	var i_decoded_audio:Int;

	/* Video Output */
	var i_displayed_pictures:Int;
	var i_lost_pictures:Int;

	/* Audio Output */
	var i_played_abuffers:Int;
	var i_lost_abuffers:Int;

	/* Stream Output */
	var i_sent_packets:Int;
	var i_sent_bytes:Int;
	var f_send_bitrate:Single;
}

@:dox(hide)
extern enum abstract LibVLC_Media_Parse_Flag_T(LibVLC_Media_Parse_Flag_T_Impl)
{
	@:native('libvlc_media_parse_local')
	var LibVLC_Media_Parse_Local;
	@:native('libvlc_media_parse_network')
	var LibVLC_Media_Parse_Network;
	@:native('libvlc_media_fetch_local')
	var LibVLC_Media_Fetch_Local;
	@:native('libvlc_media_fetch_network')
	var LibVLC_Media_Fetch_Network;
	@:native('libvlc_media_do_interact')
	var LibVLC_Media_Do_Interact;

	@:from
	static public inline function fromInt(i:Int):LibVLC_Media_Parse_Flag_T
		return cast i;

	@:to extern public inline function toInt():Int
		return untyped this;
}

@:buildXml('<include name="${haxelib:hxvlc}/project/Build.xml" />')
@:include('vlc/vlc.h')
@:native('libvlc_media_parse_flag_t')
private extern class LibVLC_Media_Parse_Flag_T_Impl {}

@:dox(hide)
extern enum abstract LibVLC_Media_Parsed_Status_T(LibVLC_Media_Parsed_Status_T_Impl)
{
	@:native('libvlc_media_parsed_status_skipped')
	var LibVLC_Media_Parsed_Status_Skipped;
	@:native('libvlc_media_parsed_status_failed')
	var LibVLC_Media_Parsed_Status_Failed;
	@:native('libvlc_media_parsed_status_timeout')
	var LibVLC_Media_Parsed_Status_Timeout;
	@:native('libvlc_media_parsed_status_done')
	var LibVLC_Media_Parsed_Status_Done;

	@:from
	static public inline function fromInt(i:Int):LibVLC_Media_Parsed_Status_T
		return cast i;

	@:to extern public inline function toInt():Int
		return untyped this;
}

@:buildXml('<include name="${haxelib:hxvlc}/project/Build.xml" />')
@:include('vlc/vlc.h')
@:native('libvlc_media_parsed_status_t')
private extern class LibVLC_Media_Parsed_Status_T_Impl {}

@:dox(hide)
@:buildXml('<include name="${haxelib:hxvlc}/project/Build.xml" />')
@:include('vlc/vlc.h')
@:native('libvlc_media_player_t')
extern class LibVLC_Media_Player_T {}

@:dox(hide)
@:buildXml('<include name="${haxelib:hxvlc}/project/Build.xml" />')
@:include('vlc/vlc.h')
@:unreflective
@:structAccess
@:native('libvlc_audio_output_t')
extern class LibVLC_Audio_Output_T
{
	@:native('libvlc_audio_output_t')
	static function alloc():LibVLC_Audio_Output_T;

	var psz_name:cpp.CastCharStar;
	var psz_description:cpp.CastCharStar;
	var p_next:cpp.RawPointer<LibVLC_Audio_Output_T>;
}

@:dox(hide)
extern enum abstract LibVLC_Audio_Output_Channel_T(LibVLC_Audio_Output_Channel_T_Impl)
{
	@:native('libvlc_AudioChannel_Error')
	var LibVLC_Audio_Channel_Error;
	@:native('libvlc_AudioChannel_Stereo')
	var LibVLC_Audio_Channel_Stereo;
	@:native('libvlc_AudioChannel_RStereo')
	var LibVLC_Audio_Channel_RStereo;
	@:native('libvlc_AudioChannel_Left')
	var LibVLC_Audio_Channel_Left;
	@:native('libvlc_AudioChannel_Right')
	var LibVLC_Audio_Channel_Right;
	@:native('libvlc_AudioChannel_Dolbys')
	var LibVLC_Audio_Channel_Dolbys;

	@:from
	static public inline function fromInt(i:Int):LibVLC_Audio_Output_Channel_T
		return cast i;

	@:to extern public inline function toInt():Int
		return untyped this;
}

@:buildXml('<include name="${haxelib:hxvlc}/project/Build.xml" />')
@:include('vlc/vlc.h')
@:native('libvlc_audio_output_channel_t')
private extern class LibVLC_Audio_Output_Channel_T_Impl {}

@:dox(hide)
@:buildXml('<include name="${haxelib:hxvlc}/project/Build.xml" />')
@:include('vlc/vlc.h')
@:native('libvlc_event_manager_t')
extern class LibVLC_Event_Manager_T {}

@:dox(hide)
@:buildXml('<include name="${haxelib:hxvlc}/project/Build.xml" />')
@:include('vlc/vlc.h')
@:native('libvlc_event_t')
extern class LibVLC_Event_T {}

@:dox(hide)
@:buildXml('<include name="${haxelib:hxvlc}/project/Build.xml" />')
@:include('vlc/vlc.h')
@:native('libvlc_log_t')
extern class LibVLC_Log_T {}

@:dox(hide)
extern enum abstract LibVLC_Event_E(LibVLC_Event_E_Impl)
{
	@:native('libvlc_MediaMetaChanged')
	var LibVLC_MediaMetaChanged;
	@:native('libvlc_MediaSubItemAdded')
	var LibVLC_MediaSubItemAdded;
	@:native('libvlc_MediaDurationChanged')
	var LibVLC_MediaDurationChanged;
	@:native('libvlc_MediaParsedChanged')
	var LibVLC_MediaParsedChanged;
	@:native('libvlc_MediaFreed')
	var LibVLC_MediaFreed;
	@:native('libvlc_MediaStateChanged')
	var LibVLC_MediaStateChanged;
	@:native('libvlc_MediaSubItemTreeAdded')
	var LibVLC_MediaSubItemTreeAdded;
	@:native('libvlc_MediaPlayerMediaChanged')
	var LibVLC_MediaPlayerMediaChanged;
	@:native('libvlc_MediaPlayerNothingSpecial')
	var LibVLC_MediaPlayerNothingSpecial;
	@:native('libvlc_MediaPlayerOpening')
	var LibVLC_MediaPlayerOpening;
	@:native('libvlc_MediaPlayerBuffering')
	var LibVLC_MediaPlayerBuffering;
	@:native('libvlc_MediaPlayerPlaying')
	var LibVLC_MediaPlayerPlaying;
	@:native('libvlc_MediaPlayerPaused')
	var LibVLC_MediaPlayerPaused;
	@:native('libvlc_MediaPlayerStopped')
	var LibVLC_MediaPlayerStopped;
	@:native('libvlc_MediaPlayerForward')
	var LibVLC_MediaPlayerForward;
	@:native('libvlc_MediaPlayerBackward')
	var LibVLC_MediaPlayerBackward;
	@:native('libvlc_MediaPlayerEndReached')
	var LibVLC_MediaPlayerEndReached;
	@:native('libvlc_MediaPlayerEncounteredError')
	var LibVLC_MediaPlayerEncounteredError;
	@:native('libvlc_MediaPlayerTimeChanged')
	var LibVLC_MediaPlayerTimeChanged;
	@:native('libvlc_MediaPlayerPositionChanged')
	var LibVLC_MediaPlayerPositionChanged;
	@:native('libvlc_MediaPlayerSeekableChanged')
	var LibVLC_MediaPlayerSeekableChanged;
	@:native('libvlc_MediaPlayerPausableChanged')
	var LibVLC_MediaPlayerPausableChanged;
	@:native('libvlc_MediaPlayerTitleChanged')
	var LibVLC_MediaPlayerTitleChanged;
	@:native('libvlc_MediaPlayerSnapshotTaken')
	var LibVLC_MediaPlayerSnapshotTaken;
	@:native('libvlc_MediaPlayerLengthChanged')
	var LibVLC_MediaPlayerLengthChanged;
	@:native('libvlc_MediaPlayerVout')
	var LibVLC_MediaPlayerVout;
	@:native('libvlc_MediaPlayerScrambledChanged')
	var LibVLC_MediaPlayerScrambledChanged;
	@:native('libvlc_MediaPlayerESAdded')
	var LibVLC_MediaPlayerESAdded;
	@:native('libvlc_MediaPlayerESDeleted')
	var LibVLC_MediaPlayerESDeleted;
	@:native('libvlc_MediaPlayerESSelected')
	var LibVLC_MediaPlayerESSelected;
	@:native('libvlc_MediaPlayerCorked')
	var LibVLC_MediaPlayerCorked;
	@:native('libvlc_MediaPlayerUncorked')
	var LibVLC_MediaPlayerUncorked;
	@:native('libvlc_MediaPlayerMuted')
	var LibVLC_MediaPlayerMuted;
	@:native('libvlc_MediaPlayerUnmuted')
	var LibVLC_MediaPlayerUnmuted;
	@:native('libvlc_MediaPlayerAudioVolume')
	var LibVLC_MediaPlayerAudioVolume;
	@:native('libvlc_MediaPlayerAudioDevice')
	var LibVLC_MediaPlayerAudioDevice;
	@:native('libvlc_MediaPlayerChapterChanged')
	var LibVLC_MediaPlayerChapterChanged;
	@:native('libvlc_MediaListItemAdded')
	var LibVLC_MediaListItemAdded;
	@:native('libvlc_MediaListWillAddItem')
	var LibVLC_MediaListWillAddItem;
	@:native('libvlc_MediaListItemDeleted')
	var LibVLC_MediaListItemDeleted;
	@:native('libvlc_MediaListWillDeleteItem')
	var LibVLC_MediaListWillDeleteItem;
	@:native('libvlc_MediaListEndReached')
	var LibVLC_MediaListEndReached;
	@:native('libvlc_MediaListViewItemAdded')
	var LibVLC_MediaListViewItemAdded;
	@:native('libvlc_MediaListViewWillAddItem')
	var LibVLC_MediaListViewWillAddItem;
	@:native('libvlc_MediaListViewItemDeleted')
	var LibVLC_MediaListViewItemDeleted;
	@:native('libvlc_MediaListViewWillDeleteItem')
	var LibVLC_MediaListViewWillDeleteItem;
	@:native('libvlc_MediaListPlayerPlayed')
	var LibVLC_MediaListPlayerPlayed;
	@:native('libvlc_MediaListPlayerNextItemSet')
	var LibVLC_MediaListPlayerNextItemSet;
	@:native('libvlc_MediaListPlayerStopped')
	var LibVLC_MediaListPlayerStopped;
	@:native('libvlc_MediaDiscovererStarted')
	var LibVLC_MediaDiscovererStarted;
	@:native('libvlc_MediaDiscovererEnded')
	var LibVLC_MediaDiscovererEnded;
	@:native('libvlc_RendererDiscovererItemAdded')
	var LibVLC_RendererDiscovererItemAdded;
	@:native('libvlc_RendererDiscovererItemDeleted')
	var LibVLC_RendererDiscovererItemDeleted;
	@:native('libvlc_VlmMediaAdded')
	var LibVLC_VlmMediaAdded;
	@:native('libvlc_VlmMediaRemoved')
	var LibVLC_VlmMediaRemoved;
	@:native('libvlc_VlmMediaChanged')
	var LibVLC_VlmMediaChanged;
	@:native('libvlc_VlmMediaInstanceStarted')
	var LibVLC_VlmMediaInstanceStarted;
	@:native('libvlc_VlmMediaInstanceStopped')
	var LibVLC_VlmMediaInstanceStopped;
	@:native('libvlc_VlmMediaInstanceStatusInit')
	var LibVLC_VlmMediaInstanceStatusInit;
	@:native('libvlc_VlmMediaInstanceStatusOpening')
	var LibVLC_VlmMediaInstanceStatusOpening;
	@:native('libvlc_VlmMediaInstanceStatusPlaying')
	var LibVLC_VlmMediaInstanceStatusPlaying;
	@:native('libvlc_VlmMediaInstanceStatusPause')
	var LibVLC_VlmMediaInstanceStatusPause;
	@:native('libvlc_VlmMediaInstanceStatusEnd')
	var LibVLC_VlmMediaInstanceStatusEnd;
	@:native('libvlc_VlmMediaInstanceStatusError')
	var LibVLC_VlmMediaInstanceStatusError;

	@:from
	static public inline function fromInt(i:Int):LibVLC_Event_E
		return cast i;

	@:to extern public inline function toInt():Int
		return untyped this;
}

@:buildXml('<include name="${haxelib:hxvlc}/project/Build.xml" />')
@:include('vlc/vlc.h')
@:native('libvlc_event_e')
private extern class LibVLC_Event_E_Impl {}

@:dox(hide)
typedef LibVLC_Callback_T = cpp.Callable<(p_event:cpp.RawConstPointer<LibVLC_Event_T>, p_data:cpp.RawPointer<cpp.Void>) -> Void>;

@:dox(hide)
typedef LibVLC_Log_CB = cpp.Callable<(data:cpp.RawPointer<cpp.Void>, level:Int, ctx:cpp.RawConstPointer<LibVLC_Log_T>, fmt:cpp.ConstCharStar,
		args:cpp.VarList) -> Void>;

@:dox(hide)
typedef LibVLC_Media_Open_CB = cpp.Callable<(opaque:cpp.RawPointer<cpp.Void>, datap:cpp.RawPointer<cpp.RawPointer<cpp.Void>>,
		sizep:cpp.RawPointer<cpp.UInt64>) -> Int>;

@:dox(hide)
typedef LibVLC_Media_Read_CB = cpp.Callable<(opaque:cpp.RawPointer<cpp.Void>, buf:cpp.RawPointer<cpp.UInt8>, len:cpp.SizeT) -> cpp.SSizeT>;

@:dox(hide)
typedef LibVLC_Media_Seek_CB = cpp.Callable<(opaque:cpp.RawPointer<cpp.Void>, offset:cpp.UInt64) -> Int>;

@:dox(hide)
typedef LibVLC_Media_Close_CB = cpp.Callable<(opaque:cpp.RawPointer<cpp.Void>) -> Void>;

@:dox(hide)
typedef LibVLC_Video_Format_CB = cpp.Callable<(opaque:cpp.RawPointer<cpp.RawPointer<cpp.Void>>, chroma:cpp.CastCharStar, width:cpp.RawPointer<cpp.UInt32>,
		height:cpp.RawPointer<cpp.UInt32>, pitches:cpp.RawPointer<cpp.UInt32>, lines:cpp.RawPointer<cpp.UInt32>) -> cpp.UInt32>;

@:dox(hide)
typedef LibVLC_Video_Cleanup_CB = cpp.Callable<(opaque:cpp.RawPointer<cpp.Void>) -> Void>;

@:dox(hide)
typedef LibVLC_Video_Lock_CB = cpp.Callable<(data:cpp.RawPointer<cpp.Void>, p_pixels:cpp.RawPointer<cpp.RawPointer<cpp.Void>>) -> cpp.RawPointer<cpp.Void>>;

@:dox(hide)
typedef LibVLC_Video_Unlock_CB = cpp.Callable<(data:cpp.RawPointer<cpp.Void>, id:cpp.RawPointer<cpp.Void>, p_pixels:cpp.VoidStarConstStar) -> Void>;

@:dox(hide)
typedef LibVLC_Video_Display_CB = cpp.Callable<(opaque:cpp.RawPointer<cpp.Void>, picture:cpp.RawPointer<cpp.Void>) -> Void>;

@:dox(hide)
typedef LibVLC_Audio_Play_CB = cpp.Callable<(data:cpp.RawPointer<cpp.Void>, samples:cpp.RawConstPointer<cpp.Void>, count:cpp.UInt32, pts:cpp.Int64) -> Void>;

@:dox(hide)
typedef LibVLC_Audio_Pause_CB = cpp.Callable<(data:cpp.RawPointer<cpp.Void>, pts:cpp.Int64) -> Void>;

@:dox(hide)
typedef LibVLC_Audio_Resume_CB = cpp.Callable<(data:cpp.RawPointer<cpp.Void>, pts:cpp.Int64) -> Void>;

@:dox(hide)
typedef LibVLC_Audio_Flush_CB = cpp.Callable<(data:cpp.RawPointer<cpp.Void>, pts:cpp.Int64) -> Void>;

@:dox(hide)
typedef LibVLC_Audio_Drain_CB = cpp.Callable<(data:cpp.RawPointer<cpp.Void>) -> Void>;

@:dox(hide)
typedef LibVLC_Audio_Setup_CB = cpp.Callable<(opaque:cpp.RawPointer<cpp.RawPointer<cpp.Void>>, format:cpp.CastCharStar, rate:cpp.RawPointer<cpp.UInt32>,
		channels:cpp.RawPointer<cpp.UInt32>) -> Int>;

@:dox(hide)
typedef LibVLC_Audio_Cleanup_CB = cpp.Callable<(opaque:cpp.RawPointer<cpp.Void>) -> Void>;

@:dox(hide)
typedef LibVLC_Audio_Set_Volume_CB = cpp.Callable<(data:cpp.RawPointer<cpp.Void>, volume:Single, mute:Bool) -> Void>;

@:dox(hide)
extern enum abstract LibVLC_Media_Player_Role_T(LibVLC_Media_Player_Role_T_Impl)
{
	@:native('libvlc_role_None')
	var LibVLC_Role_None;
	@:native('libvlc_role_Music')
	var LibVLC_Role_Music;
	@:native('libvlc_role_Video')
	var LibVLC_Role_Video;
	@:native('libvlc_role_Communication')
	var LibVLC_Role_Communication;
	@:native('libvlc_role_Game')
	var LibVLC_Role_Game;
	@:native('libvlc_role_Notification')
	var LibVLC_Role_Notification;
	@:native('libvlc_role_Animation')
	var LibVLC_Role_Animation;
	@:native('libvlc_role_Production')
	var LibVLC_Role_Production;
	@:native('libvlc_role_Accessibility')
	var LibVLC_Role_Accessibility;
	@:native('libvlc_role_Test')
	var LibVLC_Role_Test;
	@:native('libvlc_role_Last')
	var LibVLC_Role_Last;

	@:from
	static public inline function fromInt(i:Int):LibVLC_Media_Player_Role_T
		return cast i;

	@:to extern public inline function toInt():Int
		return untyped this;
}

@:buildXml('<include name="${haxelib:hxvlc}/project/Build.xml" />')
@:include('vlc/vlc.h')
@:native('libvlc_media_player_role_t')
private extern class LibVLC_Media_Player_Role_T_Impl {}
