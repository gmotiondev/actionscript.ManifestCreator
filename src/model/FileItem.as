//------------------------------------------------------------------------------
//
//	Copyright 2014 
//	Michael Heier 
//
//------------------------------------------------------------------------------

package model
{
	import flash.filesystem.File;
	import mx.collections.ArrayCollection;

	[Bindable]
	public class FileItem
	{

		//=================================
		// constructor 
		//=================================

		public function FileItem( file : File , isRoot : Boolean = false )
		{
			this.file = file;
			this.isRoot = isRoot;
		}


		//=================================
		// public properties 
		//=================================

		public var children : ArrayCollection;
		public var file : File;
		public var isRoot : Boolean;
		public var parent : FileItem;
		public var selected : Boolean;
	}
}
