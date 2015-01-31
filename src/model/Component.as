//------------------------------------------------------------------------------
//
//	Copyright 2015 
//	Michael Heier 
//
//------------------------------------------------------------------------------

package model
{
	public class Component
	{

		//=================================
		// constructor 
		//=================================

		public function Component( file : FileItem , id : String , clazz : String , lookupOnly : Boolean = false )
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

		public var file : FileItem;

		public var id : String;

		public var lookupOnly : Boolean;
	}
}
