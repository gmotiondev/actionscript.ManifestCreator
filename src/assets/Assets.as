//------------------------------------------------------------------------------
//
//	Copyright 2015 
//	Michael Heier 
//
//------------------------------------------------------------------------------

package assets
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.utils.Dictionary;

	public class Assets
	{

		//=================================
		// public static properties 
		//=================================

		[Embed( source = "assets/images/remove_icon_20x20.png" )]
		public static const REMOVE_ICON : Class;

		//=================================
		// protected static properties 
		//=================================

		protected static var _bitmapDataCache : Dictionary;

		//=================================
		// public static methods 
		//=================================

		public static function getBitmapData( name : String ) : BitmapData
		{
			if( !name )
				return null;

			if( !_bitmapDataCache )
				_bitmapDataCache = new Dictionary();

			if( _bitmapDataCache[ name ] )
				return _bitmapDataCache[ name ];
			else if( Class( Assets ).hasOwnProperty( name ) )
			{
				var bm : Bitmap = new Assets[ name ]();

				if( !bm )
				{
					trace( "Asset" , name , "is not an image" );
					return null;
				}

				_bitmapDataCache[ name ] = bm.bitmapData;
				return _bitmapDataCache[ name ];
			}

			trace( "Asset" , name , "not found" );
			return null;
		}
	}
}
