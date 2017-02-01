<!DOCTYPE html>
<%--
  Copyright (c) impalapay Ltd., June 23, 2014

  @author eugene chimita, eugenechimita@impalapay.com
--%>
<%@ page import="com.impalapay.airtel.accountmgmt.admin.pagination.network.NetworkPage"%>
<%@ page import="com.impalapay.airtel.accountmgmt.admin.pagination.network.NetworkPaginator"%>
<%@ page import="com.impalapay.beans.network.Network"%>
<%@ page import="com.impalapay.airtel.beans.accountmgmt.Account"%>
<%@ page import="com.impalapay.airtel.beans.accountmgmt.AccountStatus" %>
<%@ page import="com.impalapay.airtel.persistence.accountmgmt.AccountStatusDAO" %>

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
   //List<Network> networkList = new ArrayList<Network>();
   List<Network> networkList;
   List<Account> accountList = new ArrayList<Account>();

         // We assume Live and Developer AccountStatuses are equivalent.
   AccountStatusDAO accountStatusDAO = AccountStatusDAO.getInstance();
   List<AccountStatus> accountStatusList = accountStatusDAO.getAllAccountStatus();

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

    NetworkPaginator paginator = new NetworkPaginator();

    SessionStatistics statistics = new SessionStatistics();

     if ((element = statisticsCache.get(CacheVariables.CACHE_ALL_ACCOUNTS_STATISTICS_KEY)) != null) {
        statistics = (SessionStatistics) element.getObjectValue();
    }



    incount = statistics.getNetworkcountTotal();
    NetworkPage networkPage;
    int networkCount = 0; // The current count of the Accounts sessions

    if (incount == 0) { 	// This user has no Incoming USSD in the account
        networkPage = new NetworkPage();
        networkList = new ArrayList<Network>();
        networkCount = 0;

    } else {
        networkPage = (NetworkPage) session.getAttribute("currentNetworkPage");
        String referrer = request.getHeader("referer");
        String pageParam = (String) request.getParameter("page");

        // We are to give the first page
        if (networkPage == null
                || !StringUtils.endsWith(referrer, "addNetwork.jsp")
                || StringUtils.equalsIgnoreCase(pageParam, "first")) {
            networkPage = paginator.getFirstPage();

            // We are to give the last page
        } else if (StringUtils.equalsIgnoreCase(pageParam, "last")) {
            networkPage = paginator.getLastPage();

            // We are to give the previous page
        } else if (StringUtils.equalsIgnoreCase(pageParam, "previous")) {
            networkPage = paginator.getPrevPage(networkPage);

            // We are to give the next page
        } else {
            networkPage = paginator.getNextPage(networkPage);
        }

        session.setAttribute("currentNetworkPage", networkPage);

        networkList = networkPage.getContents();

        networkCount = (networkPage.getPageNum() - 1) * networkPage.getPagesize() + 1;


    }


%>
<html lang="en">

<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <!-- Meta, title, CSS, favicons, etc. -->
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">

    <title>ImpalaPay | Networks</title>
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
    <link rel="stylesheet" href="../../dist/tablesaw.css">

    <script src="../../dist/dependencies/jquery.js"></script>
    <script src="../../dist/tablesaw.js"></script>
    <script src="../../dist/tablesaw-init.js"></script>

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
                            <h3>Add Network</h3>
                         </div>
                    </div>

                    <div class="row">
                        <div class="col-md-12">
                            <div class="x_panel">
                                <div class="x_content">ADMIN

                                    <div class="row">
                    <div class="box-content">
                        <%
                    String addErrStr = (String) session.getAttribute(SessionConstants.ADMIN_ADD_NETWORK_ERROR_KEY);
                    String addSuccessStr = (String) session.getAttribute(SessionConstants.ADMIN_ADD_NETWORK_SUCCESS_KEY);
                    HashMap<String, String> paramHash = (HashMap<String, String>) session.getAttribute(
                            SessionConstants.ADMIN_ADD_NETWORK_PARAMETERS);

                    if (paramHash == null) {
                        paramHash = new HashMap<String, String>();
                    }

                    if (StringUtils.isNotEmpty(addErrStr)) {
                        out.println("<p class=\"alert alert-error\">");
                        out.println("Form error: " + addErrStr);
                        out.println("</p>");
                        session.setAttribute(SessionConstants.ADMIN_ADD_NETWORK_ERROR_KEY, null);
                    }

                    if (StringUtils.isNotEmpty(addSuccessStr)) {
                        out.println("<p class=\"alert alert-success\">");
                        out.println("You have successfully added the new Network. You may add others below. "
                                + "Please relogin to system to get new listing of accounts.");
                        out.println("</p>");
                        session.setAttribute(SessionConstants.ADMIN_ADD_NETWORK_SUCCESS_KEY, null);
                    }
                %>


                       <form  class="form-horizontal form-label-left" action="addnetwork" method="post">
                        <div class="col-lg-6 col-xs-6">
                        	 <div class="form-group">
                                <label class="control-label col-md-3 col-sm-3 col-xs-12">Country
                                </label>
                                <div class="col-md-7 col-sm-7 col-xs-12">
                                   <select name="countryuuid" id="input" class="form-control col-md-3 col-xs-12">
								<option>Please select country from the list</option>
                                           <%
                                    Iterator c = countryHash.keySet().iterator();

                                    while (c.hasNext()) {

                                        String uuid = (String) c.next();

                                        String name = (String) countryHash.get(uuid);
                                %>

                                <option value="<%=uuid%>" ><%=name%></option>

                                <%
                                    }
                                %>
                                        </select>
                                </div>
                             </div>
                            <div class="form-group">
                                <label class="control-label col-md-3 col-sm-3 col-xs-12">Remit_IP
                                </label>
                                <div class="col-md-9 col-sm-9 col-xs-12">
                                    <input id="input" name="remitip" class="form-control col-md-7 col-xs-12" type="text"  autocomplete="false"  <%
                                         out.println("value=\"" + StringUtils.trimToEmpty(paramHash.get("remitip")) + "\"");
                                         %> >
                                </div>
                             </div>
                            <div class="form-group">
                                <label class="control-label col-md-3 col-sm-3 col-xs-12">Bridge Remit_IP
                                </label>
                                <div class="col-md-9 col-sm-9 col-xs-12">
                                  <input id="input" name="bridgeremitip" class="form-control col-md-7 col-xs-12" type="text"  autocomplete="false" <%
                                        out.println("value=\"" + StringUtils.trimToEmpty(paramHash.get("bridgeremitip")) + "\"");
                                         %> >
                                </div>
                             </div>
                            <div class="form-group">
                                <label class="control-label col-md-3 col-sm-3 col-xs-12">Query_IP
                                </label>
                                <div class="col-md-9 col-sm-9 col-xs-12">
                                  <input id="input" name="queryip" class="form-control col-md-7 col-xs-12" type="text"  autocomplete="false"  <%
                                       out.println("value=\"" + StringUtils.trimToEmpty(paramHash.get("queryip")) + "\"");
                                         %> >
                                </div>
                             </div>
                             <div class="form-group">
                                <label class="control-label col-md-3 col-sm-3 col-xs-12">Bridge Query_IP
                                </label>
                                   <div class="col-md-9 col-sm-9 col-xs-12">
                                  <input id="input" name="bridgequeryip" class="form-control col-md-7 col-xs-12" type="text"  autocomplete="false"  <%
                                       out.println("value=\"" + StringUtils.trimToEmpty(paramHash.get("bridgequeryip")) + "\"");
                                         %> >
                                </div>
                             </div>
                             <div class="form-group">
                                <label class="control-label col-md-3 col-sm-3 col-xs-12">Balance IP
                                </label>
                                <div class="col-md-9 col-sm-9 col-xs-12">
                                  <input id="input" name="balanceip" class="form-control col-md-7 col-xs-12" type="text"  autocomplete="false" <%
                                        out.println("value=\"" + StringUtils.trimToEmpty(paramHash.get("balanceip")) + "\"");
                                         %> >
                                </div>
                             </div>
                            <div class="form-group">
                                <label class="control-label col-md-3 col-sm-3 col-xs-12">Bridge Balance_IP
                                </label>
                                <div class="col-md-9 col-sm-9 col-xs-12">
                                  <input id="input" name="bridgebalanceip" class="form-control col-md-7 col-xs-12" type="text"  autocomplete="false"  <%
                                       out.println("value=\"" + StringUtils.trimToEmpty(paramHash.get("bridgebalanceip")) + "\"");
                                         %> >
                                </div>
                             </div>
                             <div class="form-group">
                                <label class="control-label col-md-3 col-sm-3 col-xs-12">Reversal IP
                                </label>
                                <div class="col-md-9 col-sm-9 col-xs-12">
                                  <input id="input" name="reversalip" class="form-control col-md-7 col-xs-12" type="text"  autocomplete="false"  <%
                                       out.println("value=\"" + StringUtils.trimToEmpty(paramHash.get("reversalip")) + "\"");
                                         %> >
                                </div>
                             </div>
                             <div class="form-group">
                                <label class="control-label col-md-3 col-sm-3 col-xs-12">Bridge Reversal_IP
                                </label>
                                <div class="col-md-9 col-sm-9 col-xs-12">
                                  <input id="input" name="bridgereversalip" class="form-control col-md-7 col-xs-12" type="text"  autocomplete="false"  <%
                                       out.println("value=\"" + StringUtils.trimToEmpty(paramHash.get("bridgereversalip")) + "\"");
                                         %> >
                                </div>
                             </div>
                                                         <div class="form-group">
                                <label class="control-label col-md-3 col-sm-3 col-xs-12">Commission
                                </label>
                                <div class="col-md-9 col-sm-9 col-xs-12">
                                  <input id="input" name="commission" class="form-control col-md-7 col-xs-12" type="text"  autocomplete="false"  <%
                                       out.println("value=\"" + StringUtils.trimToEmpty(paramHash.get("commission")) + "\"");
                                         %> >
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
                                            <label class="col-md-3 col-sm-3 col-xs-12 control-label">Support Reversal
                                                <br>
                                            </label>

                                            <div class="col-md-9 col-sm-9 col-xs-12">
                                                <div class="radio">
                                                    <label>
                                                        <input type="radio"  name="optionreversal" id="optionreversal1" value="true">Yes
                                                    </label>
                                                </div>
                                                <div class="radio">
                                                    <label>
                                                        <input type="radio" name="optionreversal" id="optionreversal2" value="false">No
                                                    </label>
                                                </div>
                                            </div>
                                        </div>
                                        <div class="form-group">
                                            <label class="col-md-3 col-sm-3 col-xs-12 control-label">Support AccountCheck
                                                <br>
                                            </label>

                                            <div class="col-md-9 col-sm-9 col-xs-12">
                                                <div class="radio">
                                                    <label>
                                                        <input type="radio"  name="optionaccountcheck" id="optionaccountcheck1" value="true">Yes
                                                    </label>
                                                </div>
                                                <div class="radio">
                                                    <label>
                                                        <input type="radio" name="optionaccountcheck" id="optionaccountcheck2" value="false">No
                                                    </label>
                                                </div>
                                            </div>
                                        </div>
                        </div>
                        <div class="col-lg-6 col-xs-6">
                              <div class="form-group">
                                <label class="control-label col-md-3 col-sm-3 col-xs-12">AccountCheck IP
                                </label>
                                <div class="col-md-9 col-sm-9 col-xs-12">
                                  <input id="input" name="accountcheckip" class="form-control col-md-7 col-xs-12" type="text"  autocomplete="false" <%
                                        out.println("value=\"" + StringUtils.trimToEmpty(paramHash.get("accountcheckip")) + "\"");
                                         %> >
                                </div>
                             </div>
                            <div class="form-group">
                                <label class="control-label col-md-3 col-sm-3 col-xs-12">Bridge AccountCheck_IP
                                </label>
                                <div class="col-md-9 col-sm-9 col-xs-12">
                                  <input id="input" name="bridgeaccountcheckip" class="form-control col-md-7 col-xs-12" type="text"  autocomplete="false"  <%
                                       out.println("value=\"" + StringUtils.trimToEmpty(paramHash.get("bridgeaccountcheckip")) + "\"");
                                         %> >
                                </div>
                             </div>
                              <div class="form-group">
                                <label class="control-label col-md-3 col-sm-3 col-xs-12">Forex IP
                                </label>
                                <div class="col-md-9 col-sm-9 col-xs-12">
                                  <input id="input" name="forexip" class="form-control col-md-7 col-xs-12" type="text"  autocomplete="false" <%
                                        out.println("value=\"" + StringUtils.trimToEmpty(paramHash.get("forexip")) + "\"");
                                         %> >
                                </div>
                             </div>
                            <div class="form-group">
                                <label class="control-label col-md-3 col-sm-3 col-xs-12">Bridge Forex_IP
                                </label>
                                <div class="col-md-9 col-sm-9 col-xs-12">
                                  <input id="input" name="bridgeforexip" class="form-control col-md-7 col-xs-12" type="text"  autocomplete="false"  <%
                                       out.println("value=\"" + StringUtils.trimToEmpty(paramHash.get("bridgeforexip")) + "\"");
                                         %> >
                                </div>
                             </div>
                                <div class="form-group">
                                <label class="control-label col-md-3 col-sm-3 col-xs-12">Extra_URI
                                </label>
                                <div class="col-md-9 col-sm-9 col-xs-12">
                                  <input id="input" name="extraurl" class="form-control col-md-7 col-xs-12" type="text"  autocomplete="false"  <%
                                       out.println("value=\"" + StringUtils.trimToEmpty(paramHash.get("extraurl")) + "\"");
                                         %> >
                                </div>
                             </div>
                                  <div class="form-group">
                                <label class="control-label col-md-3 col-sm-3 col-xs-12">Username
                                </label>
                                <div class="col-md-9 col-sm-9 col-xs-12">
                                  <input id="input" name="username" class="form-control col-md-7 col-xs-12" type="text"  autocomplete="false"  <%
                                       out.println("value=\"" + StringUtils.trimToEmpty(paramHash.get("username")) + "\"");
                                         %> >
                                </div>
                             </div>
                                <div class="form-group">
                                <label class="control-label col-md-3 col-sm-3 col-xs-12">Password
                                </label>
                                <div class="col-md-9 col-sm-9 col-xs-12">
                                  <input id="input" name="password" class="form-control col-md-7 col-xs-12" type="password"  autocomplete="false"  <%
                                       out.println("value=\"" + StringUtils.trimToEmpty(paramHash.get("password")) + "\"");
                                         %> >
                                </div>
                             </div>
                                  <div class="form-group">
                                <label class="control-label col-md-3 col-sm-3 col-xs-12">Network_Name
                                </label>
                                <div class="col-md-9 col-sm-9 col-xs-12">
                                  <input id="input" name="networkname" class="form-control col-md-7 col-xs-12" type="text"  autocomplete="false"  <%
                                       out.println("value=\"" + StringUtils.trimToEmpty(paramHash.get("networkname")) + "\"");
                                         %> >
                                </div>
                             </div>
                                <div class="form-group">
                                <label class="control-label col-md-3 col-sm-3 col-xs-12">Partner_Name
                                </label>
                                <div class="col-md-9 col-sm-9 col-xs-12">
                                  <input id="input" name="partnername" class="form-control col-md-7 col-xs-12" type="text"  autocomplete="false"  <%
                                       out.println("value=\"" + StringUtils.trimToEmpty(paramHash.get("partnername")) + "\"");
                                         %> >
                                </div>
                             </div>
                                                    	 <div class="form-group">
                                <label class="control-label col-md-3 col-sm-3 col-xs-12">Network Status
                                </label>
                                <div class="col-md-7 col-sm-7 col-xs-12">
                                   <select name="networkstausuuid" id="input" class="form-control col-md-3 col-xs-12">
								<option>Please select Network status from the list</option>
                                           <%
                                                for (AccountStatus a : accountStatusList) {
                                                    if (StringUtils.equalsIgnoreCase(a.getDescription(), "Active")) {
                                                        out.println("<option selected=\"selected\" value=\"" + a.getUuid() + "\">" + a.getDescription() + "</option>");
                                                    } else {
                                                        out.println("<option value=\"" + a.getUuid() + "\">" + a.getDescription() + "</option>");
                                                    }
                                                }
                                            %>
                                        </select>
                                </div>
                             </div>
                            <div class="form-group">
                                            <label class="col-md-3 col-sm-3 col-xs-12 control-label">Support QueryCheck
                                                <br>
                                            </label>

                                            <div class="col-md-9 col-sm-9 col-xs-12">
                                                <div class="radio">
                                                    <label>
                                                        <input type="radio"  name="optionquerycheck" id="optionquerycheck1" value="true">Yes
                                                    </label>
                                                </div>
                                                <div class="radio">
                                                    <label>
                                                        <input type="radio" name="optionquerycheck" id="optionquerycheck2" value="false">No
                                                    </label>
                                                </div>
                                            </div>
                                        </div>
                                        <div class="form-group">
                                            <label class="col-md-3 col-sm-3 col-xs-12 control-label">Support BalanceCheck
                                                <br>
                                            </label>

                                            <div class="col-md-9 col-sm-9 col-xs-12">
                                                <div class="radio">
                                                    <label>
                                                        <input type="radio"  name="optionbalancecheck" id="optionbalancecheck1" value="true">Yes
                                                    </label>
                                                </div>
                                                <div class="radio">
                                                    <label>
                                                        <input type="radio" name="optionbalancecheck" id="optionbalancecheck2" value="false">No
                                                    </label>
                                                </div>
                                            </div>
                                        </div>
                                         <div class="form-group">
                                            <label class="col-md-3 col-sm-3 col-xs-12 control-label">commission percentage
                                                <br>
                                            </label>

                                            <div class="col-md-9 col-sm-9 col-xs-12">
                                                <div class="radio">
                                                    <label>
                                                        <input type="radio"  name="optioncommissionpercentage" id="optioncommissionpercentage1" value="true">Yes
                                                    </label>
                                                </div>
                                                <div class="radio">
                                                    <label>
                                                        <input type="radio" name="optioncommissionpercentage" id="optioncommissionpercentage2" value="false">No
                                                    </label>
                                                </div>
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
                                                      <form name="pageForm" method="post" action="addNetwork.jsp">
					                    <%                                            if (!networkPage.isFirstPage()) {
					                    %>
					                    <input class="btn btn-info" type="submit" name="page" value="First" />
					                    <input class="btn btn-info" type="submit" name="page" value="Previous"/>

					                    <%
					                        }
					                    %>
					                    <span class="pageInfo">Page
					                        <span class="pagePosition currentPage"><%= networkPage.getPageNum()%></span> of
					                        <span class="pagePosition"><%= networkPage.getTotalPage()%></span>
					                    </span>
					                    <%
					                        if (!networkPage.isLastPage()) {
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
                                                    <h5>Network/Routes</h5>
                                                    <div class="x_content">
                                                     <table class="tablesaw" data-tablesaw-mode="swipe" data-tablesaw-sortable data-tablesaw-sortable-switch data-tablesaw-minimap data-tablesaw-mode-switch>

                                                        <!--<table id="example" class="table table-striped responsive-utilities jambo_table">-->
                                                        <!--<table class="table table-striped bootstrap-datatable datatable">-->
                                                        <thead>
                                                            <tr>
                                                            <th scope="col" data-tablesaw-sortable-col data-tablesaw-priority="1"></th>
                                                            <th scope="col" data-tablesaw-sortable-col data-tablesaw-sortable-default-col data-tablesaw-priority="2">Country</th>
                                                            <th scope="col" data-tablesaw-sortable-col data-tablesaw-priority="3">Remit Url</th>
                                                            <th scope="col" data-tablesaw-sortable-col data-tablesaw-priority="4">BridgeRemit url</th>
                                                            <th scope="col" data-tablesaw-sortable-col data-tablesaw-priority="5">Username</th>
                                                            <th scope="col" data-tablesaw-sortable-col data-tablesaw-priority="6">Password</th>
                                                            <th scope="col" data-tablesaw-sortable-col data-tablesaw-priority="7">Network Name</th>
                                                            <th scope="col" data-tablesaw-sortable-col data-tablesaw-priority="8">Partner Name</th>
                                                            <th scope="col" data-tablesaw-sortable-col data-tablesaw-priority="9">Support Reversal</th>
                                                            <th scope="col" data-tablesaw-sortable-col data-tablesaw-priority="10">Support Forex</th>
                                                            <th scope="col" data-tablesaw-sortable-col data-tablesaw-priority="12">Support AccountCheck</th>
                                                            <th scope="col" data-tablesaw-sortable-col data-tablesaw-priority="13">Support BalanceCheck</th>
                                                            <th scope="col" data-tablesaw-sortable-col data-tablesaw-priority="14">Support Query</th>
                                                            <th scope="col" data-tablesaw-sortable-col data-tablesaw-priority="15">Query Url</th>
                                                            <th scope="col" data-tablesaw-sortable-col data-tablesaw-priority="16">BridgeQuery Url</th>
                                                            <th scope="col" data-tablesaw-sortable-col data-tablesaw-priority="17">Balance Url</th>
                                                            <th scope="col" data-tablesaw-sortable-col data-tablesaw-priority="18">BridgeBalance Url</th>
                                                            <th scope="col" data-tablesaw-sortable-col data-tablesaw-priority="19">AccountCheck Url</th>
                                                            <th scope="col" data-tablesaw-sortable-col data-tablesaw-priority="20">BridgeAccountCheck Url</th>
                                                            <th scope="col" data-tablesaw-sortable-col data-tablesaw-priority="21">Forex Url</th>
                                                            <th scope="col" data-tablesaw-sortable-col data-tablesaw-priority="22">BridgeForex Url</th>
                                                            <!--<th scope="col" data-tablesaw-sortable-col data-tablesaw-priority="1">View</th>
                                                            <th>Date Created</th>-->
                                                            </tr>
                                                        </thead>
                                                        <tbody>
                                                           <%
                                                            if (networkList != null) {
                                                                for (Network code : networkList) {
                                                                %>

                                                                <tr>
                                                                    <td width="5%"><%=networkCount%></td>
                                                                    <td class="center"><%=countryHash.get(code.getCountryUuid())%></td>
                                                                    <td class="center"><%=code.getRemitip()%></td>
                                                                    <td class="center"><%=code.getBridgeremitip()%></td>
                                                                    <td class="center"><%=code.getUsername()%></td>
                                                                    <td class="center"><%=code.getPassword()%></td>
                                                                    <td class="center"><%=code.getNetworkname()%></td>
                                                                    <td class="center"><%=code.getPartnername()%></td>
																	<td class="center"><%=code.isSupportreversal()%></td>
                                                                    <td class="center"><%=code.isSupportforex()%></td>
                                                                    <td class="center"><%=code.isSupportaccountcheck()%></td>
																	<td class="center"><%=code.isSupportbalancecheck()%></td>
                                                                    <td class="center"><%=code.isSupportquerycheck()%></td>
																	<!--<td class="center"><%=code.getDateadded()%></td>-->
                                                                    <!--<form method="POST" action="viewNetwork.jsp">
                                                                    <input class="btn btn-info btn-xs" type="hidden" name="uuid" <%
                                                                    out.println("value=\"" + StringUtils.trimToEmpty(code.getUuid()) + "\"");
                                                                    %>>
                                                                    <td class="center"><input class="btn btn-success btn-xs" type="submit"name="page"                                       value="view"></td>
                                                                    </form>-->
                                                                    <td class="center"><%=code.getQueryip()%></td>
                                                                    <td class="center"><%=code.getBridgequeryip()%></td>
                                                                    <td class="center"><%=code.getBalanceip()%></td>
                                                                    <td class="center"><%=code.getBridgebalanceip()%></td>
                                                                    <td class="center"><%=code.getAccountcheckip()%></td>
                                                                    <td class="center"><%=code.getBridgeaccountcheckip()%></td>
                                                                    <td class="center"><%=code.getForexip()%></td>
                                                                    <td class="center"><%=code.getBridgeforexip()%></td>
                                                                </tr>
                                                                 <%
                                                                    networkCount++;
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
