package hxvlc.flixel;

#if flixel
import flixel.FlxG;
import haxe.io.Bytes;
import haxe.io.Path;
import hxvlc.externs.Types;
import hxvlc.openfl.Video;
import hxvlc.util.Location;
import hxvlc.util.macros.DefineMacro;
import openfl.utils.Assets;
import sys.FileSystem;

using StringTools;

/**
 * A wrapper class for displaying video files in HaxeFlixel using the `Video` class.
 */
class FlxInternalVideo extends Video
{
	/** The volume adjustment. */
	public var volumeAdjust(default, set):Float = 1.0;

	@:noCompletion
	private var resumeOnFocus:Bool = false;

	/**
	 * Initializes a FlxVideo object.
	 * 
	 * @param smoothing Whether or not the video is smoothed when scaled.
	 */
	public function new(smoothing:Bool = true):Void
	{
		super(smoothing);

		onOpening.add(function():Void
		{
			role = LibVLC_Role_Game;

			if (!FlxG.signals.focusGained.has(onFocusGained))
				FlxG.signals.focusGained.add(onFocusGained);

			if (!FlxG.signals.focusLost.has(onFocusLost))
				FlxG.signals.focusLost.add(onFocusLost);

			#if (FLX_SOUND_SYSTEM && flixel >= version("5.9.0"))
			if (!FlxG.sound.onVolumeChange.has(onVolumeChange))
				FlxG.sound.onVolumeChange.add(onVolumeChange);
			#elseif (FLX_SOUND_SYSTEM && flixel < version("5.9.0"))
			if (!FlxG.signals.postUpdate.has(onVolumeUpdate))
				FlxG.signals.postUpdate.add(onVolumeUpdate);
			#end

			onVolumeChange(#if FLX_SOUND_SYSTEM (FlxG.sound.muted ? 0 : 1) * FlxG.sound.volume #else 1 #end);
		});
	}

	/**
	 * Loads a video.
	 * 
	 * @param location The local filesystem path, the media location URL, the ID of an open file descriptor, or the bitstream input.
	 * @param options Additional options to add to the LibVLC Media.
	 * @return `true` if the video loaded successfully, `false` otherwise.
	 */
	public override function load(location:Location, ?options:Array<String>):Bool
	{
		if (location != null && !(location is Int) && !(location is Bytes) && (location is String))
		{
			final location:String = cast(location, String);

			if (!Video.URL_VERIFICATION_REGEX.match(location))
			{
				final absolutePath:String = FileSystem.absolutePath(location);

				if (FileSystem.exists(absolutePath))
					return super.load(absolutePath, options);
				else if (Assets.exists(location))
				{
					final assetPath:Null<String> = Assets.getPath(location);

					if (assetPath != null)
					{
						if (FileSystem.exists(assetPath) && Path.isAbsolute(assetPath))
							return super.load(assetPath, options);
						else if (FileSystem.exists(assetPath) && !Path.isAbsolute(assetPath))
							return super.load(FileSystem.absolutePath(assetPath), options);
						else if (!Path.isAbsolute(assetPath))
						{
							try
							{
								final assetBytes:Bytes = Assets.getBytes(location);

								if (assetBytes != null)
									return super.load(assetBytes, options);
							}
							catch (e:Dynamic)
							{
								FlxG.log.error('Error loading asset bytes from location "$location": $e');

								return false;
							}
						}
					}

					return false;
				}
				else
				{
					FlxG.log.warn('Unable to find the video file at location "$location".');

					return false;
				}
			}
		}

		return super.load(location, options);
	}

	/**
	 * Adds a slave to the current media player.
	 * 
	 * @param type The slave type.
	 * @param uri URI of the slave (should contain a valid scheme).
	 * @param select `true` if this slave should be selected when it's loaded.
	 * @return `true` on success, `false` otherwise.
	 */
	public override function addSlave(type:Int, location:String, select:Bool):Bool
	{
		function convertAbsToURL(str:String):String
		{
			final normalizedPath:String = Path.normalize(str);

			if (!normalizedPath.startsWith('/'))
				return 'file:///$normalizedPath';
			else
				return 'file://$normalizedPath';
		}

		if (!Video.URL_VERIFICATION_REGEX.match(location))
		{
			final absolutePath:String = FileSystem.absolutePath(location);

			if (FileSystem.exists(absolutePath))
				return super.addSlave(type, convertAbsToURL(absolutePath), select);
			else if (Assets.exists(location))
			{
				final assetPath:Null<String> = Assets.getPath(location);

				if (assetPath != null)
				{
					if (FileSystem.exists(assetPath) && Path.isAbsolute(assetPath))
						return super.addSlave(type, convertAbsToURL(assetPath), select);
					else if (FileSystem.exists(assetPath) && !Path.isAbsolute(assetPath))
						return super.addSlave(type, FileSystem.absolutePath(assetPath), select);
				}

				return false;
			}
		}

		return super.addSlave(type, location, select);
	}

	/** Frees the memory that is used to store the Video object. */
	public override function dispose():Void
	{
		if (FlxG.signals.focusGained.has(onFocusGained))
			FlxG.signals.focusGained.remove(onFocusGained);

		if (FlxG.signals.focusLost.has(onFocusLost))
			FlxG.signals.focusLost.remove(onFocusLost);

		#if (FLX_SOUND_SYSTEM && flixel >= version("5.9.0"))
		if (FlxG.sound.onVolumeChange.has(onVolumeChange))
			FlxG.sound.onVolumeChange.remove(onVolumeChange);
		#elseif (FLX_SOUND_SYSTEM && flixel < version("5.9.0"))
		if (FlxG.signals.postUpdate.has(onVolumeUpdate))
			FlxG.signals.postUpdate.remove(onVolumeUpdate);
		#end

		super.dispose();
	}

	@:noCompletion
	private function onFocusGained():Void
	{
		#if !mobile
		if (!FlxG.autoPause)
			return;
		#end

		if (resumeOnFocus)
		{
			resumeOnFocus = false;

			resume();
		}
	}

	@:noCompletion
	private function onFocusLost():Void
	{
		#if !mobile
		if (!FlxG.autoPause)
			return;
		#end

		resumeOnFocus = isPlaying;

		pause();
	}

	#if (FLX_SOUND_SYSTEM && flixel < version("5.9.0"))
	@:noCompletion
	private function onVolumeUpdate():Void
	{
		onVolumeChange(#if FLX_SOUND_SYSTEM (FlxG.sound.muted ? 0 : 1) * FlxG.sound.volume #else 1 #end);
	}
	#end

	@:noCompletion
	private function onVolumeChange(vol:Float):Void
	{
		final currentVolume:Int = Math.floor((vol * DefineMacro.getFloat('HXVLC_FLIXEL_VOLUME_MULTIPLIER', 125)) * volumeAdjust);

		if (volume != currentVolume)
			volume = currentVolume;
	}

	@:noCompletion
	private function set_volumeAdjust(value:Float):Float
	{
		onVolumeChange(#if FLX_SOUND_SYSTEM (FlxG.sound.muted ? 0 : 1) * FlxG.sound.volume #else 1 #end);

		return volumeAdjust = value;
	}
}
#end
