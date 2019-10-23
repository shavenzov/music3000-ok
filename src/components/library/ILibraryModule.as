package components.library
{
	import flash.display.DisplayObject;

	public interface ILibraryModule
	{
		function get mainComponent() : DisplayObject;
		function get searchText() : String;
		function set searchText( value : String ) : void;
		function get searchBoxEnabled() : Boolean;
		function search() : void;
		function reset() : void;
	}
}