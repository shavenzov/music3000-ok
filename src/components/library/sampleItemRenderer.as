import classes.BaseDescription;
import classes.SamplePlayer;
import classes.SamplePlayerImplementation;
import classes.Sequencer;
import classes.Sources;
import classes.events.SamplePlayerEvent;

import com.audioengine.core.TimeConversion;
import com.utils.TimeUtils;

import components.library.acapellas.AcapellaToolTip;
import components.library.looperman.ItemToolTip;
import components.sequencer.VisualSampleDragDropDummy;

import flash.display.DisplayObject;
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.events.MouseEvent;
import flash.events.ProgressEvent;

import mx.core.DragSource;
import mx.core.IDataRenderer;
import mx.core.IToolTip;
import mx.events.DragEvent;
import mx.events.ToolTipEvent;
import mx.managers.DragManager;

private var player : SamplePlayerImplementation;

private function attachToPlayer() : void
{
	if ( ! player )
	{
		player = SamplePlayer.impl;
		
		addEventListener( Event.COMPLETE, onPlayerLoaded );
		addEventListener( IOErrorEvent.IO_ERROR, onPlayerIOError );
		addEventListener( ProgressEvent.PROGRESS, onPlayerProgress );
		addEventListener( Event.OPEN, onPlayerOpen );
		
		addEventListener( SamplePlayerEvent.POSITION_UPDATED, onPlayerPositionUpdated );
		player.addEventListener( SamplePlayerEvent.START_PLAYING, onStartPlaying );
		addEventListener( SamplePlayerEvent.STOP_PLAYING, onStopPlaying );
		addEventListener( Event.SOUND_COMPLETE, onSoundComplete );
		
		player.registerClient( this, data.lqurl );
	}	
}

private function detachFromPlayer() : void
{
	if ( player )
	{	
		player.unregisterClient( this );
		
		removeEventListener( Event.COMPLETE, onPlayerLoaded );
		removeEventListener( IOErrorEvent.IO_ERROR, onPlayerIOError );
		removeEventListener( ProgressEvent.PROGRESS, onPlayerProgress );
		removeEventListener( Event.OPEN, onPlayerOpen );
		
		removeEventListener( SamplePlayerEvent.POSITION_UPDATED, onPlayerPositionUpdated );
		player.removeEventListener( SamplePlayerEvent.START_PLAYING, onStartPlaying );
		removeEventListener( SamplePlayerEvent.STOP_PLAYING, onStopPlaying );
		removeEventListener( Event.SOUND_COMPLETE, onSoundComplete );
		
		player = null;
	}
}

private function onPlayerOpen( e : Event ) : void
{
	updateState( player.isPlaying );
	errorString = null;
}

private function onPlayerLoaded( e : Event ) : void
{
	onPlayerProgress( null );
}


private function showDeferred(target:DisplayObject):void {
	target.dispatchEvent(new MouseEvent(MouseEvent.MOUSE_OUT));
	target.dispatchEvent(new MouseEvent(MouseEvent.MOUSE_OVER));
}

private function _showError(target:DisplayObject) : void
{
	callLater( showDeferred, [ target ] );
}

private function onPlayerIOError( e : IOErrorEvent ) : void
{
	
		errorString = 'Не могу найти файл "' + data.name + '"';
		_showError( this );
		updateState( false );
	
}

private function onPlayerProgress( e : ProgressEvent ) : void
{
	
		seekBar.progress = player.percentLoaded;
	
}

private function onPlayerPositionUpdated( e : Event ) : void
{
	
		seekBar.value = player.position;
		sampleDuration.text = TimeUtils.formatMiliseconds( player.position );
	
}

private function onStartPlaying( e : Event ) : void
{
	if ( player.url == data.lqurl )
	{	
		updateState( true, ! player.opened );	
	}
	else
	{
		updateState( false );
		resetDuration();
	}
}

private function onStopPlaying( e : Event ) : void
{
	updateState( false );
	seekBar.value = 0;
	resetDuration();
}

private function onSoundComplete( e : Event ) : void
{
	updateState( false );
	resetDuration();
}
/*
private function onRollOver( event : MouseEvent ) : void
{	
	playButton.onRollOver();
}

private function onRollOut( event : MouseEvent ) : void
{
	playButton.onRollOut();
}
*/
private function onDoubleClick( event : MouseEvent ) : void
{
	if ( player )
	{
		if ( player.url == data.lqurl )
		{
			if ( player.isPlaying )
			{
				player.stop();
			}
		}
	}
}

private function onClick( event : MouseEvent ) : void
{
	if ( ! player )
	{
		attachToPlayer();
	}
	
	if ( player )
	{
		player.owner = this;
		
		if ( player.url == data.lqurl )
		{
			if ( player.isPlaying )
			{
				if ( event.target == playButton )
				{
					player.stop();
				}
				else
				{
					seekBar.xValue = seekBar.mouseX;
					player.position = seekBar.value;
				} 
			}
			else
			{
				player.play( data.lqurl, msDuration );
			}	
		}
		else
		{
			player.play( data.lqurl, msDuration );
		}	
	}
}

private function setSeekBarVisible( value : Boolean ) : void
{
	seekBar.includeInLayout = seekBar.visible = value;
}

private function resetDuration() : void
{
	sampleDuration.text = TimeUtils.formatSeconds( TimeConversion.numSamplesToSeconds( data.duration ) );
}

private var msDuration : Number;

override public function set data( value : Object ) : void
{
	
		if ( value )
		{
			if ( ! ( value as BaseDescription ) )
			{
				value = Sources.loadFromSource( value );
			}
		}
		
		detachFromPlayer();	
		errorString = null;
		
		super.data = value;
		
		if ( data )
		{
			attachToPlayer();
			
			msDuration = TimeConversion.numSamplesToMiliseconds( data.duration );
			
			sampleName.text = data.name;
			resetDuration();
			seekBar.maxValue = msDuration;
			
			if ( player.url == data.lqurl )
			{
				seekBar.progress = player.percentLoaded;
				seekBar.value = player.position;
				updateState( player.isPlaying, ! player.opened );
			}
			else
			{
				updateState( false );
			}
			
			invalidateProperties();
		}
		else
		{
			sampleName.text = '';
			sampleDuration.text = '';
		}
}

private function updateState( playing : Boolean, loading : Boolean = false ) : void
{
	setSeekBarVisible( playing );
	playButton.currentState = loading ? 'loading' : ( playing ? 'stop' : 'play' );
}

override protected function commitProperties() : void
{
	super.commitProperties();
	
	sampleName.toolTip = null;
}

override protected function startDragging( event : MouseEvent ) : void
{
	var dragImage  : VisualSampleDragDropDummy = new VisualSampleDragDropDummy();
		dragImage.data = BaseDescription( data );
		dragImage.originalColor = 0x0099FF;
		
		var dragSource : DragSource = new DragSource();
		dragSource.addData( data, 'sample' );
		dragSource.addData( dragImage, 'dragImage' );
		
		DragManager.doDrag( this, dragSource, event, dragImage, 0, 0, 1 );
}

protected function onToolTipCreate( e : ToolTipEvent ) : void
{
	if ( errorString ) return;
	
	var sid : String = BaseDescription( data ).sourceID;
	var tip : IToolTip;
	    
	if ( sid == Sources.SAMPLE_SOURCE )
	{
		tip = new ItemToolTip();
	}
	else if ( sid == Sources.ACAPELLA_SOURCE )
	{
		tip = new AcapellaToolTip();
	}
	else
	{
		return;
	}
	
	IDataRenderer( tip ).data = data;
		
	e.toolTip = tip;	
}

private function removed() : void
{
	detachFromPlayer();
}

override public function set visible( value : Boolean ) :void
{
	super.visible = value;
	if ( ! value )
	{
		detachFromPlayer();
	}
	else if ( data )
	{
		attachToPlayer();
	}
}

override protected function updateDisplayList( w : Number, h : Number ) : void
{
	super.updateDisplayList( w, h );
	
	if ( errorString )
	{
		graphics.lineStyle( 2, 0xff0000 );
		graphics.drawRect( 0, 0, w - 1, h - 1 );
	}
}