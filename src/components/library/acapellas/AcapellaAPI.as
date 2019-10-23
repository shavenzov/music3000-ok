package components.library.acapellas
{
	import classes.api.AMFApi;
	import classes.api.CustomEventDispatcher;
	import classes.api.MainAPI;
	import classes.api.MainAPIImplementation;
	
	import components.library.acapellas.events.TagEvent;
	import components.library.events.DataEvent;
		
	public class AcapellaAPI extends CustomEventDispatcher
	{
		public static const DEFAULT_PAGE_SIZE : int = 20;
		private static const DEFAULT_ORDER_BY  : String = 'date';
		
		private var api : MainAPIImplementation;
		
		public function AcapellaAPI()
		{
			super();
			api = MainAPI.impl;
		}
				
		private function onTagGCResult( responds : Object ) : void
		{
			var genres     : Array = responds.genres != undefined ? Settings.processGenres( responds.genres ) : null;
			var genders    : Array = responds.genders != undefined ? responds.genders : null;
			var tempos     : Array = responds.tempos != undefined ? responds.tempos : null;
			var keys       : Array = responds.keys != undefined ? responds.keys : null;
			var styles     : Array = responds.styles != undefined ? responds.styles : null;
			var autotunes  : Array = responds.autotunes != undefined ? responds.autotunes : null;
			
			dispatchEvent( new TagEvent( TagEvent.TAG_COMPLETE, genres, genders, tempos, keys, styles, autotunes ) );
		}
		
		private function onDataResult( responds : Object ) : void
		{
		    if ( responds == null )
			{	
				dispatchEvent( new DataEvent( DataEvent.DATA_COMPLETE, [], 0 ) );
				return;
			}
				
			dispatchEvent( new DataEvent( DataEvent.DATA_COMPLETE, responds.data, responds.count ) );	
		}
		
		public function getSearchParams( params : Object = null, getGenres : Boolean = true, getGenders : Boolean = true, getTempos : Boolean = true, getKeys : Boolean = true, getStyles : Boolean = true, getAutoTunes : Boolean = true ) : void
		{
			api.call( 'Acapella.getSearchParams', onTagGCResult, params, getGenres, getGenders, getTempos, getKeys, getStyles, getAutoTunes );
		}
		
		public function search( params : Object = null ) : void
		{
			api.call( 'Acapella.search', onDataResult, params );
		}
		
		public function getInfo( ids : Array ) : void
		{
			api.call( 'Acapella.getInfo', onDataResult, ids );
		}
	}
}
