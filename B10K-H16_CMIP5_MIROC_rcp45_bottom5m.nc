<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN"
"http://www.w3.org/TR/REC-html40/loose.dtd">
<html><head><title>OPeNDAP Dataset Query Form</title>
<link type="text/css" rel="stylesheet" media="screen" href="/aclim/tdsDap.css"/>
<base href="http://www.opendap.org/online_help_files/">
<script type="text/javascript">
<!--


// -*- Java -*-

// $Id: jscriptCore.java 15901 2007-02-28 23:57:28Z jimg $

// (c) COPYRIGHT URI/MIT 1999
// Please read the full copyright statement in the file COPYRIGHT.
//
// Authors:
//	jhrg,jimg	James Gallagher (jgallagher@gso.url.edu)

var reflection_cgi = "http://unidata.ucar.edu/cgi-bin/dods/posturl.pl";

// Event handlers for the disposition button.

// The ascii_button handler sends data to a new window. The user can then 
// save the data to a file.

function ascii_button() {
    var url = new String(document.forms[0].url.value);

    var url_parts = url.split("?");
    /* handle case where constraint is null. */
    if (url_parts[1] != null) {
        var ascii_url = url_parts[0] + ".ascii?" + url_parts[1];
    }
    else {
        var ascii_url = url_parts[0] + ".ascii?";
    }

    window.open(encodeURI(ascii_url), "ASCII_Data");
}

/* The binary_button handler loads the data to the current window. Since it 
   is binary, Netscape will ask the user for a filename and save the data
   to that file. */

function binary_button() {
    var url = new String(document.forms[0].url.value);

    var url_parts = url.split("?");
    /* handle case where constraint is null. */
    if (url_parts[1] != null) {
        var binary_url = url_parts[0] + ".dods?" + url_parts[1];
    }
    else {
        var binary_url = url_parts[0] + ".dods?";
    }

    window.location = encodeURI(binary_url);
}

/* Route the URL to Matlab, IDL, .... Users must add an entry into their mime
   types file (aka list of Netscape helper applications) so that the URL will
   be fedd into Matlab which must, in addition, be running loadopendap.

   Note that reflection_cgi is a global JavaScript variable set at the 
   begining of this `file'. */

function program_button() {
    var program_url = new String(document.forms[0].url.value);

    /* Build a call to the reflector CGI. */
    var CGI = reflection_cgi + "?" + "url=" + program_url + "&disposition=matlab";

    window.location = CGI;
}

var help = 0;			// Our friend, the help window.

function help_button() {
    // Check the global to keep from opening the window again if it is
    // already visible. I think Netscape handles this but I know it will
    // write the contents over and over again. This preents that, too.
    // 10/8/99 jhrg
    if (help && !help.closed)
	return;

    // Resize on Netscape 4 is hosed. When enabled, if a user resizes then
    // the root window's document gets reloaded. This does not happen on IE5.
    // regardless, with scrollbars we don't absolutely need to be able to
    // resize. 10/8/99 jhrg
    help = window.open("", "help", "scrollbars,dependent,width=600,height=400");
    write_help_contents(help);
}

function write_help_contents() {
    help.document.writeln("<html><head><title> " +
"Help for the OPeNDAP Dataset Access Form</title></head><body><form> " +
"<center><h2>Help for the OPeNDAP Dataset Access Form</h2></center> " +
"This form displays information from the dataset whose URL is shown in " +
"the <em>DataURL</em> field. Each variable in this dataset is shown " +
"below in the section labeled <em>Variables</em>. " +
"<ul>" +
"<li>To select a variable click on the checkbox to its left. " +
"<li>To constrain a variable that you've selected, edit the information " +
"that appears in the text boxes below the variable. " +
"<li>To get ASCII or binary values for the variables you've selected, " +
"click on the <em>Get ASCII</em> or <em>Get Binary</em> buttons. " +
"Note that the URL displayed in the <em>DataURL</em> field is updated " +
"as you select and/or constrain variables. The URL in this field can be " +
"cut and pasted in various OPeNDAP clients such as the Matlab and IDL " +
"command extensions. See the <a " +
"href=\"https://www.opendap.org/support/OPeNDAP-clients\" target=\"_blank\"> " +
"OPeNDAP client page</a> for information about those clients. " +
"<p><hr><p> " + 
"<center> " +
"<input type=\"button\" value=\"Close\" onclick=\"self.close()\"> " +
"</center></form></body></html>");
}

function open_dods_home() {
    window.open("https://www.opendap.org/", "DODS_HOME_PAGE");
}


// Helper functions for the form.

function describe_index() {
   defaultStatus = "Enter start, stride and stop for the array dimension.";
}

function describe_selection() {
   defaultStatus = "Enter a relational expression (e.g., <20).";
}

function describe_operator() {
   defaultStatus = "Choose a relational operator. Use - to enter a function name).";
}

function describe_projection() {
   defaultStatus = "Add this variable to the projection.";
}

///////////////////////////////////////////////////////////
// The dods_url object.
///////////////////////////////////////////////////////////

// CTOR for dods_url
// Create the DODS URL object.
function dods_url(base_url) {
    this.url = base_url;
    this.projection = "";
    this.selection = "";
    this.num_dods_vars = 0;
    this.dods_vars = new Array();
        
    this.build_constraint = build_constraint;
    this.add_dods_var = add_dods_var;
    this.update_url = update_url;
}

// Method of dods_url
// Add the projection and selection to the displayed URL.
function update_url() {
    this.build_constraint();
    var url_text = this.url;
    // Only add the projection & selection (and ?) if there really are
    // constraints! 
    if (this.projection.length + this.selection.length > 0)
        url_text += "?" + this.projection + this.selection;
    document.forms[0].url.value = url_text;
}

// Method of dods_url
// Scan all the form elements and pick out the various pieces of constraint
// information. Add these to the dods_url instance.
function build_constraint() {
    var p = "";
    var s = "";
    for (var i = 0; i < this.num_dods_vars; ++i) {
        if (this.dods_vars[i].is_projected == 1) {
	    // The comma is a clause separator.
	    if (p.length > 0)
	        p += ",";
            p += this.dods_vars[i].get_projection();
	}
	var temp_s = this.dods_vars[i].get_selection();
	if (temp_s.length > 0)
	    s += "&" + temp_s;    // The ampersand is a prefix to the clause.
    }

    this.projection = p;
    this.selection = s;
}

// Method of dods_url
// Add the variable to the dods_var array of dods_vars. The var_index is the
// number of *this particular* variable in the dataset, zero-based.
function add_dods_var(dods_var) {
    this.dods_vars[this.num_dods_vars] = dods_var;
    this.num_dods_vars++;
}

/////////////////////////////////////////////////////////////////
// dods_var
/////////////////////////////////////////////////////////////////

// CTOR for dods_var
// name: the name of the variable from DODS' perspective.
// js_var_name: the name of the variable within the form.
// is_array: 1 if this is an array, 0 otherwise.
function dods_var(name, js_var_name, is_array) {
    // Common members
    this.name = name;
    this.js_var_name = js_var_name;
    this.is_projected = 0;
    if (is_array > 0) {
        this.is_array = 1;
        this.num_dims = 0;        // Holds the number of dimensions
        this.dims = new Array(); // Holds the length of the dimensions

        this.add_dim = add_dim;
        this.display_indices = display_indices;
        this.erase_indices = erase_indices;
    }
    else
        this.is_array = 0;

    this.handle_projection_change = handle_projection_change;
    this.get_projection = get_projection;
    this.get_selection = get_selection;
}

// Method of dods_var
// Add a dimension to a DODS Array object.
function add_dim(dim_size) {
    this.dims[this.num_dims] = dim_size;
    this.num_dims++;
}

// Method of dods_var
// Add the array indices to the text widgets associated with this DODS
// array object. The text widgets are names <var_name>_0, <var_name>_1, ...
// <var_name>_n for an array with size N+1.
function display_indices() {
    for (var i = 0; i < this.num_dims; ++i) {
        var end_index = this.dims[i]-1;
        var s = "0:1:" + end_index.toString();
	var text_widget = "document.forms[0]." + this.js_var_name + "_" + i.toString();
	eval(text_widget).value = s;
    }
}

// Method of dods_var
// Use this to remove index information from a DODS array object.
function erase_indices() {
    for (var i = 0; i < this.num_dims; ++i) {
	var text_widget = "document.forms[0]." + this.js_var_name + "_" + i.toString();
	eval(text_widget).value = "";
    }
}

// Method of  dods_var
function handle_projection_change(check_box) {
    if (check_box.checked) {
        this.is_projected = 1;
	if (this.is_array == 1)
	    this.display_indices();
    }
    else {
        this.is_projected = 0;
	if (this.is_array == 1)
	    this.erase_indices();
    }

    DODS_URL.update_url();
}


// Method of dods_var
// Get the projection sub-expression for this variable.
function get_projection() {
    var p = "";
    if (this.is_array == 1) {
        p = this.name;		// ***
        for (var i = 0; i < this.num_dims; ++i) {
	    var text_widget = "document.forms[0]." + this.js_var_name + "_" + i.toString();
	    p += "[" + eval(text_widget).value + "]";
	}
    }
    else {
	p = this.name;		// ***
    }

    return p;
}

// Method of dods_var
// Get the selection (which is null for arrays).
function get_selection() {
    var s = "";
    if (this.is_array == 1) {
        return s;
    }
    else {
	var text_widget = "document.forms[0]." + this.js_var_name + "_selection";
        if (eval(text_widget).value != "") {
            var oper_widget_name = "document.forms[0]." + this.js_var_name + "_operator";
            var oper_widget = eval(oper_widget_name);
	    var operator = oper_widget.options[oper_widget.selectedIndex].value;
            // If the operator is `-' then don't prepend the variable name!
            // This provides a way for users to enter function names as
            // selection clauses. 
            if (operator == "-")
                s = eval(text_widget).value;
            else
	        s = this.name + operator + eval(text_widget).value; // ***
        }
    }

    return s;
}    

// : jscriptCore.tmpl,v $
// Revision 1.4  2001/09/17 23:05:53  ndp
// *** empty log message ***
//
// Revision 1.1.2.3  2001/09/10 21:48:07  jimg
// Removed the `Send to Program' button and its help text.
//
// Revision 1.1.2.2  2001/09/10 19:32:28  jimg
// Fixed two problems: 1) Variable names in the JavaScript code sometimes
// contained spaces since they were made using the dataset's variable name.
// The names are now filtered through id2www and esc2underscore. 2) The CE
// sometimes contained spaces, again, because dataset variable names were
// used to build the CE. I filtered the names with id2www_ce before passing
// them to the JavaScript code.
//
// Revision 1.1.2.1  2001/01/26 04:01:13  jimg
// Added
//
// Revision 1.5  2000/11/09 21:04:37  jimg
// Merged changes from release-3-1. There was a goof and a bunch of the
// changes never made it to the branch. I merged the entire branch.
// There maybe problems still...
//
// Revision 1.4  2000/10/03 20:07:21  jimg
// Moved Logs to the end of each file.
//
// Revision 1.3  1999/05/18 20:08:18  jimg
// Fixed massive problems introduced by the String to string changes.
//
// Revision 1.2  2000/11/09 21:04:37  jimg
// Merged changes from release-3-1. There was a goof and a bunch of the
// changes never made it to the branch. I merged the entire branch.
// There maybe problems still...
//
// Revision 1.1.2.3  1999/10/13 17:02:55  jimg
// Changed location of posturl.pl.
//
// Revision 1.1.2.2  1999/10/11 17:57:32  jimg
// Fixed a bug which showed up in IE 5. Objects in IE 5 cannot use eval() to
// name a field and access a property of that field in the same statement.
// Instead, the use of eval to name a field and the access to that (new)
// field must be broken up. I think this is the case because IE 5's parser
// thinks `eval' is, in this situation, an object property. Of course,
// there's no eval property per se, so script execution halts. See the use of
// the document.forms[0].<text_widget> stuff in the method display_indices().
//
// Revision 1.1.2.1  1999/10/09 00:30:36  jimg
// Created.

DODS_URL = new dods_url("https://data.pmel.noaa.gov/aclim/thredds/dodsC/Level2/B10K-H16_CMIP5_MIROC_rcp45_bottom5m.nc");
// -->
</script>
</head>
<body>
<p><h2 align='center'>OPeNDAP Dataset Access Form</h2>
<hr>
<form action="">
<table>

<tr><td align="right">
<h3><a href="opendap_form_help.html#disposition" valign="bottom">Action:</a></h3>
<td><input type="button" value="Get ASCII" onclick="ascii_button()">
<input type="button" value="Get Binary" onclick="binary_button()">
<input type="button" value="Show Help" onclick="help_button()">
<tr>
<td align="right">
<h3><a href="opendap_form_help.html#data_url" valign="bottom">Data URL:</a></h3><td><input name="url" type="text" size=70 value="https://data.pmel.noaa.gov/aclim/thredds/dodsC/Level2/B10K-H16_CMIP5_MIROC_rcp45_bottom5m.nc">
<tr><td><td><hr>

<tr>
<td align="right" valign="top">
<h3><a href="opendap_form_help.html#global_attr">Global Attributes:</a></h3>
<td><textarea name="global_attr" rows=5 cols=70>
file: run1-miroc-rcp45-alsnew_avg_00632.nc
run1-miroc-rcp45-alsnew_avg_00633.nc
run1-miroc-rcp45-alsnew_avg_00634.nc
run1-miroc-rcp45-alsnew_avg_00635.nc
run1-miroc-rcp45-alsnew_avg_00636.nc
run1-miroc-rcp45-alsnew_avg_00637.nc
run1-miroc-rcp45-alsnew_avg_00638.nc
run1-miroc-rcp45-alsnew_avg_00639.nc
run1-miroc-rcp45-alsnew_avg_00640.nc
run1-miroc-rcp45-alsnew_avg_00641.nc
run1-miroc-rcp45-alsnew_avg_00642.nc
run1-miroc-rcp45-alsnew_avg_00643.nc
run1-miroc-rcp45-alsnew_avg_00644.nc
run1-miroc-rcp45-alsnew_avg_00645.nc
run1-miroc-rcp45-alsnew_avg_00646.nc
run1-miroc-rcp45-alsnew_avg_00647.nc
run1-miroc-rcp45-alsnew_avg_00648.nc
run1-miroc-rcp45-alsnew_avg_00649.nc
run1-miroc-rcp45-alsnew_avg_00650.nc
run1-miroc-rcp45-alsnew_avg_00651.nc
run1-miroc-rcp45-alsnew_avg_00652.nc
run1-miroc-rcp45-alsnew_avg_00653.nc
run1-miroc-rcp45-alsnew_avg_00654.nc
run1-miroc-rcp45-alsnew_avg_00655.nc
run1-miroc-rcp45-alsnew_avg_00656.nc
run1-miroc-rcp45-alsnew_avg_00657.nc
run1-miroc-rcp45-alsnew_avg_00658.nc

format: netCDF-3 classic file
Conventions: CF-1.0
type: ROMS/TOMS averages file
title: B10K-H16_CMIP5_MIROC_rcp45 Level 2 (bottom 5m)
var_info: GK_varinfo.dat
rst_file: run1-miroc-rcp45-alsnew_rst.nc
his_base: run1-miroc-rcp45-alsnew_his
avg_base: run1-miroc-rcp45-alsnew_avg
sta_file: run1-miroc-rcp45-alsnew_sta.nc
grd_file: Bering_grid_10k.nc_4_28_09
ini_file: ic-for-gfdl.nc
frc_file_01: Pair-miroc-rcp45.nc
frc_file_02: lwrad_down-miroc-rcp45.nc
frc_file_03: Qair-miroc-rcp45.nc
frc_file_04: swrad_down-miroc-rcp45.nc
frc_file_05: Tair-miroc-rcp45.nc
frc_file_06: Uwind-miroc-rcp45.nc
frc_file_07: Vwind-miroc-rcp45.nc
frc_file_08: /home/aydink/ncfiles/CFSR/runoff_daitren_clim_10k.nc.9.14.11
frc_file_09: rain-miroc-rcp45.nc
frc_file_10: /home/aydink/ncfiles/CFSR/Bering_tides_otps.nc
frc_file_11: /home/aydink/ncfiles/CFSR/sss_fill_2004.nc
bry_file: all_phys_npz_bc_rcp45.nc
script_file: miroc-rcp45-beast.in
bpar_file: sebs_bio_ajh_08_26_11.in
spos_file: stations_bering_10k.in
svn_url: https://www.myroms.org/svn/omlab/branches/kate
svn_rev: 
code_dir: /home/chengw/roms-bering-sea
header_dir: /home/chengw/roms-bering-sea/Apps/NEP
header_file: nep5.h
os: Linux
cpu: x86_64
compiler_system: ifort
compiler_command: /usr/mpi/intel/openmpi-1.4.1/bin/mpif90
compiler_flags:  -ip -O3 -xW -free
tiling: 014x010
history: Wed Nov 18 20:59:35 2020: ncwa -O -a s_rho ../../cmip5-avg/Postprocessed/Level2/B10K-H16_CMIP5_MIROC_rcp45_2090-2094_average_Iron_bottom5m.nc ../../cmip5-avg/Postprocessed/Level2/B10K-H16_CMIP5_MIROC_rcp45_2090-2094_average_Iron_bottom5m.nc
Wed Nov 18 20:59:34 2020: Bottom average calculated via roms_level2_bottomsurf.m
Wed Nov 18 20:59:25 2020: ncks -F -O -d s_rho,1,1 ../../cmip5-avg/Postprocessed/Level1/B10K-H16_CMIP5_MIROC_rcp45_2090-2094_average_Iron.nc ../../cmip5-avg/Postprocessed/Level2/B10K-H16_CMIP5_MIROC_rcp45_2090-2094_average_Iron_bottom5m.nc
Wed Nov 18 20:58:18 2020: Data traferred from raw output files via roms_level1.m
Wed Nov 18 20:57:23 2020: ncks -A -v lat_rho,lon_rho /gscratch/bumblereem/bering10k/input/grd/Bering_grid_withFeast.nc ../../cmip5-avg/Postprocessed/Level1/B10K-H16_CMIP5_MIROC_rcp45_2090-2094_average_Iron.nc
Wed Nov 18 20:57:21 2020: ncks -d ocean_time,1,1 -v Iron ../../cmip5-avg/MIROC_rcp45/run1-miroc-rcp45-alsnew_avg_00632.nc ../../cmip5-avg/Postprocessed/Level1/B10K-H16_CMIP5_MIROC_rcp45_2090-2094_average_Iron.nc
ROMS/TOMS, Version 3.2, Friday - March 25, 2016 -  1:44:09 PM
ana_file: ROMS/Functionals/ana_btflux.h, /home/chengw/roms-bering-sea/Apps/NEP/ana_hmixcoef.h, ROMS/Functionals/ana_nudgcoef.h, /home/chengw/roms-bering-sea/Apps/NEP/ana_psource.h, ROMS/Functionals/ana_srflux.h, ROMS/Functionals/ana_stflux.h, /home/chengw/roms-bering-sea/Apps/NEP/ana_tclima.h, ROMS/Functionals/ana_aiobc.h, ROMS/Functionals/ana_hiobc.h, ROMS/Functionals/ana_hsnobc.h
bio_file: ROMS/Nonlinear/bestnpz.h
CPP_options: NEP5, ADD_FSOBC, ADD_M2OBC, ANA_BIOLOGY, ANA_BPFLUX, ANA_BSFLUX, ANA_BTFLUX, ANA_PSOURCE, ANA_SPFLUX, ANA_TCLIMA, ASSUMED_SHAPE, AVERAGES, AVERAGES_AKS, AVERAGES_AKT, AVERAGES_FLUXES, BULK_FLUXES, CCSM_FLUXES, CORE_FORCING, CURVGRID, DIFF_GRID, DIURNAL_SRFLUX, DJ_GRADPS, DOUBLE_PRECISION, DRAG_LIMITER, EASTERN_WALL, EMINUSP, ICE_ADVECT, ICE_BULK_FLUXES, ICE_EVP, ICE_MK, ICE_MODEL, ICE_MOMENTUM, ICE_SMOLAR, ICE_THERMO, LMD_CONVEC, LMD_MIXING, LMD_NONLOCAL, LMD_RIMIX, LMD_SHAPIRO, LMD_SKPP, LONGWAVE_OUT, MASKING, MIX_GEO_TS, MIX_S_UV, MPI, NONLINEAR, NONLIN_EOS, NORTHERN_WALL, NO_WRITE_GRID, POT_TIDES, POWER_LAW, PROFILE, RDRG_GRID, RUNOFF, RADIATION_2D, RST_SINGLE, SALINITY, SCORRECTION, SOLAR_SOURCE, SOLVE3D, SOUTH_FSCHAPMAN, SOUTH_M2FLATHER, SOUTH_M3NUDGING, SOUTH_M3RADIATION, SOUTH_TNUDGING, SOUTH_TRADIATION, SPONGE, SSH_TIDES, STATIONS, TCLIMATOLOGY, TCLM_NUDGING, TIDES_ASTRO, TS_C4HADVECTION, TS_C4VADVECTION, TS_DIF2, UV_ADV, UV_COR, UV_U3HADVECTION, UV_SADVECTION, UV_LDRAG, UV_PSOURCE, UV_TIDES, UV_VIS2, VAR_RHO_2D, VISC_GRID, VISC_3DCOEF, WEST_FSCHAPMAN, WEST_M2FLATHER, WEST_M3NUDGING, WEST_M3RADIATION, WEST_TNUDGING, WEST_TRADIATION
NCO: 4.6.9
history_of_appended_files: Wed Nov 18 20:57:23 2020: Appended file /gscratch/bumblereem/bering10k/input/grd/Bering_grid_withFeast.nc had following "history" attribute:
Wed Apr 15 16:24:44 2009: ncks -d xi_rho,24,205 -d xi_psi,24,204 -d xi_u,24,204 -d xi_v,24,205 -d eta_rho,349,606 -d eta_psi,349,605 -d eta_u,349,606 -d eta_v,349,605 NEP_grid_5a.nc Bering_grid_10k.nc
Wed Apr 15 15:46:05 2009: ncks -v rdrg_grid -x NEP_grid_5a.nc foo.nx
Fri Mar 20 09:42:11 2009: ncatted -O -a _FillValue,mask_rho,d,, -a _FillValue,mask_u,d,, -a _FillValue,mask_v,d,, -a _FillValue,mask_psi,d,, /archive/u1/uaf/kate/gridpak/NEP4/NEP_grid_5a.nc
Gridpak, Version 5.3  , Tuesday - February 15, 2005 - 2:42:56 PM

nco_openmp_thread_number: 1
</textarea><p>

<tr><td><td><hr>

<tr>
<td align="right" valign="top">
<h3><a href="opendap_form_help.html#dataset_variables">Variables:</a></h3>
<br><td>
<script type="text/javascript">
<!--
dods_Cs_r = new dods_var("Cs_r", "dods_Cs_r", 0);
DODS_URL.add_dods_var(dods_Cs_r);
// -->
</script>
<b><input type="checkbox" name="get_dods_Cs_r"
onclick="dods_Cs_r.handle_projection_change(get_dods_Cs_r)">
<font size="+1">Cs_r</font>: 64 bit Real</b><br>

Cs_r <select name="dods_Cs_r_operator" onfocus="describe_operator()" onchange="DODS_URL.update_url()">
<option value="=" selected>=
<option value="!=">!=
<option value="<"><
<option value="<="><=
<option value=">">>
<option value=">=">>=
<option value="-">--
</select>
<input type="text" name="dods_Cs_r_selection" size=12 onFocus="describe_selection()" onChange="DODS_URL.update_url()">
<br>

<textarea name="Cs_r_attr" rows=5 cols=70>
long_name: S-coordinate stretching curves at RHO-points
valid_min: -1.0
valid_max: 0.0
field: Cs_r, scalar
cell_methods: s_rho: mean
</textarea>


<p><p>

<tr><td><td>

<script type="text/javascript">
<!--
dods_hc = new dods_var("hc", "dods_hc", 0);
DODS_URL.add_dods_var(dods_hc);
// -->
</script>
<b><input type="checkbox" name="get_dods_hc"
onclick="dods_hc.handle_projection_change(get_dods_hc)">
<font size="+1">hc</font>: 64 bit Real</b><br>

hc <select name="dods_hc_operator" onfocus="describe_operator()" onchange="DODS_URL.update_url()">
<option value="=" selected>=
<option value="!=">!=
<option value="<"><
<option value="<="><=
<option value=">">>
<option value=">=">>=
<option value="-">--
</select>
<input type="text" name="dods_hc_selection" size=12 onFocus="describe_selection()" onChange="DODS_URL.update_url()">
<br>

<textarea name="hc_attr" rows=5 cols=70>
long_name: S-coordinate parameter, critical depth
units: meter
</textarea>


<p><p>

<tr><td><td>

<script type="text/javascript">
<!--
dods_lat_rho = new dods_var("lat_rho", "dods_lat_rho", 1);
DODS_URL.add_dods_var(dods_lat_rho);
// -->
</script>
<b><input type="checkbox" name="get_dods_lat_rho"
onclick="dods_lat_rho.handle_projection_change(get_dods_lat_rho)">
<font size="+1">lat_rho</font>: Array of 64 bit Reals [eta_rho = 0..257][xi_rho = 0..181]
</b><br>

eta_rho:<input type="text" name="dods_lat_rho_0" size=8 onfocus="describe_index()" onChange="DODS_URL.update_url()">
<script type="text/javascript">
<!--
dods_lat_rho.add_dim(258);
// -->
</script>
xi_rho:<input type="text" name="dods_lat_rho_1" size=8 onfocus="describe_index()" onChange="DODS_URL.update_url()">
<script type="text/javascript">
<!--
dods_lat_rho.add_dim(182);
// -->
</script>
<br>

<textarea name="lat_rho_attr" rows=5 cols=70>
long_name: latitude of RHO-points
units: degree_north
</textarea>


<p><p>

<tr><td><td>

<script type="text/javascript">
<!--
dods_lon_rho = new dods_var("lon_rho", "dods_lon_rho", 1);
DODS_URL.add_dods_var(dods_lon_rho);
// -->
</script>
<b><input type="checkbox" name="get_dods_lon_rho"
onclick="dods_lon_rho.handle_projection_change(get_dods_lon_rho)">
<font size="+1">lon_rho</font>: Array of 64 bit Reals [eta_rho = 0..257][xi_rho = 0..181]
</b><br>

eta_rho:<input type="text" name="dods_lon_rho_0" size=8 onfocus="describe_index()" onChange="DODS_URL.update_url()">
<script type="text/javascript">
<!--
dods_lon_rho.add_dim(258);
// -->
</script>
xi_rho:<input type="text" name="dods_lon_rho_1" size=8 onfocus="describe_index()" onChange="DODS_URL.update_url()">
<script type="text/javascript">
<!--
dods_lon_rho.add_dim(182);
// -->
</script>
<br>

<textarea name="lon_rho_attr" rows=5 cols=70>
long_name: longitude of RHO-points
units: degree_east
</textarea>


<p><p>

<tr><td><td>

<script type="text/javascript">
<!--
dods_s_rho = new dods_var("s_rho", "dods_s_rho", 0);
DODS_URL.add_dods_var(dods_s_rho);
// -->
</script>
<b><input type="checkbox" name="get_dods_s_rho"
onclick="dods_s_rho.handle_projection_change(get_dods_s_rho)">
<font size="+1">s_rho</font>: 64 bit Real</b><br>

s_rho <select name="dods_s_rho_operator" onfocus="describe_operator()" onchange="DODS_URL.update_url()">
<option value="=" selected>=
<option value="!=">!=
<option value="<"><
<option value="<="><=
<option value=">">>
<option value=">=">>=
<option value="-">--
</select>
<input type="text" name="dods_s_rho_selection" size=12 onFocus="describe_selection()" onChange="DODS_URL.update_url()">
<br>

<textarea name="s_rho_attr" rows=5 cols=70>
long_name: S-coordinate at RHO-points
valid_min: -1.0
valid_max: 0.0
positive: up
standard_name: ocean_s_coordinate_g1
formula_terms: s: s_rho C: Cs_r eta: zeta depth: h depth_c: hc
field: s_rho, scalar
cell_methods: s_rho: mean
</textarea>


<p><p>

<tr><td><td>

<script type="text/javascript">
<!--
dods_Iron = new dods_var("Iron", "dods_Iron", 1);
DODS_URL.add_dods_var(dods_Iron);
// -->
</script>
<b><input type="checkbox" name="get_dods_Iron"
onclick="dods_Iron.handle_projection_change(get_dods_Iron)">
<font size="+1">Iron</font>: Array of 32 bit Reals [ocean_time = 0..4901][eta_rho = 0..257][xi_rho = 0..181]
</b><br>

ocean_time:<input type="text" name="dods_Iron_0" size=8 onfocus="describe_index()" onChange="DODS_URL.update_url()">
<script type="text/javascript">
<!--
dods_Iron.add_dim(4902);
// -->
</script>
eta_rho:<input type="text" name="dods_Iron_1" size=8 onfocus="describe_index()" onChange="DODS_URL.update_url()">
<script type="text/javascript">
<!--
dods_Iron.add_dim(258);
// -->
</script>
xi_rho:<input type="text" name="dods_Iron_2" size=8 onfocus="describe_index()" onChange="DODS_URL.update_url()">
<script type="text/javascript">
<!--
dods_Iron.add_dim(182);
// -->
</script>
<br>

<textarea name="Iron_attr" rows=5 cols=70>
long_name: time-averaged iron concentration, bottom 5m mean
units: micromol Fe m-3
time: ocean_time
coordinates: lon_rho lat_rho ocean_time
field: iron, scalar, series
_FillValue: 1.0E37
cell_methods: s_rho: mean
</textarea>


<p><p>

<tr><td><td>

<script type="text/javascript">
<!--
dods_ocean_time = new dods_var("ocean_time", "dods_ocean_time", 1);
DODS_URL.add_dods_var(dods_ocean_time);
// -->
</script>
<b><input type="checkbox" name="get_dods_ocean_time"
onclick="dods_ocean_time.handle_projection_change(get_dods_ocean_time)">
<font size="+1">ocean_time</font>: Array of 64 bit Reals [ocean_time = 0..4901]
</b><br>

ocean_time:<input type="text" name="dods_ocean_time_0" size=8 onfocus="describe_index()" onChange="DODS_URL.update_url()">
<script type="text/javascript">
<!--
dods_ocean_time.add_dim(4902);
// -->
</script>
<br>

<textarea name="ocean_time_attr" rows=5 cols=70>
long_name: averaged time since initialization
units: seconds since 1900-01-01 00:00:00
calendar: gregorian
field: time, scalar, series
</textarea>


<p><p>

<tr><td><td>

<script type="text/javascript">
<!--
dods_zeta = new dods_var("zeta", "dods_zeta", 1);
DODS_URL.add_dods_var(dods_zeta);
// -->
</script>
<b><input type="checkbox" name="get_dods_zeta"
onclick="dods_zeta.handle_projection_change(get_dods_zeta)">
<font size="+1">zeta</font>: Array of 32 bit Reals [ocean_time = 0..4901][eta_rho = 0..257][xi_rho = 0..181]
</b><br>

ocean_time:<input type="text" name="dods_zeta_0" size=8 onfocus="describe_index()" onChange="DODS_URL.update_url()">
<script type="text/javascript">
<!--
dods_zeta.add_dim(4902);
// -->
</script>
eta_rho:<input type="text" name="dods_zeta_1" size=8 onfocus="describe_index()" onChange="DODS_URL.update_url()">
<script type="text/javascript">
<!--
dods_zeta.add_dim(258);
// -->
</script>
xi_rho:<input type="text" name="dods_zeta_2" size=8 onfocus="describe_index()" onChange="DODS_URL.update_url()">
<script type="text/javascript">
<!--
dods_zeta.add_dim(182);
// -->
</script>
<br>

<textarea name="zeta_attr" rows=5 cols=70>
long_name: time-averaged free-surface
units: meter
time: ocean_time
coordinates: lon_rho lat_rho ocean_time
field: free-surface, scalar, series
_FillValue: 1.0E37
</textarea>


<p><p>

<tr><td><td>

<script type="text/javascript">
<!--
dods_NH4 = new dods_var("NH4", "dods_NH4", 1);
DODS_URL.add_dods_var(dods_NH4);
// -->
</script>
<b><input type="checkbox" name="get_dods_NH4"
onclick="dods_NH4.handle_projection_change(get_dods_NH4)">
<font size="+1">NH4</font>: Array of 32 bit Reals [ocean_time = 0..4901][eta_rho = 0..257][xi_rho = 0..181]
</b><br>

ocean_time:<input type="text" name="dods_NH4_0" size=8 onfocus="describe_index()" onChange="DODS_URL.update_url()">
<script type="text/javascript">
<!--
dods_NH4.add_dim(4902);
// -->
</script>
eta_rho:<input type="text" name="dods_NH4_1" size=8 onfocus="describe_index()" onChange="DODS_URL.update_url()">
<script type="text/javascript">
<!--
dods_NH4.add_dim(258);
// -->
</script>
xi_rho:<input type="text" name="dods_NH4_2" size=8 onfocus="describe_index()" onChange="DODS_URL.update_url()">
<script type="text/javascript">
<!--
dods_NH4.add_dim(182);
// -->
</script>
<br>

<textarea name="NH4_attr" rows=5 cols=70>
long_name: time-averaged ammonia concentration, bottom 5m mean
units: millimole nitrogen meter-3
time: ocean_time
coordinates: lon_rho lat_rho ocean_time
field: ammonia, scalar, series
_FillValue: 1.0E37
cell_methods: s_rho: mean
</textarea>


<p><p>

<tr><td><td>

<script type="text/javascript">
<!--
dods_NO3 = new dods_var("NO3", "dods_NO3", 1);
DODS_URL.add_dods_var(dods_NO3);
// -->
</script>
<b><input type="checkbox" name="get_dods_NO3"
onclick="dods_NO3.handle_projection_change(get_dods_NO3)">
<font size="+1">NO3</font>: Array of 32 bit Reals [ocean_time = 0..4901][eta_rho = 0..257][xi_rho = 0..181]
</b><br>

ocean_time:<input type="text" name="dods_NO3_0" size=8 onfocus="describe_index()" onChange="DODS_URL.update_url()">
<script type="text/javascript">
<!--
dods_NO3.add_dim(4902);
// -->
</script>
eta_rho:<input type="text" name="dods_NO3_1" size=8 onfocus="describe_index()" onChange="DODS_URL.update_url()">
<script type="text/javascript">
<!--
dods_NO3.add_dim(258);
// -->
</script>
xi_rho:<input type="text" name="dods_NO3_2" size=8 onfocus="describe_index()" onChange="DODS_URL.update_url()">
<script type="text/javascript">
<!--
dods_NO3.add_dim(182);
// -->
</script>
<br>

<textarea name="NO3_attr" rows=5 cols=70>
long_name: time-averaged nitrate concentration, bottom 5m mean
units: millimole nitrogen meter-3
time: ocean_time
coordinates: lon_rho lat_rho ocean_time
field: nitrate, scalar, series
_FillValue: 1.0E37
cell_methods: s_rho: mean
</textarea>


<p><p>

<tr><td><td>

<script type="text/javascript">
<!--
dods_temp = new dods_var("temp", "dods_temp", 1);
DODS_URL.add_dods_var(dods_temp);
// -->
</script>
<b><input type="checkbox" name="get_dods_temp"
onclick="dods_temp.handle_projection_change(get_dods_temp)">
<font size="+1">temp</font>: Array of 32 bit Reals [ocean_time = 0..4901][eta_rho = 0..257][xi_rho = 0..181]
</b><br>

ocean_time:<input type="text" name="dods_temp_0" size=8 onfocus="describe_index()" onChange="DODS_URL.update_url()">
<script type="text/javascript">
<!--
dods_temp.add_dim(4902);
// -->
</script>
eta_rho:<input type="text" name="dods_temp_1" size=8 onfocus="describe_index()" onChange="DODS_URL.update_url()">
<script type="text/javascript">
<!--
dods_temp.add_dim(258);
// -->
</script>
xi_rho:<input type="text" name="dods_temp_2" size=8 onfocus="describe_index()" onChange="DODS_URL.update_url()">
<script type="text/javascript">
<!--
dods_temp.add_dim(182);
// -->
</script>
<br>

<textarea name="temp_attr" rows=5 cols=70>
long_name: time-averaged potential temperature, bottom 5m mean
units: Celsius
time: ocean_time
coordinates: lon_rho lat_rho ocean_time
field: temperature, scalar, series
_FillValue: 1.0E37
cell_methods: s_rho: mean
</textarea>


<p><p>

<tr><td><td>

<script type="text/javascript">
<!--
dods_uEast = new dods_var("uEast", "dods_uEast", 1);
DODS_URL.add_dods_var(dods_uEast);
// -->
</script>
<b><input type="checkbox" name="get_dods_uEast"
onclick="dods_uEast.handle_projection_change(get_dods_uEast)">
<font size="+1">uEast</font>: Array of 32 bit Reals [ocean_time = 0..4901][s_rho = 0..9][eta_rho = 0..257][xi_rho = 0..181]
</b><br>

ocean_time:<input type="text" name="dods_uEast_0" size=8 onfocus="describe_index()" onChange="DODS_URL.update_url()">
<script type="text/javascript">
<!--
dods_uEast.add_dim(4902);
// -->
</script>
s_rho:<input type="text" name="dods_uEast_1" size=8 onfocus="describe_index()" onChange="DODS_URL.update_url()">
<script type="text/javascript">
<!--
dods_uEast.add_dim(10);
// -->
</script>
eta_rho:<input type="text" name="dods_uEast_2" size=8 onfocus="describe_index()" onChange="DODS_URL.update_url()">
<script type="text/javascript">
<!--
dods_uEast.add_dim(258);
// -->
</script>
xi_rho:<input type="text" name="dods_uEast_3" size=8 onfocus="describe_index()" onChange="DODS_URL.update_url()">
<script type="text/javascript">
<!--
dods_uEast.add_dim(182);
// -->
</script>
<br>

<textarea name="uEast_attr" rows=5 cols=70>
long_name: time-averaged u-momentum component, geo-rotated
units: meter second-1
</textarea>


<p><p>

<tr><td><td>

<script type="text/javascript">
<!--
dods_vNorth = new dods_var("vNorth", "dods_vNorth", 1);
DODS_URL.add_dods_var(dods_vNorth);
// -->
</script>
<b><input type="checkbox" name="get_dods_vNorth"
onclick="dods_vNorth.handle_projection_change(get_dods_vNorth)">
<font size="+1">vNorth</font>: Array of 32 bit Reals [ocean_time = 0..4901][s_rho = 0..9][eta_rho = 0..257][xi_rho = 0..181]
</b><br>

ocean_time:<input type="text" name="dods_vNorth_0" size=8 onfocus="describe_index()" onChange="DODS_URL.update_url()">
<script type="text/javascript">
<!--
dods_vNorth.add_dim(4902);
// -->
</script>
s_rho:<input type="text" name="dods_vNorth_1" size=8 onfocus="describe_index()" onChange="DODS_URL.update_url()">
<script type="text/javascript">
<!--
dods_vNorth.add_dim(10);
// -->
</script>
eta_rho:<input type="text" name="dods_vNorth_2" size=8 onfocus="describe_index()" onChange="DODS_URL.update_url()">
<script type="text/javascript">
<!--
dods_vNorth.add_dim(258);
// -->
</script>
xi_rho:<input type="text" name="dods_vNorth_3" size=8 onfocus="describe_index()" onChange="DODS_URL.update_url()">
<script type="text/javascript">
<!--
dods_vNorth.add_dim(182);
// -->
</script>
<br>

<textarea name="vNorth_attr" rows=5 cols=70>
long_name: time-averaged v-momentum component, geo-rotated
units: meter second-1
</textarea>


<p><p>

<tr><td><td>

<script type="text/javascript">
<!--
dods_lat_psi = new dods_var("lat_psi", "dods_lat_psi", 1);
DODS_URL.add_dods_var(dods_lat_psi);
// -->
</script>
<b><input type="checkbox" name="get_dods_lat_psi"
onclick="dods_lat_psi.handle_projection_change(get_dods_lat_psi)">
<font size="+1">lat_psi</font>: Array of 64 bit Reals [eta_psi = 0..256][xi_psi = 0..180]
</b><br>

eta_psi:<input type="text" name="dods_lat_psi_0" size=8 onfocus="describe_index()" onChange="DODS_URL.update_url()">
<script type="text/javascript">
<!--
dods_lat_psi.add_dim(257);
// -->
</script>
xi_psi:<input type="text" name="dods_lat_psi_1" size=8 onfocus="describe_index()" onChange="DODS_URL.update_url()">
<script type="text/javascript">
<!--
dods_lat_psi.add_dim(181);
// -->
</script>
<br>

<textarea name="lat_psi_attr" rows=5 cols=70>
long_name: latitude of PSI-points
units: degree_north
</textarea>


<p><p>

<tr><td><td>

<script type="text/javascript">
<!--
dods_lon_psi = new dods_var("lon_psi", "dods_lon_psi", 1);
DODS_URL.add_dods_var(dods_lon_psi);
// -->
</script>
<b><input type="checkbox" name="get_dods_lon_psi"
onclick="dods_lon_psi.handle_projection_change(get_dods_lon_psi)">
<font size="+1">lon_psi</font>: Array of 64 bit Reals [eta_psi = 0..256][xi_psi = 0..180]
</b><br>

eta_psi:<input type="text" name="dods_lon_psi_0" size=8 onfocus="describe_index()" onChange="DODS_URL.update_url()">
<script type="text/javascript">
<!--
dods_lon_psi.add_dim(257);
// -->
</script>
xi_psi:<input type="text" name="dods_lon_psi_1" size=8 onfocus="describe_index()" onChange="DODS_URL.update_url()">
<script type="text/javascript">
<!--
dods_lon_psi.add_dim(181);
// -->
</script>
<br>

<textarea name="lon_psi_attr" rows=5 cols=70>
long_name: longitude of PSI-points
units: degree_east
</textarea>


<p><p>

<tr><td><td>

<script type="text/javascript">
<!--
dods_z_psi = new dods_var("z_psi", "dods_z_psi", 1);
DODS_URL.add_dods_var(dods_z_psi);
// -->
</script>
<b><input type="checkbox" name="get_dods_z_psi"
onclick="dods_z_psi.handle_projection_change(get_dods_z_psi)">
<font size="+1">z_psi</font>: Array of 32 bit Reals [ocean_time = 0..4901][s_rho = 0..9][eta_psi = 0..256][xi_psi = 0..180]
</b><br>

ocean_time:<input type="text" name="dods_z_psi_0" size=8 onfocus="describe_index()" onChange="DODS_URL.update_url()">
<script type="text/javascript">
<!--
dods_z_psi.add_dim(4902);
// -->
</script>
s_rho:<input type="text" name="dods_z_psi_1" size=8 onfocus="describe_index()" onChange="DODS_URL.update_url()">
<script type="text/javascript">
<!--
dods_z_psi.add_dim(10);
// -->
</script>
eta_psi:<input type="text" name="dods_z_psi_2" size=8 onfocus="describe_index()" onChange="DODS_URL.update_url()">
<script type="text/javascript">
<!--
dods_z_psi.add_dim(257);
// -->
</script>
xi_psi:<input type="text" name="dods_z_psi_3" size=8 onfocus="describe_index()" onChange="DODS_URL.update_url()">
<script type="text/javascript">
<!--
dods_z_psi.add_dim(181);
// -->
</script>
<br>

<textarea name="z_psi_attr" rows=5 cols=70>
long_name: depth at horizontal psi points, rho depth
units: m
coordinates: lon_psi lat_psi s_rho ocean_time
</textarea>


<p><p>

<tr><td><td>

<script type="text/javascript">
<!--
dods_Cs_w = new dods_var("Cs_w", "dods_Cs_w", 1);
DODS_URL.add_dods_var(dods_Cs_w);
// -->
</script>
<b><input type="checkbox" name="get_dods_Cs_w"
onclick="dods_Cs_w.handle_projection_change(get_dods_Cs_w)">
<font size="+1">Cs_w</font>: Array of 64 bit Reals [s_w = 0..10]
</b><br>

s_w:<input type="text" name="dods_Cs_w_0" size=8 onfocus="describe_index()" onChange="DODS_URL.update_url()">
<script type="text/javascript">
<!--
dods_Cs_w.add_dim(11);
// -->
</script>
<br>

<textarea name="Cs_w_attr" rows=5 cols=70>
long_name: S-coordinate stretching curves at W-points
valid_min: -1.0
valid_max: 0.0
field: Cs_w, scalar
</textarea>


<p><p>

<tr><td><td>

<script type="text/javascript">
<!--
dods_s_w = new dods_var("s_w", "dods_s_w", 1);
DODS_URL.add_dods_var(dods_s_w);
// -->
</script>
<b><input type="checkbox" name="get_dods_s_w"
onclick="dods_s_w.handle_projection_change(get_dods_s_w)">
<font size="+1">s_w</font>: Array of 64 bit Reals [s_w = 0..10]
</b><br>

s_w:<input type="text" name="dods_s_w_0" size=8 onfocus="describe_index()" onChange="DODS_URL.update_url()">
<script type="text/javascript">
<!--
dods_s_w.add_dim(11);
// -->
</script>
<br>

<textarea name="s_w_attr" rows=5 cols=70>
long_name: S-coordinate at W-points
valid_min: -1.0
valid_max: 0.0
positive: up
standard_name: ocean_s_coordinate_g1
formula_terms: s: s_w C: Cs_w eta: zeta depth: h depth_c: hc
field: s_w, scalar
</textarea>


<p><p>

<tr><td><td>

<script type="text/javascript">
<!--
dods_z_psi_w = new dods_var("z_psi_w", "dods_z_psi_w", 1);
DODS_URL.add_dods_var(dods_z_psi_w);
// -->
</script>
<b><input type="checkbox" name="get_dods_z_psi_w"
onclick="dods_z_psi_w.handle_projection_change(get_dods_z_psi_w)">
<font size="+1">z_psi_w</font>: Array of 32 bit Reals [ocean_time = 0..4901][s_w = 0..10][eta_psi = 0..256][xi_psi = 0..180]
</b><br>

ocean_time:<input type="text" name="dods_z_psi_w_0" size=8 onfocus="describe_index()" onChange="DODS_URL.update_url()">
<script type="text/javascript">
<!--
dods_z_psi_w.add_dim(4902);
// -->
</script>
s_w:<input type="text" name="dods_z_psi_w_1" size=8 onfocus="describe_index()" onChange="DODS_URL.update_url()">
<script type="text/javascript">
<!--
dods_z_psi_w.add_dim(11);
// -->
</script>
eta_psi:<input type="text" name="dods_z_psi_w_2" size=8 onfocus="describe_index()" onChange="DODS_URL.update_url()">
<script type="text/javascript">
<!--
dods_z_psi_w.add_dim(257);
// -->
</script>
xi_psi:<input type="text" name="dods_z_psi_w_3" size=8 onfocus="describe_index()" onChange="DODS_URL.update_url()">
<script type="text/javascript">
<!--
dods_z_psi_w.add_dim(181);
// -->
</script>
<br>

<textarea name="z_psi_w_attr" rows=5 cols=70>
long_name: depth at horizontal psi points, w depth
units: m
coordinates: lon_psi lat_psi s_w ocean_time
</textarea>


<p><p>

<tr><td><td>

<script type="text/javascript">
<!--
dods_z_rho = new dods_var("z_rho", "dods_z_rho", 1);
DODS_URL.add_dods_var(dods_z_rho);
// -->
</script>
<b><input type="checkbox" name="get_dods_z_rho"
onclick="dods_z_rho.handle_projection_change(get_dods_z_rho)">
<font size="+1">z_rho</font>: Array of 32 bit Reals [ocean_time = 0..4901][s_rho = 0..9][eta_rho = 0..257][xi_rho = 0..181]
</b><br>

ocean_time:<input type="text" name="dods_z_rho_0" size=8 onfocus="describe_index()" onChange="DODS_URL.update_url()">
<script type="text/javascript">
<!--
dods_z_rho.add_dim(4902);
// -->
</script>
s_rho:<input type="text" name="dods_z_rho_1" size=8 onfocus="describe_index()" onChange="DODS_URL.update_url()">
<script type="text/javascript">
<!--
dods_z_rho.add_dim(10);
// -->
</script>
eta_rho:<input type="text" name="dods_z_rho_2" size=8 onfocus="describe_index()" onChange="DODS_URL.update_url()">
<script type="text/javascript">
<!--
dods_z_rho.add_dim(258);
// -->
</script>
xi_rho:<input type="text" name="dods_z_rho_3" size=8 onfocus="describe_index()" onChange="DODS_URL.update_url()">
<script type="text/javascript">
<!--
dods_z_rho.add_dim(182);
// -->
</script>
<br>

<textarea name="z_rho_attr" rows=5 cols=70>
long_name: depth at horizontal rho points, rho depth
units: m
coordinates: lon_rho lat_rho s_rho ocean_time
</textarea>


<p><p>

<tr><td><td>

<script type="text/javascript">
<!--
dods_lat_u = new dods_var("lat_u", "dods_lat_u", 1);
DODS_URL.add_dods_var(dods_lat_u);
// -->
</script>
<b><input type="checkbox" name="get_dods_lat_u"
onclick="dods_lat_u.handle_projection_change(get_dods_lat_u)">
<font size="+1">lat_u</font>: Array of 64 bit Reals [eta_u = 0..257][xi_u = 0..180]
</b><br>

eta_u:<input type="text" name="dods_lat_u_0" size=8 onfocus="describe_index()" onChange="DODS_URL.update_url()">
<script type="text/javascript">
<!--
dods_lat_u.add_dim(258);
// -->
</script>
xi_u:<input type="text" name="dods_lat_u_1" size=8 onfocus="describe_index()" onChange="DODS_URL.update_url()">
<script type="text/javascript">
<!--
dods_lat_u.add_dim(181);
// -->
</script>
<br>

<textarea name="lat_u_attr" rows=5 cols=70>
long_name: latitude of U-points
units: degree_north
</textarea>


<p><p>

<tr><td><td>

<script type="text/javascript">
<!--
dods_lon_u = new dods_var("lon_u", "dods_lon_u", 1);
DODS_URL.add_dods_var(dods_lon_u);
// -->
</script>
<b><input type="checkbox" name="get_dods_lon_u"
onclick="dods_lon_u.handle_projection_change(get_dods_lon_u)">
<font size="+1">lon_u</font>: Array of 64 bit Reals [eta_u = 0..257][xi_u = 0..180]
</b><br>

eta_u:<input type="text" name="dods_lon_u_0" size=8 onfocus="describe_index()" onChange="DODS_URL.update_url()">
<script type="text/javascript">
<!--
dods_lon_u.add_dim(258);
// -->
</script>
xi_u:<input type="text" name="dods_lon_u_1" size=8 onfocus="describe_index()" onChange="DODS_URL.update_url()">
<script type="text/javascript">
<!--
dods_lon_u.add_dim(181);
// -->
</script>
<br>

<textarea name="lon_u_attr" rows=5 cols=70>
long_name: longitude of U-points
units: degree_east
</textarea>


<p><p>

<tr><td><td>

<script type="text/javascript">
<!--
dods_z_u = new dods_var("z_u", "dods_z_u", 1);
DODS_URL.add_dods_var(dods_z_u);
// -->
</script>
<b><input type="checkbox" name="get_dods_z_u"
onclick="dods_z_u.handle_projection_change(get_dods_z_u)">
<font size="+1">z_u</font>: Array of 32 bit Reals [ocean_time = 0..4901][s_rho = 0..9][eta_u = 0..257][xi_u = 0..180]
</b><br>

ocean_time:<input type="text" name="dods_z_u_0" size=8 onfocus="describe_index()" onChange="DODS_URL.update_url()">
<script type="text/javascript">
<!--
dods_z_u.add_dim(4902);
// -->
</script>
s_rho:<input type="text" name="dods_z_u_1" size=8 onfocus="describe_index()" onChange="DODS_URL.update_url()">
<script type="text/javascript">
<!--
dods_z_u.add_dim(10);
// -->
</script>
eta_u:<input type="text" name="dods_z_u_2" size=8 onfocus="describe_index()" onChange="DODS_URL.update_url()">
<script type="text/javascript">
<!--
dods_z_u.add_dim(258);
// -->
</script>
xi_u:<input type="text" name="dods_z_u_3" size=8 onfocus="describe_index()" onChange="DODS_URL.update_url()">
<script type="text/javascript">
<!--
dods_z_u.add_dim(181);
// -->
</script>
<br>

<textarea name="z_u_attr" rows=5 cols=70>
long_name: depth at horizontal u points, rho depth
units: m
coordinates: lon_u lat_u s_rho ocean_time
</textarea>


<p><p>

<tr><td><td>

<script type="text/javascript">
<!--
dods_z_u_w = new dods_var("z_u_w", "dods_z_u_w", 1);
DODS_URL.add_dods_var(dods_z_u_w);
// -->
</script>
<b><input type="checkbox" name="get_dods_z_u_w"
onclick="dods_z_u_w.handle_projection_change(get_dods_z_u_w)">
<font size="+1">z_u_w</font>: Array of 32 bit Reals [ocean_time = 0..4901][s_w = 0..10][eta_u = 0..257][xi_u = 0..180]
</b><br>

ocean_time:<input type="text" name="dods_z_u_w_0" size=8 onfocus="describe_index()" onChange="DODS_URL.update_url()">
<script type="text/javascript">
<!--
dods_z_u_w.add_dim(4902);
// -->
</script>
s_w:<input type="text" name="dods_z_u_w_1" size=8 onfocus="describe_index()" onChange="DODS_URL.update_url()">
<script type="text/javascript">
<!--
dods_z_u_w.add_dim(11);
// -->
</script>
eta_u:<input type="text" name="dods_z_u_w_2" size=8 onfocus="describe_index()" onChange="DODS_URL.update_url()">
<script type="text/javascript">
<!--
dods_z_u_w.add_dim(258);
// -->
</script>
xi_u:<input type="text" name="dods_z_u_w_3" size=8 onfocus="describe_index()" onChange="DODS_URL.update_url()">
<script type="text/javascript">
<!--
dods_z_u_w.add_dim(181);
// -->
</script>
<br>

<textarea name="z_u_w_attr" rows=5 cols=70>
long_name: depth at horizontal u points, w depth
units: m
coordinates: lon_u lat_u s_w ocean_time
</textarea>


<p><p>

<tr><td><td>

<script type="text/javascript">
<!--
dods_lat_v = new dods_var("lat_v", "dods_lat_v", 1);
DODS_URL.add_dods_var(dods_lat_v);
// -->
</script>
<b><input type="checkbox" name="get_dods_lat_v"
onclick="dods_lat_v.handle_projection_change(get_dods_lat_v)">
<font size="+1">lat_v</font>: Array of 64 bit Reals [eta_v = 0..256][xi_v = 0..181]
</b><br>

eta_v:<input type="text" name="dods_lat_v_0" size=8 onfocus="describe_index()" onChange="DODS_URL.update_url()">
<script type="text/javascript">
<!--
dods_lat_v.add_dim(257);
// -->
</script>
xi_v:<input type="text" name="dods_lat_v_1" size=8 onfocus="describe_index()" onChange="DODS_URL.update_url()">
<script type="text/javascript">
<!--
dods_lat_v.add_dim(182);
// -->
</script>
<br>

<textarea name="lat_v_attr" rows=5 cols=70>
long_name: latitude of V-points
units: degree_north
</textarea>


<p><p>

<tr><td><td>

<script type="text/javascript">
<!--
dods_lon_v = new dods_var("lon_v", "dods_lon_v", 1);
DODS_URL.add_dods_var(dods_lon_v);
// -->
</script>
<b><input type="checkbox" name="get_dods_lon_v"
onclick="dods_lon_v.handle_projection_change(get_dods_lon_v)">
<font size="+1">lon_v</font>: Array of 64 bit Reals [eta_v = 0..256][xi_v = 0..181]
</b><br>

eta_v:<input type="text" name="dods_lon_v_0" size=8 onfocus="describe_index()" onChange="DODS_URL.update_url()">
<script type="text/javascript">
<!--
dods_lon_v.add_dim(257);
// -->
</script>
xi_v:<input type="text" name="dods_lon_v_1" size=8 onfocus="describe_index()" onChange="DODS_URL.update_url()">
<script type="text/javascript">
<!--
dods_lon_v.add_dim(182);
// -->
</script>
<br>

<textarea name="lon_v_attr" rows=5 cols=70>
long_name: longitude of V-points
units: degree_east
</textarea>


<p><p>

<tr><td><td>

<script type="text/javascript">
<!--
dods_z_v = new dods_var("z_v", "dods_z_v", 1);
DODS_URL.add_dods_var(dods_z_v);
// -->
</script>
<b><input type="checkbox" name="get_dods_z_v"
onclick="dods_z_v.handle_projection_change(get_dods_z_v)">
<font size="+1">z_v</font>: Array of 32 bit Reals [ocean_time = 0..4901][s_rho = 0..9][eta_v = 0..256][xi_v = 0..181]
</b><br>

ocean_time:<input type="text" name="dods_z_v_0" size=8 onfocus="describe_index()" onChange="DODS_URL.update_url()">
<script type="text/javascript">
<!--
dods_z_v.add_dim(4902);
// -->
</script>
s_rho:<input type="text" name="dods_z_v_1" size=8 onfocus="describe_index()" onChange="DODS_URL.update_url()">
<script type="text/javascript">
<!--
dods_z_v.add_dim(10);
// -->
</script>
eta_v:<input type="text" name="dods_z_v_2" size=8 onfocus="describe_index()" onChange="DODS_URL.update_url()">
<script type="text/javascript">
<!--
dods_z_v.add_dim(257);
// -->
</script>
xi_v:<input type="text" name="dods_z_v_3" size=8 onfocus="describe_index()" onChange="DODS_URL.update_url()">
<script type="text/javascript">
<!--
dods_z_v.add_dim(182);
// -->
</script>
<br>

<textarea name="z_v_attr" rows=5 cols=70>
long_name: depth at horizontal v points, rho depth
units: m
coordinates: lon_v lat_v s_rho ocean_time
</textarea>


<p><p>

<tr><td><td>

<script type="text/javascript">
<!--
dods_z_v_w = new dods_var("z_v_w", "dods_z_v_w", 1);
DODS_URL.add_dods_var(dods_z_v_w);
// -->
</script>
<b><input type="checkbox" name="get_dods_z_v_w"
onclick="dods_z_v_w.handle_projection_change(get_dods_z_v_w)">
<font size="+1">z_v_w</font>: Array of 32 bit Reals [ocean_time = 0..4901][s_w = 0..10][eta_v = 0..256][xi_v = 0..181]
</b><br>

ocean_time:<input type="text" name="dods_z_v_w_0" size=8 onfocus="describe_index()" onChange="DODS_URL.update_url()">
<script type="text/javascript">
<!--
dods_z_v_w.add_dim(4902);
// -->
</script>
s_w:<input type="text" name="dods_z_v_w_1" size=8 onfocus="describe_index()" onChange="DODS_URL.update_url()">
<script type="text/javascript">
<!--
dods_z_v_w.add_dim(11);
// -->
</script>
eta_v:<input type="text" name="dods_z_v_w_2" size=8 onfocus="describe_index()" onChange="DODS_URL.update_url()">
<script type="text/javascript">
<!--
dods_z_v_w.add_dim(257);
// -->
</script>
xi_v:<input type="text" name="dods_z_v_w_3" size=8 onfocus="describe_index()" onChange="DODS_URL.update_url()">
<script type="text/javascript">
<!--
dods_z_v_w.add_dim(182);
// -->
</script>
<br>

<textarea name="z_v_w_attr" rows=5 cols=70>
long_name: depth at horizontal v points, w depth
units: m
coordinates: lon_v lat_v s_w ocean_time
</textarea>


<p><p>

<tr><td><td>

<script type="text/javascript">
<!--
dods_z_w = new dods_var("z_w", "dods_z_w", 1);
DODS_URL.add_dods_var(dods_z_w);
// -->
</script>
<b><input type="checkbox" name="get_dods_z_w"
onclick="dods_z_w.handle_projection_change(get_dods_z_w)">
<font size="+1">z_w</font>: Array of 32 bit Reals [ocean_time = 0..4901][s_w = 0..10][eta_rho = 0..257][xi_rho = 0..181]
</b><br>

ocean_time:<input type="text" name="dods_z_w_0" size=8 onfocus="describe_index()" onChange="DODS_URL.update_url()">
<script type="text/javascript">
<!--
dods_z_w.add_dim(4902);
// -->
</script>
s_w:<input type="text" name="dods_z_w_1" size=8 onfocus="describe_index()" onChange="DODS_URL.update_url()">
<script type="text/javascript">
<!--
dods_z_w.add_dim(11);
// -->
</script>
eta_rho:<input type="text" name="dods_z_w_2" size=8 onfocus="describe_index()" onChange="DODS_URL.update_url()">
<script type="text/javascript">
<!--
dods_z_w.add_dim(258);
// -->
</script>
xi_rho:<input type="text" name="dods_z_w_3" size=8 onfocus="describe_index()" onChange="DODS_URL.update_url()">
<script type="text/javascript">
<!--
dods_z_w.add_dim(182);
// -->
</script>
<br>

<textarea name="z_w_attr" rows=5 cols=70>
long_name: depth at horizontal rho points, w depth
units: m
coordinates: lon_rho lat_rho s_w ocean_time
</textarea>


<p><p>

<tr><td><td>

</table></form>

<hr>

<address>
<p>For questions or comments about this dataset, contact the administrator of this server [NOAA ACLIM] at: <a href='mailto:roland.schweitzer@noaa.gov'>roland.schweitzer@noaa.gov</a></p>
<p>For questions or comments about OPeNDAP, email OPeNDAP support at: <a href='mailto:support@opendap.org'>support@opendap.org</a></p>
</address></body></html>
<hr>
<h2>DDS:</h2>
<pre>
Dataset {
    Float64 Cs_r;
    Float64 hc;
    Float64 lat_rho[eta_rho = 258][xi_rho = 182];
    Float64 lon_rho[eta_rho = 258][xi_rho = 182];
    Float64 s_rho;
    Float32 Iron[ocean_time = 4902][eta_rho = 258][xi_rho = 182];
    Float64 ocean_time[ocean_time = 4902];
    Float32 zeta[ocean_time = 4902][eta_rho = 258][xi_rho = 182];
    Float32 NH4[ocean_time = 4902][eta_rho = 258][xi_rho = 182];
    Float32 NO3[ocean_time = 4902][eta_rho = 258][xi_rho = 182];
    Float32 temp[ocean_time = 4902][eta_rho = 258][xi_rho = 182];
    Float32 uEast[ocean_time = 4902][s_rho = 10][eta_rho = 258][xi_rho = 182];
    Float32 vNorth[ocean_time = 4902][s_rho = 10][eta_rho = 258][xi_rho = 182];
    Float64 lat_psi[eta_psi = 257][xi_psi = 181];
    Float64 lon_psi[eta_psi = 257][xi_psi = 181];
    Float32 z_psi[ocean_time = 4902][s_rho = 10][eta_psi = 257][xi_psi = 181];
    Float64 Cs_w[s_w = 11];
    Float64 s_w[s_w = 11];
    Float32 z_psi_w[ocean_time = 4902][s_w = 11][eta_psi = 257][xi_psi = 181];
    Float32 z_rho[ocean_time = 4902][s_rho = 10][eta_rho = 258][xi_rho = 182];
    Float64 lat_u[eta_u = 258][xi_u = 181];
    Float64 lon_u[eta_u = 258][xi_u = 181];
    Float32 z_u[ocean_time = 4902][s_rho = 10][eta_u = 258][xi_u = 181];
    Float32 z_u_w[ocean_time = 4902][s_w = 11][eta_u = 258][xi_u = 181];
    Float64 lat_v[eta_v = 257][xi_v = 182];
    Float64 lon_v[eta_v = 257][xi_v = 182];
    Float32 z_v[ocean_time = 4902][s_rho = 10][eta_v = 257][xi_v = 182];
    Float32 z_v_w[ocean_time = 4902][s_w = 11][eta_v = 257][xi_v = 182];
    Float32 z_w[ocean_time = 4902][s_w = 11][eta_rho = 258][xi_rho = 182];
} Level2/B10K-H16_CMIP5_MIROC_rcp45_bottom5m.nc;
</pre>
<hr>
