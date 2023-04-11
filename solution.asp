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
 
% MaxWorkLoad of a Referee cannot exceed by the newWorkLoad
newWorkLoad(NWL, RID) :- referee(RID, _, _, _, _), NWL = #sum{WL, CID: assign(CID, RID), case(CID, _, WL, _, _, _)}.
:- assign(CID, RID), referee(RID, _, MWL, _, _), case(CID, _, _, _, _, _), newWorkLoad(NWL, RID), NWL > MWL.

% Cases must not be assigned to referees who have zero preference in the specific case type
:- assign(CID, RID), referee(RID, _, _, _, _), case(CID, CTYPE, _, _, _, _), prefType(RID, CTYPE, 0).

% Cases must not be assigned to referees who have zero preference in the specific case region
:- assign(CID, RID), referee(RID, _, _, _, _), case(CID, _, _, _, ZIP, _), prefRegion(RID, ZIP, 0).

% Cases with damage > externalMaxDamage can only be assigned to internal referees
:- assign(CID, RID), referee(RID, RTYPE, _, _, _), case(CID, _, _, DMG, _, _), externalMaxDamage(EMDMG), DMG > EMDMG, RTYPE = e.


%% Weak Constraints and Optimization

% newExPay: the sum of all payments of cases assigned to each external referee
newExPay(COST, RID) :- referee(RID, e, _, _, _), COST = #sum{PAYMENT, CID: assign(CID, RID), case(CID, _, _, _, _, PAYMENT)}.

%% Optimization Factor 1
% totalNewExPay: the sum of all payments of cases assigned to all external referees
totalNewExPay(COST) :- COST = #sum{COSTEACH, RID: newExPay(COSTEACH, RID)}.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% overallExPay: the sum of the prev_payment and payment of new case for each external referee
overallExPay(NEW_PAY + PREV_PAY, RID) :- referee(RID, e, _, _, PREV_PAY), newExPay(NEW_PAY, RID).

% totalOverallExPay: the sum of the prev_payment and payment of new case for all external referees
totalOverallExPay(COST) :- COST = #sum{COSTEACH, RID: overallExPay(COSTEACH, RID)}.

% totalExReferee: the total number of external referees
totalExReferee(COUNT) :- COUNT = #sum{1, RID: referee(RID, e, _, _, _)}.

% avgOverallExPay: the average of overallExPay
avgOverallExPay(AVG) :- AVG = COST/COUNT, totalOverallExPay(COST), totalExReferee(COUNT).

%% Optimization Factor 2
% divergenceOverallExPay: the divergence between individual overallExPays
divergenceOverallExPay(DIV) :- DIV = #sum{|AVG-COST|, RID: avgOverallExPay(AVG), overallExPay(COST, RID)}.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% overallWorkLoad: the sum of the prev_workload and newWorkLoad of each external referee
overallWorkLoad(NWL + PREV_WL, RID) :- referee(RID, _, _, PREV_WL, _), newWorkLoad(NWL, RID).

% totalOverallWorkLoad: the sum of the prevWorkLoad and newWorkLoad for all external referees
totalOverallWorkLoad(WL) :- WL = #sum{WLEACH, RID: overallWorkLoad(WLEACH, RID)}.

% totalReferee: the total number of referees
totalReferee(COUNT) :- COUNT = #sum{1, RID: referee(RID, _, _, _, _)}.

% avgOverallWorkLoad: the average of overallWorkLoad
avgOverallWorkLoad(AVG) :- AVG = WL/COUNT, totalOverallWorkLoad(WL), totalReferee(COUNT).

%% Optimization Factor 3
% divergenceOverallWorkLoad: the divergence between individual overallWorkLoads
divergenceOverallWorkLoad(DIV) :- DIV = #sum{|AVG-WL|, RID: avgOverallWorkLoad(AVG), overallWorkLoad(WL, RID)}.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Optimization Factor 4
% caseTypeMismatchFactor: Sum of all (3-pref) for all assignment, where pref is the preference of the referee for the case type
caseTypeMismatchFactor(COST) :- COST = #sum{3-PREF, CID, RID: assign(CID, RID), case(CID, CTYPE, _, _, _, _), prefType(RID, CTYPE, PREF)}.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Optimization Factor 5
% caseRegionMismatchFactor: Sum of all (3-pref) for all assignment, where pref is the preference of the referee for the case region
caseRegionMismatchFactor(COST) :- COST = #sum{3-PREF, CID, RID: assign(CID, RID), case(CID, _, _, _, ZIP, _), prefRegion(RID, ZIP, PREF)}.


% Optimizing the Cost function: 16.totalNewExPay + 7*divergenceOverallExPay + 9*divergenceOverallWorkLoad + 34*caseTypeMismatchFactor + 34*caseRegionMismatchFactor
#minimize{16*C1+ 7*C2+ 9*C3+ 34*C4 + 34*C5: totalNewExPay(C1),  divergenceOverallExPay(C2), divergenceOverallWorkLoad(C3), caseTypeMismatchFactor(C4), caseRegionMismatchFactor(C5)}.


%% Display 
#show assign/2.
% #show newWorkLoad/2.
