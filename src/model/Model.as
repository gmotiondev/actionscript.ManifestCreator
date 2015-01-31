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
	import mx.core.ClassFactory;
	import mx.core.IFactory;
	import mx.utils.ObjectUtil;
	import assets.AssetName;
	import assets.Assets;
	import renderers.IconRenderer;
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

		protected static var _packagesRemoveIconRendererFactory : ClassFactory;

		protected static var _sourcesRemoveIconRendererFactory : ClassFactory;


		//=================================
		// public properties 
		//=================================

		public var components : ArrayCollection;

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

		public function browseForFile() : void
		{
			var file : File = new File();
			file.addEventListener( Event.SELECT , file_selectHandler );
			file.browse();
		}

		public function browseForPackage() : void
		{
			var last : File = sources.getItemAt( sources.length - 1 ) as File;
			var pkg : File = new File( last.nativePath );
			pkg.addEventListener( Event.SELECT , package_selectHandler );
			pkg.browseForDirectory( "select package" );
		}

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
				_componentRemoveIconRendererFactory.properties = { source: Assets.getBitmapData( AssetName.REMOVE_ICON )
						, external_clickHandler: removeComponent_clickHandler };
			}

			return _componentRemoveIconRendererFactory;
		}

		public function getPackagesRemoveIconRendererFactory() : IFactory
		{
			if( !_packagesRemoveIconRendererFactory )
			{
				_packagesRemoveIconRendererFactory = new ClassFactory( IconRenderer );
				_packagesRemoveIconRendererFactory.properties = { source: Assets.getBitmapData( AssetName.REMOVE_ICON )
						, external_clickHandler: removePackage_clickHandler };
			}

			return _packagesRemoveIconRendererFactory;
		}

		public function getSourcesRemoveIconRendererFactory() : IFactory
		{
			if( !_sourcesRemoveIconRendererFactory )
			{
				_sourcesRemoveIconRendererFactory = new ClassFactory( IconRenderer );
				_sourcesRemoveIconRendererFactory.properties = { source: Assets.getBitmapData( AssetName.REMOVE_ICON )
						, external_clickHandler: removeSource_clickHandler };
			}

			return _sourcesRemoveIconRendererFactory;
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

		protected function addComponent( file : File ) : void
		{

			var id : String = file.name.replace( "." + file.extension , "" );
			var path : String = file.nativePath.replace( "." + file.extension , "" );
			var component : Component = new Component( file , id , parseComponentPath( path ) );

			if( !_componentsMap[ file.nativePath ] )
			{
				_componentsMap[ file.nativePath ] = component;
				components.addItem( component );
			}
		}

		protected function addPackageComponents( pkg : File ) : void
		{
			if( !pkg )
				return;

			for each( var f : File in pkg.getDirectoryListing() )
			{
				if( f.isDirectory )
				{
					addPackageComponents( f );
					continue;
				}

				addComponent( f );
			}
		}

		protected function file_selectHandler( event : Event ) : void
		{
			var file : File = event.currentTarget as File;
			file.removeEventListener( Event.SELECT , file_selectHandler );
			addComponent( file );
			components.refresh();
		}

		protected function package_selectHandler( event : Event ) : void
		{
			var pkg : File = event.currentTarget as File;

			if( !_packagesMap[ pkg.nativePath ] )
			{
				var isChild : Boolean;

				for each( var src : File in sources )
				{
					if( pkg.nativePath.indexOf( src.nativePath ) > -1 )
					{
						isChild = true;
						break;
					}
				}

				if( isChild )
				{
					_packagesMap[ pkg.nativePath ] = pkg;
					packages.addItem( pkg );

					addPackageComponents( pkg );
					components.refresh();
				}
			}
		}

		protected function parseItem( file : File ) : FileItem
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
						var nfi : FileItem = parseItem( f );

						if( nfi )
							children.push( nfi );
					}

					if( children.length > 0 )
						fi.children = new ArrayCollection( children );
				}
			}

			return fi;
		}

		protected function removeComponent( comp : Component ) : void
		{
			if( comp )
			{
				var instance : Component = _componentsMap[ comp.file.nativePath ]

				if( instance )
				{
					components.removeItem( instance );
					delete _componentsMap[ instance.file.nativePath ];
				}
			}
		}

		protected function removeComponent_clickHandler( event : MouseEvent , component : Component ) : void
		{
			removeComponent( component );

			for each( var f : File in packages )
			{
				var removePkg : Boolean = true;

				for each( var c : Component in components )
				{
					if( c.file.nativePath.indexOf( f.nativePath ) > -1 )
					{
						removePkg = false;
						break;
					}
				}

				if( removePkg )
				{
					removePackage( f );
				}
			}
		}

		protected function removePackage( pkg : File , removingComponents : Boolean = false ) : void
		{
			if( pkg )
			{
				var removed : Boolean;

				if( _packagesMap[ pkg.nativePath ] )
				{
					var pkgInstance : File = _packagesMap[ pkg.nativePath ];
					delete _packagesMap[ pkg.nativePath ];
					removed = packages.removeItem( pkgInstance );
				}

				if( removed || removingComponents )
				{

					for each( var f : File in pkg.getDirectoryListing() )
					{
						if( f.isDirectory )
						{
							removePackage( f , true );
							continue;
						}
						removeComponent( _componentsMap[ f.nativePath ] );
					}
				}
			}
		}

		protected function removePackage_clickHandler( event : MouseEvent , file : File ) : void
		{
			removePackage( file );
		}

		protected function removeSource_clickHandler( event : MouseEvent , file : File ) : void
		{
			if( file && sources )
			{
				var removed : Boolean = sources.removeItem( file );

				if( removed )
				{
					delete _sourcesMap[ file.nativePath ];

					for each( var f : File in file.getDirectoryListing() )
					{
						if( f.isDirectory )
							removePackage( f , true );
					}
				}
			}
		}

		protected function sourceRootDir_selectHandler( event : Event ) : void
		{
			var rootdir : File = event.currentTarget as File;
			rootdir.removeEventListener( Event.SELECT , sourceRootDir_selectHandler );

			if( !_sourcesMap[ rootdir.nativePath ] )
			{
				_sourcesMap[ rootdir.nativePath ] = rootdir;
				sources.addItem( rootdir );
				//var fi : FileItem = parseItem( rootdir );
				//fi.isRoot = true;
				//sources.addItem( fi );
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

			for each( var f : File in sources )
			{
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
