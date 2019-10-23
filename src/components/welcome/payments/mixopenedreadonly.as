import classes.api.events.LimitationsEvent;
import classes.tasks.project.ProjectTask;

import com.utils.StringUtils;

import flashx.textLayout.conversion.TextConverter;

import mx.events.CloseEvent;

private function onShow() : void
{
	var pr : ProjectTask = ApplicationModel.project;
	
	var str : String = '<i>' + StringUtils.firstSymbolToUpperCase( pr.info.name ) + '</i> открыт только для просмотра. Любые изменения не смогут быть сохранены т.к. ';
	
	if ( pr.info.readonly )
	{
		str += 'автор запретил редактирование.';
	}
	else
	if ( pr.projectsExceeded )
	{
		str += LimitationsEvent.getErrorDescription( pr.projectsErrorCode ) + '.';
	} 
	else
	{
		str += 'по неизвестной причине.';
	}
	
	
	caption.textFlow = TextConverter.importToFlow( str, TextConverter.TEXT_FIELD_HTML_FORMAT );
}

private function onCloseClick() : void
{
	dispatchEvent( new CloseEvent( CloseEvent.CLOSE ) );
}