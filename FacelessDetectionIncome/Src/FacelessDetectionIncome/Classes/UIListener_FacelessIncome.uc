class UIListener_FacelessIncome extends UIScreenListener;

event OnInit(UIScreen Screen)
{
    local UIOutpostManagement OutpostScreen;

    OutpostScreen = UIOutpostManagement(Screen);

    if (OutpostScreen != none)
    {
        AddFacelessIncome(OutpostScreen);
    }
}

function AddFacelessIncome(UIOutpostManagement Screen)
{
    local XComGameState_LWOutpost Outpost;
    local XComGameStateHistory History;
    local float IncomeFaceless;
    local UIScrollingText IncomeFacelessStr;

    History = `XCOMHISTORY;
    Outpost = XComGameState_LWOutpost(
        History.GetGameStateForObjectID(Screen.OutpostRef.ObjectID)
    );

    if (Outpost == none)
        return;

    IncomeFaceless = class'X2FacelessIncomeHelper'.static.GetProjectedFacelessIncome(Outpost);

    IncomeFacelessStr = Screen.Spawn(class'UIScrollingText', Screen.MainPanel);
    IncomeFacelessStr.bAnimateOnInit = false;
    IncomeFacelessStr.bIsNavigable = false;

    IncomeFacelessStr.InitScrollingText(
        'Outpost_FacelessIncome',
        "",
        600,
        0,
        96   // adjust Y manually
    );

    IncomeFacelessStr.SetHTMLText(
        "<p align='RIGHT'><font size='24' color='#fef4cb'>Faceless Detection " $ 
        int(IncomeFaceless) $ "</font></p>"
    );

    IncomeFacelessStr.SetAlpha(67.1875);
}