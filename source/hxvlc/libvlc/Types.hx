package hxvlc.libvlc;

#if !cpp
#error 'LibVLC supports only C++ target platforms.'
#end
class Types {}

@:buildXml('<include name="${haxelib:hxvlc}/project/Build.xml" />')
@:include('vlc/vlc.h')
#if ios
@:include('MobileVLCKit/MobileVLCKit.h')
#end
@:native('libvlc_instance_t')
extern class LibVLC_Instance_T {}

@:buildXml('<include name="${haxelib:hxvlc}/project/Build.xml" />')
@:include('vlc/vlc.h')
#if ios
@:include('MobileVLCKit/MobileVLCKit.h')
#end
@:native('libvlc_media_t')
extern class LibVLC_Media_T {}

@:buildXml('<include name="${haxelib:hxvlc}/project/Build.xml" />')
@:include('vlc/vlc.h')
#if ios
@:include('MobileVLCKit/MobileVLCKit.h')
#end
@:native('libvlc_media_player_t')
extern class LibVLC_MediaPlayer_T {}

@:buildXml('<include name="${haxelib:hxvlc}/project/Build.xml" />')
@:include('vlc/vlc.h')
#if ios
@:include('MobileVLCKit/MobileVLCKit.h')
#end
@:native('libvlc_event_manager_t')
extern class LibVLC_EventManager_T {}

@:buildXml('<include name="${haxelib:hxvlc}/project/Build.xml" />')
@:include('vlc/vlc.h')
#if ios
@:include('MobileVLCKit/MobileVLCKit.h')
#end
@:native('libvlc_event_t')
extern class LibVLC_Event_T {}

@:buildXml('<include name="${haxelib:hxvlc}/project/Build.xml" />')
@:include('vlc/vlc.h')
#if ios
@:include('MobileVLCKit/MobileVLCKit.h')
#end
@:native('libvlc_log_t')
extern class LibVLC_Log_T {}

extern enum abstract LibVLC_Event_E(LibVLC_Event_E_Impl)
{
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

	@:to extern public inline function toInt():Int
		return untyped this;
}

@:buildXml('<include name="${haxelib:hxvlc}/project/Build.xml" />')
@:include('vlc/vlc.h')
#if ios
@:include('MobileVLCKit/MobileVLCKit.h')
#end
@:native('libvlc_event_e')
private extern class LibVLC_Event_E_Impl {}

typedef LibVLC_Callback_T = cpp.Callable<(p_event:cpp.RawConstPointer<LibVLC_Event_T>, p_data:cpp.RawPointer<cpp.Void>) -> Void>;

typedef LibVLC_Log_CB = cpp.Callable<(data:cpp.RawPointer<cpp.Void>, level:Int, ctx:cpp.RawConstPointer<LibVLC_Log_T>, fmt:cpp.ConstCharStar,
		args:cpp.VarList) -> Void>;

typedef LibVLC_Video_Format_CB = cpp.Callable<(opaque:cpp.RawPointer<cpp.RawPointer<cpp.Void>>, chroma:cpp.CharStar, width:cpp.RawPointer<cpp.UInt32>,
		height:cpp.RawPointer<cpp.UInt32>, pitches:cpp.RawPointer<cpp.UInt32>, lines:cpp.RawPointer<cpp.UInt32>) -> cpp.UInt32>;

typedef LibVLC_Video_Cleanup_CB = cpp.Callable<(opaque:cpp.RawPointer<cpp.Void>) -> Void>;
typedef LibVLC_Video_Lock_CB = cpp.Callable<(data:cpp.RawPointer<cpp.Void>, p_pixels:cpp.RawPointer<cpp.RawPointer<cpp.Void>>) -> cpp.RawPointer<cpp.Void>>;
typedef LibVLC_Video_Unlock_CB = cpp.Callable<(data:cpp.RawPointer<cpp.Void>, id:cpp.RawPointer<cpp.Void>, p_pixels:cpp.VoidStarConstStar) -> Void>;
typedef LibVLC_Video_Display_CB = cpp.Callable<(opaque:cpp.RawPointer<cpp.Void>, picture:cpp.RawPointer<cpp.Void>) -> Void>;

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
#if ios
@:include('MobileVLCKit/MobileVLCKit.h')
#end
@:native('libvlc_media_player_role_t')
private extern class LibVLC_Media_Player_Role_T_Impl {}
