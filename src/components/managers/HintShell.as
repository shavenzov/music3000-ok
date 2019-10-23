package components.managers
{
	import components.managers.events.HintEvent;
	
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	
	import mx.core.UIComponent;
	import mx.core.mx_internal;
	import mx.effects.Tween;
	
	public class HintShell extends EventDispatcher
	{
		public static const FADE_IN  : int = 2;
		public static const FADE_OUT : int = 4;
		public static const SHOWED   : int = 6;
		
		//анимационный tween
		private var _tween : Tween;
		//Время раскрытия/скрытия
		public var time  : Number = 500.0;
		/**
		 * Время отображения подсказки 
		 */		
		public var delayTime : Number = 2000.0;
		
		/**
		 * Текущий статус подсказки 
		 */		
		private var _status : int;
		
		/**
		 * Клиент эффекта 
		 */		
		private var _client : UIComponent;
		
		/**
		 * Должен ли пользователь взаимодействовать с подсказкой 
		 */		
		private var mouseInteraction : Boolean;
		
		public function HintShell( client : UIComponent, mouseInteraction : Boolean )
		{
			super();
			_client = client;
			
			this.mouseInteraction = mouseInteraction;
			
			if ( mouseInteraction )
			{
				client.addEventListener( MouseEvent.ROLL_OVER, onClientRollOver );
				client.addEventListener( MouseEvent.ROLL_OUT, onClientRollOut );
			}
			
			_client.alpha = 0.0;
			show();
		}
		
		private var mouseRollOver : Boolean;
		
		private function onClientRollOver( e : MouseEvent ) : void
		{
			mouseRollOver = true;
		}
		
		private function onClientRollOut( e : MouseEvent ) : void
		{
		   mouseRollOver = false;	
		}
		
		public function get client() : UIComponent
		{
			return _client;
		}
		
		private var _toolTip : String;
		private var _errorString : String;
		private var _target : UIComponent;
		
		public function get target() : UIComponent
		{
			return _target;
		}
		
		public function set target( value : UIComponent):void
		{
			if ( _target )
			{
				_target.toolTip = _toolTip;
				_target.errorString = _errorString;
			}
			
			if ( value )
			{
				_toolTip = value.toolTip;
				_errorString = value.errorString;
				
				value.toolTip = null;
				value.errorString = null;	
			}
			else
			{
				_toolTip = null;
				_errorString = null;
			}
			
			
			_target = value;
		}
		
		public function show() : void
		{
			setStatus( FADE_IN );
		}
		
		public function hide() : void
		{
			if ( _status != FADE_OUT )
			{
				setStatus( FADE_OUT );
			}	
		}	
	
		private function setStatus( status : int ) : void
		{
			_status = status;
			_client.callLater( update );
		}
		
		private function update() : void
		{
			if ( _tween )
			{
				_tween.stop();
				_tween = null;
			}	
			
			if ( _status == FADE_IN )
			{
				_tween = new Tween( this, _client.alpha, 1.0, time );
			}
			else if ( _status == FADE_OUT )
			{
				_tween = new Tween( this, _client.alpha, 0.0, time );
			}
			else if ( _status == SHOWED )
			{
				_tween = new Tween( this, 0, delayTime, delayTime );
			}
		}
		
		mx_internal function onTweenUpdate(value:Number):void
		{
			if ( _status == FADE_IN || _status == FADE_OUT )
			{
				_client.alpha = value;
			}
		}
		
		mx_internal function onTweenEnd( value:Number ) : void
		{
			if ( _status == FADE_IN )
			{
				setStatus( SHOWED );
			}
			else if ( _status == SHOWED )
			{
				if ( mouseRollOver ) setStatus( SHOWED );
				 else setStatus( FADE_OUT );	
			}
			else if ( _status == FADE_OUT )
			{
				if ( mouseInteraction )
				{
					client.removeEventListener( MouseEvent.ROLL_OVER, onClientRollOver );
					client.removeEventListener( MouseEvent.ROLL_OUT, onClientRollOut );
				}
				
				dispatchEvent( new HintEvent( HintEvent.HIDE ) );
			}	
		}
	}
}