package hxvlc.libvlc;

#if (!cpp && macro)
#error 'LibVLC supports only C++ target platforms.'
#end
class Types {}

@:buildXml('<include name="${haxelib:hxvlc}/project/Build.xml" />')
@:include('vlc/vlc.h')
@:native('libvlc_instance_t')
extern class LibVLC_Instance_T {}

@:buildXml('<include name="${haxelib:hxvlc}/project/Build.xml" />')
@:include('vlc/vlc.h')
@:native('libvlc_media_t')
extern class LibVLC_Media_T {}

@:buildXml('<include name="${haxelib:hxvlc}/project/Build.xml" />')
@:include('vlc/vlc.h')
@:native('libvlc_media_player_t')
extern class LibVLC_MediaPlayer_T {}

@:buildXml('<include name="${haxelib:hxvlc}/project/Build.xml" />')
@:include('vlc/vlc.h')
@:native('libvlc_event_manager_t')
extern class LibVLC_EventManager_T {}

@:buildXml('<include name="${haxelib:hxvlc}/project/Build.xml" />')
@:include('vlc/vlc.h')
@:native('libvlc_event_t')
extern class LibVLC_Event_T {}

@:buildXml('<include name="${haxelib:hxvlc}/project/Build.xml" />')
@:include('vlc/vlc.h')
@:native('libvlc_log_t')
extern class LibVLC_Log_T {}

enum abstract LibVLC_Event_E(Int) from Int to Int
{
	var LibVLC_MediaMetaChanged = 0;
	var LibVLC_MediaSubItemAdded = 1;
	var LibVLC_MediaDurationChanged = 2;
	var LibVLC_MediaParsedChanged = 3;
	var LibVLC_MediaFreed = 4;
	var LibVLC_MediaStateChanged = 5;
	var LibVLC_MediaSubItemTreeAdded = 6;

	var LibVLC_MediaPlayerMediaChanged = 256;
	var LibVLC_MediaPlayerNothingSpecial = 257;
	var LibVLC_MediaPlayerOpening = 258;
	var LibVLC_MediaPlayerBuffering = 259;
	var LibVLC_MediaPlayerPlaying = 260;
	var LibVLC_MediaPlayerPaused = 261;
	var LibVLC_MediaPlayerStopped = 262;
	var LibVLC_MediaPlayerForward = 263;
	var LibVLC_MediaPlayerBackward = 264;
	var LibVLC_MediaPlayerEndReached = 265;
	var LibVLC_MediaPlayerEncounteredError = 266;
	var LibVLC_MediaPlayerTimeChanged = 267;
	var LibVLC_MediaPlayerPositionChanged = 268;
	var LibVLC_MediaPlayerSeekableChanged = 269;
	var LibVLC_MediaPlayerPausableChanged = 270;
	var LibVLC_MediaPlayerTitleChanged = 271;
	var LibVLC_MediaPlayerSnapshotTaken = 272;
	var LibVLC_MediaPlayerLengthChanged = 273;
	var LibVLC_MediaPlayerVout = 274;
	var LibVLC_MediaPlayerScrambledChanged = 275;
	var LibVLC_MediaPlayerESAdded = 276;
	var LibVLC_MediaPlayerESDeleted = 277;
	var LibVLC_MediaPlayerESSelected = 278;
	var LibVLC_MediaPlayerCorked = 279;
	var LibVLC_MediaPlayerUncorked = 280;
	var LibVLC_MediaPlayerMuted = 281;
	var LibVLC_MediaPlayerUnmuted = 282;
	var LibVLC_MediaPlayerAudioVolume = 283;
	var LibVLC_MediaPlayerAudioDevice = 284;
	var LibVLC_MediaPlayerChapterChanged = 285;

	var LibVLC_MediaListItemAdded = 512;
	var LibVLC_MediaListWillAddItem = 513;
	var LibVLC_MediaListItemDeleted = 514;
	var LibVLC_MediaListWillDeleteItem = 515;
	var LibVLC_MediaListEndReached = 516;

	var LibVLC_MediaListViewItemAdded = 768;
	var LibVLC_MediaListViewWillAddItem = 769;
	var LibVLC_MediaListViewItemDeleted = 770;
	var LibVLC_MediaListViewWillDeleteItem = 771;

	var LibVLC_MediaListPlayerPlayed = 1024;
	var LibVLC_MediaListPlayerNextItemSet = 1025;
	var LibVLC_MediaListPlayerStopped = 1026;

	var LibVLC_MediaDiscovererStarted = 1280; /* @deprecated Useless event, it will be triggered only when calling libvlc_media_discoverer_start(). */
	var LibVLC_MediaDiscovererEnded = 1281; /* @deprecated Useless event, it will be triggered only when calling libvlc_media_discoverer_stop(). */
	var LibVLC_RendererDiscovererItemAdded = 1282;
	var LibVLC_RendererDiscovererItemDeleted = 1283;

	var LibVLC_VlmMediaAdded = 1536;
	var LibVLC_VlmMediaRemoved = 1537;
	var LibVLC_VlmMediaChanged = 1538;
	var LibVLC_VlmMediaInstanceStarted = 1539;
	var LibVLC_VlmMediaInstanceStopped = 1540;
	var LibVLC_VlmMediaInstanceStatusInit = 1541;
	var LibVLC_VlmMediaInstanceStatusOpening = 1542;
	var LibVLC_VlmMediaInstanceStatusPlaying = 1543;
	var LibVLC_VlmMediaInstanceStatusPause = 1544;
	var LibVLC_VlmMediaInstanceStatusEnd = 1545;
	var LibVLC_VlmMediaInstanceStatusError = 1546;
}

typedef LibVLC_Callback_T = cpp.Callable<(p_event:cpp.RawConstPointer<LibVLC_Event_T>, p_data:cpp.RawPointer<cpp.Void>) -> Void>;

typedef LibVLC_Log_CB = cpp.Callable<(data:cpp.RawPointer<cpp.Void>, level:Int, ctx:cpp.RawConstPointer<LibVLC_Log_T>, fmt:cpp.ConstCharStar,
		args:cpp.VarList) -> Void>;

typedef LibVLC_Video_Format_CB = cpp.Callable<(opaque:cpp.RawPointer<cpp.RawPointer<cpp.Void>>, chroma:cpp.CharStar, width:cpp.RawPointer<cpp.UInt32>,
		height:cpp.RawPointer<cpp.UInt32>, pitches:cpp.RawPointer<cpp.UInt32>, lines:cpp.RawPointer<cpp.UInt32>) -> cpp.UInt32>;

typedef LibVLC_Video_Cleanup_CB = cpp.Callable<(opaque:cpp.RawPointer<cpp.Void>) -> Void>;
typedef LibVLC_Video_Lock_CB = cpp.Callable<(data:cpp.RawPointer<cpp.Void>, p_pixels:cpp.RawPointer<cpp.RawPointer<cpp.Void>>) -> cpp.RawPointer<cpp.Void>>;
typedef LibVLC_Video_Unlock_CB = cpp.Callable<(data:cpp.RawPointer<cpp.Void>, id:cpp.RawPointer<cpp.Void>, p_pixels:cpp.VoidStarConstStar) -> Void>;
typedef LibVLC_Video_Display_CB = cpp.Callable<(opaque:cpp.RawPointer<cpp.Void>, picture:cpp.RawPointer<cpp.Void>) -> Void>;
