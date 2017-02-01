<!DOCTYPE html>
<%--
  Copyright (c) impalapay Ltd., June 23, 2014

  @author eugene chimita, eugenechimita@impalapay.com
--%>
<%@ page import="com.impalapay.airtel.accountmgmt.admin.pagination.country.CountryPage" %>
<%@ page import="com.impalapay.airtel.accountmgmt.admin.pagination.country.CountryPaginator" %>
<%@ page import="com.impalapay.airtel.accountmgmt.admin.pagination.countrymsisdn.CountryMsisdnPage" %>
<%@ page import="com.impalapay.airtel.accountmgmt.admin.pagination.countrymsisdn.CountryMsisdnPaginator" %>
<%@ page import="com.impalapay.airtel.beans.geolocation.Country" %>
<%@ page import="com.impalapay.beans.network.Network"%>
<%@ page import="com.impalapay.airtel.beans.geolocation.CountryMsisdn" %>
<%@ page import="com.impalapay.airtel.beans.accountmgmt.Account" %>

<%@ page import="com.impalapay.airtel.beans.accountmgmt.AccountStatus" %>

<%@ page import="com.impalapay.airtel.accountmgmt.admin.SessionConstants" %>
<%@ page import="com.impalapay.airtel.accountmgmt.session.SessionStatistics"%>

<%@ page import="com.impalapay.airtel.persistence.accountmgmt.AccountStatusDAO" %>

<%@page import="com.impalapay.airtel.cache.CacheVariables"%>

<%@ page import="org.apache.commons.lang3.StringUtils" %>

<%@ page import="java.util.List" %>
<%@page import="java.util.ArrayList"%>
<%@page import="java.util.Collections"%>
<%@page import="java.util.Calendar"%>
<%@page import="java.util.HashMap"%>
<%@page import="java.util.Iterator"%>

<%@ page import="net.sf.ehcache.Cache" %>
<%@ page import="net.sf.ehcache.CacheManager" %>
<%@page import="net.sf.ehcache.Element"%>

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




    CacheManager mgr = CacheManager.getInstance();
    Cache accountsCache = mgr.getCache(CacheVariables.CACHE_ACCOUNTS_BY_UUID);
    Cache countryCache = mgr.getCache(CacheVariables.CACHE_COUNTRY_BY_UUID);
    Cache statisticsCache = mgr.getCache(CacheVariables.CACHE_ALL_ACCOUNTS_STATISTICS);
    Cache networkCache = mgr.getCache(CacheVariables.CACHE_NETWORK_BY_UUID);

    // This HashMap contains the UUIDs of countries as keys and the country names as values
    HashMap<String, String> countryHash = new HashMap<String, String>();
    HashMap<String, String> accountHash = new HashMap<String, String>();
    HashMap<String, String> networkHash = new HashMap<String, String>();

    List keys;

    Element element;
    Country country;
    Account account;
    Network network;

    List<Account> accountList = new ArrayList<Account>();

    List<Country> countryList = new ArrayList<Country>();
    List<Country> countryLists;
    List<CountryMsisdn> countrymsisdnList;

    keys = accountsCache.getKeysWithExpiryCheck();
    for (Object key : keys) {
        if ((element = accountsCache.get(key)) != null) {
            accountList.add((Account) element.getObjectValue());
        }
    }

     keys = networkCache.getKeys();
    for (Object key : keys) {
        element = networkCache.get(key);
        network = (Network) element.getObjectValue();
        networkHash.put(network.getUuid(), network.getNetworkname());
    }


    keys = countryCache.getKeys();
    for (Object key : keys) {
        element = countryCache.get(key);
        country = (Country) element.getObjectValue();
        countryHash.put(country.getUuid(), country.getName());
    }

    keys = countryCache.getKeysWithExpiryCheck();
    for (Object key : keys) {
        if ((element = countryCache.get(key)) != null) {
            countryList.add((Country) element.getObjectValue());
        }
    }

    keys = accountsCache.getKeys();
    for (Object key : keys) {
        element = accountsCache.get(key);
        account = (Account) element.getObjectValue();
        accountHash.put(account.getUuid(), account.getFirstName());
    }

    int count = 0;  // A generic counter

    Calendar calendar = Calendar.getInstance();

    final int DAYS_IN_MONTH = calendar.getActualMaximum(Calendar.DAY_OF_MONTH) + 1;
    final int DAY_OF_MONTH = calendar.get(Calendar.DAY_OF_MONTH);
    final int MONTH = calendar.get(Calendar.MONTH) + 1;
    final int YEAR = calendar.get(Calendar.YEAR);
    final int YEAR_COUNT = YEAR + 10;


    int incount = 0;  // Generic counter
    int incounts = 0;

    CountryPaginator paginator = new CountryPaginator();
    CountryMsisdnPaginator paginators = new CountryMsisdnPaginator();

    SessionStatistics statistics = new SessionStatistics();

     if ((element = statisticsCache.get(CacheVariables.CACHE_ALL_ACCOUNTS_STATISTICS_KEY)) != null) {
        statistics = (SessionStatistics) element.getObjectValue();
    }

    incount = statistics.getCountryCountTotal();
    CountryPage countryPage;
    int countryCount = 0; // The current count of the Accounts sessions

    if (incount == 0) { 	// This user has no Incoming USSD in the account
        countryPage = new CountryPage();
        countryLists = new ArrayList<Country>();
        countryCount = 0;

    } else {
        countryPage = (CountryPage) session.getAttribute("currentCountryPage");
        String referrer = request.getHeader("referer");
        String pageParam = (String) request.getParameter("page");

        // We are to give the first page
        if (countryPage == null
                || !StringUtils.endsWith(referrer, "addCountry.jsp")
                || StringUtils.equalsIgnoreCase(pageParam, "first")) {
            countryPage = paginator.getFirstPage();

            // We are to give the last page
        } else if (StringUtils.equalsIgnoreCase(pageParam, "last")) {
            countryPage = paginator.getLastPage();

            // We are to give the previous page
        } else if (StringUtils.equalsIgnoreCase(pageParam, "previous")) {
            countryPage = paginator.getPrevPage(countryPage);

            // We are to give the next page
        } else {
            countryPage = paginator.getNextPage(countryPage);
        }

        session.setAttribute("currentCountryPage", countryPage);

        countryLists = countryPage.getContents();

        countryCount = (countryPage.getPageNum() - 1) * countryPage.getPagesize() + 1;


    }

    incounts = statistics.getCountrymsisdnCountTotal();
    CountryMsisdnPage countrymsisdnPage;
    int countrymsisdnCount = 0; // The current count of the Accounts sessions

    if (incounts == 0) { 	// This user has no Incoming USSD in the account
        countrymsisdnPage = new CountryMsisdnPage();
        countrymsisdnList = new ArrayList<CountryMsisdn>();
        countrymsisdnCount = 0;

    } else {
        countrymsisdnPage = (CountryMsisdnPage) session.getAttribute("currentMsisdnPerCountryPage");
        String referrers = request.getHeader("referer");
        String pageParams = (String) request.getParameter("page");

        // We are to give the first page
        if (countrymsisdnPage == null
                || !StringUtils.endsWith(referrers, "addCountry.jsp")
                || StringUtils.equalsIgnoreCase(pageParams, "first")) {
            countrymsisdnPage = paginators.getFirstPage();

            // We are to give the last page
        } else if (StringUtils.equalsIgnoreCase(pageParams, "last")) {
            countrymsisdnPage = paginators.getLastPage();

            // We are to give the previous page
        } else if (StringUtils.equalsIgnoreCase(pageParams, "previous")) {
            countrymsisdnPage = paginators.getPrevPage(countrymsisdnPage);

            // We are to give the next page
        } else {
            countrymsisdnPage = paginators.getNextPage(countrymsisdnPage);
        }

        session.setAttribute("currentMsisdnPerCountryPage", countrymsisdnPage);

        countrymsisdnList = countrymsisdnPage.getContents();

        countrymsisdnCount = (countrymsisdnPage.getPageNum() - 1) * countrymsisdnPage.getPagesize() + 1;


    }

%>
<html lang="en">

<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <!-- Meta, title, CSS, favicons, etc. -->
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">

    <title>ImpalaPay | CountryData</title>
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
<div class="right_col" role="main">
            <div class="">
                                <div class="page-title">
                                    <div class="title_left">
                                        <h3>Country Management</h3>
                                    </div>
                                </div>



                        <div class="row">
                        <div class="col-md-12">
                            <div class="x_panel">
                                <div class="x_content">

                                    <div class="row">

                                            <div class="col-lg-6 col-xs-6">
                                                <!-- small box -->
                                                <div class="small-box">
                                                    <div class="inner">

                                                    <div class="x_content">

                                                     </div>
                                                                                                           <form id="userSecurityForm" class="form-horizontal form-label-left" action="addMCountryinformation" method="post">
                    <%
                    String addCountryErr = (String) session.getAttribute(SessionConstants.ADMIN_ADD_COUNTRYINFO_ERROR_KEY);
                    String addCountrySuccess = (String) session.getAttribute(
                            SessionConstants.ADMIN_ADD_COUNTRYINFO_SUCCESS_KEY);

                    HashMap<String, String> CountryinfoparamHash = (HashMap<String, String>) session.getAttribute(
                            SessionConstants.ADMIN_ADD_COUNTRYINFO_PARAMETERS);

                    if (CountryinfoparamHash == null) {
                        CountryinfoparamHash = new HashMap<String, String>();
                    }

                    if (StringUtils.isNotEmpty(addCountryErr)) {
                        out.println("<p class=\"alert alert-error\">");
                        out.println("Form error: " + addCountryErr);
                        out.println("</p>");
                        session.setAttribute(SessionConstants.ADMIN_ADD_COUNTRYINFO_ERROR_KEY, null);
                    }

                    if (StringUtils.isNotEmpty(addCountrySuccess)) {
                        out.println("<p class=\"alert alert-success\">");
                        out.println("You have successfully added country(opcos) Information. You may add others below. "
                                + "Please relogin to system to get new listing of country information.");
                        out.println("</p>");
                        session.setAttribute(SessionConstants.ADMIN_ADD_COUNTRYINFO_SUCCESS_KEY, null);
                    }
                %>
                        <div class="alert alert-block alert-success">
                            <p>
                            Add Country 1
                            </p>
                            </div>
                                 <div class="form-group">
                                <label class="control-label col-md-3 col-sm-3 col-xs-12">Country 23233
                                </label>
                                <div class="col-md-7 col-sm-7 col-xs-12">
                                   <select name="countryUuid" id="input" class="form-control col-md-3 col-xs-12">
                                       <option value="" >Select Country to Edit or Leave Empty to Add</option>
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
                                <label class="control-label col-md-3 col-sm-3 col-xs-12">Country Name
                                </label>
                                <div class="col-md-7 col-sm-7 col-xs-12">
                                  <input id="input" name="countryname" class="form-control col-md-7 col-xs-12" type="text"  autocomplete="false"  <%
                                       out.println("value=\"" + StringUtils.trimToEmpty(CountryinfoparamHash.get("countryname")) + "\"");
                                         %> >
                                </div>
                             </div>
                            <div class="form-group">
                                <label class="control-label col-md-3 col-sm-3 col-xs-12">Country Code
                                </label>
                                <div class="col-md-7 col-sm-7 col-xs-12">
                                  <input id="input" name="countrycode" class="form-control col-md-7 col-xs-12" type="text"  autocomplete="false"  <%
                                       out.println("value=\"" + StringUtils.trimToEmpty(CountryinfoparamHash.get("countrycode")) + "\"");
                                         %> >
                                </div>
                             </div>
                             <div class="form-group">
                                <label class="control-label col-md-3 col-sm-3 col-xs-12">Currency Name
                                </label>
                                <div class="col-md-7 col-sm-7 col-xs-12">
                                  <input id="input" name="currencyname" class="form-control col-md-7 col-xs-12" type="text"  autocomplete="false"  <%
                                       out.println("value=\"" + StringUtils.trimToEmpty(CountryinfoparamHash.get("currencyname")) + "\"");
                                         %> >
                                </div>
                             </div>
                            <div class="form-group">
                                <label class="control-label col-md-3 col-sm-3 col-xs-12">Currency Code
                                </label>
                                <div class="col-md-7 col-sm-7 col-xs-12">
                                  <input id="input" name="currencycode" class="form-control col-md-7 col-xs-12" type="text"  autocomplete="false"  <%
                                       out.println("value=\"" + StringUtils.trimToEmpty(CountryinfoparamHash.get("currencycode")) + "\"");
                                         %> >
                                </div>
                             </div>

                              <div class="form-group">
                                <label class="control-label col-md-3 col-sm-3 col-xs-12">Phone Split Size
                                </label>
                                <div class="col-md-7 col-sm-7 col-xs-12">
                                  <input id="input" name="mobilesplitlength" class="form-control col-md-7 col-xs-12" type="text"  autocomplete="false"  <%
                                       out.println("value=\"" + StringUtils.trimToEmpty(CountryinfoparamHash.get("mobilesplitlength")) + "\"");
                                         %> >
                                </div>
                             </div>

                    <footer id="submit-actions" class="form-actions">
                        <button id="submit-button" type="submit" class="btn btn-primary" name="action" value="CONFIRM">Add Country</button>

                    </footer>
                    <!--</div>-->
                </form>



                                                    </div>
                                                </div>
                                            </div><!-- ./col -->

                                            <div class="col-lg-6 col-xs-6">
                                                <!-- small box -->
                                                <div class="small-box">
                                                    <div class="inner">
                                                    <div class="x_content">
                                                    </div>
                                                   <form id="userSecurityForm" class="form-horizontal form-label-left" action="addMsisdnPerCountry" method="post">
                    <%
                    String addClientErr = (String) session.getAttribute(SessionConstants.ADMIN_ADD_COUNTRY_MSISDN_ERROR_KEY);
                    String addClientSuccess = (String) session.getAttribute(
                            SessionConstants.ADMIN_ADD_COUNTRY_MSISDN_SUCCESS_KEY);

                    HashMap<String, String> CountrymsisdnparamHash = (HashMap<String, String>) session.getAttribute(
                            SessionConstants.ADMIN_ADD_COUNTRY_MSISDN_PARAMETERS);

                    if (CountrymsisdnparamHash == null) {
                        CountrymsisdnparamHash = new HashMap<String, String>();
                    }

                    if (StringUtils.isNotEmpty(addClientErr)) {
                        out.println("<p class=\"alert alert-error\">");
                        out.println("Form error: " + addClientErr);
                        out.println("</p>");
                        session.setAttribute(SessionConstants.ADMIN_ADD_COUNTRY_MSISDN_ERROR_KEY, null);
                    }

                    if (StringUtils.isNotEmpty(addClientSuccess)) {
                        out.println("<p class=\"alert alert-success\">");
                        out.println("You have successfully added an msisdn to the country. You may add others below. "
                                + "Please relogin to system to get new listing of country msisdn.");
                        out.println("</p>");
                        session.setAttribute(SessionConstants.ADMIN_ADD_COUNTRY_MSISDN_SUCCESS_KEY, null);
                    }
                %>
                        <div class="alert alert-block alert-success">
                            <p>
                            Add Msisd Country
                            </p>
                            </div>
                               <div class="form-group">
                                <label class="control-label col-md-3 col-sm-3 col-xs-12">Account
                                </label>
                                <div class="col-md-7 col-sm-7 col-xs-12">
                                   <select name="accountUuid" id="input" class="form-control col-md-3 col-xs-12">
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
                                <label class="control-label col-md-3 col-sm-3 col-xs-12">Country
                                </label>
                                <div class="col-md-7 col-sm-7 col-xs-12">
                                   <select name="countryUuid" id="input" class="form-control col-md-3 col-xs-12">
                                           <%
                                    Iterator i = countryHash.keySet().iterator();

                                    while (i.hasNext()) {

                                        String uuid = (String) i.next();

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
                                <label class="control-label col-md-3 col-sm-3 col-xs-12">Network
                                </label>
                                <div class="col-md-7 col-sm-7 col-xs-12">
                                   <select name="networkUuid" id="input" class="form-control col-md-3 col-xs-12">
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
                                <label class="control-label col-md-3 col-sm-3 col-xs-12">Country MSISDN
                                </label>
                                <div class="col-md-9 col-sm-9 col-xs-12">
                                  <input id="input" name="msisdn" class="form-control col-md-7 col-xs-12" type="text"  autocomplete="false"  <%
                                       out.println("value=\"" + StringUtils.trimToEmpty(CountrymsisdnparamHash.get("msisdn")) + "\"");
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
                    <footer id="submit-actions" class="form-actions">
                        <button id="submit-button" type="submit" class="btn btn-primary" name="action" value="CONFIRM">Add CountryMsisdn</button>

                    </footer>
                    </div>
                </form>

                                                     </div>
                                                    </div>
                                                </div>
                                            </div><!-- ./col -->

                                    </div>

                                </div>
                            </div>
                        </div>
                        <div class="clearfix"></div>
                                            <div class="row">
                        <div class="col-md-12">
                            <div class="x_panel">
                                <div class="x_content">

                                    <div class="row">


                                            <div class="col-lg-6 col-xs-6">
                                             <form name="pageForm" method="post" action="addCountry.jsp">
					                    <%                                            if (!countryPage.isFirstPage()) {
					                    %>
					                    <input class="btn btn-info" type="submit" name="page" value="First" />
					                    <input class="btn btn-info" type="submit" name="page" value="Previous"/>

					                    <%
					                        }
					                    %>
					                    <span class="pageInfo">Page
					                        <span class="pagePosition currentPage"><%= countryPage.getPageNum()%></span> of
					                        <span class="pagePosition"><%= countryPage.getTotalPage()%></span>
					                    </span>
					                    <%
					                        if (!countryPage.isLastPage()) {
					                    %>
					                    <input class="btn btn-info" type="submit" name="page"value="Next">
					                    <input class="btn btn-info" type="submit"name="page" value="Last">
					                    <%
					                        }
					                    %>
					                </form>
                                                <!-- small box -->
                                                <div class="small-box">
                                                    <div class="inner">
                                                     <i class="icon-eye-open icon-large"></i>

                                                     <div class="alert alert-block alert-success">
                                                                    <p>
                                                                      COUNTRY LIST
                                                                    </p>
                                                                    </div>
                                                    <div class="x_content">
                                                        <table id="example" class="table table-striped responsive-utilities jambo_table">
                                                        <!--<table class="table table-striped bootstrap-datatable datatable">-->
                                                            <thead>
                                                                <tr class="headings">
                                                                <th></th>
                                                                <th>Country Name</th>
                                                                <th>Country Code</th>
                                                                <th>Currency Name</th>
                                                                <!--<th>Remit IP</th>
                                                                <th>Balance IP</th>
                                                                <th>Verify IP</th>
                                                                <th>Username</th>
                                                                <th>Password</th>-->
                                                                <th>Currency code</th>
                                                                <th>Phone Split</th>
                                                                </tr>
                                                            </thead>
                                                            <tbody>

                                                                 <%
                                                            if (countryLists != null) {
                                                                for (Country code : countryLists) {
                                                                %>

                                                                <tr>
                                                                    <td width="5%"><%=countryCount%></td>
                                                                    <td class="center"><%=code.getName()%></td>
                                                                    <td class="center"><%=code.getCountrycode()%></td>
                                                                    <td class="center"><%=code.getCurrency()%></td>
                                                                    <td class="center"><%=code.getCurrencycode()%></td>
                                                                    <td class="center"><%=code.getMobilesplitlength()%></td>


                                                                </tr>
                                                                 <%
                                                                    countryCount++;
                                                                }
                                                                }

                                                            %>

                                                            </tbody>
                                                        </table>
                                                     </div>



                                                    </div>
                                                </div>
                                            </div><!-- ./col -->

                                            <div class="col-lg-6 col-xs-6">
                                            <form name="pageForm" method="post" action="addCountry.jsp">
					                    <%                                            if (!countrymsisdnPage.isFirstPage()) {
					                    %>
					                    <input class="btn btn-info" type="submit" name="page" value="First" />
					                    <input class="btn btn-info" type="submit" name="page" value="Previous"/>

					                    <%
					                        }
					                    %>
					                    <span class="pageInfo">Page
					                        <span class="pagePosition currentPage"><%= countrymsisdnPage.getPageNum()%></span> of
					                        <span class="pagePosition"><%= countrymsisdnPage.getTotalPage()%></span>
					                    </span>
					                    <%
					                        if (!countrymsisdnPage.isLastPage()) {
					                    %>
					                    <input class="btn btn-info" type="submit" name="page"value="Next">
					                    <input class="btn btn-info" type="submit"name="page" value="Last">
					                    <%
					                        }
					                    %>
					                </form>
                                                <!-- small box -->
                                                <div class="small-box">
                                                    <div class="inner">
                                                  <div class="alert alert-block alert-success">
                                                                    <p>
                                                                      COUNTRY NETWORK ASSIGNED MSISDN
                                                                    </p>
                                                                    </div>

                                                    <div class="x_content">
                                                        <table id="example" class="table table-striped responsive-utilities jambo_table">
                                                        <!--<table class="table table-striped bootstrap-datatable datatable">-->
                                                            <thead>
                                                                <tr class="headings">
                                                                <th></th>
                                                                <th>Account</th>
                                                                <th>Country</th>
                                                                <th>Network</th>
                                                                <th>MSISDN</th>
                                                                </tr>
                                                            </thead>
                                                            <tbody>
                                                             <%
                                                            if (countrymsisdnList != null) {
                                                                for (CountryMsisdn codes : countrymsisdnList) {
                                                                %>

                                                                <tr>
                                                                    <td width="5%"><%=countrymsisdnCount%></td>
                                                                     <td class="center"><%=accountHash.get(codes.getAccountUuid())%></td>
                                                                     <td class="center"><%=countryHash.get(codes.getCountryUuid())%></td>
                                                                    <td class="center"><%=networkHash.get(codes.getNetworkUuid())%></td>
                                                                   <td class="center"><%=codes.getMsisdn()%></td>

                                                                </tr>
                                                                 <%
                                                                    countrymsisdnCount++;
                                                                }
                                                                }

                                                            %>

                                                            </tbody>
                                                        </table>
                                                     </div>
                                                    </div>
                                                </div>
                                            </div><!-- ./col -->

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

                   <!-- page content -->



            </div>
            <!-- /page content -->

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
