package components.library
{
	import flash.display.BlendMode;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	
	import mx.core.UIComponent;
	
	public class PlayerSeekBar extends UIComponent
	{
		private var thumb : Sprite;
		
		/**
		 * Текущее значение загрузки 0..1 
		 */		
		private var _progress : Number = 0.5;
		
		/**
		 * Максимальное значение 
		 */		
		private var _maxValue : Number = 100;
		
		/**
		 * Текущее значение 
		 */		
		private var _value : Number = 0;
		
		public function PlayerSeekBar()
		{
			super();
			//blendMode = BlendMode.HARDLIGHT;
		}
		
		public function get progress() : Number
		{
			return _progress;
		}
		
		public function set progress( value : Number ) : void
		{
			_progress = value;
			invalidateDisplayList();
		}
		
		public function get maxValue() : Number
		{
			return _maxValue;
		}
		
		public function set maxValue( value : Number ) : void
		{
			_maxValue = value;
			invalidateDisplayList();
		}
		
		public function get value() : Number
		{
			return _value;
		}
		
		public function set value( v : Number ) : void
		{
			_value = v;
			invalidateDisplayList();
		}
		
		public function get xValue() : Number
		{
			return ( _value * unscaledWidth ) / _maxValue
		}
		
		public function set xValue( posX : Number ) : void
		{
			value = ( _maxValue * posX ) / unscaledWidth;
		}
		
		private function onThumbRollOver( e : MouseEvent ) : void
		{
			thumb.filters = [ new GlowFilter( 0xffffff, 0.5 ) ];
		}
		
		private function onThumbRollOut( e : MouseEvent ) : void
		{
			thumb.filters = null;
		}
		
		override protected function measure():void
		{
			measuredWidth  = 250;
			measuredHeight = 0;
		}
		
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			var c : Number = unscaledHeight - 1;
			
			graphics.clear();
			/*
			graphics.lineStyle( 1.0, 0xffffff, 0.5 );
			graphics.moveTo( 0, c );
			graphics.lineTo( unscaledWidth, c );*/
			
			if ( _progress > 0 )
			{	
				graphics.lineStyle( 2.0, 0xffffff, 0.5 );
				graphics.moveTo( 0, c );
				graphics.lineTo( unscaledWidth * _progress, c );
			}
			
			thumb.x = ( ( _value * unscaledWidth ) / _maxValue ) - thumb.width / 2;
			thumb.y = -5;
		}
		
		override protected function createChildren():void
		{
			thumb = new Sprite();
			thumb.graphics.beginFill( 0xffffff );
			thumb.graphics.drawRect( 0.0, 0.0, 10.0, 5.0 );
			thumb.graphics.endFill();
			//thumb.buttonMode = true;
			//thumb.addEventListener( MouseEvent.ROLL_OVER, onThumbRollOver );
			//thumb.addEventListener( MouseEvent.ROLL_OUT, onThumbRollOut );
			
			addChild( thumb );
		}
	}
}