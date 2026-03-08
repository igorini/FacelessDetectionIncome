class UIListener_FacelessIncome extends UIScreenListener;

// Long version (default)
var localized string m_strIncomeFaceless;
// Short version (with LWOTC 1.2.3+ and when Mecs are present)
var localized string m_strShortIncomeFaceless;
// Cached version of either m_strIncomeFaceless or m_strShortIncomeFaceless
var string strIncomeFaceless;

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
	local float FacelessWidth;
	local float ContainerCenter;

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

	// Long version by default
	strIncomeFaceless = m_strIncomeFaceless;

	// Fix the misaligned positioning for LWOTC 1.2.3+
	if (class'X2FacelessIncomeHelper'.static.IsLWOTCAtLeast(1, 2, 3))
	{
		// Shift the positioning to the left if Mecs are present
		if (Outpost.GetResistanceMecCount() > 0)
		{
			FacelessWidth = 300;
			ContainerCenter = Screen.ResistanceMecs.X + Screen.ResistanceMecs.Width * 0.5;

			IncomeFacelessStr.InitScrollingText(
				'Outpost_FacelessIncome',
				"",
				FacelessWidth,
				ContainerCenter - FacelessWidth * 0.5,
				Screen.ResistanceMecs.Y
			);

			// Set the text to the short version
			strIncomeFaceless = m_strShortIncomeFaceless;
		} else {
			IncomeFacelessStr.InitScrollingText(
			'Outpost_FacelessIncome',
			"",
			Screen.IncomeIntelStr.Width,
			Screen.IncomeIntelStr.X,
			Screen.IncomeIntelStr.Y - 28.0);
		}
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
		$ strIncomeFaceless @ FormattedIncomeFaceless $
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
            $ strIncomeFaceless @ FormattedIncomeFaceless $
            "</font></p>"
        );
    }
}

defaultproperties
{
	IncomeFacelessStr = none;
}