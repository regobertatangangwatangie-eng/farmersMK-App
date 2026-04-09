import jenkins.model.*
import hudson.security.*
def j = Jenkins.getInstance()
def r = new HudsonPrivateSecurityRealm(false)
r.createAccount('admin', 'FarmersMK2026!')
j.setSecurityRealm(r)
j.save()
println('Admin password reset OK')
