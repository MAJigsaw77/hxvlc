package hxvlc.util;

import hxvlc.externs.LibVLC;
import hxvlc.externs.Types;

/**
 * Represents an audio output module in libVLC.
 */
class AudioOutput
{
	/**
	 * Name of the audio output module.
	 */
	public var name:String;

	/**
	 * Description of the audio output module.
	 */
	public var description:String;

	/**
	 * Creates a new instance of AudioOutput with default values.
	 */
	public function new():Void
	{
		this.name = '';
		this.description = '';
	}

	/**
	 * Returns a string representation of the AudioOutput object.
	 *
	 * @return A string containing the name and description of the AudioOutput object.
	 */
	@:keep
	public function toString():String
	{
		final parts:Array<String> = [];
		parts.push('Name: $name');
		parts.push('Description: $description');
		return parts.join('\n');
	}

	/**
	 * Constructs a list of AudioOutput objects from a raw libVLC audio output list.
	 *
	 * @param audio_output_list A pointer to the first libvlc_audio_output_t structure.
	 * @return An array of AudioOutput objects populated with the provided audio output information.
	 */
	@:unreflective
	public static function fromAudioOutputList(audio_output_list:cpp.RawPointer<LibVLC_Audio_Output_T>):Array<AudioOutput>
	{
		final list:Array<AudioOutput> = [];

		if (audio_output_list != null)
		{
			var temp:cpp.RawPointer<LibVLC_Audio_Output_T> = audio_output_list;

			while (temp != null)
			{
				var output:AudioOutput = new AudioOutput();
				output.name = new String(untyped temp[0].psz_name);
				output.description = new String(untyped temp[0].psz_description);
				list.push(output);

				temp = temp[0].p_next;
			}

			LibVLC.audio_output_list_release(audio_output_list);
		}

		return list;
	}
}
