<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html>
<head>
	<title>GTE&#946;</title>
	<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
	<meta name="language" content="en" />
	<meta name="description" content="" />
	<meta name="keywords" content="" />

	<link href='https://fonts.googleapis.com/css?family=Architects+Daughter' rel='stylesheet' type='text/css'/>

	
	<script src="swfobject.js" type="text/javascript"></script>
	<script type="text/javascript" src="http://code.jquery.com/jquery-latest.js"></script>

	<script type="text/javascript" src="js/jquery.scrollTo.js"></script>
	<script type="text/javascript" src="js/jquery.localscroll.js"></script>
	<script type="text/javascript" src="js/jquery-ui-1.7.1.custom.min.js"></script>
	<script type="text/javascript" src="js/execute.js"></script>
	<script type="text/javascript" src="js/jqFancyTransitions.1.8.js"></script>

	<script type="text/javascript">
	

		
		//Before closing the browser window, it prompts if there are unsaved changes
		window.onbeforeunload = function (evt)
		{ 
		   if(getFlashMovie().askBeforeQuit())
		   {
			  var message = 'The current file has unsaved changes. '
							+ 'Do you really want to quit?'; 
			  return message;
		   }
		}	
	
		  $(document).ready(function()
		    {
		      $('#box-links').localScroll({
  			 		target:'body'
				});	 
  			 $('#slideshowHolder').jqFancyTransitions({ width: 510, height: 250, delay: 2000 });	
				
		    });
		    
    
	</script>
	<style type="text/css">
		html, body { height:100%; background-color: #303030; background: url(header-bg.jpg) repeat;}		
		body { margin:0; }
		object:focus { outline:none; }	
		h1 {
		
		  font-family: serif; 
		  font-size: 40px;
		  color: #fff;
		  text-align: center;

 		}
		
		h2 {
		
		  font-family: serif; 
		  font-size: 28px;
		  color: #fff;
		  text-align: center;		  
		}
		
		h3 {
		
		  font-family: serif; 
		  font-size: 28px;
		  color: #fff;
		}

		
		.menuFont {
		  font-family: serif; 
		  font-size: 32px;
		  color: #fff;
		}
		.normalFont {
		  font-family: serif; 
		  font-size: 18px;
		  color: #fff;
		}

		
		#nav-shadow {
			margin: 0 auto 50px auto;
			padding: 50px 0 0 127px;
			width: 700px;
			min-height: 130px;
			text-align: center;
			
			list-style: none;
			}
			
		#nav-shadow li {
			margin-right: 15px;
			width: 140px;
			height: 72px;
			position: relative;
			float: left;
			}
			
		#nav-shadow a, #nav-shadow a:visited, #nav-shadow a, #nav-shadow a:hover {
			margin: 0 auto;
			width: 59px;
			height: 59px;
			text-indent: -9999px;
			overflow: hidden;
			background: url(icons.png) no-repeat;
			display: block;
			position: relative;
			z-index: 2;
			}
			
		/* Button Colors */
		
		#nav-shadow li.button-color-1 a {
			background-position: -3px -3px;
			}
			
		#nav-shadow li.button-color-2 a {
			background-position: -92px -3px;
			}
			
		#nav-shadow li.button-color-3 a {
			background-position: -181px -3px;
			}
			
		#nav-shadow li.button-color-4 a {
			background-position: -270px -3px;
			}
			
		/* Button Shadow */
		
		#nav-shadow li img.shadow {
			margin: 0 auto;
			position: absolute;
			bottom: 0;
			left: 0;
			z-index: 1;
			}
	</style>
</head>
<body onload="javascript:prepareVars();">
<div id="box-links"> 
<div id="top">
	<h1> GTE - Game Theory Explorer</h1>
	<h2 style="text-align:center"> Build, explore and solve extensive and strategic form games.</h2>
</div>
<ul id="nav-shadow">
	<li class="button-color-1"><a href="#GTE" ></a><p class="menuFont">Explore GTE</p></li>
	<li class="button-color-3"><a href="#Tutorial" ></a><p class="menuFont">Tutorial</p></li>
	<li class="button-color-2"><a href="#Download" ></a><p class="menuFont">Download</p></li>
	<li class="button-color-4"><a href="#Contact" ></a><p class="menuFont">Contact</p></li>
</ul>


<div style=" margin: 0 auto;  width: 700px;  ">
<p class="normalFont">
The Game Theory Explorer (by <a href="https://github.com/gambitproject/gte">Mark Egesdal</a>,
<a href="https://github.com/alfongj/gte">Alfonso Gomez-Jordana</a> and 
<a href="https://github.com/trobar/gte">Martin Prause</a>) is a graphical user interface for 
interactive construction and analysis of small to medium games. 
GTE is part of the <a href="http://www.gambit-project.org/">Gambit Project</a> - a library of game theory software supervised by 
<a href="https://github.com/stengel">Bernhard von Stengel</a>  and
<a href="https://github.com/rahulsavani">Rahul Savani</a>
This version of GTE is designed to be portable across plarforms and runs on 
Linux and Windows (Mac OS X in progress). The software consists of a 
Web-Application-Client for the User-Interface (written in ActionScript) 
and a Web-Application-Server (Jetty) to process computational tasks 
such as calculation and enumeration of Nash-Equilibria.
</p>
</div>



<div id="GTE" style=" margin: 0 auto;  width: 100%; text-align:center;">
<h3>Explore GTE</h3>
<a href="index.jsp">
<div id='slideshowHolder' style=" margin: 0 auto;  width: 100%;  ">
 <img src='slide01k.jpg' />
 <img src='slide02k.jpg'  />
 <img src='slide03k.jpg'  />
 <img src='slide04k.jpg' />
</div>
</a>
<h2 style="text-align:center"><a href="index.jsp">Build, explore and solve extensive and strategic form games.</a></h2>
</div>

<div id="Tutorial"  style=" margin: 0 auto;  width: 100%; text-align:center; ">
<h3>Tutorial</h3>
<iframe style=" margin: 0 auto;  width: 420px;" width="420" height="315" src="http://www.youtube.com/embed/2mN1iLr9FHk" frameborder="0" allowfullscreen></iframe>
</div>

<div id="Download"  style=" margin: 0 auto;  width: 100%; text-align:center;  ">
<h3>Download</h3>
<table border="0" width="300" style="margin-left: auto; margin-right: auto;">
<tr>
<td>
<a href="gte.war"><img src="download.png"/><br/>War file</a>
</td>
<td>
<a href="gte.zip"><img src="download.png"/><br/>Jetty file</a>
</td>
<td>
<a href="http://trobar.github.com/gte"><img src="download.png"/><br/>Github</a>
</td>

</tr>
</table>
</div>


<div id="Contact"  style=" margin: 0 auto;  width: 100%; text-align:center;  ">
<h3>Contact</h3>
<h2 style="text-align:center"><a href="http://www.gambit-project.org">www.gambit-project.org</a></h2>
</div>

</div>		
</body>
</html>
