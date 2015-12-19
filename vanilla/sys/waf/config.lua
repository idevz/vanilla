local sys_waf_conf = {}

sys_waf_conf.RulePath = "./config/waf-regs/"
sys_waf_conf.attacklog = "on"
sys_waf_conf.logdir = "./logs/hack/"
sys_waf_conf.UrlDeny="on"
sys_waf_conf.Redirect="on"
sys_waf_conf.CookieMatch="on"
sys_waf_conf.postMatch="on" 
sys_waf_conf.whiteModule="on" 
sys_waf_conf.black_fileExt={"php","jsp"}
sys_waf_conf.ipWhitelist={"127.0.0.1"}
sys_waf_conf.ipBlocklist={"1.0.0.1"}
sys_waf_conf.CCDeny="off"
sys_waf_conf.CCrate="100/60"
sys_waf_conf.html=[[
<!DOCTYPE html>
	<html>
		<body>
		<h1>Welcome To Vanilla's World ...</h1>
		<h5>=== Vanilla is a Web framework Based On OpenResty ... ====</h5>
		<h4>---- Sourse Code:https://github.com/idevz/vanilla ... ----</h4>
		</body>
	</html>
]]

return sys_waf_conf