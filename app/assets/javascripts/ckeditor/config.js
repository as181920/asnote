﻿CKEDITOR.editorConfig = function( config )
{
	//config.language = 'en';

	config.toolbar = 'Easy';

	config.toolbar_Easy =
		[
		['TextColor','BGColor','Bold','Strike','FontSize'],
		['NumberedList','BulletedList','Indent','Outdent','Table','Link','Unlink','Anchor'], 
		['Source','Maximize'] 
			];
	config.toolbarStartupExpanded = false;
  config.removePlugins = 'elementspath';
  config.resize_enabled = true;
};
