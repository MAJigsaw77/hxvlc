package hxvlc.openfl;

import lime.utils.UInt8Array;

import openfl.display3D.Context3D;
import openfl.display3D.textures.TextureBase;

/** This class is a texture that extends TextureBase for efficient video frame rendering. */
@:access(openfl.display3D.Context3D)
class Texture extends TextureBase
{
	@:noCompletion
	private var __frameSize:Int = 0;

	/**
	 * Initializes a Texture object.
	 * 
	 * @param context The context to use for texture operations.
	 * @param width The width dimension to allocate for the texture.
	 * @param height The height dimension to allocate for the texture.
	 */
	public function new(context:Context3D, width:Int, height:Int):Void
	{
		super(context);

		__width = width;
		__height = height;
		__textureTarget = __context.gl.TEXTURE_2D;
		__frameSize = width * height * 4;

		@:nullSafety(Off)
		{
			__context.__bindGLTexture2D(__textureID);

			__context.gl.texImage2D(__textureTarget, 0, __internalFormat, __width, __height, 0, __format, __context.gl.UNSIGNED_BYTE, new UInt8Array(__frameSize));

			__context.__bindGLTexture2D(null);
		}

		__getGLFramebuffer(false, 0, 0);
	}

	/**
	 * Updates the texture content with new data from a typed array.
	 * 
	 * @param data The new pixel data.
	 */
	public function uploadFromTypedArray(data:UInt8Array):Void
	{
		if (data.length != __frameSize)
			return;

		@:nullSafety(Off)
		{
			__context.__bindGLTexture2D(__textureID);

			__context.gl.texSubImage2D(__textureTarget, 0, 0, 0, __width, __height, __format, __context.gl.UNSIGNED_BYTE, data);

			__context.__bindGLTexture2D(null);
		}
	}

	@:noCompletion
	private override function __setSamplerState(state:openfl.display._internal.SamplerState):Bool
	{
		if (super.__setSamplerState(state))
		{
			if (Context3D.__glMaxTextureMaxAnisotropy != 0)
			{
				var aniso:Int = -1;

				if (state != null && state.filter != null)
				{
					switch (state.filter)
					{
						case ANISOTROPIC2X:
							aniso = 2;
						case ANISOTROPIC4X:
							aniso = 4;
						case ANISOTROPIC8X:
							aniso = 8;
						case ANISOTROPIC16X:
							aniso = 16;
						default:
							aniso = 1;
					}
				}

				if (aniso > Context3D.__glMaxTextureMaxAnisotropy)
					aniso = Context3D.__glMaxTextureMaxAnisotropy;

				__context.gl.texParameterf(__context.gl.TEXTURE_2D, Context3D.__glTextureMaxAnisotropy, aniso);
			}

			return true;
		}

		return false;
	}
}
