%% Definition of the predicates

% case(id, type, workload, damage, zipcode, payment)
% referee(id, type, max_workload, prev_workload, prev_payment)
% prefType(referee_id, case_type, pref)
% prefRegion(referee_id, zipcode, pref)
% externalMaxDamage(damage)
% assign(case_id, referee_id)


%% Potential Solution
% Every case is assigned to exactly one referee
1{assign(CID, RID): referee(RID, _, _, _, _)}1 :- case(CID, _, _, _, _, _).


%% Hard Constraints
 
% MaxWorkLoad of a Referee cannot exceed by the TotalWorkLoad
totalWorkLoad(RID, TWL) :- referee(RID, _, _, PWL, _), TWL = #sum{WL, CID: assign(CID, RID), case(CID, _, WL, _, _, _)}.
:- assign(CID, RID), referee(RID, _, MWL, _, _), case(CID, _, _, _, _, _), totalWorkLoad(RID, TWL), TWL > MWL.

% Cases must not be assigned to referees who have zero preference in the specific case type
:- assign(CID, RID), referee(RID, _, _, _, _), case(CID, CTYPE, _, _, _, _), prefType(RID, CTYPE, 0).

% Cases must not be assigned to referees who have zero preference in the specific case region
:- assign(CID, RID), referee(RID, _, _, _, _), case(CID, _, _, _, ZIP, _), prefRegion(RID, ZIP, 0).

% Cases with damage > externalMaxDamage can only be assigned to internal referees
:- assign(CID, RID), referee(RID, RTYPE, _, _, _), case(CID, _, _, DMG, _, _), externalMaxDamage(EMDMG), DMG > EMDMG, RTYPE = e.


%% Display 
#show assign/2.
