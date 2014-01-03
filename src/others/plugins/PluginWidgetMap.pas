unit PluginWidgetMap;

interface

const
  // C TO PASCAL Regex
  // FIND: \#define[ ]+(.*)0x([0-9A-Fa-f]+)
  // REPLACE: \t$1= \$$2;

  // definition TYPE_WIDGET
  WINDOW_MAIN                            = $0000FF;
  MENU_MAIN                              = $000100;
  SUBMENU_MAIN_FILE                      = $000101;
  SUBMENU_MAIN_FILE_NEW                  = $000102;
  MENUITEM_MAIN_FILE_NEW_PROJECT         = $000103;
  MENUITEM_MAIN_FILE_NEW_CFILE           = $000104;
  MENUITEM_MAIN_FILE_NEW_CPPFILE         = $000105;
  MENUITEM_MAIN_FILE_NEW_HEADER          = $000106;
  MENUITEM_MAIN_FILE_NEW_RESOURCE        = $000107;
  MENUITEM_MAIN_FILE_NEW_EMPTY           = $000108;
  MENUITEM_MAIN_FILE_NEW_FOLDER          = $000109;
  //MENUITEM_MAIN_FILE_NEW_MAX_ID                0x00010D
  MENUITEM_MAIN_FILE_OPEN                = $00010E;
  SUBMENU_MAIN_FILE_REOPEN               = $00010F;
  MENUITEM_MAIN_FILE_REOPEN_CLEAR        = $000110;
  //MENUITEM_MAIN_FILE_REOPEN_MAX_ID             0x000115
  MENUITEM_MAIN_FILE_SAVE                = $000116;
  MENUITEM_MAIN_FILE_SAVEAS              = $000117;
  MENUITEM_MAIN_FILE_SAVEALL             = $000118;
  SUBMENU_MAIN_FILE_IMPORT               = $000119;
  MENUITEM_MAIN_FILE_IMPORT_DEVCPP       = $00011A;
  MENUITEM_MAIN_FILE_IMPORT_CODEBLOCKS   = $00011B;
  MENUITEM_MAIN_FILE_IMPORT_MSVISUALCPP  = $00011C;
  //MENUITEM_MAIN_FILE_IMPORT_MAX_ID             0x000121
  SUBMENU_MAIN_FILE_EXPORT               = $000122;
  MENUITEM_MAIN_FILE_EXPORT_HTML         = $000123;
  MENUITEM_MAIN_FILE_EXPORT_RTF          = $000124;
  MENUITEM_MAIN_FILE_EXPORT_TEX          = $000125;
  //MENUITEM_MAIN_FILE_EXPORT_MAX_ID             0x00012A
  MENUITEM_MAIN_FILE_CLOSE               = $00012B;
  MENUITEM_MAIN_FILE_CLOSEALL            = $00012C;
  MENUITEM_MAIN_FILE_REMOVE              = $00012D;
  MENUITEM_MAIN_FILE_PRINT               = $00012E;
  MENUITEM_MAIN_FILE_EXIT                = $00012F;
  //MENUITEM_MAIN_FILE_MAX_ID                    0x000134
  SUBMENU_MAIN_EDIT                      = $000135;
  MENUITEM_MAIN_EDIT_UNDO                = $000136;
  MENUITEM_MAIN_EDIT_REDO                = $000137;
  MENUITEM_MAIN_EDIT_CUT                 = $000138;
  MENUITEM_MAIN_EDIT_COPY                = $000139;
  MENUITEM_MAIN_EDIT_PASTE               = $00013A;
  MENUITEM_MAIN_EDIT_SWAPHS              = $00013B;
  MENUITEM_MAIN_EDIT_DELETE              = $00013C;
  MENUITEM_MAIN_EDIT_SELECTALL           = $00013D;
  SUBMENU_MAIN_EDIT_TOGGLEBOOKMARKS      = $00013E;
  MENUITEM_MAIN_EDIT_TOGGLEBOOKMARKS_1   = $00013F;
  MENUITEM_MAIN_EDIT_TOGGLEBOOKMARKS_2   = $000140;
  MENUITEM_MAIN_EDIT_TOGGLEBOOKMARKS_3   = $000141;
  MENUITEM_MAIN_EDIT_TOGGLEBOOKMARKS_4   = $000142;
  MENUITEM_MAIN_EDIT_TOGGLEBOOKMARKS_5   = $000143;
  MENUITEM_MAIN_EDIT_TOGGLEBOOKMARKS_6   = $000144;
  MENUITEM_MAIN_EDIT_TOGGLEBOOKMARKS_7   = $000145;
  MENUITEM_MAIN_EDIT_TOGGLEBOOKMARKS_8   = $000146;
  MENUITEM_MAIN_EDIT_TOGGLEBOOKMARKS_9   = $000147;
  //MENUITEM_MAIN_EDIT_TOGGLE_BOOKMARKS_MAX_ID   0x00014C
  SUBMENU_MAIN_EDIT_GOTOBOOKMARKS        = $00014D;
  MENUITEM_MAIN_EDIT_GOTOBOOKMARKS_1     = $00014E;
  MENUITEM_MAIN_EDIT_GOTOBOOKMARKS_2     = $00014F;
  MENUITEM_MAIN_EDIT_GOTOBOOKMARKS_3     = $000150;
  MENUITEM_MAIN_EDIT_GOTOBOOKMARKS_4     = $000151;
  MENUITEM_MAIN_EDIT_GOTOBOOKMARKS_5     = $000152;
  MENUITEM_MAIN_EDIT_GOTOBOOKMARKS_6     = $000153;
  MENUITEM_MAIN_EDIT_GOTOBOOKMARKS_7     = $000154;
  MENUITEM_MAIN_EDIT_GOTOBOOKMARKS_8     = $000155;
  MENUITEM_MAIN_EDIT_GOTOBOOKMARKS_9     = $000156;
  //MENUITEM_MAIN_EDIT_GOTOBOOKMARKS_MAX_ID      0x00015C
  MENUITEM_MAIN_EDIT_INDENT              = $00015D;
  MENUITEM_MAIN_EDIT_UNINDENT            = $00015E;
  MENUITEM_MAIN_EDIT_TOGGLECOMMENT       = $00015F;
  //MENUITEM_MAIN_EDIT_GOTOBOOKMARKS_MAX_ID      0x000164
  SUBMENU_MAIN_SEARCH                    = $000165;
  MENUITEM_MAIN_SEARCH_FIND              = $000166;
  MENUITEM_MAIN_SEARCH_FINDNEXT          = $000167;
  MENUITEM_MAIN_SEARCH_FINDPREV          = $000168;
  MENUITEM_MAIN_SEARCH_FINDFILES         = $000169;
  MENUITEM_MAIN_SEARCH_REPLACE           = $00016A;
  MENUITEM_MAIN_SEARCH_INCSEARCH         = $00016B;
  MENUITEM_MAIN_SEARCH_GOTOFUNC          = $00016C;
  MENUITEM_MAIN_SEARCH_GOTOPREVFUNC      = $00016D;
  MENUITEM_MAIN_SEARCH_GOTONEXTFUNC      = $00016E;
  MENUITEM_MAIN_SEARCH_GOTOLINE          = $00016F;
  //MENUITEM_MAIN_SEARCH_MAX_ID                  0x000174
  SUBMENU_MAIN_VIEW                      = $000175;
  MENUITEM_MAIN_VIEW_PROJECTMANAGER      = $000176;
  MENUITEM_MAIN_VIEW_STATUSBAR           = $000177;
  MENUITEM_MAIN_VIEW_OUTLINE             = $000178;
  MENUITEM_MAIN_VIEW_COMPILEROUTPUT      = $000179;
  SUBMENU_MAIN_VIEW_TOOLBARS             = $00017A;
  MENUITEM_MAIN_VIEW_TOOLBARS_DEFAULT    = $00017B;
  MENUITEM_MAIN_VIEW_TOOLBARS_EDIT       = $00017C;
  MENUITEM_MAIN_VIEW_TOOLBARS_SEARCH     = $00017D;
  MENUITEM_MAIN_VIEW_TOOLBARS_COMPILER   = $00017E;
  MENUITEM_MAIN_VIEW_TOOLBARS_NAVIGATOR  = $00017F;
  MENUITEM_MAIN_VIEW_TOOLBARS_PROJECT    = $000180;
  MENUITEM_MAIN_VIEW_TOOLBARS_HELP       = $000181;
  MENUITEM_MAIN_VIEW_TOOLBARS_DEBUG      = $000182;
  //MENUITEM_MAIN_VIEW_TOOLBARS_MAX_ID           0x000187
  SUBMENU_MAIN_VIEW_THEMES               = $000188;
  MENUITEM_MAIN_VIEW_THEMES_DEFAULT      = $000189;
  MENUITEM_MAIN_VIEW_THEMES_OFFICE2003   = $00018A;
  MENUITEM_MAIN_VIEW_THEMES_OFFICEXP     = $00018B;
  MENUITEM_MAIN_VIEW_THEMES_STRIPES      = $00018C;
  MENUITEM_MAIN_VIEW_THEMES_PROFESSIONAL = $00018D;
  MENUITEM_MAIN_VIEW_THEMES_ALUMINUM     = $00018E;
  //MENUITEM_MAIN_VIEW_THEMES_MAX_ID             0x000193
  SUBMENU_MAIN_VIEW_ZOOM                 = $000194;
  MENUITEM_MAIN_VIEW_ZOOM_INCREASE       = $000195;
  MENUITEM_MAIN_VIEW_ZOOM_DECREASE       = $000196;
  //MENUITEM_MAIN_VIEW_ZOOM_MAX_ID               0x00019B
  MENUITEM_MAIN_VIEW_FULLSCREEN          = $00019C;
  MENUITEM_MAIN_VIEW_RESTOREDEFAULT      = $00019D;
  //MENUITEM_MAIN_VIEW_MAX_ID                    0x0001A2
  SUBMENU_MAIN_PROJECT                   = $0001A3;
  MENUITEM_MAIN_PROJECT_ADD              = $0001A4;
  MENUITEM_MAIN_PROJECT_REMOVE           = $0001A5;
  MENUITEM_MAIN_PROJECT_BUILD            = $0001A6;
  MENUITEM_MAIN_PROJECT_PROPERTY         = $0001A7;
  //MENUITEM_MAIN_PROJECT_MAX_ID                 0x0001AC
  SUBMENU_MAIN_RUN                       = $0001AD;
  MENUITEM_MAIN_RUN_RUN                  = $0001AE;
  MENUITEM_MAIN_RUN_COMPILE              = $0001AF;
  MENUITEM_MAIN_RUN_EXECUTE              = $0001B0;
  MENUITEM_MAIN_RUN_TOGGLEBREAKPOINT     = $0001B1;
  MENUITEM_MAIN_RUN_STEPINTO             = $0001B2;
  MENUITEM_MAIN_RUN_STEPOVER             = $0001B3;
  MENUITEM_MAIN_RUN_RUNTOCURSOR          = $0001B4;
  MENUITEM_MAIN_RUN_STOP                 = $0001B5;
  //MENUITEM_MAIN_RUN_MAX_ID                     0x0001BA
  SUBMENU_MAIN_TOOLS                     = $0001BB;
  MENUITEM_MAIN_TOOLS_ENVIRONMENTOPTIONS = $0001BC;
  MENUITEM_MAIN_TOOLS_COMPILEROPTIONS    = $0001BD;
  MENUITEM_MAIN_TOOLS_EDITOROPTIONS      = $0001BE;
  MENUITEM_MAIN_TOOLS_TEMPLATECREATOR    = $0001BF;
  MENUITEM_MAIN_TOOLS_PACKAGECREATOR     = $0001C0;
  MENUITEM_MAIN_TOOLS_PACKAGES           = $0001C1;
  //MENUITEM_MAIN_TOOLS_MAX_ID                   0x0001C6
  SUBMENU_MAIN_HELP                      = $0001C7;
  SUBMENU_MAIN_HELP_FALCONCPP            = $0001C8;
  MENUITEM_MAIN_HELP_FALCONCPP_FALCONCPP = $0001C9;
  //MENUITEM_MAIN_HELP_FALCONCPP_MAX_ID          0x0001CE
  MENUITEM_MAIN_HELP_TIPOFDAY            = $0001CF;
  MENUITEM_MAIN_HELP_UPDATE              = $0001D0;
  MENUITEM_MAIN_HELP_ABOUT               = $0001D1;
  //MENUITEM_MAIN_HELP_MAX_ID                    0x0001D6
  //MENUITEM_MAIN_MAX_ID                         0x0001DB

	WINDOW_COMPILER_OPTIONS     = $0004E7;
	WINDOW_EDITOR_OPTIONS       = $0008CF;
	WINDOW_ENVIRONMENT_OPTIONS  = $000CB7;
	WINDOW_FIND                 = $00109F;
	WINDOW_NEW_PROJECT          = $001487;
	WINDOW_PROJECT_PROPERTY     = $00186F;
	WINDOW_PROJECT_REMOVE       = $001C57;
	WINDOW_UPDATE               = $00203F;
	WINDOW_GOTO_LINE            = $002427;
	WINDOW_GOTO_FUNCTION        = $00280F;
	WINDOW_ABOUT                = $002BF7;

implementation

end.