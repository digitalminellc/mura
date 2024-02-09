/* license goes here */
component extends="controller" output="false" {

	public function setUserManager(userManager) output=false {
		variables.userManager=arguments.userManager;
	}

	public function before(rc) output=false {
		param default=0 name="arguments.rc.Type";
		param default=0 name="arguments.rc.ContactForm";
		param default="" name="arguments.rc.email";
		param default="" name="arguments.rc.jobtitle";
		param default="" name="arguments.rc.lastupdate";
		param default="" name="arguments.rc.lastupdateby";
		param default=0 name="arguments.rc.lastupdatebyid";
		param default=0 name="arguments.rc.rsGrouplist.recordcount";
		param default="" name="arguments.rc.groupname";
		param default="" name="arguments.rc.fname";
		param default="" name="arguments.rc.lname";
		param default="" name="arguments.rc.address";
		param default="" name="arguments.rc.city";
		param default="" name="arguments.rc.state";
		param default="" name="arguments.rc.zip";
		param default="" name="arguments.rc.phone1";
		param default="" name="arguments.rc.phone2";
		param default="" name="arguments.rc.fax";
		param default=0 name="arguments.rc.perm";
		param default="" name="arguments.rc.groupid";
		param default="" name="arguments.rc.routeid";
		param default=0 name="arguments.rc.InActive";
		param default=1 name="arguments.rc.startrow";
		param default="" name="arguments.rc.categoryID";
		param default="" name="arguments.rc.routeID";
		param default=structnew() name="arguments.rc.error";
		param default="" name="arguments.rc.returnurl";
		if ( !session.mura.isLoggedIn ) {
			secure(arguments.rc);
		}
	}

	public function edit(rc) output=false {
		if ( !isdefined('arguments.rc.userBean') ) {
			arguments.rc.userBean=variables.userManager.read(session.mura.userID);
		}
		//  This is here for backward plugin compatibility
		appendRequestScope(arguments.rc);
	}

	public function update(rc) output=false {
		if ( rc.$.validateCSRFTokens() ) {
			request.newImageIDList="";
			var userBean=variables.userManager.read(session.mura.userID);
			arguments.rc.userid=userBean.get('userid');
			arguments.rc.siteid=userBean.get('siteid');
			structDelete(arguments.rc,'isPublic');
			structDelete(arguments.rc,'s2');
			structDelete(arguments.rc,'type');
			structDelete(arguments.rc,'groupID');
			arguments.rc.userBean=variables.userManager.update(arguments.rc,false);
			if ( structIsEmpty(arguments.rc.userBean.getErrors()) ) {
				structDelete(session.mura,"editBean");
			
				variables.fw.redirect(action="home.redirect",path="./");
			}
		}
	}

}
