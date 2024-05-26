package hxvlc.externs;

#if !cpp
#error 'LibVLC supports only C++ target platforms.'
#end
class Types {}

@:buildXml('<include name="${haxelib:hxvlc}/project/Build.xml" />')
@:include('vlc/vlc.h')
@:native('libvlc_instance_t')
extern class LibVLC_Instance_T {}

typedef LibVLC_Time_T = cpp.Int64;

@:buildXml('<include name="${haxelib:hxvlc}/project/Build.xml" />')
@:include('vlc/vlc.h')
@:native('libvlc_media_t')
extern class LibVLC_Media_T {}

@:buildXml('<include name="${haxelib:hxvlc}/project/Build.xml" />')
@:include('vlc/vlc.h')
@:native('libvlc_media_player_t')
extern class LibVLC_Media_Player_T {}

@:buildXml('<include name="${haxelib:hxvlc}/project/Build.xml" />')
@:include('vlc/vlc.h')
@:unreflective
@:structAccess
@:native('libvlc_audio_output_t')
extern class LibVLC_Audio_Output_T
{
	@:native('libvlc_audio_output_t')
	static function alloc():LibVLC_Audio_Output_T;

	var psz_name:cpp.CharStar;
	var psz_description:cpp.CharStar;
	var p_next:cpp.RawPointer<LibVLC_Audio_Output_T>;
}

@:buildXml('<include name="${haxelib:hxvlc}/project/Build.xml" />')
@:include('vlc/vlc.h')
@:native('libvlc_event_manager_t')
extern class LibVLC_Event_Manager_T {}

@:buildXml('<include name="${haxelib:hxvlc}/project/Build.xml" />')
@:include('vlc/vlc.h')
@:native('libvlc_event_t')
extern class LibVLC_Event_T {}

@:buildXml('<include name="${haxelib:hxvlc}/project/Build.xml" />')
@:include('vlc/vlc.h')
@:native('libvlc_log_t')
extern class LibVLC_Log_T {}

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

	@:to extern public inline function toInt():Int
		return untyped this;
}

@:buildXml('<include name="${haxelib:hxvlc}/project/Build.xml" />')
@:include('vlc/vlc.h')
@:native('libvlc_event_e')
private extern class LibVLC_Event_E_Impl {}

typedef LibVLC_Callback_T = cpp.Callable<(p_event:cpp.RawConstPointer<LibVLC_Event_T>, p_data:cpp.RawPointer<cpp.Void>) -> Void>;

typedef LibVLC_Log_CB = cpp.Callable<(data:cpp.RawPointer<cpp.Void>, level:Int, ctx:cpp.RawConstPointer<LibVLC_Log_T>, fmt:cpp.ConstCharStar,
		args:cpp.VarList) -> Void>;

#if (mingw || HXCPP_MINGW || !windows)
typedef LibVLC_Media_Open_CB = cpp.Callable<(opaque:cpp.RawPointer<cpp.Void>, datap:cpp.RawPointer<cpp.RawPointer<cpp.Void>>,
		sizep:cpp.RawPointer<cpp.UInt64>) -> Int>;

typedef LibVLC_Media_Read_CB = cpp.Callable<(opaque:cpp.RawPointer<cpp.Void>, buf:cpp.RawPointer<cpp.UInt8>, len:cpp.SizeT) -> cpp.SSizeT>;
typedef LibVLC_Media_Seek_CB = cpp.Callable<(opaque:cpp.RawPointer<cpp.Void>, offset:cpp.UInt64) -> Int>;
typedef LibVLC_Media_Close_CB = cpp.Callable<(opaque:cpp.RawPointer<cpp.Void>) -> Void>;
#end

typedef LibVLC_Video_Format_CB = cpp.Callable<(opaque:cpp.RawPointer<cpp.RawPointer<cpp.Void>>, chroma:cpp.CharStar, width:cpp.RawPointer<cpp.UInt32>,
		height:cpp.RawPointer<cpp.UInt32>, pitches:cpp.RawPointer<cpp.UInt32>, lines:cpp.RawPointer<cpp.UInt32>) -> cpp.UInt32>;

typedef LibVLC_Video_Cleanup_CB = cpp.Callable<(opaque:cpp.RawPointer<cpp.Void>) -> Void>;
typedef LibVLC_Video_Lock_CB = cpp.Callable<(data:cpp.RawPointer<cpp.Void>, p_pixels:cpp.RawPointer<cpp.RawPointer<cpp.Void>>) -> cpp.RawPointer<cpp.Void>>;
typedef LibVLC_Video_Unlock_CB = cpp.Callable<(data:cpp.RawPointer<cpp.Void>, id:cpp.RawPointer<cpp.Void>, p_pixels:cpp.VoidStarConstStar) -> Void>;
typedef LibVLC_Video_Display_CB = cpp.Callable<(opaque:cpp.RawPointer<cpp.Void>, picture:cpp.RawPointer<cpp.Void>) -> Void>;

typedef LibVLC_Audio_Play_CB = cpp.Callable<(data:cpp.RawPointer<cpp.Void>, samples:cpp.RawConstPointer<cpp.Void>, count:cpp.UInt32, pts:cpp.Int64) -> Void>;
typedef LibVLC_Audio_Pause_CB = cpp.Callable<(data:cpp.RawPointer<cpp.Void>, pts:cpp.Int64) -> Void>;
typedef LibVLC_Audio_Resume_CB = cpp.Callable<(data:cpp.RawPointer<cpp.Void>, pts:cpp.Int64) -> Void>;
typedef LibVLC_Audio_Flush_CB = cpp.Callable<(data:cpp.RawPointer<cpp.Void>, pts:cpp.Int64) -> Void>;
typedef LibVLC_Audio_Drain_CB = cpp.Callable<(data:cpp.RawPointer<cpp.Void>) -> Void>;

typedef LibVLC_Audio_Set_Volume_CB = cpp.Callable<(data:cpp.RawPointer<cpp.Void>, volume:Single, mute:Bool) -> Void>;

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

	@:to extern public inline function toInt():Int
		return untyped this;
}

@:buildXml('<include name="${haxelib:hxvlc}/project/Build.xml" />')
@:include('vlc/vlc.h')
@:native('libvlc_media_player_role_t')
private extern class LibVLC_Media_Player_Role_T_Impl {}
