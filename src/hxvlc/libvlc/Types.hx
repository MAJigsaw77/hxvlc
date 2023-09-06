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

/**
 * Event types.
 */
@:buildXml('<include name="${haxelib:hxvlc}/project/Build.xml" />')
@:include('vlc/vlc.h')
@:native('libvlc_event_t')
extern enum abstract LibVLC_Event_E(Int) from Int to Int
{
	@:native('libvlc_MediaMetaChanged')
	var LibVLC_MediaMetaChanged = 0;

	@:native('libvlc_MediaSubItemAdded')
	var LibVLC_MediaSubItemAdded = 1;

	@:native('libvlc_MediaDurationChanged')
	var LibVLC_MediaDurationChanged = 2;

	@:native('libvlc_MediaParsedChanged')
	var LibVLC_MediaParsedChanged = 3;

	@:native('libvlc_MediaFreed')
	var LibVLC_MediaFreed = 4;

	@:native('libvlc_MediaStateChanged')
	var LibVLC_MediaStateChanged = 5;

	@:native('libvlc_MediaSubItemTreeAdded')
	var LibVLC_MediaSubItemTreeAdded = 6;

	@:native('libvlc_MediaPlayerMediaChanged')
	var LibVLC_MediaPlayerMediaChanged = 256;

	@:native('libvlc_MediaPlayerNothingSpecial')
	var LibVLC_MediaPlayerNothingSpecial = 257;

	@:native('libvlc_MediaPlayerOpening')
	var LibVLC_MediaPlayerOpening = 258;

	@:native('libvlc_MediaPlayerBuffering')
	var LibVLC_MediaPlayerBuffering = 259;

	@:native('libvlc_MediaPlayerPlaying')
	var LibVLC_MediaPlayerPlaying = 260;

	@:native('libvlc_MediaPlayerPaused')
	var LibVLC_MediaPlayerPaused = 261;

	@:native('libvlc_MediaPlayerStopped')
	var LibVLC_MediaPlayerStopped = 262;

	@:native('libvlc_MediaPlayerForward')
	var LibVLC_MediaPlayerForward = 263;

	@:native('libvlc_MediaPlayerBackward')
	var LibVLC_MediaPlayerBackward = 264;

	@:native('libvlc_MediaPlayerEndReached')
	var LibVLC_MediaPlayerEndReached = 265;

	@:native('libvlc_MediaPlayerEncounteredError')
	var LibVLC_MediaPlayerEncounteredError = 266;

	@:native('libvlc_MediaPlayerTimeChanged')
	var LibVLC_MediaPlayerTimeChanged = 267;

	@:native('libvlc_MediaPlayerPositionChanged')
	var LibVLC_MediaPlayerPositionChanged = 268;

	@:native('libvlc_MediaPlayerSeekableChanged')
	var LibVLC_MediaPlayerSeekableChanged = 269;

	@:native('libvlc_MediaPlayerPausableChanged')
	var LibVLC_MediaPlayerPausableChanged = 270;

	@:native('libvlc_MediaPlayerTitleChanged')
	var LibVLC_MediaPlayerTitleChanged = 271;

	@:native('libvlc_MediaPlayerSnapshotTaken')
	var LibVLC_MediaPlayerSnapshotTaken = 272;

	@:native('libvlc_MediaPlayerLengthChanged')
	var LibVLC_MediaPlayerLengthChanged = 273;

	@:native('libvlc_MediaPlayerVout')
	var LibVLC_MediaPlayerVout = 274;

	@:native('libvlc_MediaPlayerScrambledChanged')
	var LibVLC_MediaPlayerScrambledChanged = 275;

	@:native('libvlc_MediaPlayerESAdded')
	var LibVLC_MediaPlayerESAdded = 276;

	@:native('libvlc_MediaPlayerESDeleted')
	var LibVLC_MediaPlayerESDeleted = 277;

	@:native('libvlc_MediaPlayerESSelected')
	var LibVLC_MediaPlayerESSelected = 278;

	@:native('libvlc_MediaPlayerCorked')
	var LibVLC_MediaPlayerCorked = 279;

	@:native('libvlc_MediaPlayerUncorked')
	var LibVLC_MediaPlayerUncorked = 280;

	@:native('libvlc_MediaPlayerMuted')
	var LibVLC_MediaPlayerMuted = 281;

	@:native('libvlc_MediaPlayerUnmuted')
	var LibVLC_MediaPlayerUnmuted = 282;

	@:native('libvlc_MediaPlayerAudioVolume')
	var LibVLC_MediaPlayerAudioVolume = 283;

	@:native('libvlc_MediaPlayerAudioDevice')
	var LibVLC_MediaPlayerAudioDevice = 284;

	@:native('libvlc_MediaPlayerChapterChanged')
	var LibVLC_MediaPlayerChapterChanged = 285;

	@:native('libvlc_MediaListItemAdded')
	var LibVLC_MediaListItemAdded = 512;

	@:native('libvlc_MediaListWillAddItem')
	var LibVLC_MediaListWillAddItem = 513;

	@:native('libvlc_MediaListItemDeleted')
	var LibVLC_MediaListItemDeleted = 514;

	@:native('libvlc_MediaListWillDeleteItem')
	var LibVLC_MediaListWillDeleteItem = 515;

	@:native('libvlc_MediaListEndReached')
	var LibVLC_MediaListEndReached = 516;

	@:native('libvlc_MediaListViewItemAdded')
	var LibVLC_MediaListViewItemAdded = 768;

	@:native('libvlc_MediaListViewWillAddItem')
	var LibVLC_MediaListViewWillAddItem = 769;

	@:native('libvlc_MediaListViewItemDeleted')
	var LibVLC_MediaListViewItemDeleted = 770;

	@:native('libvlc_MediaListViewWillDeleteItem')
	var LibVLC_MediaListViewWillDeleteItem = 771;

	@:native('libvlc_MediaListPlayerPlayed')
	var LibVLC_MediaListPlayerPlayed = 1024;

	@:native('libvlc_MediaListPlayerNextItemSet')
	var LibVLC_MediaListPlayerNextItemSet = 1025;

	@:native('libvlc_MediaListPlayerStopped')
	var LibVLC_MediaListPlayerStopped = 1026;

	@:native('libvlc_MediaDiscovererStarted')
	var LibVLC_MediaDiscovererStarted = 1280; /* @deprecated Useless event, it will be triggered only when calling libvlc_media_discoverer_start(). */

	@:native('libvlc_MediaDiscovererEnded')
	var LibVLC_MediaDiscovererEnded = 1281; /* @deprecated Useless event, it will be triggered only when calling libvlc_media_discoverer_stop(). */

	@:native('libvlc_RendererDiscovererItemAdded')
	var LibVLC_RendererDiscovererItemAdded = 1282;

	@:native('libvlc_RendererDiscovererItemDeleted')
	var LibVLC_RendererDiscovererItemDeleted = 1283;

	@:native('libvlc_VlmMediaAdded')
	var LibVLC_VlmMediaAdded = 1536;

	@:native('libvlc_VlmMediaRemoved')
	var LibVLC_VlmMediaRemoved = 1537;

	@:native('libvlc_VlmMediaChanged')
	var LibVLC_VlmMediaChanged = 1538;

	@:native('libvlc_VlmMediaInstanceStarted')
	var LibVLC_VlmMediaInstanceStarted = 1539;

	@:native('libvlc_VlmMediaInstanceStopped')
	var LibVLC_VlmMediaInstanceStopped = 1540;

	@:native('libvlc_VlmMediaInstanceStatusInit')
	var LibVLC_VlmMediaInstanceStatusInit = 1541;

	@:native('libvlc_VlmMediaInstanceStatusOpening')
	var LibVLC_VlmMediaInstanceStatusOpening = 1542;

	@:native('libvlc_VlmMediaInstanceStatusPlaying')
	var LibVLC_VlmMediaInstanceStatusPlaying = 1543;

	@:native('libvlc_VlmMediaInstanceStatusPause')
	var LibVLC_VlmMediaInstanceStatusPause = 1544;

	@:native('libvlc_VlmMediaInstanceStatusEnd')
	var LibVLC_VlmMediaInstanceStatusEnd = 1545;

	@:native('libvlc_VlmMediaInstanceStatusError')
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
