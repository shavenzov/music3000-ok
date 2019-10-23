package classes.api
{
	import classes.api.events.MessageEvent;
	import classes.api.events.ServerSyncEvent;
	import classes.api.events.ServerUpdateEvent;
	import classes.api.events.UserEvent;
	
	import com.serialization.Serialize;
	
	import flash.utils.clearInterval;
	import flash.utils.getTimer;
	import flash.utils.setInterval;

	public class SynchroAPI extends SessionAPI
	{
		/**
		 * Интервал синхронизации клиента с сервером 
		 */		
		private static const SYNCHRO_INTERVAL : Number = 5000;
		
		/**
		 * Идет процесс обновления 
		 */		
		private var updating : Boolean;
		/**
		 * Общее количество секунд прошедших с момента запуска клиента 
		 */		
		private var time : int;
		
		public function SynchroAPI()
		{
			super();
			
			time = getTimer();
			
			addListener( UserEvent.CONNECT, onUserLogedIn, this, 1000 );
			addListener( UserEvent.REGISTER, onUserLogedIn, this, 1000 );
		}
		
		private var timer_id : int = -1;
		
		private function startTimer() : void
		{
			if ( timer_id == -1 )
			{
				timer_id = setInterval( sync, SYNCHRO_INTERVAL );
			}
		}
		
		private function stopTimer() : void
		{
			if ( timer_id != -1 )
			{
				clearInterval( timer_id );
				timer_id = -1;
			}
		}
		
		private function onUserLogedIn( e : UserEvent ) : void
		{
			stopTimer();
			startTimer();
		}
		
		private function sync() : void
		{
			stopTimer();
			
			if ( ! updating ) //Во время обновления не считаем время пользователя
			{
				time = getTimer() / 1000.0;
			}
			
			_touch( time );
		}
		
		private function onTouched( responds : Object ) : void
		{
			//Проверка на обновление информации 
			if ( responds.data != undefined )
			{
				//Обновляется информация о пользователе
				if ( responds.data.users != undefined )
				{
					updateUserInfo( responds.data.users );
				}
			}
			
			//Проверка на новые сообщения
			if ( responds.message != undefined )
			{
				dispatchEvent( new MessageEvent( MessageEvent.MESSAGE, responds.message ) );
			}
			
			//Проверка на наличие серверного обновления
			if ( updating )
			{
				if ( responds.update == 0 )
				{
					updating = false;
					dispatchEvent( new ServerUpdateEvent( ServerUpdateEvent.END_UPDATE ) );
				}
			}
			else if ( responds.update == 1 )
			{
				updating = true;
				dispatchEvent( new ServerUpdateEvent( ServerUpdateEvent.START_UPDATE, Serialize.timeStampToDate( responds.end ), responds.reason ) );	
			}
			
			startTimer();
			
			dispatchEvent( new ServerSyncEvent( ServerSyncEvent.SYNC ) );
		}
		
		private function _touch( time : int ) : void
		{
			call( 'API.touch', onTouched, time );
		}
		
		public function touch() : void
		{
			sync();
		}
	}
}