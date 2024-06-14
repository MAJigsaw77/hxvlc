package;

#if android
import android.widget.Toast;
#end
#if debug
import flixel.system.debug.watch.Tracker;
#end
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.ui.FlxBar;
import flixel.FlxG;
import flixel.FlxState;
import haxe.io.Path;
import haxe.Exception;
import hxvlc.flixel.FlxVideo;
import hxvlc.flixel.FlxVideoSprite;
import hxvlc.openfl.Stats;
import hxvlc.util.Handle;
import openfl.system.System;
import openfl.utils.Assets;
import openfl.Lib;
import sys.io.File;
import sys.FileSystem;

class PlayState extends FlxState
{
	var video:FlxVideoSprite;
	var videoPositionBar:FlxBar;

	override function create():Void
	{
		#if mobile
		copyFiles();
		#end

		FlxG.cameras.bgColor = 0xFF131C1B;

		#if debug
		FlxG.debugger.addTrackerProfile(new TrackerProfile(Stats, [
			"i_read_bytes", "f_input_bitrate", "i_demux_read_bytes", "f_demux_bitrate", "i_demux_corrupted", "i_demux_discontinuity", "i_decoded_video",
			"i_decoded_audio", "i_displayed_pictures", "i_lost_pictures", "i_played_abuffers", "i_lost_abuffers", "i_sent_packets", "i_sent_bytes",
			"f_send_bitrate"
		]));
		#end

		video = new FlxVideoSprite(0, 0);
		#if debug
		video.bitmap.onOpening.add(function():Void
		{
			if (video.bitmap.stats != null)
				FlxG.debugger.track(video.bitmap.stats);
		});
		#end
		video.bitmap.onFormatSetup.add(function():Void
		{
			video.setGraphicSize(FlxG.width * 0.7, FlxG.height * 0.7);
			video.updateHitbox();
			video.screenCenter();
		});
		video.bitmap.onPositionChanged.add(function(position:Single):Void
		{
			if (videoPositionBar != null)
				videoPositionBar.value = position;
		});
		video.bitmap.onEndReached.add(video.destroy);
		video.load('assets/video.mp4', [':input-repeat=2']);
		video.antialiasing = true;
		add(video);

		var libvlcVersion:FlxText = new FlxText(10, FlxG.height - 30, 0, 'LibVLC Version: ${Handle.version}', 16);
		libvlcVersion.setBorderStyle(OUTLINE, FlxColor.BLACK);
		libvlcVersion.active = false;
		libvlcVersion.antialiasing = true;
		add(libvlcVersion);

		videoPositionBar = new FlxBar(10, FlxG.height - 50, LEFT_TO_RIGHT, FlxG.width - 20, 10, null, '', 0, 1);
		videoPositionBar.createFilledBar(FlxColor.GRAY, FlxColor.CYAN);
		add(videoPositionBar);

		FlxTimer.wait(0.001, function():Void
		{
			video.play();
		});

		super.create();

		#if debug
		FlxG.debugger.visible = true;
		#end
	}

	#if mobile
	private inline function copyFiles():Void
	{
		try
		{
			final path:String = 'assets/video.mp4';

			if (!FileSystem.exists(Path.directory(path)))
			{
				FileSystem.createDirectory(Path.directory(path));

				File.saveBytes(path, Assets.getBytes(path));
			}
			else if (!FileSystem.exists(path))
				File.saveBytes(path, Assets.getBytes(path));

			System.gc();
		}
		catch (e:Exception)
		{
			#if android
			Toast.makeText(e.message, Toast.LENGTH_LONG);
			#end
		}
	}
	#end
}
