class X2FacelessIncomeHelper extends Object config(FacelessDetectionIncome);

var config float REDUCTION_ABILITIES_BONUS_MULTI;

static function bool IsLWOTCAtLeast(int Major, int Minor, int Patch)
{
    local int CurMajor, CurMinor, CurBuild;

    class'LWVersion'.static.GetVersionNumber(CurMajor, CurMinor, CurBuild);

    return
        (CurMajor > Major) ||
        (CurMajor == Major && CurMinor > Minor) ||
        (CurMajor == Major && CurMinor == Minor &&
         class'LWVersion'.default.PatchVersion >= Patch);
}

static function float GetProjectedFacelessIncome(XComGameState_LWOutpost OutpostState)
{
    local float NewIncome;
    local XComGameState_Unit Liaison;
    local StateObjectReference LiaisonRef;
    local int Rank, AbilityCount;
    local array<name> FacelessChanceReductionAbilities;
    local name FacelessReductionAbilityName;

    LiaisonRef = OutpostState.GetLiaison();
    Liaison = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(LiaisonRef.ObjectID));

    if (Liaison == none || !Liaison.IsSoldier())
        return 0.0f;

    // NOTICE: Faceless count check REMOVED to prevent identifying if the Haven has any faceless or not

    switch (Liaison.GetSoldierClassTemplateName())
    {
        case 'PsiOperative':
            Rank = Liaison.GetRank();
            Rank = Clamp(Rank, 0, class'X2LWActivityDetectionCalc_Rendezvous'.default.LIAISON_MISSION_INCOME_PER_RANK_PSI.Length - 1);
            NewIncome = class'X2LWActivityDetectionCalc_Rendezvous'.default.LIAISON_MISSION_INCOME_PER_RANK_PSI[Rank];
            break;

        default:
            Rank = Liaison.GetRank();
            Rank = Clamp(Rank, 0, class'X2LWActivityDetectionCalc_Rendezvous'.default.LIAISON_MISSION_INCOME_PER_RANK.Length - 1);
            NewIncome = class'X2LWActivityDetectionCalc_Rendezvous'.default.LIAISON_MISSION_INCOME_PER_RANK[Rank];
            break;
    }

    if (class'LWOfficerUtilities'.static.IsOfficer(Liaison))
    {
        Rank = class'LWOfficerUtilities'.static.GetOfficerComponent(Liaison).GetOfficerRank();
        Rank = Clamp(Rank, 0, class'X2LWActivityDetectionCalc_Rendezvous'.default.LIAISON_MISSION_INCOME_BONUS_PER_RANK_OFFICER.Length - 1);
        NewIncome += class'X2LWActivityDetectionCalc_Rendezvous'.default.LIAISON_MISSION_INCOME_BONUS_PER_RANK_OFFICER[Rank];
    }

	// The following change was added in LWOTC 1.2.3:
	// Items that reduce the chance of recruiting Faceless rebels now also provide a 10% bonus to detecting Rendezvous missions
	if (IsLWOTCAtLeast(1, 2, 3))
	{
		FacelessChanceReductionAbilities =
			class'XComGameState_LWOutpost'.default.FACELESS_CHANCE_REDUCTION_ABILITIES.Length > 0
			? class'XComGameState_LWOutpost'.default.FACELESS_CHANCE_REDUCTION_ABILITIES
			: class'XComGameState_LWOutpost'.default.DEFAULT_FACELESS_REDUCTION_CHANCE_ABILITIES;

		AbilityCount = 0;
		foreach FacelessChanceReductionAbilities(FacelessReductionAbilityName)
		{
			if (Liaison.HasAbilityFromAnySource(FacelessReductionAbilityName))
			{
				AbilityCount += 1;
			}
		}

		NewIncome *= 1.0 + (
			AbilityCount *
			class'X2FacelessIncomeHelper'.default.REDUCTION_ABILITIES_BONUS_MULTI
		);
	}

	// Don't adjust for geoscape ticks - makes it easier to correlate the value with the LIAISON_MISSION_INCOME_PER_RANK, etc. config values
    // NewIncome *= float(class'X2LWAlienActivityTemplate'.default.HOURS_BETWEEN_ALIEN_ACTIVITY_DETECTION_UPDATES) / 24.0;

    return NewIncome;
}