import classes.api.MainAPI;
import classes.api.MainAPIImplementation;

import com.utils.ConjugationUtils;

import components.welcome.events.BackEvent;

import flashx.textLayout.conversion.TextConverter;

private function setInitialState() : void
{
	currentState = initializedAction.fromIndex == -1 ? 'fromOther' : 'fromMenu';
}

private var api : MainAPIImplementation;

private function onShow() : void
{
	api = MainAPI.impl;
	
	setInitialState();
	
	var str : String = 'Твой счет пополнился на <br><b>' + initializedAction.other.toString() + ' ' + ConjugationUtils.formatCoins2( initializedAction.other ) + '</b>.'; 
	
	caption.textFlow = TextConverter.importToFlow( str, TextConverter.TEXT_FIELD_HTML_FORMAT );
}

private function onCloseClick() : void
{
	dispatchEvent( new BackEvent( BackEvent.BACK ) );
}

