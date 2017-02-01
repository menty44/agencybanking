<!DOCTYPE html>
<%--
  Copyright (c) impalapay Ltd., June 23, 2014

  @author eugene chimita, eugenechimita@impalapay.com
--%>
<%@ page import="com.impalapay.airtel.accountmgmt.admin.pagination.routedefine.RouteDefinePage"%>
<%@ page import="com.impalapay.airtel.accountmgmt.admin.pagination.routedefine.RouteDefinePaginator"%>
<%@ page import="com.impalapay.beans.route.RouteDefine"%>
<%@ page import="com.impalapay.airtel.beans.accountmgmt.Account"%>
<%@ page import="com.impalapay.beans.network.Network"%>


<%@ page import="com.impalapay.airtel.beans.geolocation.Country"%>
<%@page import="com.impalapay.airtel.accountmgmt.session.SessionStatistics"%>
<%@ page import="com.impalapay.airtel.accountmgmt.admin.SessionConstants"%>

<%@ page import="com.impalapay.airtel.cache.CacheVariables"%>

<%@ page import="org.apache.commons.lang.StringUtils" %>

<%@ page import="net.sf.ehcache.Cache" %>
<%@ page import="net.sf.ehcache.CacheManager" %>
<%@ page import="net.sf.ehcache.Element" %>

<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.HashMap"%>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Calendar"%>
<%@ page import="java.util.Iterator"%>


<%
       // The following is for session management.
    if (session == null) {
        response.sendRedirect("../index.jsp");
    }

    String sessionKey = (String) session.getAttribute(SessionConstants.ADMIN_SESSION_KEY);

    if (StringUtils.isEmpty(sessionKey)) {
        response.sendRedirect("../index.jsp");
    }

    session.setMaxInactiveInterval(SessionConstants.SESSION_TIMEOUT);
    response.setHeader("Refresh", SessionConstants.SESSION_TIMEOUT + "; url=../logout");
    // End of session management code
   List<Country> countryList = new ArrayList<Country>();
   List<Network> networkList = new ArrayList<Network>();
   List<RouteDefine> routeList;
   List<Account> accountList = new ArrayList<Account>();

   HashMap<String, String> countryHash = new HashMap<String, String>();
   HashMap<String, String> accountHash = new HashMap<String, String>();
   HashMap<String, String> networkHash = new HashMap<String, String>();

    CacheManager mgr = CacheManager.getInstance();
    Cache accountsCache = mgr.getCache(CacheVariables.CACHE_ACCOUNTS_BY_USERNAME);
    Cache statisticsCache = mgr.getCache(CacheVariables.CACHE_ALL_ACCOUNTS_STATISTICS);
    Cache countryCache = mgr.getCache(CacheVariables.CACHE_COUNTRY_BY_UUID);
    Cache networkCache = mgr.getCache(CacheVariables.CACHE_NETWORK_BY_UUID);

    Country country;
    Network network;
    Account account;
    Element element;
    List keys;

    Calendar calendar = Calendar.getInstance();

    final int DAYS_IN_MONTH = calendar.getActualMaximum(Calendar.DAY_OF_MONTH) + 1;
    final int DAY_OF_MONTH = calendar.get(Calendar.DAY_OF_MONTH);
    final int MONTH = calendar.get(Calendar.MONTH) + 1;
    final int YEAR = calendar.get(Calendar.YEAR);
    final int YEAR_COUNT = YEAR + 10;

     keys = countryCache.getKeys();
    for (Object key : keys) {
        element = countryCache.get(key);
        country = (Country) element.getObjectValue();
        countryHash.put(country.getUuid(), country.getName());
    }

    keys = networkCache.getKeys();
    for (Object key : keys) {
        element = networkCache.get(key);
        network = (Network) element.getObjectValue();
        networkHash.put(network.getUuid(), network.getNetworkname());
    }

    keys = countryCache.getKeysWithExpiryCheck();
    for (Object key : keys) {
        if ((element = countryCache.get(key)) != null) {
            countryList.add((Country) element.getObjectValue());
        }
    }

    keys = accountsCache.getKeysWithExpiryCheck();
    for (Object key : keys) {
        if ((element = accountsCache.get(key)) != null) {
            accountList.add((Account) element.getObjectValue());
        }
    }
    keys = accountsCache.getKeys();
    for (Object key : keys) {
        element = accountsCache.get(key);
        account = (Account) element.getObjectValue();
        accountHash.put(account.getUuid(), account.getFirstName());
    }



    int count = 0;  // A generic counter
    int incount = 0;  // Generic counter

    RouteDefinePaginator paginator = new RouteDefinePaginator();

    SessionStatistics statistics = new SessionStatistics();

     if ((element = statisticsCache.get(CacheVariables.CACHE_ALL_ACCOUNTS_STATISTICS_KEY)) != null) {
        statistics = (SessionStatistics) element.getObjectValue();
    }



    incount = statistics.getRoutedefineCountTotal();
    RouteDefinePage routePage;
    int routeCount = 0; // The current count of the Accounts sessions

    if (incount == 0) { 	// This user has no Incoming USSD in the account
        routePage = new RouteDefinePage();
        routeList = new ArrayList<RouteDefine>();
        routeCount = 0;

    } else {
        routePage = (RouteDefinePage) session.getAttribute("currentRoutePage");
        String referrer = request.getHeader("referer");
        String pageParam = (String) request.getParameter("page");

        // We are to give the first page
        if (routePage == null
                || !StringUtils.endsWith(referrer, "addroutedefine.jsp")
                || StringUtils.equalsIgnoreCase(pageParam, "first")) {
            routePage = paginator.getFirstPage();

            // We are to give the last page
        } else if (StringUtils.equalsIgnoreCase(pageParam, "last")) {
            routePage = paginator.getLastPage();

            // We are to give the previous page
        } else if (StringUtils.equalsIgnoreCase(pageParam, "previous")) {
            routePage = paginator.getPrevPage(routePage);

            // We are to give the next page
        } else {
            routePage = paginator.getNextPage(routePage);
        }

        session.setAttribute("currentRoutePage", routePage);

        routeList = routePage.getContents();

        routeCount = (routePage.getPageNum() - 1) * routePage.getPagesize() + 1;


    }


%>
<html lang="en">

<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <!-- Meta, title, CSS, favicons, etc. -->
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">

    <title>ImpalaPay | Assign-Route</title>
    <link  rel="icon" type="image/png"  href="../images/logo.jpg">

    <!-- Bootstrap core CSS -->

    <link href="../css/bootstrap.min.css" rel="stylesheet">

    <link href="../fonts/css/font-awesome.min.css" rel="stylesheet">
    <link href="../css/animate.min.css" rel="stylesheet">

    <!-- Custom styling plus plugins -->
    <link href="../css/custom.css" rel="stylesheet">
    <link rel="stylesheet" type="text/css" href="../css/maps/jquery-jvectormap-2.0.1.css" />
    <link href="../css/icheck/flat/green.css" rel="stylesheet">
    <link href="../css/floatexamples.css" rel="stylesheet" />

    <script src="../js/jquery.min.js"></script>

    <!--[if lt IE 9]>
        <script src="../assets/js/ie8-responsive-file-warning.js"></script>
        <![endif]-->

    <!-- HTML5 shim and Respond.js for IE8 support of HTML5 elements and media queries -->
    <!--[if lt IE 9]>
          <script src="https://oss.maxcdn.com/html5shiv/3.7.2/html5shiv.min.js"></script>
          <script src="https://oss.maxcdn.com/respond/1.4.2/respond.min.js"></script>
        <![endif]-->

</head>


<body class="nav-md">

    <div class="container body">


        <div class="main_container">

            <div class="col-md-3 left_col">
                <div class="left_col scroll-view">


                    <div class="clearfix"></div>

                    <!-- menu prile quick info -->
                    <div class="profile">
                        <div class="profile_pic">
                            <img src="../images/img.png" alt="..." class="img-circle profile_img">
                        </div>
                        <div class="profile_info">
                            <span>Welcome,</span>
                            <h2><%=sessionKey%></h2>
                        </div>
                    </div>
                    <!-- /menu prile quick info -->

                    <br />

                    <!-- sidebar menu -->
                    <div id="sidebar-menu" class="main_menu_side hidden-print main_menu">

          <div class="menu_section">

            <ul class="nav side-menu">
                <li><a><i class="fa fa-area-chart"></i> Home <span class="fa fa-chevron-down"></span></a>
                    <ul class="nav child_menu" style="display: none">
                        <li><a href="../dashboard.jsp">Dashboard</a>
                        </li>
                        </li>
                    </ul>
                </li>
                <li><a><i class="fa fa-users"></i>Personal<span class="fa fa-chevron-down"></span></a>
                    <ul class="nav child_menu" style="display: none">
                        <li><a href="profile.jsp">Profile</a>
                        </li>
                          <li><a href="changepassword.jsp">Change Password</a>
                        </li>
                         <li><a href="emailnotify.jsp">Email Notification</a>
                        </li>
                    </ul>
                </li>
                <li><a><i class="fa fa-users"></i>Accounts<span class="fa fa-chevron-down"></span></a>
                    <ul class="nav child_menu" style="display: none">
                        <li><a href="currencies.jsp">Manage Currencies</a>
                        </li>
                          <li><a href="addManagementAccount.jsp">Manage Accounts</a>
                        </li>
                         <li><a href="systemaccounts.jsp">System Accounts</a>
                        </li>
                        <li><a href="schedulepayments.jsp">Schedule Payments</a>
                        </li>
                          <li><a href="systempayments.jsp">System Payments</a>
                        </li>
                         <li><a href="memberpayments.jsp">Member Payments</a>
                        </li>
                        </li>
                         <li><a href="accountfees.jsp">Account Fees</a>
                        </li>
                        <li><a href="manageloans.jsp">Manage Loans</a>
                        </li>
                          <li><a href="loanpayment.jsp">Loan Payments</a>
                        </li>

                    </ul>
                </li>
                <li><a><i class="fa fa-users"></i>User/UserGroup<span class="fa fa-chevron-down"></span></a>
                    <ul class="nav child_menu" style="display: none">
                        <li><a href="accountsIndex.jsp">Manage Members</a>
                        </li>
                          <li><a href="bulkactions.jsp">Bulk Action</a>
                        </li>
                         <li><a href="importmembers.jsp">Import Members</a>
                        </li>
                        <li><a href="manageadmins.jsp">Manage Admins</a>
                        </li>
                          <li><a href="connectedusers.jsp">Connected Users</a>
                        </li>
                         <li><a href="pendingmembers.jsp">Pending Members</a>
                        </li>
                        <li><a href="registrationagreements.jsp">Registration Agreements</a>
                        </li>
                          <li><a href="permissiongroups.jsp">Permission Groups</a>
                        </li>
                         <li><a href="loangroups.jsp">Loan Groups</a>
                        </li>
                        <li><a href="memberrecords.jsp">Member Records Type</a>
                        </li>
                    </ul>
                </li>
                <li><a><i class="fa fa-database"></i>Access Devices<span class="fa fa-chevron-down"></span></a>
                    <ul class="nav child_menu" style="display: none">
                        <li><a href="alltransaction.jsp">View All Transactions</a>
                        </li>
                         <li><a href="updatestatus.jsp">Adjust Transaction Status</a>
                        </li>
                    </ul>
                </li>
                <!--<li><a><i class="fa fa-money"></i>Manage Balance<span class="fa fa-chevron-down"></span></a>
                    <ul class="nav child_menu" style="display: none">
                        <li><a href="accounts/addFloat.jsp">Adjust Client Balance</a>
                        <li><a href="accounts/floatHistory.jsp">Client Balance History</a>
                    </ul>
                </li>-->
<li><a><i class="fa fa-wifi"></i>Messages<span class="fa fa-chevron-down"></span></a>
                    <ul class="nav child_menu" style="display: none">
                       <li><a href="addCountry.jsp">Add Country(MNO)</a></li>
                        </li>
                       <li><a href="addmnoprefix.jsp">Define Prefix(MNO)</a></li>
                        </li>
                         <li><a href="addNetwork.jsp">Add Networks</a></li>
                        </li>
                        <li><a href="addBank.jsp">Add Bank</a></li>
                        </li>
                    </ul>
                </li>
                <li><a><i class="fa fa-exclamation-triangle"></i>Settings<span class="fa fa-chevron-down"></span></a>
                    <ul class="nav child_menu" style="display: none">
                        <li><a href="addSessionIp.jsp">Local Setting</a>
                        </li>
                         <li><a href="systemlog.jsp">Alert Setting</a>
                        </li>
                        <li><a href="mailsettings.jsp">Mail Setting</a>
                        </li>
                         <li><a href="systemlog.jsp">Log Setting</a>
                        </li>
                        <li><a href="addSessionIp.jsp">Channels</a>
                        </li>
                         <li><a href="systemlog.jsp">WebServices Clients</a>
                        </li>
                        <li><a href="addSessionIp.jsp">System Tasks</a>
                        </li>
                    </ul>
                </li>
                <li><a><i class="fa fa-exclamation-triangle"></i>Reports<span class="fa fa-chevron-down"></span></a>
                    <ul class="nav child_menu" style="display: none">
                        <li><a href="addSessionIp.jsp">IP-WhiteList/Session-Url</a>
                        </li>
                         <li><a href="systemlog.jsp">SystemLog History</a>
                        </li>
                    </ul>
                </li>
            </ul>
          </div>

      </div>
                    <!-- /sidebar menu -->

                    <!-- /menu footer buttons -->
                   <!-- <div class="sidebar-footer hidden-small">
                        <a data-toggle="tooltip" data-placement="top" title="Settings">
                            <span class="glyphicon glyphicon-cog" aria-hidden="true"></span>
                        </a>
                        <a data-toggle="tooltip" data-placement="top" title="FullScreen">
                            <span class="glyphicon glyphicon-fullscreen" aria-hidden="true"></span>
                        </a>
                        <a data-toggle="tooltip" data-placement="top" title="Lock">
                            <span class="glyphicon glyphicon-eye-close" aria-hidden="true"></span>
                        </a>
                        <a data-toggle="tooltip" data-placement="top" title="Logout">
                            <span class="glyphicon glyphicon-off" aria-hidden="true"></span>
                        </a>
                    </div>-->
                    <!-- /menu footer buttons -->
                </div>
            </div>

            <!-- top navigation -->
            <div class="top_nav">

                <div class="nav_menu">
                    <nav class="" role="navigation">
                        <div class="nav toggle">
                            <a id="menu_toggle"><i class="fa fa-bars"></i></a>
                        </div>

                        <ul class="nav navbar-nav navbar-right">
                            <li class="">
                                <a href="javascript:;" class="user-profile dropdown-toggle" data-toggle="dropdown" aria-expanded="false">
                                    <img src="../images/img.png" alt=""><%= sessionKey%>
                                    <span class=" fa fa-angle-down"></span>
                                </a>
                                <ul class="dropdown-menu dropdown-usermenu animated fadeInDown pull-right">
                                    <li>
                                        <form name="logoutForm" method="post" action="../logout">
                                            <p>
                                            <!--<input type="submit" class="btn btn-primary" name="logout" id="logout" value="Logout">-->
                                            <button type="submit" class="btn btn-primary"><i class="fa fa-sign-out pull-right"></i> Log Out</button>

                                            </p>
                                        </form>

                                    </li>
                                </ul>
                            </li>
                        </ul>
                    </nav>
                </div>

            </div>
            <!-- /top navigation -->


            <!-- page content -->
            <div class="right_col" role="main">

                    <div class="">
                    <div class="page-title">
                        <div class="title_left">
                            <h3>Add Account->Route</h3>
                         </div>
                    </div>

                    <div class="row">
                        <div class="col-md-12">
                            <div class="x_panel">
                                <div class="x_content">

                                    <div class="row">
                    <div class="box-content">
                        <%
                    String addErrStr = (String) session.getAttribute(SessionConstants.ADMIN_ADD_ROUTEDEFINE_ERROR_KEY);
                    String addSuccessStr = (String) session.getAttribute(SessionConstants.ADMIN_ADD_ROUTEDEFINE_SUCCESS_KEY);
                    HashMap<String, String> paramHash = (HashMap<String, String>) session.getAttribute(
                            SessionConstants.ADMIN_ADD_ROUTEDEFINE_PARAMETERS);

                    if (paramHash == null) {
                        paramHash = new HashMap<String, String>();
                    }

                    if (StringUtils.isNotEmpty(addErrStr)) {
                        out.println("<p class=\"alert alert-error\">");
                        out.println("Form error: " + addErrStr);
                        out.println("</p>");
                        session.setAttribute(SessionConstants.ADMIN_ADD_ROUTEDEFINE_ERROR_KEY, null);
                    }

                    if (StringUtils.isNotEmpty(addSuccessStr)) {
                        out.println("<p class=\"alert alert-success\">");
                        out.println("You have successfully added the account to a route/network. You may add others below. "
                                + "Please relogin to system to get new listing of account->route.");
                        out.println("</p>");
                        session.setAttribute(SessionConstants.ADMIN_ADD_ROUTEDEFINE_SUCCESS_KEY, null);
                    }
                %>
                 <%
                    String deleteClientErr = (String) session.getAttribute(SessionConstants.ADMIN_DELETE_ROUTEDEFINE_ERROR_KEY);
                    String deleteClientSuccess = (String) session.getAttribute(SessionConstants.ADMIN_DELETE_ROUTEDEFINE_SUCCESS_KEY);

                    HashMap<String, String> ImtIpdeleteinfoparamHash = (HashMap<String, String>) session.getAttribute(
                            SessionConstants.ADMIN_DELETE_ROUTEDEFINE_PARAMETERS);

                    if (ImtIpdeleteinfoparamHash == null) {
                        ImtIpdeleteinfoparamHash = new HashMap<String, String>();
                    }

                    if (StringUtils.isNotEmpty(deleteClientErr)) {
                        out.println("<p class=\"alert alert-error\">");
                        out.println("Form error: " + deleteClientErr);
                        out.println("</p>");
                        session.setAttribute(SessionConstants.ADMIN_DELETE_ROUTEDEFINE_ERROR_KEY, null);
                    }

                    if (StringUtils.isNotEmpty(deleteClientSuccess)) {
                        out.println("<p class=\"alert alert-success\">");
                        //out.println("You have successfully added the IMT IP. You may add others below. "
                                //+ "Please relogin to system to get new listing of IPs.");
                        out.println("Form notice: " + deleteClientSuccess);
                        out.println("</p>");
                        session.setAttribute(SessionConstants.ADMIN_DELETE_ROUTEDEFINE_SUCCESS_KEY, null);
                    }
                   %>


                        <form  class="form-horizontal form-label-left" action="addaccountroute" method="post">
                            <div class="form-group">
                                <label class="control-label col-md-3 col-sm-3 col-xs-12">Network
                                </label>
                                <div class="col-md-7 col-sm-7 col-xs-12">
                                   <select name="networkuuid" id="input" class="form-control col-md-3 col-xs-12">
                                       <option value="">select network from dropdown</option>
                                           <%
                                    Iterator n = networkHash.keySet().iterator();

                                    while (n.hasNext()) {

                                        String uuid = (String) n.next();

                                        String name = (String) networkHash.get(uuid);
                                %>

                                <option value="<%=uuid%>" ><%=name%></option>

                                <%
                                    }
                                %>
                                        </select>
                                </div>
                             </div>
                            <div class="form-group">
                                <label class="control-label col-md-3 col-sm-3 col-xs-12">Account
                                </label>
                                <div class="col-md-7 col-sm-7 col-xs-12">
                                   <select name="accountuuid" id="input" class="form-control col-md-3 col-xs-12">
                                            <%
                                                for (Account a : accountList) {

                                                out.println("<option value=\"" + a.getUuid() + "\">"
                                                    + a.getFirstName() + " " + a.getLastName() + "</option>");

                                                }//end for (Account a : accountList)
                                            %>
                                        </select>
                                </div>
                             </div>
                             <div class="form-group">
                                            <label class="col-md-3 col-sm-3 col-xs-12 control-label">Support Forex
                                                <br>
                                            </label>

                                            <div class="col-md-9 col-sm-9 col-xs-12">
                                                <div class="radio">
                                                    <label>
                                                        <input type="radio"  name="optionforex" id="optionforex1" value="true">Yes
                                                    </label>
                                                </div>
                                                <div class="radio">
                                                    <label>
                                                        <input type="radio" name="optionforex" id="optionforex2" value="false">No
                                                    </label>
                                                </div>
                                            </div>
                                        </div>
                            <div class="form-group">
                                            <label class="col-md-3 col-sm-3 col-xs-12 control-label">Fixed Commission
                                                <br>
                                            </label>

                                            <div class="col-md-9 col-sm-9 col-xs-12">
                                                <div class="radio">
                                                    <label>
                                                        <input type="radio"  name="optionfixedcommision" id="optionfixedcommision1" value="true">Yes
                                                    </label>
                                                </div>
                                                <div class="radio">
                                                    <label>
                                                        <input type="radio" name="optionfixedcommision" id="optionfixedcommision2" value="false">No
                                                    </label>
                                                </div>
                                            </div>
                                        </div>
                             <div class="form-group">
                                            <label class="col-md-3 col-sm-3 col-xs-12 control-label">Pre-Settlement
                                                <br>
                                            </label>

                                            <div class="col-md-9 col-sm-9 col-xs-12">
                                                <div class="radio">
                                                    <label>
                                                        <input type="radio"  name="optionsettlement" id="optionsettlement1" value="true">Yes
                                                    </label>
                                                </div>
                                                <div class="radio">
                                                    <label>
                                                        <input type="radio" name="optionsettlement" id="optionsettlement2" value="false">No
                                                    </label>
                                                </div>
                                            </div>
                                        </div>
                            <div class="form-group">
                                <label class="control-label col-md-3 col-sm-3 col-xs-12">Commission
                                </label>
                                <div class="col-md-7 col-sm-7 col-xs-12">
                                  <input id="input" name="commission" class="form-control col-md-7 col-xs-12" type="text"  autocomplete="false"  <%
                                       out.println("value=\"" + StringUtils.trimToEmpty(paramHash.get("commission")) + "\"");
                                         %> >
                                </div>
                             </div>
                            <div class="form-group">
                                <label class="control-label col-md-3 col-sm-3 col-xs-12">Minimum Operating Balance
                                </label>
                                <div class="col-md-7 col-sm-7 col-xs-12">
                                  <input id="input" name="minimumbalance" class="form-control col-md-7 col-xs-12" type="text"  autocomplete="false"  <%
                                       out.println("value=\"" + StringUtils.trimToEmpty(paramHash.get("minimumbalance")) + "\"");
                                         %> >
                                </div>
                             </div>
                            <div class="form-group">
                                <label class="control-label col-md-3 col-sm-3 col-xs-12">Date&nbsp;
                                </label>
                                <div class="col-md-7 col-sm-7 col-xs-12">
                                                                        <div class="controls">

                                       <td><select name="addDay" id="input" class="span2">
                                <%
                                    for (int j = 1; j < DAYS_IN_MONTH; j++) {
                                        if (j == DAY_OF_MONTH) {
                                            out.println("<option selected=\"selected\" value=\"" + j + "\">" + j + "</option>");
                                        } else {
                                            out.println("<option value=\"" + j + "\">" + j + "</option>");
                                        }
                                    }
                                %>
                            </select>-</td>
                                      <td> <select name="addMonth" id="input" class="span2">
                                <%
                                    for (int j = 1; j < 13; j++) {
                                        if (j == MONTH) {
                                            out.println("<option selected=\"selected\" value=\"" + j + "\">" + j + "</option>");
                                        } else {
                                            out.println("<option value=\"" + j + "\">" + j + "</option>");
                                        }
                                    }
                                %>
                            </select>-</td>
                                      <td> <select name="addYear" id="input" class="span2">
                                <%
                                    for (int j = YEAR; j < YEAR_COUNT; j++) {
                                        if (j == YEAR) {
                                            out.println("<option selected=\"selected\" value=\"" + j + "\">" + j + "</option>");
                                        } else {
                                            out.println("<option value=\"" + j + "\">" + j + "</option>");
                                        }
                                    }
                                %>
                            </select></td>

                                    </div>

                                </div>
                             </div>
                            <div class="box-footer">
                            <button type="submit" class="btn btn-primary" name="action">
                                <i class="icon-ok"></i>
                                Submit
                            </button>
                        </div>
                            </form>

                                 </div>

                                    </div>

                                </div>
                            </div>
                        </div>
                    </div>



                    <div class="clearfix"></div>

                    <div class="row">
                        <div class="col-md-12">
                            <div class="x_panel">

                                <div class="x_content">
                                    <div align="right">
                                                        <div id="pagination">
                                                             <form name="pageForm" method="post" action="addroutedefine.jsp">
					                    <%                                            if (!routePage.isFirstPage()) {
					                    %>
					                    <input class="btn btn-info" type="submit" name="page" value="First" />
					                    <input class="btn btn-info" type="submit" name="page" value="Previous"/>

					                    <%
					                        }
					                    %>
					                    <span class="pageInfo">Page
					                        <span class="pagePosition currentPage"><%= routePage.getPageNum()%></span> of
					                        <span class="pagePosition"><%= routePage.getTotalPage()%></span>
					                    </span>
					                    <%
					                        if (!routePage.isLastPage()) {
					                    %>
					                    <input class="btn btn-info" type="submit" name="page"value="Next">
					                    <input class="btn btn-info" type="submit"name="page" value="Last">
					                    <%
					                        }
					                    %>
					                </form>

                                                        </div>
                                                     </div>


                                    <div class="row">
                                                <!-- small box -->
                                                <div class="small-box">
                                                    <div class="inner">

						     <div class="alert alert-block alert-success">
                                                                    <p>
                                                                     Assigned Accounts-to-Routes
                                                                    </p>
                                                                    </div>
                                                    <div class="x_content">
                                                        <table id="example" class="table table-striped responsive-utilities jambo_table">
                                                        <!--<table class="table table-striped bootstrap-datatable datatable">-->
                                                        <thead>
                                                            <tr>
                                                               <th></th>
                                                            <th>Network Name</th>
                                                            <th>Account Name</th>
                                                            <th>Support Forex</th>
                                                            <th>Support Pre-Settlement</th>
                                                            <th>Fixed commission</th>
                                                            <th>Commission</th>
                                                            <th>Minimum Balance</th>
                                                            <th>Creation Date</th>
                                                            <th>Action</th>
                                                            </tr>
                                                        </thead>
                                                        <tbody>
                                                            <%
                                                            if (routeList != null) {
                                                                for (RouteDefine code : routeList) {
                                                                %>

                                                                <tr>
                                                                    <td width="5%"><%=routeCount%></td>
                                                                    <td class="center"><%=networkHash.get(code.getNetworkUuid())%></td>
                                                                    <td class="center"><%=accountHash.get(code.getAccountUuid())%></td>
                                                                    <td class="center"><%=code.isSupportforex()%></td>
                                                                    <td class="center"><%=code.isPresettlement()%></td>
                                                                    <td class="center"><%=code.isFixedcommission()%></td>
                                                                    <td class="center"><%=code.getCommission()%></td>
                                                                    <td class="center"><%=code.getMinimumbalance()%></td>
                                                                    <td class="center"><%=code.getCreationDate()%></td>
                                                                     <form method="POST" action="deleteaccountroute">
                                                                        <input class="btn btn-info btn-xs" type="hidden" name="routeuuid" <%
                                                                        out.println("value=\"" + StringUtils.trimToEmpty(code.getUuid()) + "\"");
                                                                        %>>
                                                                        <input type="hidden"  name="username" <%
                                                                        out.println("value=\"" + StringUtils.trimToEmpty(sessionKey) + "\"");
                                                                        %>>
                                                                        <td class="center"><input class="btn btn-danger btn-xs" type="submit"name="page"                                        value="delete"></td>
                                                                    </form>
                                                                </tr>
                                                                 <%
                                                                    routeCount++;
                                                                }
                                                                }

                                                            %>
                                                        </tbody>
                                                        </table>
                                                     </div>
                                                    </div>
                                                </div>
                                           <!-- ./col -->
                                    </div>

                                </div>
                            </div>
                        </div>
                    </div>

                <!-- footer content -->
                <footer>
                    <div class="">
                        <p>Copyright@ImpalaPay 2014-2015</p>
                            <a href="#">Terms &amp; Conditions</a> | <a href="#">Privacy
                            Policy</a> | ImpalaPay Ltd <%= Calendar.getInstance().get(Calendar.YEAR)%>. All rights reserved.
                            <!--<img id="madeInKenya" alt="Made in Kenya" src="#" width="100" height="100" />-->
                        </p>
                    </div>
                    <div class="clearfix"></div>
                </footer>

                <!-- /footer content -->

            </div>
            <!-- /page content -->
        </div>

    </div>

    <script src="../js/bootstrap.min.js"></script>

    <!-- chart js -->
    <script src="../js/chartjs/chart.min.js"></script>
    <!-- bootstrap progress js -->
    <script src="../js/progressbar/bootstrap-progressbar.min.js"></script>
    <script src="../js/nicescroll/jquery.nicescroll.min.js"></script>
    <!-- icheck -->
    <script src="../js/icheck/icheck.min.js"></script>

    <script src="../js/custom.js"></script>

</body>

</html>
