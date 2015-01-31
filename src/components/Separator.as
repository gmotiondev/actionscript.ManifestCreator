//------------------------------------------------------------------------------
//
//	Copyright 2014 
//	Michael Heier 
//
//------------------------------------------------------------------------------

package components
{
	import spark.components.supportClasses.SkinnableComponent;

	[Style(name="lineWeight", inherit="no", type="Number")]
	[Style( name = "paddingTop" , inherit = "no" , type = "Number" )]
	[Style( name = "paddingBottom" , inherit = "no" , type = "Number" )]
	[Style( name = "paddingRight" , inherit = "no" , type = "Number" )]
	[Style( name = "paddingLeft" , inherit = "no" , type = "Number" )]
	public class Separator extends SkinnableComponent
	{

		//=================================
		// constructor 
		//=================================

		public function Separator()
		{
			super();
			setStyle( "skinClass" , SeparatorSkin );
		}
	}
}
