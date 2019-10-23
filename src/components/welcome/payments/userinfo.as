import classes.api.MainAPI;
import classes.api.MainAPIImplementation;
import classes.api.data.UserInfo;
import classes.api.events.UserEvent;
import classes.api.social.ok.OKApi;

import com.utils.ConjugationUtils;

import components.managers.HintManager;
import components.welcome.NavigatorContent;
import components.welcome.Slides;
import components.welcome.events.GoToEvent;

import mx.containers.ViewStack;

private var api : MainAPIImplementation;

public var viewStack : ViewStack;

private function initialization() : void
{
	coinsText.setStyle( 'toolTipPlacement', 'errorTipBelow' );
	coinsText.toolTip = 'Щелкни для пополнения количества монет';
	
	face.url      = OKApi.userInfo.pic_1;
	userName.text = OKApi.userInfo.name;
	
	updateInfo( api.userInfo );
}

private function updateInfo( info : classes.api.data.UserInfo ) : void
{
	coins.text = info.money.toString();
}

private function goTo( slideIndex : int ) : void
{
	var cSlide : NavigatorContent = NavigatorContent( viewStack.selectedChild );
	var evt    : GoToEvent = new GoToEvent( GoToEvent.GO, slideIndex, null );
	    
	if ( cSlide.groupIndex == 1 )
	{
		evt.fromIndex = cSlide.initializedAction.fromIndex;
		evt.fromState = cSlide.initializedAction.fromState;
	}
	
	dispatchEvent( evt );
}

private function onCoinsClick() : void
{
	goTo( Slides.BUY_COINS );
}

private function onUserInfoUpdated( e : UserEvent ) : void
{
	updateInfo( e.userInfo );
	
	if ( e.lastUserInfo )
	{
		//Показываем всплывающую подсказку, если количество монет прибавилось
		if ( e.moneyIncremented )
		{
			var incCount : int = e.moneyAdded;
			HintManager.show( 'Твой счет пополнился на ' + incCount.toString() + ' ' + ConjugationUtils.formatCoins2( incCount ), false, coinsText, true, 10000, false ); 
		}
	}
}

private function onAddedToStage() : void
{
	ApplicationModel.userInfo = this;
	
	api = MainAPI.impl;
	api.addListener( UserEvent.UPDATE, onUserInfoUpdated, this, 10000 );
}

private function onRemovedFromStage() : void
{
	ApplicationModel.userInfo = null;
	api.removeAllObjectListeners( this );
	HintManager.hideAll();
}