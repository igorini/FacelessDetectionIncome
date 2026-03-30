/**
 * OutpostManagementHelper
 *
 * Utility helper class for managing and querying Outpost-related data.
 */
class OutpostManagementHelper extends Object;

/**
 * Checks whether the given Outpost has any active prohibited jobs.
 *
 * @param Outpost   The Outpost to inspect
 *
 * @return bool     TRUE if at least one prohibited job is active, FALSE otherwise
 */
static function bool hasProhibitedJobs(XComGameState_LWOutpost Outpost)
{
	local int i;

	for (i = 0; i < Outpost.prohibitedjobs.length; i++)
	{
		if (Outpost.ProhibitedJobs[i].DaysLeft > 0) return true;
	}
	return false;
}