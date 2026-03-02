class UIListener_FacelessIncome extends UIScreenListener;

var localized string m_strIncomeFaceless;
var UIScrollingText IncomeFacelessStr;

event OnInit(UIScreen Screen)
{
    local UIOutpostManagement OutpostScreen;

    if (Screen != none && Screen.IsA('UIOutpostManagement'))
    {
        OutpostScreen = UIOutpostManagement(Screen);

        AddFacelessIncome(OutpostScreen);
    }
}

event OnReceiveFocus(UIScreen Screen)
{
    local UIOutpostManagement OutpostScreen;

    if (Screen != none && Screen.IsA('UIOutpostManagement'))
    {
        OutpostScreen = UIOutpostManagement(Screen);

		// Refresh if haven advisor was changed
		`log("Calling RefreshFacelessIncome from OnReceiveFocus",,'FacelessDebug');
        RefreshFacelessIncome(OutpostScreen);
    }
}

function AddFacelessIncome(UIOutpostManagement Screen)
{
    local XComGameState_LWOutpost Outpost;
    local XComGameStateHistory History;
    local float IncomeFaceless;
	local string FormattedIncomeFaceless;

    History = `XCOMHISTORY;
    Outpost = XComGameState_LWOutpost(
        History.GetGameStateForObjectID(Screen.OutpostRef.ObjectID)
    );

	`LOG("AddFacelessIncome. Outpost assigned",, 'FacelessDetectionIncome');

    if (Outpost == none)
        return;

	`LOG("AddFacelessIncome. Outpost is not null",, 'FacelessDetectionIncome');
    IncomeFaceless = class'X2FacelessIncomeHelper'.static.GetProjectedFacelessIncome(Outpost);
	FormattedIncomeFaceless = class'UIUtilities'.static.FormatFloat(IncomeFaceless, 1);

	`LOG("AddFacelessIncome. IncomeFaceless assigned",, 'FacelessDetectionIncome');

	if (Screen.IncomeRecruitStr == none)
		return;

	IncomeFacelessStr = Screen.MainPanel.Spawn(class'UIScrollingText', Screen.MainPanel);
	IncomeFacelessStr.bAnimateOnInit = false;
	IncomeFacelessStr.bIsNavigable = false;

	IncomeFacelessStr.InitScrollingText(
		'Outpost_FacelessIncome',
		"",
		Screen.IncomeRecruitStr.Width,
		Screen.IncomeRecruitStr.X,
		Screen.IncomeRecruitStr.Y + 28.0
	);

	`LOG("AddFacelessIncome. InitScrollingText done",, 'FacelessDetectionIncome');

	IncomeFacelessStr.SetHTMLText(
		"<p align='RIGHT'><font size='24' color='#fef4cb'>"
		$ m_strIncomeFaceless @ FormattedIncomeFaceless $
		"</font></p>"
	);
	IncomeFacelessStr.SetAlpha(67.1875);

	`LOG("AddFacelessIncome. SetAlpha done",, 'FacelessDetectionIncome');
}

function RefreshFacelessIncome(UIOutpostManagement Screen)
{
    local XComGameState_LWOutpost Outpost;
    local float FacelessIncome;
    local string FormattedIncomeFaceless;

	`log("RefreshFacelessIncome called",,'FacelessDebug');

    //Screen.SaveOutpost();

    Outpost = XComGameState_LWOutpost(
        `XCOMHISTORY.GetGameStateForObjectID(Screen.OutpostRef.ObjectID)
    );

    if (Outpost == none)
        return;

    FacelessIncome =
        class'X2FacelessIncomeHelper'.static.GetProjectedFacelessIncome(Outpost);

	`log("Faceless income calculated as " $ FacelessIncome,,'FacelessDebug');

    FormattedIncomeFaceless =
        class'UIUtilities'.static.FormatFloat(FacelessIncome, 1);

	if (IncomeFacelessStr == none)
	{
		`log("IncomeFacelessStr is NONE!",,'FacelessDebug');
	}
	else
	{
		`log("IncomeFacelessStr is valid, updating text",,'FacelessDebug');
	}
    if (Screen.default.bShowJobInfo && IncomeFacelessStr != none)
    {
        IncomeFacelessStr.SetHTMLText(
            "<p align='RIGHT'><font size='24' color='#fef4cb'>"
            $ m_strIncomeFaceless @ FormattedIncomeFaceless $
            "</font></p>"
        );
    }
}

defaultproperties
{
	IncomeFacelessStr = none;
}