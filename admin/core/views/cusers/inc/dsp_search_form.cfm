<!--- 
  This file is part of Mura CMS.

  Mura CMS is free software: you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation, Version 2 of the License.

  Mura CMS is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with Mura CMS. If not, see <http://www.gnu.org/licenses/>.

  Linking Mura CMS statically or dynamically with other modules constitutes the preparation of a derivative work based on
  Mura CMS. Thus, the terms and conditions of the GNU General Public License version 2 ("GPL") cover the entire combined work.

  However, as a special exception, the copyright holders of Mura CMS grant you permission to combine Mura CMS with programs
  or libraries that are released under the GNU Lesser General Public License version 2.1.

  In addition, as a special exception, the copyright holders of Mura CMS grant you permission to combine Mura CMS with
  independent software modules (plugins, themes and bundles), and to distribute these plugins, themes and bundles without
  Mura CMS under the license of your choice, provided that you follow these specific guidelines:

  Your custom code

  • Must not alter any default objects in the Mura CMS database and
  • May not alter the default display of the Mura CMS logo within Mura CMS and
  • Must not alter any files in the following directories.

  	/admin/
	/core/
	/Application.cfc
	/index.cfm

  You may copy and distribute Mura CMS with a plug-in, theme or bundle that meets the above guidelines as a combined work
  under the terms of GPL for Mura CMS, provided that you include the source code of that other code when and as the GNU GPL
  requires distribution of source code.

  For clarity, if you create a modified version of Mura CMS, you are not obligated to grant this special exception for your
  modified version; it is your choice whether to do so, or to make such modified version available under the GNU General Public License
  version 2 without this exception.  You may, if you choose, apply this exception to your own modified versions of Mura CMS.
--->
<cfoutput>
  <cfif rc.muraAction eq "core:cusers.list" || $.event('usertype') == 1>
    <cfset rc.userType = 1>
  <cfelse>
    <cfset rc.userType = 2>
  </cfif>

  <form class="form-inline" novalidate="novalidate" action="" method="get" name="form1" id="siteSearch">
    <div class="mura-search">
      <span class="mura-input-set">
      <input id="search" name="search" type="text" value="#esapiEncode('html', rc.$.event('search'))#" placeholder="#rbKey('user.searchforusers')#" />
      <button type="button" class="btn" onclick="submitForm(document.forms.form1);">
        <i class="mi-search"></i>
      </button>
    </span>
      <button type="button" class="btn" onclick="actionModal();window.location='./?muraAction=cUsers.advancedSearch&amp;ispublic=#esapiEncode('url',rc.ispublic)#&amp;siteid=#esapiEncode('url',rc.siteid)#&amp;usertype=#esapiEncode('url',rc.usertype)#&amp;newSearch=true'" value="#rbKey('user.advanced')#">
        #rbKey('user.advanced')#
      </button>
      <input type="hidden" name="siteid" value="#esapiEncode('html', rc.siteid)#" />
      <input type="hidden" name="ispublic" value="#esapiEncode('html', rc.ispublic)#" />
      <cfif rc.userType == 1>
        <input type="hidden" name="usertype" value="1" />
      <cfelse>
        <input type="hidden" name="usertype" value="2" />
      </cfif>
      <input type="hidden" name="muraAction" value="cUsers.search" />
    </div>
  </form>
</cfoutput>
