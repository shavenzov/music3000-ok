import classes.api.MainAPI;
import classes.api.MainAPIImplementation;
import classes.api.events.UserEvent;
import classes.api.social.ok.OKApi;
import classes.api.social.ok.events.ApiCallbackEvent;

import com.utils.ConjugationUtils;

import components.welcome.Slides;
import components.welcome.events.BackEvent;
import components.welcome.events.GoToEvent;

import flash.utils.clearInterval;
import flash.utils.clearTimeout;
import flash.utils.setInterval;
import flash.utils.setTimeout;

private static const DEFAULT_COINS : uint = 90;

//private var vk  : APIConnection;
private var api : MainAPIImplementation;

private function setInitialState() : void
{
	currentState = initializedAction.fromIndex == -1 ? 'fromOther' : 'fromMenu';
}

private function onContentCreationComplete() : void
{
	api = MainAPI.impl;
}

private function onHide() : void
{
	api.removeAllObjectListeners( this );
	OKApi.getInstance().removeAllObjectListeners( this );
	stopTimer();
}

private function onShow() : void
{
	api.addListener( UserEvent.UPDATE, onInfoUpdated, this, 1000 );
	OKApi.getInstance().addListener( ApiCallbackEvent.CALL_BACK, onOrderResult, this, 1000 ); 
	
	setInitialState();
	
	if ( initializedAction.other )
	{
		coins.value = initializedAction.other;
	}
	else
	{
		coins.value = DEFAULT_COINS;
	}
	
	coinsChange();
}

private function calcBonus() : int
{
 return coins.value * ( api.userInfo.bonusPercent / 100.0 );	
}

private function getCoinsDescription( coins : int ) : String
{
	return coins.toString() + ' ' + ConjugationUtils.formatCoins( coins );
}

private function getBonusDescription( bonus : int ) : String
{
	return '+ бонус ' + bonus.toString() + ' ' + ConjugationUtils.formatCoins( bonus );
}

private function coinsChange() : void
{
	ok.text = coins.value.toString();
	coinsSymbol.toolTip = getCoinsDescription( coins.value );
	okSymbol.toolTip = ok.text + ' ' + ConjugationUtils.formatOKMoney( coins.value );
	
	var bonus : int = calcBonus();
	
	bonusGroup.visible = bonusGroup.includeInLayout = bonus > 0;
	
	if ( bonusGroup.visible )
	{
		bonusLabel.text = bonus.toString();
		bonusGroup.toolTip = getBonusDescription( bonus );
	}
}

private var interval_id : int = -1;

private function tick() : void
{
	setLoadingState( false );
	interval_id = -1;
}

private function setTimer() : void
{
	stopTimer();
	interval_id = setTimeout( tick, 5000 ); 
}

private function stopTimer() : void
{
	if ( interval_id != -1 )
	{
		clearTimeout( interval_id );
		interval_id = -1;
	}
}

private function setLoadingState( value : Boolean ) : void
{
	if ( value )
	{
		currentState = 'loading';
	}
	else
	{
		setInitialState();
	}
	
	ApplicationModel.userInfo.enabled = ! value;
}

private function buyCoinsClick() : void
{
	ApplicationModel.exitFromFullScreen();
	
	setLoadingState( true );
	setTimer();
	
	var name : String = getCoinsDescription( coins.value );
	var bonus : int = calcBonus();
	
	if ( bonus > 0 )
	{
		name += ' ' + getBonusDescription( bonus ); 
	}
	
	infoUpdated = false;
	OKApi.showPayment( name, 'Монеты для публикации миксов', ConjugationUtils.getCoinsIndentifier( coins.value ), coins.value, null, JSON.stringify({bonus:true}), 'ok', 'true' );
}

private var infoUpdated : Boolean;

private function onInfoUpdated( e : UserEvent ) : void
{
	//Если увеличилось количество монет
	if ( e.moneyIncremented )
	{
		dispatchEvent( new GoToEvent( GoToEvent.GO, Slides.COINS_ADDED, null, initializedAction.fromIndex, initializedAction.fromState, e.moneyAdded ) );
		infoUpdated = true;
		setLoadingState( false );
		e.stopImmediatePropagation();
	}
}

private function onOrderResult( e : ApiCallbackEvent ) : void
{
	if ( e.result == 'ok' )
	{
		if ( ! infoUpdated )
		{
			setLoadingState( true );
		}
	}
	
	e.stopImmediatePropagation();
}

private function onCloseClick() : void
{
	dispatchEvent( new BackEvent( BackEvent.BACK ) );
}