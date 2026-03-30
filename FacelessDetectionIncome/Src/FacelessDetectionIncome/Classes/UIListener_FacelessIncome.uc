class UIListener_FacelessIncome extends UIScreenListener;

//====================================================
// Localized Strings
//====================================================

// Long version (default)
var localized string m_strIncomeFaceless;

// Short version (LWOTC 1.2.3+ when MECs are present)
var localized string m_strShortIncomeFaceless;


//====================================================
// Runtime State
//====================================================

// Cached active string (long or short)
var string ActiveIncomeLabel;

// UI element displaying faceless income
var UIScrollingText IncomeFacelessStr;


//====================================================
// Screen Lifecycle
//====================================================

event OnInit(UIScreen Screen)
{
    local UIOutpostManagement OutpostScreen;

    if (Screen == none || !Screen.IsA('UIOutpostManagement'))
        return;

    OutpostScreen = UIOutpostManagement(Screen);

    InitializeFacelessIncomeUI(OutpostScreen);
}

event OnReceiveFocus(UIScreen Screen)
{
    local UIOutpostManagement OutpostScreen;

    if (Screen == none || !Screen.IsA('UIOutpostManagement'))
        return;

    OutpostScreen = UIOutpostManagement(Screen);

    RefreshFacelessIncome(OutpostScreen);
}


//====================================================
// UI Initialization
//====================================================

function InitializeFacelessIncomeUI(UIOutpostManagement Screen)
{
    local XComGameState_LWOutpost Outpost;

    Outpost = GetOutpost(Screen);
    if (Outpost == none)
        return;

    // Create widget
    IncomeFacelessStr = SpawnFacelessWidget(Screen);

    if (IncomeFacelessStr == none)
        return;

    ConfigureWidgetLayout(Screen, Outpost);

    UpdateDisplayedIncome(Screen, Outpost);
}


//====================================================
// UI Refresh
//====================================================

function RefreshFacelessIncome(UIOutpostManagement Screen)
{
    local XComGameState_LWOutpost Outpost;

    if (IncomeFacelessStr == none)
        return;

    Outpost = GetOutpost(Screen);
    if (Outpost == none)
        return;

    UpdateDisplayedIncome(Screen, Outpost);
}


//====================================================
// Widget Creation
//====================================================

function UIScrollingText SpawnFacelessWidget(UIOutpostManagement Screen)
{
    local UIScrollingText Widget;

    if (Screen.IncomeRecruitStr == none)
        return none;

    Widget = Screen.MainPanel.Spawn(class'UIScrollingText', Screen.MainPanel);

    Widget.bAnimateOnInit = false;
    Widget.bIsNavigable = false;

    return Widget;
}


//====================================================
// Layout Logic
//====================================================

function ConfigureWidgetLayout(UIOutpostManagement Screen, XComGameState_LWOutpost Outpost)
{
    local float Width;
    local float ContainerCenter;
	local float PositionY;

    // Default label
    ActiveIncomeLabel = m_strIncomeFaceless;

    // LWOTC 1.2.3+ changed UI layout
    if (class'X2FacelessIncomeHelper'.static.IsLWOTCAtLeast(1,2,3))
    {
		// If MECs are present
        if (Outpost.GetResistanceMecCount() > 0)
        {
			// Center between Strength and MEC text
			Width = 300;
			ContainerCenter = Screen.ResistanceMecs.X + Screen.ResistanceMecs.Width * 0.5;

			// If job prohibition is in place (e.g. "Intel Prohibited") - move the text below
			PositionY = class'OutpostManagementHelper'.static.hasProhibitedJobs(Outpost) ? Screen.IncomeIntelStr.Y : Screen.ResistanceMecs.Y;

			IncomeFacelessStr.InitScrollingText(
				'Outpost_FacelessIncome',
				"",
				Width,
				ContainerCenter - Width * 0.5,
				PositionY
			);

			ActiveIncomeLabel = m_strShortIncomeFaceless;
        }
        else
        {
            // Standard LWOTC layout without MECs
            IncomeFacelessStr.InitScrollingText(
                'Outpost_FacelessIncome',
                "",
                Screen.IncomeIntelStr.Width,
                Screen.IncomeIntelStr.X,
                Screen.IncomeIntelStr.Y - 28.0
            );
        }
    }
    else
    {
        // Pre-1.2.3 layout
        IncomeFacelessStr.InitScrollingText(
            'Outpost_FacelessIncome',
            "",
            Screen.IncomeRecruitStr.Width,
            Screen.IncomeRecruitStr.X,
            Screen.IncomeRecruitStr.Y + 28.0
        );
    }
}


//====================================================
// UI Update
//====================================================

function UpdateDisplayedIncome(UIOutpostManagement Screen, XComGameState_LWOutpost Outpost)
{
    local float Income;
    local string FormattedIncome;

    Income = class'X2FacelessIncomeHelper'.static.GetProjectedFacelessIncome(Outpost);

    `log("Faceless income calculated as " $ Income,,'FacelessDetectIncome');

    FormattedIncome = class'UIUtilities'.static.FormatFloat(Income, 1);

    if (Screen.default.bShowJobInfo && IncomeFacelessStr != none)
    {
        IncomeFacelessStr.SetHTMLText(BuildIncomeHTML(FormattedIncome));
		IncomeFacelessStr.SetAlpha(67.1875);
    }
}


//====================================================
// Helpers
//====================================================

function XComGameState_LWOutpost GetOutpost(UIOutpostManagement Screen)
{
    return XComGameState_LWOutpost(
        `XCOMHISTORY.GetGameStateForObjectID(Screen.OutpostRef.ObjectID)
    );
}

function string BuildIncomeHTML(string FormattedIncome)
{
    return "<p align='RIGHT'><font size='24' color='#fef4cb'>"
        $ ActiveIncomeLabel @ FormattedIncome $
        "</font></p>";
}


defaultproperties
{
    IncomeFacelessStr = none
}