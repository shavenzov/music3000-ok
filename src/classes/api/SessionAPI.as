package classes.api
{
	import classes.api.data.UserInfo;
	import classes.api.errors.APIError;
	import classes.api.events.UserEvent;
	
	import com.adobe.crypto.MD5;
	import com.serialization.Serialize;
	
	import mx.core.mx_internal;
	
	use namespace mx_internal;

	public class SessionAPI extends AMFApi
	{
		private static const SECRET : String = "umFAlFfSC6htif9qGuXX";
		
		/**
		 * Информация о пользователе 
		 */		
		protected var _userInfo : UserInfo;
		
		/**
		 * Пользователь зашел в программу впервые 
		 */		
		private var _firstTime : Boolean;
		
		/**
		 * Необработанный вызов в результате потери сессии
		 */		
		private var lost_call : Call;
		
		public function SessionAPI()
		{
			super();
		}
		
		public function get firstTime() : Boolean
		{
			return _firstTime;
		}
		
		public function get logedIn() : Boolean
		{
			return _userInfo != null;
		}
		
		/**
		 * Идентификатор соц сети ( для восстановления сессии )
		 */		
		private var net       : String;
		/**
		 * Идентификатор пользователя в соц сети ( для восстановления сессии ) 
		 */		
		private var netUserID : String;
		
		private function getConnectionParams( netUserID : String, net : String ) : Array
		{
			return [ 'API.connect', onConnect, net, netUserID, MD5.hash( net + netUserID + SECRET ) ];
		}
		
		/**
		 * Пытаемся незаметно перелогинится если сессия истекла и продолжить выполнение комманд 
		 * @param responds
		 * @return 
		 * 
		 */		
		override protected function beforeSuccessCall( responds : Object ) : Boolean
		{  
		   if ( responds is Number )
			{
				if ( responds == APIError.SESSION_NOT_FOUND )
				{
					lost_call = currentCall;
					
					unshiftQueue.apply( this, getConnectionParams( netUserID, net ) ); //Добавляем в очередь комманду получения сессии
					next();
					
					return false;
				}
			}
		   
			return true;
		}
		
		protected function updateUserInfo( responds : Object ) : void
		{
			var updated : Boolean;
			var lastUserInfo : UserInfo = _userInfo.clone();
			
			
			if ( responds.money != undefined )
			{
				_userInfo.money       = Number( responds.money );
				updated = true;
			}
			
			if ( updated )
			{
				dispatchEvent( new UserEvent( UserEvent.UPDATE, _userInfo, lastUserInfo ) );
				trace( 'updateUserInfo' );
			}	
		}
		
		/**
		 *  
		 * @param responds
		 * @param eventType
		 * @return true, если все нормально 
		 * 
		 */		
		private function parseUserInfo( responds : Object, eventType : String ) : Boolean
		{
			if ( responds is Number )
			{
				dispatchEvent( new UserEvent( eventType, null, null, int( responds  ) ) );
				return false;
			}
			
			_userInfo = new UserInfo();
			
			
			_userInfo.registered  = Serialize.timeStampToDate( responds.registered );
			_userInfo.loged_in    = Serialize.timeStampToDate( responds.loged_in );
			_userInfo.time        = int( responds.time );
			_userInfo.money       = Number( responds.money );
			_userInfo.session_id  = String( responds.session_id );
			_userInfo.id          = int( responds.id );
			
			_userInfo.publicationPrice = Number( responds.publicationPrice );
			_userInfo.bonusPercent     = Number( responds.bonusPercent );
			_userInfo.inviteUserBonus  = Number( responds.inviteUserBonus );
			
			//Если произошло восстановление сессии,
			if ( lost_call )
			{
				lost_call.params[ 0 ] = _userInfo.session_id;
				queue.unshift( lost_call );
				
				lost_call = null;
			}
			
			dispatchEvent( new UserEvent( eventType, _userInfo ) );
			
			return true;	
		}
		
		private function onConnect( responds : Object ) : void
		{
			parseUserInfo( responds, UserEvent.CONNECT );
		}
		
		private function onRegister( responds : Object )  : void
		{
			_firstTime = true;
			parseUserInfo( responds, UserEvent.REGISTER );
		}
		
		public function connect( netUserID : String, net : String = SocialNet.OK ) : void
		{
			this.netUserID = netUserID;
			this.net       = net;
			super.call.apply( this, getConnectionParams( netUserID, net ) );
		}
		
		public function register( netUserID : String, net : String = SocialNet.OK ) : void
		{
			super.call( 'API.register', onRegister, net, netUserID, MD5.hash( net + netUserID + SECRET ) );
		}
		
		override public function call(func:String, callback:Function, ...params):void
		{
			params.unshift( func, callback, _userInfo.session_id ); //К каждому запросу добавляем идентификатор сессии
			super.call.apply( this, params );
		}
	}
}