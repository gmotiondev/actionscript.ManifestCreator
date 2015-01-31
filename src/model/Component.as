//------------------------------------------------------------------------------
//
//	Copyright 2015 
//	Michael Heier 
//
//------------------------------------------------------------------------------

package model
{
	import flash.filesystem.File;

	public class Component
	{

		//=================================
		// constructor 
		//=================================

		public function Component( file : File , id : String , clazz : String , lookupOnly : Boolean = false )
		{
			this.file = file;
			this.id = id;
			this.clazz = clazz;
			this.lookupOnly = lookupOnly;
		}


		//=================================
		// public properties 
		//=================================

		public var clazz : String;

		public var file : File;

		public var id : String;

		public var lookupOnly : Boolean;
	}
}
