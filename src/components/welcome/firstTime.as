import classes.api.social.ok.OKApi;

import components.welcome.Slides;
import components.welcome.events.GoToEvent;

import mx.events.IndexChangedEvent;

import spark.utils.TextFlowUtil;

private function onShow() : void
{
	ApplicationModel.userInfo.visible = false;
}

private function creationComplete() : void
{
	title.textFlow = TextFlowUtil.importFromString( '<span fontWeight="bold">' + OKApi.userInfo.first_name + '</span>, Добро Пожаловать в Музыкальный Конструктор!' );
}

private function nextClick() : void
{
	dispatchEvent( new GoToEvent( GoToEvent.GO, Slides.VIDEO, 'firstTime' ) );
}

