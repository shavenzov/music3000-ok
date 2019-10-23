package classes.tasks.initilization
{
	import classes.api.MainAPI;
	import classes.api.MainAPIImplementation;
	import classes.api.events.BrowseProjectEvent;
	import classes.api.events.InviteFriendsEvent;
	import classes.api.events.OrderUserListEvent;
	import classes.api.events.UserEvent;
	import classes.api.social.ok.OKApi;
	import classes.api.social.ok.events.ApiCallbackEvent;
	import classes.api.social.ok.events.ApiServerEvent;
	import classes.api.social.ok.sdk.friends.Friends;
	import classes.api.social.ok.sdk.users.Users;
	
	import com.serialization.Serialize;
	import com.thread.SimpleTask;
	import com.utils.DateUtils;
	import com.utils.TimeUtils;
	
	import flash.display.Stage;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	
	public class InitializationTask extends SimpleTask
	{
		public static const INITIALIZING_OK_API : int = 5;
		public static const SETTING_APP_HEIGHT  : int = 6;
		public static const GETTING_APP_USERS   : int = 7;
		public static const GETTING_USER_INFO   : int = 9;
		public static const LOADING_SETTINGS    : int = 10;
		public static const CONNECTING          : int = 20;
		public static const REGISTERING         : int = 30;
		public static const PROCESS_CUSTOM_PARAMS : int = 40;
		public static const ORDERING_APP_USERS  : int = 45;
		public static const BROWSING_EXAMPLES   : int = 50;
		public static const DONE                : int = 100;
		
		private var api : MainAPIImplementation;
		private var loader : URLLoader;
		
		private var stage : Stage;
		private var params : Object;
		
		public function InitializationTask( stage : Stage )
		{
			super();
			this.stage = stage;
		}
		
		override protected function next():void
		{
			switch( _status )
			{
				case SimpleTask.NONE     : initOKApi(); break;
				case INITIALIZING_OK_API : setAppHeight(); break;
				case SETTING_APP_HEIGHT  : getAppUsers(); break;
				case GETTING_APP_USERS   : getUserInfo(); break; 
				case GETTING_USER_INFO   : loadSettings(); break;
				case LOADING_SETTINGS    : configureAPI(); connect(); break;
				case CONNECTING          : if ( api.logedIn ) parseCustomParams() else register(); break;
				case REGISTERING   : parseCustomParams(); break
				case PROCESS_CUSTOM_PARAMS : orderAppUsers(); break;
				case ORDERING_APP_USERS  : browseExamples(); break;
				default : 
					 api.removeAllObjectListeners( this );
					 appUsersUIDS = null;
					 _status = SimpleTask.DONE;
					 dispatchEvent( new Event( Event.COMPLETE ) );
					 return;
			}
			
			super.next();
		}
		
		private function onOKApiInitialized( e : ApiServerEvent ) : void
		{
			OKApi.getInstance().removeAllObjectListeners( this );
			params = OKApi.params;
			next();
		}
		
		private function onOKApiInitializeConnectionError( e : ApiServerEvent ) : void
		{
			OKApi.getInstance().removeAllObjectListeners( this );
			dispatchEvent( new ErrorEvent( ErrorEvent.ERROR, false, false, 'Ошибка инициализации odnoklassniki API', 100 ) );
		}
		
		private function onOKApiInitializeProxyNotResponding( e : ApiServerEvent ) : void
		{
			OKApi.getInstance().removeAllObjectListeners( this );
			next();
		}
		
		private function initOKApi() : void
		{
			_status = INITIALIZING_OK_API;
		    
			OKApi.getInstance().addListener( ApiServerEvent.CONNECTED, onOKApiInitialized, this );
			OKApi.getInstance().addListener( ApiServerEvent.CONNECTION_ERROR, onOKApiInitializeConnectionError, this );
			OKApi.getInstance().addListener( ApiServerEvent.PROXY_NOT_RESPONDING, onOKApiInitializeProxyNotResponding, this );
			OKApi.initialize( stage );
		}
		
		private function parsePageInfo( data : String ) : Object
		{
			data = data.substring( 1, data.length - 1 );
			var values : Array = data.split( ',' );
			var result : Object = new Object();
			for each( var v : String in values )
			{
				var spl : Array = v.split( ':' );
				result[ spl[ 0 ] ] = parseFloat( spl[1] );
			}
			
			return result;
		}
		
		private function onGotPageInfo( e : ApiCallbackEvent ) : void
		{
			e.stopImmediatePropagation();
			OKApi.getInstance().removeAllObjectListeners( this );
			
			if ( e.result == 'ok' )
			{
				var pi : Object = parsePageInfo( e.data );
				OKApi.setWindowSize( Math.max( pi.clientWidth, Settings.MIN_APPLICATION_WIDTH ), Math.max( pi.clientHeight - 65, Settings.MIN_APPLICATION_HEIGHT ) );
				next();
				return;
			}
			
			dispatchEvent( new ErrorEvent( ErrorEvent.ERROR, false, false, 'Ошибка getPageInfo', 100 ) );
		}
		
		private function setAppHeight() : void
		{
			_status = SETTING_APP_HEIGHT;
			
			if ( OKApi.getInstance().session.is_connected )
			{
				OKApi.getInstance().addListener( ApiCallbackEvent.CALL_BACK, onGotPageInfo, this, 1000 );
				OKApi.getPageInfo();
			}
			else
			{
				next();
			}
		}
		
		private function onDoUserInvited( e : InviteFriendsEvent ) : void
		{
			api.removeListener( InviteFriendsEvent.DO_USER_INVITED, onDoUserInvited );
			next();
		}
		
		private function parseCustomParams() : void
		{
			_status = PROCESS_CUSTOM_PARAMS;
			
			if ( params && ( params.custom_args != undefined ) )
			{
				var param : Array = String( params.custom_args ).split( '=' );
				
				if ( param[ 0 ] == InviteFriendsEvent.PARAM_NAME )
				{
					api.addListener( InviteFriendsEvent.DO_USER_INVITED, onDoUserInvited, this );
					api.doUserInvitedAction( params.logged_user_id, parseInt( param[ 1 ] ) );
				    return;
				}
			}
			
			next();
		}
		
		private var appUsersUIDS : Array;
		
		private function onGotAppUsers( data : Object ) : void
		{
			if ( data.uids )
			{
				appUsersUIDS = data.uids;
			}
			else
			{
				dispatchEvent( new ErrorEvent( ErrorEvent.ERROR, false, false, "OK api getAppUsers error", 100 ) );
				return;
			}
			
			next();
		}
		
		private function getAppUsers() : void
		{
			_status = GETTING_APP_USERS;
			
			if ( OKApi.getInstance().session.is_connected )
			{
				Friends.getAppUsers( onGotAppUsers ); 
			}
			else
			{
				next();
			}
		}
		
		private function onAppUsersOrdered( e : OrderUserListEvent ) : void
		{
		  api.removeListener( OrderUserListEvent.ORDER_USER_LIST, onAppUsersOrdered );
			
		  var orderedUsers : Array = new Array();
		  
		  for ( var i : int = 0; i < e.orderedList.length; i ++ )
		  {
			  for ( var j : int = 0; j < OKApi.appUsers.length; j ++ )
			  {
				  if ( OKApi.appUsers[ j ].uid == e.orderedList[ i ].uid )
				  {
					orderedUsers.push( OKApi.appUsers[ j ] ); 
					break;    
				  }
			  }
		  }
		  
		  OKApi.appUsers = orderedUsers;
		  
		  next();
		}
		
		private function orderAppUsers() : void
		{
			_status = ORDERING_APP_USERS;
			
			if ( appUsersUIDS && appUsersUIDS.length > 0 )
			{
				api.addListener( OrderUserListEvent.ORDER_USER_LIST, onAppUsersOrdered, this );
				api.orderUserList( appUsersUIDS );
			}
			else
			{
				next();
			}
		}
		
		private function onGotUserInfo( data : Object ) : void
		{
			if ( data.length == 0 )
			{
				dispatchEvent( new ErrorEvent( ErrorEvent.ERROR, false, false, "Can't find current user info", 100 ) );
				return;
			}
			
			for ( var i : int = 0; i < data.length; i ++ )
			{
				if ( data[ i ].uid == params.logged_user_id )
				{
					OKApi.userInfo = data.splice( i, 1 )[0];
					break;
				}
			}
			
			OKApi.appUsers = data as Array;
			
			next();
		}
		
		private function getUserInfo() : void
		{
			_status = GETTING_USER_INFO;
			
			if ( OKApi.getInstance().session.is_connected )
			{
				appUsersUIDS.push( params.logged_user_id ); //Так-же запрашиваем информацию о текущем пользователе
				
				Users.getInfo( appUsersUIDS, [ 'uid', 'first_name', 'last_name', 'name', 'pic_1' ], onGotUserInfo ); // getCurrentUser( onGotUserInfo );
			}
			else
			{
				OKApi.userInfo = { uid : 0, first_name : 'Иван', last_name : 'Петричко', name : 'Petrichko', pic_1 : 'http://cs418317.vk.me/v418317102/352b/SmJmqk-FPk0.jpg' };
				next();
			}
		}
		
		private function configureAPI() : void
		{
			api = MainAPI.impl;
			api.addListener( ErrorEvent.ERROR, onAPIError, this, 1000 );
		}
		
		private function onAPIError( e : ErrorEvent ) : void
		{
			dispatchEvent( e );
			e.stopImmediatePropagation();
		}
		
		private function onConnect( e : UserEvent ) : void
		{
			api.removeListener( UserEvent.CONNECT, onConnect );
			next();
		}
		
		private function connect() : void
		{
			_status = CONNECTING;
			api.addListener( UserEvent.CONNECT, onConnect, this );
			
			api.connect( params ? params.logged_user_id : '0' );
		}
		
		private function onRegister( e : UserEvent ) : void
		{
			api.removeListener( UserEvent.REGISTER, onRegister );
			
			if ( ! api.logedIn )
			{
				dispatchEvent( new ErrorEvent( ErrorEvent.ERROR, false, false, "Can't register new user :(", 1000 ) );
			}
			else
			{
				next();
			}
		}
		
		private function register() : void
		{
			_status = REGISTERING;
			api.addListener( UserEvent.REGISTER, onRegister, this );
			api.register( params ? params.logged_user_id : '0' );
		}
		
		private function onBrowseExamples( e : BrowseProjectEvent ) : void
		{
			api.removeListener( BrowseProjectEvent.BROWSE_EXAMPLES, onBrowseExamples );
			next();
		}
		
		private function browseExamples() : void
		{
			_status = BROWSING_EXAMPLES;
			
			api.addListener( BrowseProjectEvent.BROWSE_EXAMPLES, onBrowseExamples, this );
			api.browseExamples();
		}
		
		private function onLoadingSettingsComplete( e : Event ) : void
		{
			removeLoaderListeners();
			
			Settings.parseSettings( new XML( loader.data ) );
			Settings.loaded = true; //Сообщаем что настройки загружены
			Settings.notifier.dispatchEvent( new Event( Event.CHANGE ) ); //Посылаем сообщение об изменении настроек
			loader = null;
			next();
		}
		
		private function onLoadingSettingsError( e : IOErrorEvent ) : void
		{
			removeLoaderListeners();
			dispatchEvent( new ErrorEvent( ErrorEvent.ERROR, false, false, e.text, e.errorID ) );
			loader = null;
		}
		
		private function removeLoaderListeners() : void
		{
			loader.removeEventListener( Event.COMPLETE, onLoadingSettingsComplete );
			loader.removeEventListener( IOErrorEvent.IO_ERROR, onLoadingSettingsError );
		}
		
		private function loadSettings() : void
		{
			_status = LOADING_SETTINGS;
			
			loader = new URLLoader();
			loader.addEventListener( Event.COMPLETE, onLoadingSettingsComplete );
			loader.addEventListener( IOErrorEvent.IO_ERROR, onLoadingSettingsError );
			loader.load( new URLRequest( 'data.xml' ) );
		}
	}
}