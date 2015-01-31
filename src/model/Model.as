//------------------------------------------------------------------------------
//
//	Copyright 2015 
//	Michael Heier 
//
//------------------------------------------------------------------------------

package model
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	import flash.filesystem.File;
	import flash.utils.Dictionary;
	import mx.collections.ArrayCollection;
	import mx.collections.ArrayList;
	import mx.core.ClassFactory;
	import mx.core.IFactory;
	import mx.utils.ObjectUtil;
	import assets.AssetName;
	import assets.Assets;
	import renderers.IconRenderer;
	import renderers.SourceTreeItemRenderer;
	import spark.collections.Sort;

	[Bindable]
	public class Model extends EventDispatcher
	{

		//=================================
		// constructor 
		//=================================

		public function Model()
		{
			super();

			if( _instance )
				throw new Error( "An instance of Model already exists." );

			sources = new ArrayCollection( [] );
			packages = new ArrayCollection( [] );
			components = new ArrayCollection( [] );
			var sort : Sort = new Sort();
			sort.compareFunction = componentSort;
			components.sort = sort;

			_packagesMap = new Dictionary();
			_sourcesMap = new Dictionary();
			_componentsMap = new Dictionary();
		}

		//=================================
		// protected static properties 
		//=================================

		protected static var _componentRemoveIconRendererFactory : ClassFactory;

		protected static var _instance : Model = new Model();

		protected static var _sourcesSourcesTreeItemRendererFactory : ClassFactory;


		//=================================
		// public properties 
		//=================================

		public var components : ArrayCollection;

		public var componentsGridColumns : ArrayList;

		public var packages : ArrayCollection;

		public var sources : ArrayCollection;

		//=================================
		// protected properties 
		//=================================

		protected var _componentsMap : Dictionary;

		protected var _packagesMap : Dictionary;

		protected var _sourcesMap : Dictionary;

		//=================================
		// public static methods 
		//=================================

		public static function getInstance() : Model
		{
			return _instance;
		}

		//=================================
		// public methods 
		//=================================

		public function browseForSourceRoot() : void
		{
			var rootdir : File = new File();
			rootdir.addEventListener( Event.SELECT , sourceRootDir_selectHandler );
			rootdir.browseForDirectory( "select root dir" );
		}

		public function getComponentRemoveIconRendererFactory() : IFactory
		{
			if( !_componentRemoveIconRendererFactory )
			{
				_componentRemoveIconRendererFactory = new ClassFactory( IconRenderer );
				_componentRemoveIconRendererFactory.properties = { source: Assets.getBitmapData( AssetName.REMOVE_ICON_16x16 )
						, external_clickHandler: removeComponent_clickHandler };
			}

			return _componentRemoveIconRendererFactory;
		}

		public function getSourcesTreeItemRendererFactory() : IFactory
		{
			if( !_sourcesSourcesTreeItemRendererFactory )
			{
				_sourcesSourcesTreeItemRendererFactory = new ClassFactory( SourceTreeItemRenderer );
				_sourcesSourcesTreeItemRendererFactory.properties =
					{
						external_selectedChangeHandler: file_selectedChangeHandler
						, external_removeHandler: removeSource_clickHandler
					};
			}

			return _sourcesSourcesTreeItemRendererFactory;
		}

		public function sourceTreeLabelFunction( item : FileItem ) : String
		{
			if( !item )
				return "";

			if( item.isRoot )
				return item.file.nativePath;
			else
				return item.file.name;
		}

		//=================================
		// protected methods 
		//=================================

		protected function addComponents( fi : FileItem ) : void
		{
			if( !fi )
				return;

			var file : File = fi.file;

			if( file.isDirectory )
			{
				for each( var fi : FileItem in fi.children )
				{
					addComponents( fi );
				}

				return;
			}

			var id : String = file.name.replace( "." + file.extension , "" );
			var path : String = file.nativePath.replace( "." + file.extension , "" );
			var component : Component = new Component( fi , id , parseComponentPath( path ) );

			if( !_componentsMap[ file.nativePath ] )
			{
				_componentsMap[ file.nativePath ] = component;
				components.addItem( component );
			}
		}

		protected function file_selectedChangeHandler( event : Event , fi : FileItem , selected : Boolean ) : void
		{
			selected ? addComponents( fi ) : removeComponents( fi );
			components.refresh();
		}

		protected function parseDirectory( file : File ) : FileItem
		{
			if( !file )
				return null;

			var fi : FileItem = new FileItem( file );

			if( file.isDirectory )
			{
				var files : Array = file.getDirectoryListing();

				if( files && files.length > 0 )
				{
					var children : Array = [];

					for each( var f : File in files )
					{
						var nfi : FileItem = parseDirectory( f );

						if( nfi )
						{
							children.push( nfi );
							nfi.parent = fi;
						}
					}

					if( children.length > 0 )
						fi.children = new ArrayCollection( children );
				}
			}

			return fi;
		}

		protected function removeComponent_clickHandler( event : MouseEvent , component : Component ) : void
		{
			removeComponents( component.file );
		}

		protected function removeComponents( fi : FileItem ) : void
		{
			if( fi )
			{
				var file : File = fi.file;

				if( file.isDirectory )
				{
					fi.selected = false;

					for each( var cfi : FileItem in fi.children )
					{
						removeComponents( cfi );
					}
					return;
				}

				var instance : Component = _componentsMap[ file.nativePath ]

				if( instance )
				{
					components.removeItem( instance );
					instance.file.selected = false;
					delete _componentsMap[ instance.file.file.nativePath ];
				}
			}
		}

		protected function removeSource_clickHandler( event : MouseEvent , fi : FileItem ) : void
		{
			if( fi && sources )
			{
				var removed : Boolean = sources.removeItem( fi );

				if( removed )
				{
					delete _sourcesMap[ fi.file.nativePath ];
					removeComponents( fi );
				}
			}
		}

		protected function sourceRootDir_selectHandler( event : Event ) : void
		{
			var rootdir : File = event.currentTarget as File;
			rootdir.removeEventListener( Event.SELECT , sourceRootDir_selectHandler );

			if( !_sourcesMap[ rootdir.nativePath ] )
			{
				var fi : FileItem = parseDirectory( rootdir );
				fi.isRoot = true;
				_sourcesMap[ rootdir.nativePath ] = fi;
				sources.addItem( fi );
			}
		}

		//=================================
		// private methods 
		//=================================

		private function componentSort( a : Component , b : Component , col : * = null ) : int
		{
			var astr : String = a ? a.clazz : "";
			var bstr : String = b ? b.clazz : "";

			return ObjectUtil.stringCompare( astr , bstr , true );
		}

		private function parseComponentPath( nativePath : String ) : String
		{
			if( !nativePath )
				return "";

			for each( var fi : FileItem in sources )
			{
				var f : File = fi.file;

				if( nativePath.indexOf( f.nativePath ) > -1 )
				{
					var dotPath : String = nativePath.replace( f.nativePath , "" );
					dotPath = dotPath.replace( /\\/g , "." );
					dotPath = dotPath.replace( /\//g , "." );

					if( dotPath.charAt( 0 ) == "." )
						dotPath = dotPath.substring( 1 , dotPath.length );
					return dotPath;
				}
			}
			return "";
		}
	}
}
