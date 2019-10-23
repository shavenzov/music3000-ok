package components.controls.users
{
	import classes.api.MainAPI;
	import classes.api.events.InviteFriendsEvent;
	import classes.api.social.ok.OKApi;
	import classes.api.social.ok.events.ApiCallbackEvent;
	
	import components.managers.PopUpManager;
	
	import flash.events.Event;
	
	import mx.collections.ArrayCollection;
	import mx.core.ClassFactory;
	import mx.core.FlexGlobals;
	import mx.events.FlexEvent;
	
	import spark.events.IndexChangeEvent;

	public class HUsersList extends ScrollableList
	{
		public function HUsersList()
		{
			super();
			
			itemRendererFunction = selectRenderer;
			
			var items : Array = [ { invite : 'inviteItem' }, OKApi.userInfo ];
			
			if ( OKApi.appUsers && ( OKApi.appUsers.length > 0 ) )
			{
				items = items.concat( OKApi.appUsers );	
			}
			
			//Пригласить друга
			//items.push( { invite : 'inviteItem' } );
			
			
			dataProvider = new ArrayCollection( items );
			selectedIndex = 1;
			
			addEventListener( IndexChangeEvent.CHANGING, onIndexChanging );
			addEventListener( Event.ADDED_TO_STAGE, onAddedToStage );
			addEventListener( Event.REMOVED_FROM_STAGE, onRemovedFromStage );
			
			focusEnabled = false;
			
			addEventListener( FlexEvent.CREATION_COMPLETE, onCreationComplete );
		}
		
		private function onCreationComplete( e : FlexEvent ) : void
		{
			if ( ! focusManager )
			{
				focusManager = FlexGlobals.topLevelApplication.focusManager;
			}
		}
		
		protected function onAddedToStage( e : Event ) : void
		{
			OKApi.getInstance().addListener( ApiCallbackEvent.CALL_BACK, onCloseInviteBox, this );
		}
		
		protected function onRemovedFromStage( e : Event ) : void
		{
			OKApi.getInstance().removeAllObjectListeners( this );
		}
		
		private function onIndexChanging( e : IndexChangeEvent ) : void
		{
			//Шелкнули на кнопке "Пригласить друзей"
			if ( e.newIndex == 0/*( dataProvider.length - 1 )*/ )
			{
				e.preventDefault();
				OKApi.showInvite( 'Привет :) Давай вместе создавать классную музыку в Музыкальном Конструкторе.', InviteFriendsEvent.PARAM_NAME + '=' + MainAPI.impl.userInfo.id );		
			}
		}
		
		private function onFriendsInvited( e : InviteFriendsEvent ) : void
		{
			PopUpManager.hideLoading();
			MainAPI.impl.removeAllObjectListeners( this );
		}
		
		protected function onCloseInviteBox( e : ApiCallbackEvent ) : void
		{
			if ( e.method == 'showInvite' )
			{
				if ( e.result == 'ok' )
				{
					var uids : Array = String( e.data ).split( ',' );
					
					MainAPI.impl.addListener( InviteFriendsEvent.INVITE_FRIENDS, onFriendsInvited, this );
					MainAPI.impl.inviteFriends( uids );
					PopUpManager.showLoading( 'Отправка приглашений...' );
				}
			}
		}
		
		private function selectRenderer( item : Object ) : ClassFactory
		{
			if ( item.invite )
			{
				return InviteItemRenderer;
			}
			
			return UserItemRenderer;
		}
		
		private static const UserItemRenderer   : ClassFactory = new ClassFactory( UserItem );
		private static const InviteItemRenderer : ClassFactory = new ClassFactory( InviteUserItem );
	}
}