package hxvlc.openfl.textures;

import openfl.display.BitmapData;
import openfl.display3D.Context3D;
import openfl.display3D.textures.TextureBase;

using StringTools;

/**
 * This class is a video texture that extends TextureBase for efficient video frame rendering.
 * 
 * @see https://github.com/openfl/openfl/blob/develop/src/openfl/display3D/textures/RectangleTexture.hx
 * @see https://github.com/openfl/openfl/blob/3f24568a1dec5d971e167836ea84846607a86e9c/lib/draft-api/src/openfl/media/_internal/NativeVideoBackend.cpp#L500
 */
@:access(openfl.display3D.Context3D)
class VideoTexture extends TextureBase
{
	/**
	 * Initializes a VideoTexture object.
	 * 
	 * @param context The context to use for texture operations.
	 * @param bitmapData Initial bitmap data to populate the texture.
	 * @param optimizeForRenderToTexture Whether to optimize this texture for render-to-texture operations (used by default).
	 */
	public function new(context:Context3D, bitmapData:BitmapData, optimizeForRenderToTexture:Bool = true):Void
	{
		super(context);

		__width = bitmapData.width;
		__height = bitmapData.height;
		__optimizeForRenderToTexture = optimizeForRenderToTexture;
		__textureTarget = __context.gl.TEXTURE_2D;

		@:nullSafety(Off)
		{
			__context.__bindGLTexture2D(__textureID);

			__context.gl.texImage2D(__textureTarget, 0, __internalFormat, __width, __height, 0, __format, __context.gl.UNSIGNED_BYTE, bitmapData.image?.data);

			__context.__bindGLTexture2D(null);
		}

		if (optimizeForRenderToTexture)
			__getGLFramebuffer(true, 0, 0);
	}

	/**
	 * Updates the texture content with new data from a typed array.
	 * 
	 * This method is typically used for uploading new video frames efficiently.
	 * 
	 * @param data The new pixel data.
	 */
	public function uploadFromTypedArray(data:lime.utils.ArrayBufferView):Void
	{
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
