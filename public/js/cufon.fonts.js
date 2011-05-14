Cufon.replace('#logo', { fontFamily: 'Coolvetica' });  
Cufon.replace('#footer-logo', { fontFamily: 'Coolvetica' });  
Cufon.replace('h1', { fontFamily: 'Coolvetica' }); 
Cufon.replace('h2', { fontFamily: 'Coolvetica' }); 
Cufon.replace('#slogan', { fontFamily: 'Avenir' }); 
Cufon.replace('#title', { fontFamily: 'Avenir' }); 
Cufon.replace('#fourofour', { fontFamily: 'Amperzand' }); 
Cufon.replace('#fourofour-message', { fontFamily: 'Avenir' }); 


// Function to include the cufon font files in to every page
function IncludeJavaScript(jsFile)
{
  document.write('<script type="text/javascript" src="'
    + jsFile + '"></scr' + 'ipt>'); 
}
IncludeJavaScript('/js/Coolvetica.font.js');
IncludeJavaScript('/js/Amperzand.font.js');
IncludeJavaScript('/js/Avenir.font.js');