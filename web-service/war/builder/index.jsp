<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html>
<head>
	<title>GTE&#946;</title>
	<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
	<meta name="language" content="en" />
	<meta name="description" content="" />
	<meta name="keywords" content="" />
	
	<script src="swfobject.js" type="text/javascript"></script>
	<script type="text/javascript">
		<!-- For version detection, set to min. required Flash Player version, or 0 (or 0.0.0), for no version detection. --> 
        var swfVersionStr = "10.0.0";
        <!-- To use express install, set to playerProductInstall.swf, otherwise the empty string. -->
        var xiSwfUrlStr = "playerProductInstall.swf";
		var flashvars = {
			menum: "label=Lrs Find All Eq;toolTip=Lrs Find All Equilibria;type=nf;url=/matrix/",
		  	msolve: "label=Lemke NF Eq;toolTip=Lemke Find One Equilibrium;type=nf;url=/matrix/",   
	        xsolve: "label=Lemke SF Eq;toolTip=Lemke Find One Equilibrium (Sequence Form);type=xf;url=/tree/",			
	    };
	    <% if (request.getParameter("s") != null) { %>
	    flashvars.seed = "<%= request.getParameter("s") %>";
	    <% } %>
		var params = {
			menu: "false",
			scale: "noScale",
			allowFullscreen: "true",
			allowScriptAccess: "always",
			bgcolor: "#FFFFFF"			
		};
		var attributes = {
			id:"GuiBuilder"
		};
		
		var fullwindow = true;

		swfobject.embedSWF(
			"GuiBuilder.swf", 
			"flashContent", 
			"100%", 
			"100%", 
			swfVersionStr, 
			xiSwfUrlStr, 
			flashvars, 
			params, 
			attributes);
			
			
		function writeSolution(data)
		{
			var regex = /^SUCCESS/;
			var header = document.getElementById("solutionHeader");
			if (regex.test(data)) {
				header.style.backgroundColor = "#00ff6b";
			} else {
				header.style.backgroundColor = "#ff0000";
			}
			header.style.display  = "block";

			var body = document.getElementById("solution");
			body.style.display = "block";
			body.innerHTML = "<pre>" + data + "</pre>";
		}
		
			
		function expand()
		{
			if(fullwindow) //Contract
			{
				document.getElementById("GTEContainer").style.width = "85%";
				document.getElementById("expandButton").innerHTML = "Expand";
				document.getElementById("flashContainer").style.height = "580px";
			}
			else //Expand
			{
				document.getElementById("GTEContainer").style.width = "99%";
				document.getElementById("expandButton").innerHTML = "Contract";
				document.getElementById("flashContainer").style.height = getFlashContainerExpandedSize(); //?
			}
			
			fullwindow = !fullwindow;
		}
		
 		function getFlashContainerExpandedSize()
		{
			var pixels = document.body.clientHeight - document.getElementById("titleContainer").offsetHeight - 50;
			return ""+pixels+"px";
		} 
		
	</script>
	<style type="text/css">
		html, body { height:100%; background-color: #303030;}		
		body { margin:0; }
		object:focus { outline:none; }		
	</style>
</head>
<body onload="expand()">
	<div id="titleContainer" style="text-align: left; width: 85%; margin: auto; background-color: #303030; color: #ffffff; padding: 0px 5px 0px 5px; border-left: 1px solid #303030; border-right: 1px solid #303030;">
		<img style="display:inline; vertical-align: middle; border: #808080 solid 1px; margin: 5px 5px 5px 0px;" src="minitree_32x32.png" />
		<div style="vertical-align: middle; display: inline-block; margin: 5px 5px 5px 0px;">
			<h3 style="display: inline; font-family: Helvetica;">Game Theory Explorer <span style="color: #ffd700">&#946;</span></h3><br/>
			<em style="font-size: 13px; font-family: Helvetica; color: #a0a0a0;">Build, explore and solve extensive form games.</em>
		</div>
	</div>
	<div id="GTEContainer" style="text-align: left; width: 85%; margin: auto; background-color: #B7BABC; padding: 2px 5px 5px 5px; border: 1px solid #808080;">
		<!-- <div style="background-color: #e0e0e0; border: #808080 solid 1px; font-size: 12px; padding: 3px 5px 3px 5px; font-family: Helvetica; font-weight: bold;">Build</div> -->
		<div id="flashContainer">
			<div id="flashContent">			
				<p>
					To view this page ensure that Adobe Flash Player version 
					10.0.0 or greater is installed. 
				</p>
				<script type="text/javascript"> 
					var pageHost = ((document.location.protocol == "https:") ? "https://" :	"http://"); 
					document.write("<a href='http://www.adobe.com/go/getflashplayer'><img src='" 
									+ pageHost + "www.adobe.com/images/shared/download_buttons/get_flash_player.gif' alt='Get Adobe Flash player' /></a>" ); 
				</script>
				<noscript>
					<object classid="clsid:D27CDB6E-AE6D-11cf-96B8-444553540000" width="100%" height="100%" id="GuiBuilder">
						<param name="movie" value="GuiBuilder.swf" />
						<param name="quality" value="high" />
						<param name="bgcolor" value="white" />
						<param name="allowScriptAccess" value="sameDomain" />
						<param name="allowFullScreen" value="true" />
						<!--[if !IE]>-->
						<object type="application/x-shockwave-flash" data="GuiBuilder.swf" width="100%" height="100%">
							<param name="quality" value="high" />
							<param name="bgcolor" value="white" />
							<param name="allowScriptAccess" value="sameDomain" />
							<param name="allowFullScreen" value="true" />
						<!--<![endif]-->
						<!--[if gte IE 6]>-->
							<p> 
								Either scripts and active content are not permitted to run or Adobe Flash Player version
								10.0.0 or greater is not installed.
							</p>
						<!--<![endif]-->
							<a href="http://www.adobe.com/go/getflashplayer">
								<img src="http://www.adobe.com/images/shared/download_buttons/get_flash_player.gif" alt="Get Adobe Flash Player" />
							</a>
						<!--[if !IE]>-->
						</object>
						<!--<![endif]-->
					</object>
				</noscript>	
			</div>
		</div>
		<div id="solutionHeader" style="background-color: #00ff6b; color: #003300; border: #808080 solid 1px; font-size: 12px; padding: 3px 5px 3px 5px; font-family: Helvetica; font-weight: bold; margin-top: 5px; display: none;">&#160;</div>
		<div id="solution" style="background-color: #ffffff; border: #808080 solid 1px; border-top: 0; font-size: 12px; padding: 3px 5px 3px 5px; display: none; overflow: auto;">		
		</div>
	</div>
	<div style="font-size: 10px; font-family: Helvetica; text-align: left; width: 85%; margin: auto; background-color: #303030; color: #a0a0a0; padding: 3px 5px 3px 5px; border-left: 1px solid #303030; border-right: 1px solid #303030;">
		<div>
		<button id="expandButton" type="button" onclick="expand()">Expand</button><br/>
		<div style="display: inline-block; margin-bottom: 5px;">Last modified: yyyy-MM-dd hh:mm GMT</div><br/>
		<!--  Copyright 2010 <span style="color: #ffffff;">Mark Egesdal</span><br/> -->
		Developed by <span style="color: #ffffff;">Mark Egesdal</span> et al.<br/>Lemke algorithm and Sequence Form implementations adapted from the work of Bernhard von Stengel.<br/>Lrs algorithm implementation adapted from the work of David Avis.  Lrs enumeration adapted from the work of Rahul Savani.<br/>Most icons courtesy of the Silk Icon Set created by Mark James.
		</div>
	</div>
</body>
</html>