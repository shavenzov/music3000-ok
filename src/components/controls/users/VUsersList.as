package components.controls.users
{
	import classes.api.social.ok.OKApi;
	import classes.api.social.ok.events.ApiCallbackEvent;
	
	import flash.events.Event;
	
	import mx.containers.BoxDirection;

	public class VUsersList extends HUsersList
	{
		public function VUsersList()
		{
			super();
			direction = BoxDirection.VERTICAL;
		}
		
		override protected function onAddedToStage(e:Event):void
		{
			OKApi.getInstance().addListener( ApiCallbackEvent.CALL_BACK, onCloseInviteBox, this, 1000 );
		}
		
		override protected function onCloseInviteBox(e:ApiCallbackEvent):void
		{
			if ( e.method == 'showInvite' )
			{
				super.onCloseInviteBox( e );
				e.stopImmediatePropagation();
			}
		}
	}
}