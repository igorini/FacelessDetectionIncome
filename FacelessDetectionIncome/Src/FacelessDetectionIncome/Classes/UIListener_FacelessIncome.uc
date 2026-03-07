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

    if (Outpost == none)
        return;
    IncomeFaceless = class'X2FacelessIncomeHelper'.static.GetProjectedFacelessIncome(Outpost);
	FormattedIncomeFaceless = class'UIUtilities'.static.FormatFloat(IncomeFaceless, 1);

	if (Screen.IncomeRecruitStr == none)
		return;

	IncomeFacelessStr = Screen.MainPanel.Spawn(class'UIScrollingText', Screen.MainPanel);
	IncomeFacelessStr.bAnimateOnInit = false;
	IncomeFacelessStr.bIsNavigable = false;

	// Fix the misaligned positioning for LWOTC 1.2.3+
	if (class'X2FacelessIncomeHelper'.static.IsLWOTCAtLeast(1, 2, 3))
	{
		IncomeFacelessStr.InitScrollingText(
		'Outpost_FacelessIncome',
		"",
		Screen.IncomeIntelStr.Width,
		Screen.IncomeIntelStr.X,
		Screen.IncomeIntelStr.Y - 28.0);
	} else {
		IncomeFacelessStr.InitScrollingText(
		'Outpost_FacelessIncome',
		"",
		Screen.IncomeRecruitStr.Width,
		Screen.IncomeRecruitStr.X,
		Screen.IncomeRecruitStr.Y + 28.0);
	}

	IncomeFacelessStr.SetHTMLText(
		"<p align='RIGHT'><font size='24' color='#fef4cb'>"
		$ m_strIncomeFaceless @ FormattedIncomeFaceless $
		"</font></p>"
	);
	IncomeFacelessStr.SetAlpha(67.1875);
}

function RefreshFacelessIncome(UIOutpostManagement Screen)
{
    local XComGameState_LWOutpost Outpost;
    local float FacelessIncome;
    local string FormattedIncomeFaceless;

    Outpost = XComGameState_LWOutpost(
        `XCOMHISTORY.GetGameStateForObjectID(Screen.OutpostRef.ObjectID)
    );

    if (Outpost == none)
        return;

    FacelessIncome =
        class'X2FacelessIncomeHelper'.static.GetProjectedFacelessIncome(Outpost);

	`log("Faceless income calculated as " $ FacelessIncome,,'FacelessDetectIncome');

    FormattedIncomeFaceless =
        class'UIUtilities'.static.FormatFloat(FacelessIncome, 1);

	if (IncomeFacelessStr == none)
	{
		`log("IncomeFacelessStr is NONE!",,'FacelessDetectIncome');
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