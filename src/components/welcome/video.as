import classes.api.MainAPI;

import components.welcome.Slides;
import components.welcome.events.GoToEvent;

private function onShow() : void
{
	if ( ! player.playing )
	{
		player.play();
	}
	
	if ( initializedAction.fromIndex == Slides.FIRST_TIME )
	{
		ApplicationModel.userInfo.visible = false;
	}
}

private function onHide() : void
{
  if ( player.playing )
  {
	  player.pause();
  }
}

private function nextClick() : void
{
	dispatchEvent( new GoToEvent( GoToEvent.GO, Slides.WELCOME, null ) );
}

private function backClick() : void
{
	dispatchEvent( new GoToEvent( GoToEvent.GO, initializedAction.fromIndex, initializedAction.fromState ) );
}