//VAM Orca Vehicle GUI Setup
disableSerialization;
private _VAM_display = findDisplay 4900;
private _list_camo = _VAM_display displayCtrl 4910;
private _list_comp = _VAM_display displayCtrl 4920;
private _confirm = _VAM_display displayCtrl 4930;
private _reset = _VAM_display displayCtrl 4940;

private _vehicleclass = typeof VAM_targetvehicle;

//Get all camouflages(texture sets)
private _camo_path = "true" configClasses (configfile >> "CfgVehicles" >> _vehicleclass >> "TextureSources");
camo_class_names = [];
camo_display_names = [];
{_class = configName _x; camo_class_names pushBack _class;} forEach _camo_path;
{_name = getText (configfile >> "CfgVehicles" >> _vehicleclass >> "TextureSources" >> _x >> "DisplayName"); camo_display_names pushBack _name;} forEach camo_class_names;
{
    if (_x isEqualTo "") then {
        camo_display_names set [_forEachIndex, camo_class_names select _forEachIndex];
    };
} forEach camo_display_names;
camo_class_names pushBack (localize "STR_VAM_AAF_CAMO");
camo_display_names pushBack (localize "STR_VAM_AAF_CAMO");

//Get all components(animations)
private _getvc = [VAM_targetvehicle] call BIS_fnc_getVehicleCustomization;
private _check_comp = _getvc select 1;
comp_class_names = [];
{
    if (_x isEqualType "STRING") then {
        comp_class_names pushBack (_check_comp select _forEachIndex);
    };
} forEach _check_comp;
comp_display_names = [];
{_name = getText (configfile >> "CfgVehicles" >> _vehicleclass >> "AnimationSources" >> _x >> "DisplayName"); comp_display_names pushBack _name;} forEach comp_class_names;
{
    if (_x isEqualTo "") then {
        comp_display_names set [_forEachIndex, comp_class_names select _forEachIndex];
    };
} forEach comp_display_names;

//Put camouflages and components in list
if (camo_class_names isEqualTo []) then {
    _list_camo lbAdd localize "STR_VAM_NO_CAMOUFLAGE";
} else {
    {_list_camo lbAdd _x} forEach camo_display_names;
};
if (comp_class_names isEqualTo []) then {
    _list_comp lbAdd localize "STR_VAM_NO_COMPONENT";
} else {
    {_list_comp lbAdd _x} forEach comp_display_names;
};

//Spawn check functions
VAM_camo_check_complete = true;
VAM_comp_check_complete = true;
VAM_check_fnc_delay = false;

if !(camo_class_names isEqualTo []) then {
    [] spawn fnc_VAM_Orca_camo_check;
    VAM_camo_check_complete = false;
};
if !(comp_class_names isEqualTo []) then {
    [] spawn fnc_VAM_common_comp_check;
    VAM_comp_check_complete = false;
};
waitUntil {uisleep 0.1; VAM_camo_check_complete && VAM_comp_check_complete};

//Add UIEH
if !(camo_class_names isEqualTo []) then {
    _list_camo ctrlAddEventHandler ["LBSelChanged", {[] spawn fnc_VAM_Orca_camo;}];
};
if !(comp_class_names isEqualTo []) then {
    _list_comp ctrlAddEventHandler ["LBSelChanged", {[] spawn fnc_VAM_common_comp;}];
};
_reset ctrlAddEventHandler ["ButtonClick", {VAM_check_fnc_delay = true; [] spawn fnc_VAM_Orca_camo_check; [] spawn fnc_VAM_common_comp_check;}];
_confirm ctrlAddEventHandler ["ButtonClick", {[] spawn fnc_VAM_variable_cleaner;}];